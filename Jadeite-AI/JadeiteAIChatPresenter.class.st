"
JadeiteAIChatPresenter — Spec 2 chat UI for the Jadeite AI assistant.

Menu path:  Tools > Ask Jadeite
            Browser class-list context menu > Ask Jadeite about this class
            Browser method-list context menu > Ask Jadeite about selected method(s)
Setup:      Install Ollama from https://ollama.com, then run: ollama pull qwen2.5-coder:7b
            No account or API key needed. If Ollama is not running, a setup
            dialog explains exactly what to do.
Tests:      JadeiteAIChatTestCase run

The presenter is self-contained:
  - transcript area shows alternating user / assistant turns
  - input area accepts multi-line prompts (Ctrl+Enter for newline, Enter to send)
  - Send forks a background worker so the UI stays responsive
  - GemStone source context is injected automatically when a browser is open
  - A singleton window (CurrentWindow class variable) ensures only one is open at a time
  - Class and method context can be set explicitly from browser context menus

Note: the instance variable is named llmAdapter (not adapter) to avoid
shadowing SpPresenter>>adapter which Spec 2 uses for its Morphic backend.
"
Class {
	#name : 'JadeiteAIChatPresenter',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'transcriptArea',
		'transcriptContent',
		'inputArea',
		'sendButton',
		'stopButton',
		'clearButton',
		'statusLabel',
		'contextLabel',
		'includeAllButton',
		'clearContextButton',
		'teachJadeiteButton',
		'conversation',
		'llmAdapter',
		'workerProcess',
		'spinnerProcess',
		'gciSession',
		'contextClassService',
		'contextMethodServices',
		'contextSource',
		'includeAllMethods',
		'messageHistory',
		'historyIndex',
		'thinkingStart'
	],
	#classVars : [
		'CurrentWindow'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'accessing' }
JadeiteAIChatPresenter class >> currentWindow [

	^ CurrentWindow
]

