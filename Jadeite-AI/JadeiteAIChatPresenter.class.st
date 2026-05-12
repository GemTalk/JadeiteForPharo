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
		'clearContextButton',
		'conversation',
		'llmAdapter',
		'workerProcess',
		'spinnerProcess',
		'gciSession',
		'contextClassService',
		'contextMethodServices',
		'contextSource',
		'messageHistory',
		'historyIndex',
		'thinkingStart',
		'pharoCheckbox',
		'gemstoneCheckbox',
		'adapterDropList',
		'modelDropList',
		'updatingModelList'
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
JadeiteAIChatPresenter class >> openWithSession: aGciSession forStackAnalysis: aStackString [
	"Open (or activate) the singleton window and immediately analyze the given stack.
	 Deferred so the window renders before the transcript is populated."

	| window |
	window := self openWithSession: aGciSession.
	window ifNotNil: [ UIManager default defer: [ window analyzeStack: aStackString ] ].
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

{ #category : 'accessing' }
JadeiteAIChatPresenter >> adapterDisplayName [
	"Return a short display name for the current adapter."

	llmAdapter isNil ifTrue: [ ^ 'None' ].
	(llmAdapter isKindOf: JadeiteAIClaudeAdapter) ifTrue: [ ^ 'Claude' ].
	^ 'Ollama'
]

{ #category : 'api' }
JadeiteAIChatPresenter >> addStyle: aString [

	super addStyle: aString.
	transcriptArea addStyle: aString.
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> analyzeStack: aStackString [
	"Send the stack to Claude for analysis.
	 The transcript shows a short summary so the full stack doesn't flood the chat."

	| fullPrompt summaryLine displayText |
	fullPrompt := 'Please analyze this GemStone stack and explain what went wrong:

' , aStackString.
	summaryLine := (aStackString lines
		ifEmpty: [ '' ]
		ifNotEmpty: [ :lines | lines first ]) trimBlanks.
	(summaryLine endsWith: ':') ifTrue: [
		summaryLine := summaryLine copyFrom: 1 to: summaryLine size - 1 ].
	displayText := summaryLine isEmpty
		ifTrue: [ 'Analyzing stack' ]
		ifFalse: [ 'Analyzing stack: ' , summaryLine ].
	self sendStackAnalysis: fullPrompt displayText: displayText
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
	 formatting when re-reading from the widget.
	 Returns the 1-based start position of the newly appended content."

	| startPos |
	thinkingStart ifNotNil: [ :start |
		transcriptContent := transcriptContent copyFrom: 1 to: start.
		thinkingStart := nil ].
	startPos := transcriptContent isEmpty ifTrue: [ 1 ] ifFalse: [ transcriptContent size + 2 ].
	transcriptContent isEmpty
		ifFalse: [ transcriptContent := transcriptContent , String lf asText ].
	transcriptContent := transcriptContent , aTextOrString asText.
	transcriptArea text: transcriptContent.
	[ transcriptArea scrollValue: 1 @ 1 ]
		on: Error
		do: [ "ignore if widget not yet realized" ].
	^ startPos
]

{ #category : 'private' }
JadeiteAIChatPresenter >> buildContextSourceFromClass: aClassService [
	"Build a context string from the class service.
	 Includes definition (name, vars) plus all available method selectors.
	 Selectors from both GemStone (via class service) and Pharo (via reflection) are included.
	 Full source is fetched on demand by the LLM using <pharo> or <gemstone> tags."

	| ws methods selectors pharoClass |
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

	methods := (aClassService methods ifNil: [ #() ]) asArray.
	methods isEmpty ifFalse: [
		selectors := (methods collect: [ :m | m selector ]) asSortedCollection.
		ws nextPutAll: String lf; nextPutAll: 'GemStone selectors: '; nextPutAll: String lf.
		selectors do: [ :sel | ws nextPutAll: sel; nextPut: $  ] ].

	pharoClass := Smalltalk at: aClassService name asSymbol ifAbsent: [ nil ].
	pharoClass ifNotNil: [ :cls |
		| instSelectors classSelectors |
		instSelectors := cls methodDict keys asSortedCollection.
		classSelectors := cls class methodDict keys asSortedCollection.
		instSelectors isEmpty ifFalse: [
			ws nextPutAll: String lf; nextPutAll: 'Pharo instance-side selectors: '; nextPutAll: String lf.
			instSelectors do: [ :sel | ws nextPutAll: sel; nextPut: $  ] ].
		classSelectors isEmpty ifFalse: [
			ws nextPutAll: String lf; nextPutAll: 'Pharo class-side selectors: '; nextPutAll: String lf.
			classSelectors do: [ :sel | ws nextPutAll: sel; nextPut: $  ] ] ].

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
	stopButton enabled: true.
	self startSpinner
]

{ #category : 'private' }
JadeiteAIChatPresenter >> enableInput [

	self stopSpinner.
	sendButton enabled: true.
	stopButton enabled: false.
	[ inputArea takeKeyboardFocus ] on: Error do: [  ]
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

	| start end expr |
	start := (aString indexOfSubCollection: openTag startingAt: 1 ifAbsent: [ ^ '' ])
	         + openTag size.
	end := (aString indexOfSubCollection: closeTag startingAt: start ifAbsent: [ ^ '' ])
	       - 1.
	expr := (aString copyFrom: start to: end) trimBlanks.
	"Strip leading lines that are markdown artifacts (start with a backtick).
	 If no newline follows the backtick, the expression is wrapped in inline code — strip the backticks."
	[ expr notEmpty and: [ expr first = $` ] ] whileTrue: [
		| lineEnd |
		lineEnd := expr indexOf: (Character value: 10) ifAbsent: [ 0 ].
		lineEnd = 0
			ifTrue: [ expr := expr copyWithout: $` ]
			ifFalse: [ expr := (expr copyFrom: lineEnd to: expr size) trimBlanks ] ].
	^ expr
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
	messageHistory := OrderedCollection new.
	historyIndex := 0.
	updatingModelList := false
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initializePresenters [

	| buttonRow inputLabel contextRow inputRow checkboxColumn |
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
		toAction: [ self insertNewlineAtCursor ].
	inputArea
		bindKeyCombination: KeyboardKey up asKeyCombination
		toAction: [ self historyUp ].
	inputArea
		bindKeyCombination: KeyboardKey down asKeyCombination
		toAction: [ self historyDown ].
	pharoCheckbox := self newCheckBox
		label: 'Pharo';
		yourself.
	gemstoneCheckbox := self newCheckBox
		label: 'GemStone';
		yourself.
	checkboxColumn := SpBoxLayout newVertical spacing: 4.
	checkboxColumn
		add: pharoCheckbox withConstraints: [ :c | c height: 24; expand: false ];
		add: gemstoneCheckbox withConstraints: [ :c | c height: 24; expand: false ].
	inputRow := SpBoxLayout newHorizontal spacing: 6.
	inputRow
		add: inputArea;
		add: checkboxColumn withConstraints: [ :c | c width: 100; expand: false ].
	self layout add: inputRow withConstraints: [ :c | c height: 100 ].

	contextRow := SpBoxLayout newHorizontal spacing: 6.
	contextRow borderWidth: 4.
	contextLabel := self newLabel label: ''.
	clearContextButton := self newButton
		                      label: 'Clear Context';
		                      action: [ self clearContext ];
		                      enabled: false;
		                      yourself.
	contextRow
		add: clearContextButton withConstraints: [ :c |
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
	adapterDropList := self newDropList
		                   items: #( 'Claude' 'Ollama' );
		                   whenSelectedItemChangedDo: [ :item |
			                   self switchToAdapterNamed: item ];
		                   yourself.
	modelDropList := self newDropList
		                 whenSelectedItemChangedDo: [ :item |
			                 item ifNotNil: [ self switchToModel: item ] ];
		                 yourself.
	buttonRow
		add: sendButton expand: false;
		add: stopButton expand: false;
		add: clearButton expand: false;
		add: statusLabel;
		add: adapterDropList withConstraints: [ :c |
			c
				width: 110;
				expand: false ];
		add: modelDropList withConstraints: [ :c |
			c
				width: 180;
				expand: false ].
	self layout add: buttonRow withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Ask Jadeite'
			, (llmAdapter ifNotNil: [ ' — ' , self adapterDisplayName ] ifNil: [ '' ]);
		initialExtent: 700 @ 520;
		whenClosedDo: [ self class currentWindow: nil ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> inputCursorPosition [
	"Return the character index of the cursor in the input area, or 0 on error."

	^ [ inputArea adapter widget textMorph selectionInterval first ]
		on: Error
		do: [ 0 ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> insertNewlineAtCursor [
	"Insert a newline at the current cursor position and restore the cursor.
	 Uses UIManager defer for cursor repositioning because inputArea text:
	 triggers async morph updates that would otherwise reset the selection."

	| pos text before after newPos |
	pos := self inputCursorPosition.
	text := inputArea text asString.
	pos <= 0 ifTrue: [ pos := text size + 1 ].
	before := text copyFrom: 1 to: ((pos - 1) max: 0).
	after := text copyFrom: pos to: text size.
	newPos := before size + 2.
	inputArea text: before , String lf , after.
	UIManager default defer: [
		[ inputArea adapter widget textMorph selectFrom: newPos to: newPos - 1 ]
			on: Error do: [  ] ]
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

	llmAdapter := aJadeiteAIHttpAdapter.
	self updateAdapterUI
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> maxAgentIterations [
	"Maximum number of code-execution rounds per LLM response before stopping."

	^ 6
]

{ #category : 'private' }
JadeiteAIChatPresenter >> moveCursorDownLine [
	"Move the cursor down one line, keeping the same column."

	| text pos lineStart lineEnd nextLineStart nextLineEnd col newPos |
	text := inputArea text asString.
	pos := self inputCursorPosition.
	(pos <= 0 or: [ pos > (text size + 1) ]) ifTrue: [ ^ self ].
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
	(pos <= 0 or: [ pos > (text size + 1) ]) ifTrue: [ ^ self ].
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

	| startPos |
	conversation addAssistantMessage: replyString.
	startPos := self appendToTranscript: '[AI] ' asText allBold , replyString asText.
	[ transcriptArea adapter widget textMorph
		selectFrom: startPos to: transcriptContent size ] on: Error do: [  ].
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
	"Map ```smalltalk fences to <gemstone> — generic Smalltalk defaults to GemStone."
	result := result copyReplaceAll: '```smalltalk' with: '```gemstone'.
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
	 All paths are synchronous. Caches the result in contextSource."

	contextSource ifNotNil: [ :src |
		aBlock value: src.
		^ self ].

	contextClassService ifNotNil: [ :cs |
		contextSource := self buildContextSourceFromClass: cs.
		aBlock value: contextSource.
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		contextSource := self buildContextSourceFromMethods: ms.
		aBlock value: contextSource.
		^ self ].

	aBlock value: String new
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
			| reply agentIteration queryMsgIndex bothEnvsRequested gemstoneExecuted pharoExecuted |
			[
				conversation contextMessage: (context isEmpty
					ifTrue: [ nil ]
					ifFalse: [ 'Class context (selectors and definition):
' , context ]).
				conversation addUserMessage: userText.
				queryMsgIndex := conversation messages size.
				bothEnvsRequested := pharoCheckbox state and: [ gemstoneCheckbox state ].
				gemstoneExecuted := false.
				pharoExecuted := false.
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
					useGemstone
						ifTrue: [ gemstoneExecuted := true ]
						ifFalse: [ pharoExecuted := true ].
					UIManager default defer: [
						self appendToTranscript: '[Result] ' asText allBold , result asText ].
					"Keep LLM feedback short to avoid overflowing the context window"
					feedbackResult := result size > 150
						ifTrue: [ (result copyFrom: 1 to: 150) , '...[truncated]' ]
						ifFalse: [ result ].
					feedbackMsg := (result includesSubstring: errorTag)
						ifTrue: [
							(useGemstone ifTrue: [ 'GemStone' ] ifFalse: [ 'Pharo' ])
							, ' execution failed: ' , feedbackResult
							, ' Write the corrected expression inside '
							, (useGemstone ifTrue: [ '<gemstone>' ] ifFalse: [ '<pharo>' ])
							, ' tags. Do NOT use markdown code fences, placeholder names, or prose descriptions.' ]
						ifFalse: [
							(useGemstone ifTrue: [ 'GemStone' ] ifFalse: [ 'Pharo' ])
							, ' execution returned: ' , feedbackResult
							, ((bothEnvsRequested and: [ gemstoneExecuted and: [ pharoExecuted ] ])
								ifTrue: [ '. Both environments have been executed. Give your final answer now using the results above. Do not execute any more code.' ]
								ifFalse: [
									bothEnvsRequested
										ifTrue: [
											| otherEnv otherTag |
											otherEnv := useGemstone ifTrue: [ 'Pharo' ] ifFalse: [ 'GemStone' ].
											otherTag := useGemstone ifTrue: [ '<pharo>...</pharo>' ] ifFalse: [ '<gemstone>...</gemstone>' ].
											'. You were asked to evaluate in both environments. Execute in ' , otherEnv , ' now using ' , otherTag , ' — required, output the tag immediately.' ]
										ifFalse: [ '. If you need more data, use another <gemstone> or <pharo> tag. Otherwise give your final answer.' ] ]) ].
					conversation addAssistantMessage: preText.
					conversation addUserMessage: feedbackMsg.
					reply := self preprocessReply: (llmAdapter sendConversationStep: conversation) ].

				"Compact: strip intermediate code-execution messages from history.
				 Keeps only the original user question; onWorkerDone: adds the final answer.
				 Prevents context bloat from multi-iteration agent loops."
				conversation compactFrom: queryMsgIndex.
				UIManager default defer: [ self onWorkerDone: reply ] ]
				on: Error
				do: [ :ex |
					UIManager default defer: [ self onWorkerError: ex messageText ] ] ]
			forkNamed: 'JadeiteAI-LLMWorker' ]
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> sendStackAnalysis: fullPrompt displayText: displayText [
	"One-shot stack analysis: short system prompt, no agent loop.
	 displayText appears in the transcript; fullPrompt (with full stack) goes to Claude."

	displayText trimBlanks isEmpty ifTrue: [ ^ self ].

	messageHistory addLast: displayText.
	historyIndex := messageHistory size + 1.
	transcriptContent isEmpty ifFalse: [ self appendToTranscript: '' ].
	self appendToTranscript: '[You] ' asText allBold , displayText asText.
	inputArea text: ''.
	self disableInput.

	workerProcess := [
		| analysisConversation reply |
		[
			analysisConversation := JadeiteAIChatConversation new
				systemPrompt: self stackAnalysisSystemPrompt;
				yourself.
			analysisConversation addUserMessage: fullPrompt.
			reply := llmAdapter sendConversation: analysisConversation.
			conversation addUserMessage: displayText.
			UIManager default defer: [ self onWorkerDone: reply ] ]
		on: Error
		do: [ :ex |
			UIManager default defer: [ self onWorkerError: ex messageText ] ] ]
	forkNamed: 'JadeiteAI-LLMWorker'
]

{ #category : 'private' }
JadeiteAIChatPresenter >> stackAnalysisSystemPrompt [
	"Minimal system prompt for stack analysis — no code-execution or method-reading
	 instructions, keeping input tokens low."

	^ 'You are a helpful GemStone Smalltalk programming assistant.
Analyze the GemStone call stack provided and explain:
1. What went wrong — the root cause of the error
2. Which frame triggered the error and why
3. How to fix it

Be concise. Focus on the most relevant frames. Do not execute any code.'
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
		'Checking GitHub blame...'
		'Waiting for the merge to resolve...'
		'Counting commits to trunk...'
		'Praying to the GemStone gods...'
		'Waiting for the GC to finish...'
		'Befuddling the ponytails...'
		'Waking the gray-beards from their naps...'
		'Preparing for Thursday meeting...'
		'Watering plants...'
		'Reviewing contractual agreements...'
		)
]

{ #category : 'private' }
JadeiteAIChatPresenter >> startSpinner [
	"Show an animated thinking indicator in the transcript (like VS Code Claude).
	 The indicator is removed or replaced when real content arrives.
	 spinnerProcess must be set before calling appendThinkingIndicator: because
	 that method guards on spinnerProcess notNil."

	| frames messages frameIdx rotationCount msgIdx |
	frames := #( '|' '/' '-' '\' ).
	messages := self spinnerMessages.
	frameIdx := 1.
	rotationCount := 0.
	msgIdx := (1 to: messages size) atRandom.
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
		                  forkNamed: 'JadeiteAI-Spinner'.
	self appendThinkingIndicator: ('[AI] |  ' , (messages at: msgIdx)) asText allBold
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
JadeiteAIChatPresenter >> switchToAdapterNamed: aString [
	"Called when the user changes the adapter dropdown.
	 Validates availability before switching; reverts the dropdown on failure."

	| newAdapter currentName |
	currentName := self adapterDisplayName.
	aString = currentName ifTrue: [ ^ self ].
	aString = 'Claude'
		ifTrue: [
			newAdapter := JadeiteAIClaudeAdapter default.
			newAdapter isAvailable ifFalse: [
				JadeiteAIClaudeAdapter requestApiKey isNil ifTrue: [
					adapterDropList selectItem: currentName.
					^ self ].
				newAdapter := JadeiteAIClaudeAdapter default ] ]
		ifFalse: [
			JadeiteAISettings isOllamaAvailable ifFalse: [
				UIManager default
					alert: 'Ollama is not running.
Start it with:  ollama serve'.
				adapterDropList selectItem: currentName.
				^ self ].
			newAdapter := JadeiteAIOllamaAdapter default ].
	llmAdapter := newAdapter.
	self updateModelDropList.
	self updateWindowTitle
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> switchToModel: aModelString [
	"Called when the user selects a model from the model dropdown.
	 Warns that switching clears the conversation; reverts on cancel."

	updatingModelList ifTrue: [ ^ self ].
	(llmAdapter isKindOf: JadeiteAIOllamaAdapter) ifFalse: [ ^ self ].
	aModelString = llmAdapter model ifTrue: [ ^ self ].
	(conversation messages notEmpty and: [
		 (UIManager default confirm:
			  'Switching models will clear the current conversation. Continue?') not ])
		ifTrue: [
			modelDropList selectItem: llmAdapter model.
			^ self ].
	llmAdapter model: aModelString.
	conversation messages notEmpty ifTrue: [ self clearChat ]
]

{ #category : 'constants' }
JadeiteAIChatPresenter >> timeout [

	^ 60000
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
JadeiteAIChatPresenter >> updateAdapterUI [
	"Sync the dropdown, model list, and window title to the current adapter.
	 Called from llmAdapter: when the adapter is set externally."

	adapterDropList ifNil: [ ^ self ].
	adapterDropList selectItem: self adapterDisplayName.
	self updateModelDropList.
	self updateWindowTitle
]

{ #category : 'private' }
JadeiteAIChatPresenter >> updateContextLabel [
	"Refresh the context row to reflect the current context state."

	contextLabel ifNil: [ ^ self ].

	contextClassService ifNotNil: [ :cs |
		contextLabel label: 'Context: class ' , cs name.
		clearContextButton ifNotNil: [ clearContextButton enabled: true ].
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		contextLabel label: 'Context: ' , ms size printString , ' selected method(s)'.
		clearContextButton ifNotNil: [ clearContextButton enabled: true ].
		^ self ].

	contextLabel label: ''.
	clearContextButton ifNotNil: [ clearContextButton enabled: false ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> updateModelDropList [
	"Populate the model dropdown for Ollama; hide it for Claude.
	 Queries Ollama in a background thread to avoid blocking the UI."

	modelDropList ifNil: [ ^ self ].
	(llmAdapter isKindOf: JadeiteAIOllamaAdapter)
		ifTrue: [
			modelDropList enabled: true.
			[
			| models currentModel |
			models := JadeiteAIOllamaAdapter availableModels.
			models isEmpty ifTrue: [ models := Array with: llmAdapter model ].
			currentModel := llmAdapter model.
			UIManager default defer: [
				updatingModelList := true.
				[
				modelDropList items: models.
				(models includes: currentModel) ifTrue: [
					modelDropList selectItem: currentModel ] ]
					ensure: [ updatingModelList := false ] ] ] fork ]
		ifFalse: [
			modelDropList
				items: #(  );
				enabled: false ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> updateWindowTitle [

	[ self window title: 'Ask Jadeite — ' , self adapterDisplayName ]
		on: Error
		do: [  ]
]