{ #category : 'accessing' }
JadeiteAIChatPresenter class >> currentWindow: aPresenterOrNil [

	CurrentWindow := aPresenterOrNil
]

{ #category : 'instance creation' }
JadeiteAIChatPresenter class >> openWithSession: aGciSession [
	"Open the singleton AI chat window, or bring it to front if already open.
	 Invoked from the Tools menu; clears any prior context so the window is fresh."

	| resolvedAdapter |
	CurrentWindow ifNotNil: [ :w |
		aGciSession ifNotNil: [ w gciSession: aGciSession ].
		w clearContext.
		[ w window window activate ] on: Error do: [  ].
		^ w ].

	resolvedAdapter := JadeiteAISettings resolveAdapter.
	resolvedAdapter isNil ifTrue: [
		UIManager default alert: JadeiteAISettings configurationHelpMessage.
		^ nil ].

	CurrentWindow := self new.
	aGciSession ifNotNil: [ CurrentWindow gciSession: aGciSession ].
	CurrentWindow llmAdapter: resolvedAdapter.
	CurrentWindow open.
	CurrentWindow addStyle: 'jadeiteTextBackgroundColor'.
	^ CurrentWindow
]

{ #category : 'instance creation' }
JadeiteAIChatPresenter class >> openWithSession: aGciSession classService: aClassService [
	"Open (or activate) the singleton window and load a class context."

	| window |
	window := self openWithSession: aGciSession.
	window ifNotNil: [ window setClassContext: aClassService ].
	^ window
]

{ #category : 'instance creation' }
JadeiteAIChatPresenter class >> openWithSession: aGciSession methodServices: aCollection [
	"Open (or activate) the singleton window and load a method context."

	| window |
	window := self openWithSession: aGciSession.
	window ifNotNil: [ window setMethodsContext: aCollection ].
	^ window
]

{ #category : 'api' }
JadeiteAIChatPresenter >> addStyle: aString [

	super addStyle: aString.
	transcriptArea addStyle: aString.
]

{ #category : 'private' }
JadeiteAIChatPresenter >> appendThinkingIndicator: aText [
	"Replace any current thinking indicator with aText, or append if none exists.
	 Called from startSpinner and the spinner animation loop."

	spinnerProcess ifNil: [ ^ self ]. "ignore deferred updates after spinner stopped"
	thinkingStart ifNotNil: [ :start |
		transcriptContent := transcriptContent copyFrom: 1 to: start.
		thinkingStart := nil ].
	thinkingStart := transcriptContent size.
	transcriptContent isEmpty
		ifFalse: [ transcriptContent := transcriptContent , String lf asText ].
	transcriptContent := transcriptContent , aText.
	transcriptArea text: transcriptContent.
	[ transcriptArea scrollValue: 1 @ 1 ] on: Error do: [  ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> appendToTranscript: aTextOrString [
	"Append text to the transcript, preserving Text attributes (bold etc.).
	 Removes any thinking indicator first so real content always follows it.
	 Maintains transcriptContent as the source of truth to avoid losing
	 formatting when re-reading from the widget."

	thinkingStart ifNotNil: [ :start |
		transcriptContent := transcriptContent copyFrom: 1 to: start.
		thinkingStart := nil ].
	transcriptContent isEmpty
		ifFalse: [ transcriptContent := transcriptContent , String lf asText ].
	transcriptContent := transcriptContent , aTextOrString asText.
	transcriptArea text: transcriptContent.
	[ transcriptArea scrollValue: 1 @ 1 ]
		on: Error
		do: [ "ignore if widget not yet realized" ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> buildContextSourceFromClass: aClassService [
	"Build a context string from the replicated class service.
	 Always includes definition (name, superclass, vars).
	 Includes method sources only when includeAllMethods is true, capped at methodCap."

	| ws methods cap capped truncated |
	ws := WriteStream on: String new.
	ws nextPutAll: 'Class: '; nextPutAll: aClassService name; nextPutAll: String lf.

	(aClassService instVarNames notNil and: [ aClassService instVarNames notEmpty ])
		ifTrue: [
			ws nextPutAll: 'Instance variables: '.
			aClassService instVarNames do: [ :v | ws nextPutAll: v; nextPut: $  ].
			ws nextPutAll: String lf ].

	(aClassService classVarNames notNil and: [ aClassService classVarNames notEmpty ])
		ifTrue: [
			ws nextPutAll: 'Class variables: '.
			aClassService classVarNames do: [ :v | ws nextPutAll: v; nextPut: $  ].
			ws nextPutAll: String lf ].

	includeAllMethods ifFalse: [ ^ ws contents ].

	methods := (aClassService methods ifNil: [ #(  ) ]) asArray.
	methods isEmpty ifTrue: [ ^ ws contents ].

	cap := self methodCap.
	capped := methods size > cap.
	truncated := capped
		             ifTrue: [ methods copyFrom: 1 to: cap ]
		             ifFalse: [ methods ].

	ws nextPutAll: String lf; nextPutAll: 'Methods:'; nextPutAll: String lf.
	capped ifTrue: [
		ws
			nextPutAll: '(First ' , cap printString , ' of ' , methods size printString
				, ' shown. Large contexts may exceed the LLM token limit.)';
			nextPutAll: String lf ].

	truncated do: [ :method |
		ws nextPutAll: '---'; nextPutAll: String lf.
		ws nextPutAll: (method source ifNil: [ '' ]); nextPutAll: String lf ].

	^ ws contents
]

{ #category : 'private' }
JadeiteAIChatPresenter >> buildContextSourceFromMethods: aCollection [
	"Build a context string from a collection of method services."

	| ws |
	ws := WriteStream on: String new.
	aCollection do: [ :method |
		ws nextPutAll: '---'; nextPutAll: String lf.
		ws nextPutAll: (method source ifNil: [ '' ]); nextPutAll: String lf ].
	^ ws contents
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> clearChat [
	"Reset the transcript display and start a fresh conversation."

	transcriptContent := '' asText.
	transcriptArea text: transcriptContent.
	conversation := JadeiteAIChatConversation new
]

{ #category : 'context' }
JadeiteAIChatPresenter >> clearContext [
	"Remove any explicit class/method context."

	contextClassService := nil.
	contextMethodServices := nil.
	contextSource := nil.
	includeAllMethods := false.
	self updateContextLabel
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> conversation [

	^ conversation
]

{ #category : 'layout' }
JadeiteAIChatPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'private' }
JadeiteAIChatPresenter >> disableInput [

	sendButton enabled: false.
	inputArea enabled: false.
	stopButton enabled: true.
	self startSpinner
]

{ #category : 'private' }
JadeiteAIChatPresenter >> enableInput [

	self stopSpinner.
	sendButton enabled: true.
	inputArea enabled: true.
	stopButton enabled: false
]

{ #category : 'private' }
JadeiteAIChatPresenter >> executeGemStoneExpression: expr [
	"Execute a Smalltalk expression on the GemStone server and return the result string.
	 Called from the LLM worker thread; uses a Semaphore to block until the async
	 RowanAnsweringService call completes.
	 Wraps the expression in a server-side error handler so runtime errors are returned
	 as 'ERROR: ...' strings rather than opening a debugger. Times out after 30 seconds
	 to prevent infinite hangs on compile errors."

	| service sem result wrappedExpr |
	gciSession ifNil: [
		^ '<gemstoneerror>no GemStone session available</gemstoneerror>' ].
	wrappedExpr := '[ ' , expr
	               ,
	               ' ] on: Error do: [ :__e | ''<gemstoneerror>'' , __e asString , ''</gemstoneerror>'' ]'.
	sem := Semaphore new.
	service := RowanAnsweringService new.
	[
		service exec: wrappedExpr in: gciSession onCompletion: [
				[ result := service answer ]
					on: Error
					do: [ :ex |
						result := '<gemstoneerror>' , ex messageText
						          , '</gemstoneerror>' ].
				sem signal ] ]
		on: Error
		do: [ :ex |
				result := '<gemstoneerror>' , ex messageText , '</gemstoneerror>'.
				sem signal ].
	(sem waitTimeoutMilliseconds: self timeout) ifTrue: [
		^ '<gemstoneerror>GemStone query timed out</gemstoneerror>' ].
	result ifNil: [
		^ '<gemstoneerror>no result returned</gemstoneerror>' ].
	(result isString and: [ result includesSubstring: '<gemstoneerror>' ])
		ifTrue: [ ^ result ].
	^ self truncateResult: (result isString ifTrue: [ result ] ifFalse: [ result printString ])
]

{ #category : 'private' }
JadeiteAIChatPresenter >> executePharoExpression: expr [
	"Evaluate a Pharo Smalltalk expression in the local image and return the result string."

	| result |
	expr isEmpty ifTrue: [
		^ '<pharoerror>empty expression — missing closing </pharo> tag?</pharoerror>' ].
	result := [
		          self truncateResult: (OpalCompiler new
				           source: expr;
				           evaluate) printString ]
		          on: Error
		          do: [ :e |
		          '<pharoerror>' , e messageText , '</pharoerror>' ].
	^ result
]

{ #category : 'private' }
JadeiteAIChatPresenter >> extractExpressionFrom: aString openTag: openTag closeTag: closeTag [
	"Return the Smalltalk expression between the first openTag...closeTag pair."

	| start end |
	start := (aString indexOfSubCollection: openTag startingAt: 1 ifAbsent: [ ^ '' ])
	         + openTag size.
	end := (aString indexOfSubCollection: closeTag startingAt: start ifAbsent: [ ^ '' ])
	       - 1.
	^ (aString copyFrom: start to: end) trimBlanks
]

{ #category : 'private' }
JadeiteAIChatPresenter >> extractGemStoneExpressionFrom: aString [
	"Return the Smalltalk expression between the first <gemstone>...</gemstone> tags."

	^ self extractExpressionFrom: aString openTag: '<gemstone>' closeTag: '</gemstone>'
]

{ #category : 'private' }
JadeiteAIChatPresenter >> extractPharoExpressionFrom: aString [
	"Return the Smalltalk expression between the first <pharo>...</pharo> tags."

	^ self extractExpressionFrom: aString openTag: '<pharo>' closeTag: '</pharo>'
]

{ #category : 'private' }
JadeiteAIChatPresenter >> extractTextBefore: tag in: aString [
	"Return the text before the first occurrence of tag, trimmed."

	| idx |
	idx := aString indexOfSubCollection: tag startingAt: 1 ifAbsent: [ ^ aString ].
	idx <= 1 ifTrue: [ ^ '' ].
	^ (aString copyFrom: 1 to: idx - 1) trimBlanks
]

{ #category : 'private' }
JadeiteAIChatPresenter >> fetchGemStoneContext [
	"Fallback: return source of the currently-selected method from any open Jadeite
	 browser, or empty string if nothing is selected. Used when no explicit context set."

	gciSession ifNil: [ ^ '' ].
	JadeiteBrowserPresenter allInstances do: [ :browser |
		| src |
		src := [
			| methods |
			methods := browser selectedMethods.
			(methods notNil and: [ methods notEmpty ])
				ifTrue: [ methods first source ]
				ifFalse: [ nil ] ]
			on: Error
			do: [ nil ].
		(src notNil and: [ src notEmpty ]) ifTrue: [ ^ src ] ].
	^ ''
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> gciSession: aGciSession [

	gciSession := aGciSession
]

{ #category : 'private' }
JadeiteAIChatPresenter >> historyDown [
	"At the last line of input: advance forward through history.
	 Otherwise move the cursor down one line within the text."

	messageHistory isEmpty ifTrue: [ ^ self ].
	self isInputAtLastLine ifFalse: [ self moveCursorDownLine. ^ self ].
	historyIndex := historyIndex + 1.
	historyIndex > messageHistory size
		ifTrue: [
			historyIndex := messageHistory size + 1.
			inputArea text: '' ]
		ifFalse: [ inputArea text: (messageHistory at: historyIndex) ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> historyUp [
	"At the first line of input: step back through history.
	 Otherwise move the cursor up one line within the text."

	messageHistory isEmpty ifTrue: [ ^ self ].
	self isInputAtFirstLine ifFalse: [ self moveCursorUpLine. ^ self ].
	historyIndex := (historyIndex - 1) max: 1.
	inputArea text: (messageHistory at: historyIndex)
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initialize [

	super initialize.
	conversation := JadeiteAIChatConversation new.
	transcriptContent := '' asText.
	includeAllMethods := false.
	messageHistory := OrderedCollection new.
	historyIndex := 0
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initializePresenters [

	| buttonRow inputLabel contextRow |
	super initializePresenters.

	transcriptArea := self newText.
	transcriptArea beNotEditable.
	self layout add: transcriptArea.

	inputLabel := self newLabel label:
		              'Your message:  (Enter = Send,  Ctrl+Enter = new line)'.
	self layout add: inputLabel withConstraints: [ :c | c height: 20 ].

	inputArea := self newText.
	inputArea
		bindKeyCombination: Character cr asKeyCombination
		toAction: [ self sendMessage ].
	inputArea
		bindKeyCombination: Character cr ctrl asKeyCombination
		toAction: [ inputArea text: inputArea text , String cr ].
	inputArea
		bindKeyCombination: KeyboardKey up asKeyCombination
		toAction: [ self historyUp ].
	inputArea
		bindKeyCombination: KeyboardKey down asKeyCombination
		toAction: [ self historyDown ].
	self layout add: inputArea withConstraints: [ :c | c height: 100 ].

	contextRow := SpBoxLayout newHorizontal spacing: 6.
	contextRow borderWidth: 4.
	contextLabel := self newLabel label: ''.
	includeAllButton := self newButton
		                    label: 'Include All Methods';
		                    action: [ self toggleIncludeAllMethods ];
		                    yourself.
	clearContextButton := self newButton
		                      label: 'Clear Context';
		                      action: [ self clearContext ];
		                      enabled: false;
		                      yourself.
	teachJadeiteButton := self newButton
		                      label: 'Teach Jadeite';
		                      action: [ self teachJadeite ];
		                      enabled: false;
		                      yourself.
	contextRow
		add: includeAllButton withConstraints: [ :c |
				c
					width: 160;
					expand: false ];
		add: clearContextButton withConstraints: [ :c |
				c
					width: 110;
					expand: false ];
		add: teachJadeiteButton withConstraints: [ :c |
				c
					width: 110;
					expand: false ];
		add: contextLabel.
	self layout add: contextRow withConstraints: [ :c | c height: 34 ].

	buttonRow := SpBoxLayout newHorizontal.
	sendButton := self newButton
		              label: 'Send';
		              action: [ self sendMessage ];
		              yourself.
	stopButton := self newButton
		              label: 'Stop';
		              enabled: false;
		              action: [ self stopWorker ];
		              yourself.
	clearButton := self newButton
		               label: 'Clear';
		               action: [ self clearChat ];
		               yourself.
	statusLabel := self newLabel label: ''.
	buttonRow
		add: sendButton expand: false;
		add: stopButton expand: false;
		add: clearButton expand: false;
		add: statusLabel.
	self layout add: buttonRow withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Ask Jadeite'.
	aWindowPresenter initialExtent: 700 @ 520.
	aWindowPresenter whenClosedDo: [ self class currentWindow: nil ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> inputCursorPosition [
	"Return the character index of the cursor in the input area, or 0 on error."

	^ [ inputArea adapter widget textMorph selectionInterval first ]
		on: Error
		do: [ 0 ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> isInputAtFirstLine [
	"True if the cursor is on the first line (no newline before cursor position)."

	| pos textBefore |
	pos := self inputCursorPosition.
	pos <= 1 ifTrue: [ ^ true ].
	textBefore := inputArea text asString copyFrom: 1 to: pos - 1.
	^ (textBefore includes: Character cr) not
		and: [ (textBefore includes: Character lf) not ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> isInputAtLastLine [
	"True if the cursor is on the last line (no newline from cursor position to end)."

	| pos text textAfter |
	text := inputArea text asString.
	pos := self inputCursorPosition.
	pos > text size ifTrue: [ ^ true ].
	textAfter := text copyFrom: pos to: text size.
	^ (textAfter includes: Character cr) not
		and: [ (textAfter includes: Character lf) not ]
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> llmAdapter [

	^ llmAdapter
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> llmAdapter: aJadeiteAIHttpAdapter [

	llmAdapter := aJadeiteAIHttpAdapter
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> maxAgentIterations [
	"Maximum number of code-execution rounds per LLM response before stopping."

	^ 6
]

{ #category : 'constants' }
JadeiteAIChatPresenter >> methodCap [
	"Maximum number of methods to include when building a class context."

	^ 50
]

{ #category : 'private' }
JadeiteAIChatPresenter >> moveCursorDownLine [
	"Move the cursor down one line, keeping the same column."

	| text pos lineStart lineEnd nextLineStart nextLineEnd col newPos |
	text := inputArea text asString.
	pos := self inputCursorPosition.
	(pos <= 0 or: [ pos > text size + 1 ]) ifTrue: [ ^ self ].
	lineEnd := pos.
	[ lineEnd <= text size and: [
		  (text at: lineEnd) ~= Character cr and: [ (text at: lineEnd) ~= Character lf ] ] ]
		whileTrue: [ lineEnd := lineEnd + 1 ].
	lineEnd > text size ifTrue: [ ^ self ].
	nextLineStart := lineEnd + 1.
	nextLineStart > text size ifTrue: [ ^ self ].
	nextLineEnd := nextLineStart.
	[ nextLineEnd <= text size and: [
		  (text at: nextLineEnd) ~= Character cr
		  and: [ (text at: nextLineEnd) ~= Character lf ] ] ]
		whileTrue: [ nextLineEnd := nextLineEnd + 1 ].
	lineStart := 1.
	1 to: pos - 1 do: [ :i |
		((text at: i) = Character cr or: [ (text at: i) = Character lf ])
			ifTrue: [ lineStart := i + 1 ] ].
	col := pos - lineStart.
	newPos := (nextLineStart + col) min: nextLineEnd.
	[ inputArea adapter widget textMorph selectFrom: newPos to: newPos - 1 ]
		on: Error
		do: [  ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> moveCursorUpLine [
	"Move the cursor up one line, keeping the same column."

	| text pos lineStart prevLineEnd prevLineStart col newPos |
	text := inputArea text asString.
	pos := self inputCursorPosition.
	(pos <= 0 or: [ pos > text size + 1 ]) ifTrue: [ ^ self ].
	lineStart := 1.
	1 to: pos - 1 do: [ :i |
		((text at: i) = Character cr or: [ (text at: i) = Character lf ])
			ifTrue: [ lineStart := i + 1 ] ].
	col := pos - lineStart.
	lineStart <= 1 ifTrue: [ ^ self ].
	prevLineEnd := lineStart - 2.
	prevLineEnd < 1 ifTrue: [ ^ self ].
	prevLineStart := 1.
	1 to: prevLineEnd - 1 do: [ :i |
		((text at: i) = Character cr or: [ (text at: i) = Character lf ])
			ifTrue: [ prevLineStart := i + 1 ] ].
	newPos := (prevLineStart + col) min: prevLineEnd + 1.
	[ inputArea adapter widget textMorph selectFrom: newPos to: newPos - 1 ]
		on: Error
		do: [  ]
]

{ #category : 'event handling' }
JadeiteAIChatPresenter >> onWorkerDone: replyString [
	"Called on the UI thread after a successful LLM response."

	conversation addAssistantMessage: replyString.
	self appendToTranscript: '[AI] ' asText allBold , replyString asText.
	self enableInput
]

{ #category : 'event handling' }
JadeiteAIChatPresenter >> onWorkerError: errorString [
	"Called on the UI thread when the worker catches an error."

	self appendToTranscript: '[Error] ' , errorString.
	self enableInput
]

{ #category : 'private' }
JadeiteAIChatPresenter >> preprocessReply: aString [
	"Convert Markdown code fences (```gemstone...``` or ```pharo...```) to
	 XML-like execution tags. Fallback for models that default to Markdown formatting."

	| result |
	result := aString.
	#( 'gemstone' 'pharo' ) do: [ :lang |
		| marker |
		marker := '```' , lang.
		[ result includesSubstring: marker ] whileTrue: [
			| openAt contentStart closeAt exprEnd expr |
			openAt := result
				indexOfSubCollection: marker
				startingAt: 1
				ifAbsent: [ result size + 1 ].
			contentStart := openAt + marker size.
			[ contentStart <= result size and: [
				  (result at: contentStart) = Character cr
				  or: [ (result at: contentStart) = Character lf ] ] ]
				whileTrue: [ contentStart := contentStart + 1 ].
			closeAt := result
				indexOfSubCollection: '```'
				startingAt: contentStart
				ifAbsent: [ 0 ].
			closeAt = 0
				ifTrue: [
					"No closing fence — use the first line of content as the expression"
					| lineEnd |
					lineEnd := contentStart.
					[ lineEnd <= result size
					  and: [ (result at: lineEnd) ~= Character cr
					         and: [ (result at: lineEnd) ~= Character lf ] ] ]
						whileTrue: [ lineEnd := lineEnd + 1 ].
					expr := (result copyFrom: contentStart to: lineEnd - 1) trimSeparators.
					result := (result copyFrom: 1 to: openAt - 1)
					          , '<' , lang , '>' , expr , '</' , lang , '>'
					          , (result copyFrom: lineEnd to: result size) ]
				ifFalse: [
					exprEnd := closeAt - 1.
					[ exprEnd >= contentStart and: [ (result at: exprEnd) isSeparator ] ]
						whileTrue: [ exprEnd := exprEnd - 1 ].
					expr := exprEnd >= contentStart
						        ifTrue: [ result copyFrom: contentStart to: exprEnd ]
						        ifFalse: [ '' ].
					result := (result copyFrom: 1 to: openAt - 1)
					          , '<' , lang , '>' , expr , '</' , lang , '>'
					          , (result copyFrom: closeAt + 3 to: result size) ] ] ].
	^ result
]

{ #category : 'private' }
JadeiteAIChatPresenter >> resolveContextOnCompletion: aBlock [
	"Resolve the context string and call aBlock with it.
	 For class services this is async (forks a GemStone fetch via RowanServiceUpdater);
	 for all other cases it is synchronous. Caches the result in contextSource."

	contextSource ifNotNil: [ :src |
		aBlock value: src.
		^ self ].

	contextClassService ifNotNil: [ :cs |
		includeAllMethods
			ifFalse: [
				contextSource := self buildContextSourceFromClass: cs.
				aBlock value: contextSource ]
			ifTrue: [
				RowanServiceUpdater current
					updateService: cs
					session: gciSession
					onCompletion: [
						contextSource := self buildContextSourceFromClass: cs.
						aBlock value: contextSource ] ].
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		contextSource := self buildContextSourceFromMethods: ms.
		aBlock value: contextSource.
		^ self ].
	aBlock value: String new. 
	"aBlock value: self fetchGemStoneContext"
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> sendMessage [
	"Grab input, resolve GemStone context (async for class services), then POST to the LLM."

	| userText |
	userText := inputArea text trimBlanks.
	userText isEmpty ifTrue: [ ^ self ].

	messageHistory addLast: userText.
	historyIndex := messageHistory size + 1.
	transcriptContent isEmpty ifFalse: [ self appendToTranscript: '' ].
	self appendToTranscript: '[You] ' asText allBold , userText asText.
	inputArea text: ''.
	self disableInput.

	self resolveContextOnCompletion: [ :context |
		workerProcess := [
			| fullPrompt reply agentIteration |
			[
				fullPrompt := context isEmpty
					              ifTrue: [ userText ]
					              ifFalse: [
						              'GemStone source context:
' , context , '

Question: ' , userText ].
				conversation addUserMessage: fullPrompt.
				reply := self preprocessReply: (llmAdapter sendConversation: conversation).

				agentIteration := 0.

				[ | hasGemstone hasPharo |
				  hasGemstone := reply includesSubstring: '<gemstone>'.
				  hasPharo := reply includesSubstring: '<pharo>'.
				  (hasGemstone or: [ hasPharo ])
				  and: [ agentIteration < self maxAgentIterations ] ]
				whileTrue: [
					| preText expr result feedbackResult feedbackMsg useGemstone tag errorTag label |
					agentIteration := agentIteration + 1.
					useGemstone := (reply
						indexOfSubCollection: '<gemstone>'
						startingAt: 1
						ifAbsent: [ reply size + 1 ]) < (reply
						indexOfSubCollection: '<pharo>'
						startingAt: 1
						ifAbsent: [ reply size + 1 ]).
					useGemstone
						ifTrue: [
							tag := '<gemstone>'.
							errorTag := '<gemstoneerror>'.
							label := '[GemStone]'.
							preText := self extractTextBefore: tag in: reply.
							expr := self extractGemStoneExpressionFrom: reply ]
						ifFalse: [
							tag := '<pharo>'.
							errorTag := '<pharoerror>'.
							label := '[Pharo]'.
							preText := self extractTextBefore: tag in: reply.
							expr := self extractPharoExpressionFrom: reply ].
					preText isEmpty ifFalse: [
						UIManager default defer: [
							self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
					expr isEmpty ifFalse: [
						UIManager default defer: [
							self appendToTranscript: (label , ' ' , expr) asText ] ].
					Processor yield.
					result := useGemstone
						ifTrue: [ self executeGemStoneExpression: expr ]
						ifFalse: [ self executePharoExpression: expr ].
					UIManager default defer: [
						self appendToTranscript: '[Result] ' asText allBold , result asText ].
					"Keep LLM feedback short to avoid overflowing the context window"
					feedbackResult := result size > 150
						ifTrue: [ (result copyFrom: 1 to: 150) , '...[truncated]' ]
						ifFalse: [ result ].
					feedbackMsg := (result includesSubstring: errorTag)
						ifTrue: [
							'Your ' , label , ' query failed: ' , feedbackResult ,
							' Please analyze the error and retry with a corrected expression.' ]
						ifFalse: [ label , ' query result: ' , feedbackResult ].
					conversation addAssistantMessage: preText.
					conversation addUserMessage: feedbackMsg.
					reply := self preprocessReply: (llmAdapter sendConversation: conversation) ].

				UIManager default defer: [ self onWorkerDone: reply ] ]
				on: Error
				do: [ :ex |
					UIManager default defer: [ self onWorkerError: ex messageText ] ] ]
			forkNamed: 'JadeiteAI-LLMWorker' ]
]

{ #category : 'context' }
JadeiteAIChatPresenter >> setClassContext: aClassService [
	"Set an explicit class context; clears any prior method context and cached source."

	contextClassService := aClassService.
	contextMethodServices := nil.
	contextSource := nil.
	self updateContextLabel
]

{ #category : 'context' }
JadeiteAIChatPresenter >> setMethodsContext: aCollection [
	"Set explicit method context; clears any prior class context and cached source."

	contextMethodServices := aCollection.
	contextClassService := nil.
	contextSource := nil.
	self updateContextLabel
]

{ #category : 'private' }
JadeiteAIChatPresenter >> spinnerMessages [

	^ #(
		'Polishing gem facets...'
		'Bribing the Stone keeper...'
		'Negotiating with the Gem process...'
		'Reticulating GemStone splines...'
		'Asking Topaz nicely...'
		'Herding stray objects...'
		'Convincing the GC to wait...'
		'Sharpening the SortBlock...'
		'Alphabetizing the symbol table...'
		'Consulting ancient ObjectMemory scrolls...'
		'Asking Allen...'
		'Reading Lisa''s Docs...'
		'Checking SVN blame...'
		'Waiting for the merge to resolve...'
		'Counting commits to trunk...'
		'Praying to the GemStone gods...'
		'Waiting for the GC to finish...'
		'Befuddling the ponytails...'
		'Waking the gray-beards from their naps...'
		)
]

{ #category : 'private' }
JadeiteAIChatPresenter >> startSpinner [
	"Show an animated thinking indicator in the transcript (like VS Code Claude).
	 The indicator is removed or replaced when real content arrives."

	| frames messages frameIdx rotationCount msgIdx |
	frames := #( '|' '/' '-' '\' ).
	messages := self spinnerMessages.
	frameIdx := 1.
	rotationCount := 0.
	msgIdx := (1 to: messages size) atRandom.
	self appendThinkingIndicator: ('[AI] |  ' , (messages at: msgIdx)) asText allBold.
	spinnerProcess := [
		                  [ true ] whileTrue: [
			                  | label |
			                  label := '[AI] ' , (frames at: frameIdx) , '  '
				                        , (messages at: msgIdx).
			                  UIManager default defer: [
				                  self appendThinkingIndicator: label asText allBold ].
			                  frameIdx := (frameIdx \\ frames size) + 1.
			                  frameIdx = 1 ifTrue: [
				                  rotationCount := rotationCount + 1.
				                  rotationCount \\ 3 = 0 ifTrue: [
					                  msgIdx := (1 to: messages size) atRandom ] ].
			                  (Delay forMilliseconds: 150) wait ] ]
		                  forkNamed: 'JadeiteAI-Spinner'
]

{ #category : 'private' }
JadeiteAIChatPresenter >> stopSpinner [

	spinnerProcess ifNotNil: [ :p |
		p terminate.
		spinnerProcess := nil ].
	thinkingStart ifNotNil: [ :start |
		transcriptContent := transcriptContent copyFrom: 1 to: start.
		thinkingStart := nil.
		transcriptArea text: transcriptContent ].
	statusLabel label: ''
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> stopWorker [
	"Terminate the in-flight LLM request and re-enable input."

	workerProcess ifNotNil: [ :p |
		p terminate.
		workerProcess := nil ].
	self appendToTranscript: '[Stopped]'.
	self enableInput
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> teachJadeite [
	"Append the current context to the permanent knowledge base.
	 When includeAllMethods is true, loads method sources via RowanServiceUpdater first
	 (same async path as resolveContextOnCompletion:) so sources are not nil."

	| label |
	contextClassService ifNotNil: [ :cs |
		label := cs name.
		self appendToTranscript:
			('[Teaching] Loading ' , label , '...') asText allBold.
		includeAllMethods
			ifFalse: [
				self teachJadeiteWrite: (self buildContextSourceFromClass: cs) label: label ]
			ifTrue: [
				RowanServiceUpdater current
					updateService: cs
					session: gciSession
					onCompletion: [
						self teachJadeiteWrite: (self buildContextSourceFromClass: cs) label: label ] ].
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		| text |
		label := ms size printString , ' method(s)'.
		text := self buildContextSourceFromMethods: ms.
		self appendToTranscript:
			('[Teaching] Adding ' , label , ' to permanent knowledge...') asText allBold.
		self teachJadeiteWrite: text label: label ]
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> teachJadeiteWrite: text label: label [
	"Write text to the knowledge base and log the result."

	text trimBlanks isEmpty
		ifTrue: [
			self appendToTranscript:
				('[Teaching] Nothing to add for ' , label) asText ]
		ifFalse: [
			JadeiteAIKnowledgeBase current appendText: text , String lf.
			self appendToTranscript:
				('[Teaching] ' , label , ' added to permanent knowledge.') asText allBold ]
]

{ #category : 'constants' }
JadeiteAIChatPresenter >> timeout [

	^ 60000
]

{ #category : 'context' }
JadeiteAIChatPresenter >> toggleIncludeAllMethods [
	"Toggle whether all methods are included in the class context.
	 Clears the cached contextSource so it is rebuilt on next send."

	includeAllMethods := includeAllMethods not.
	contextSource := nil.
	self updateContextLabel
]

{ #category : 'private' }
JadeiteAIChatPresenter >> truncateResult: aString [
	"Truncate a result string that is too long to be useful in the transcript or LLM context."

	| maxLen |
	maxLen := 500.
	aString size <= maxLen ifTrue: [ ^ aString ].
	^ (aString copyFrom: 1 to: maxLen)
	  , String lf
	  , '[...truncated — ' , (aString size - maxLen) printString , ' more characters]'
]

{ #category : 'private' }
JadeiteAIChatPresenter >> updateContextLabel [
	"Refresh the context row to reflect the current context state."

	contextLabel ifNil: [ ^ self ].

	contextClassService ifNotNil: [ :cs |
		| label |
		label := 'Context: class ' , cs name.
		includeAllMethods
			ifTrue: [ label := label , ' (all methods included)' ]
			ifFalse: [ label := label , ' (definition only — toggle to include method sources)' ].
		contextLabel label: label.
		clearContextButton ifNotNil: [ clearContextButton enabled: true ].
		teachJadeiteButton ifNotNil: [ teachJadeiteButton enabled: true ].
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		contextLabel label: 'Context: ' , ms size printString , ' selected method(s)'.
		clearContextButton ifNotNil: [ clearContextButton enabled: true ].
		teachJadeiteButton ifNotNil: [ teachJadeiteButton enabled: true ].
		^ self ].

	contextLabel label: ''.
	clearContextButton ifNotNil: [ clearContextButton enabled: false ].
	teachJadeiteButton ifNotNil: [ teachJadeiteButton enabled: false ]
]
