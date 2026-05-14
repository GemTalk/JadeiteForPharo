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
		'historyIndex',
		'draftInput',
		'thinkingStart',
		'pharoCheckbox',
		'gemstoneCheckbox',
		'adapterDropList',
		'modelDropList',
		'updatingModelList',
		'projectPaths',
		'gemstoneEnvVarCache'
	],
	#classVars : [
		'CurrentWindow',
		'MessageHistory'
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

{ #category : 'accessing' }
JadeiteAIChatPresenter class >> windowClass [

	^ JadeiteAIWindow
]

{ #category : 'instance creation' }
JadeiteAIChatPresenter class >> openWithSession: aGciSession [
	"Open the singleton AI chat window, or bring it to front if already open.
	 Invoked from the Tools menu; clears any prior context so the window is fresh."

	CurrentWindow ifNotNil: [ :w |
		aGciSession ifNotNil: [ w gciSession: aGciSession ].
		w clearContext.
		[ w window window activate ] on: Error do: [  ].
		^ w ].

	^ (JadeiteAIChatApplication new gciSession: aGciSession; yourself) start
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
JadeiteAIChatPresenter class >> openWithSession: aGciSession forMethodExplanation: aMethodService [
	"Open (or activate) the singleton window and immediately explain the selected method."

	| window |
	window := self openWithSession: aGciSession.
	window ifNotNil: [
		UIManager default defer: [
			[ window explainMethod: aMethodService ]
				on: Error
				do: [ :ex | window onWorkerError: ex messageText ] ] ].
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
JadeiteAIChatPresenter >> explainMethod: aMethodService [
	"Auto-send an explanation request using the full agent loop.
	 Uses sendText: directly to avoid an inputArea round-trip that can return
	 empty when called from a deferred block on a fresh window."

	| className selector prompt |
	className := aMethodService className.
	selector := aMethodService selector.
	prompt := 'Explain the GemStone Smalltalk method ' , className , ' >> #' , selector , '.'.
	self sendText: prompt.
	self setMethodsContext: (Array with: aMethodService)
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> analyzeStack: aStackString [
	"Send the stack for analysis. The LLM can use bash to read relevant method sources
	 from registered project roots listed in the context message."

	| summaryLine displayText fullPrompt |
	summaryLine := (aStackString lines
		ifEmpty: [ '' ]
		ifNotEmpty: [ :lines | lines first ]) trimBlanks.
	(summaryLine endsWith: ':') ifTrue: [
		summaryLine := summaryLine copyFrom: 1 to: summaryLine size - 1 ].
	displayText := summaryLine isEmpty
		ifTrue: [ 'Analyzing stack' ]
		ifFalse: [ 'Analyzing stack: ' , summaryLine ].
	fullPrompt := 'Please analyze this GemStone stack. Explain what went wrong, which frame triggered the error, and how to fix it.

Stack:
' , aStackString.
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
JadeiteAIChatPresenter >> buildContextMessage: context [
	"Combine class context and project source path info into a single context message.
	 Returns nil if neither is present."

	| ws projectContext |
	projectContext := self buildProjectPathsContext.
	(context isEmpty and: [ projectContext isEmpty ]) ifTrue: [ ^ nil ].
	ws := WriteStream on: String new.
	context isEmpty ifFalse: [
		ws nextPutAll: 'Class context (selectors and definition):'; nextPutAll: String lf.
		ws nextPutAll: context ].
	projectContext isEmpty ifFalse: [
		context isEmpty ifFalse: [ ws nextPutAll: String lf ].
		ws nextPutAll: projectContext ].
	^ ws contents
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
JadeiteAIChatPresenter >> executeSafeCommand: aCommandString [
	"Execute a whitelisted read-only shell command and return stdout+stderr as a string.
	 Commands use absolute paths supplied by the LLM from the project roots in context."

	| tmpFile fullCmd result sem |
	(self isSafeCommand: aCommandString) ifFalse: [
		^ 'Error: Command not permitted. Only read-only commands (ls, find, grep, cat, wc, head, tail, sort, uniq, diff, sed, awk, echo, pwd, file, stat, du) are allowed. Output redirection (>), sed -i, semicolons, and shell metacharacters are blocked.' ].
	tmpFile := '/tmp/jadeite_bash_' , Processor activeProcess identityHash printString , '.txt'.
	fullCmd := 'timeout 30 ' , aCommandString , ' > ' , tmpFile , ' 2>&1'.
	sem := Semaphore new.
	[ LibC system: fullCmd. sem signal ] forkNamed: 'JadeiteAI-Bash'.
	(sem waitTimeoutMilliseconds: 35000) ifTrue: [
		^ '(bash command did not complete within timeout)' ].
	[ result := tmpFile asFileReference contents ]
		on: Error
		do: [ :e | result := 'Error reading output: ' , e messageText ].
	[ tmpFile asFileReference delete ] on: Error do: [  ].
	result isEmpty ifTrue: [ result := '(no output — command produced no output or timed out after 30s)' ].
	result size > 10000 ifTrue: [
		result := (result copyFrom: 1 to: 10000) , String lf
			, '... [output truncated at 10000 chars — use a more specific command to reduce output]' ].
	^ result
]

{ #category : 'private' }
JadeiteAIChatPresenter >> isSafeCommand: aCommandString [
	"Return true if aCommand uses only whitelisted verbs and no dangerous metacharacters."

	| allowedVerbs blocked segments |
	allowedVerbs := #( 'ls' 'find' 'grep' 'cat' 'wc' 'head' 'tail' 'sort' 'uniq' 'diff' 'echo' 'pwd' 'file' 'stat' 'du' 'sed' 'awk' ).
	blocked := #( ' > ' ';' '`' '$(' 'sed -i' 'rm ' 'mv' 'cp' 'chmod' 'chown' 'touch' 'mkdir' 'rmdir' 'kill' 'sudo' 'bash' 'python' 'ruby' 'perl' ).
	blocked do: [ :b |
		(aCommandString includesSubstring: b) ifTrue: [ ^ false ] ].
	segments := aCommandString substrings: '|'.
	segments do: [ :seg |
		| words |
		words := seg trimBlanks substrings.
		words isEmpty ifFalse: [
			(allowedVerbs includes: words first) ifFalse: [ ^ false ] ] ].
	^ true
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleBashTag: reply conversation: aConversation [
	"Handle a <bash> tag: run a safe read-only shell command in the registered project root."

	| preText cmd result |
	preText := self extractTextBefore: '<bash>' in: reply.
	cmd := (self extractExpressionFrom: reply openTag: '<bash>' closeTag: '</bash>') trimBlanks.
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	UIManager default defer: [
		self appendToTranscript: ('[bash] ' asText allBold , cmd asText) ].
	result := self executeSafeCommand: cmd.
	aConversation addAssistantMessage: preText.
	aConversation addUserMessage: '[System: bash result]
$ ' , cmd , '
' , result , '
[System: You are a GemStone Smalltalk assistant. Act on the result above.
Available action tags (use exactly one if appropriate, then stop):
  Open a method in browser:  <jadeiteaction:findgemstonemethod>ClassName>>selector</jadeiteaction:findgemstonemethod>
  Open a class in browser:   <jadeiteaction:findgemstoneclass>ClassName</jadeiteaction:findgemstoneclass>
  Open a package in browser: <jadeiteaction:findgemstonepackage>PackageName</jadeiteaction:findgemstonepackage>
  Inspect an object:         <jadeiteaction:openinspector>expression</jadeiteaction:openinspector>
  Run another bash command:  <bash>command</bash>
Rules: If the result contains the answer, give your final answer now — no tag needed.
If you need to open something in the browser, use the action tag immediately.
If you need more information, issue ONE tag. Do not describe what you are about to do — just do it.]'.
	^ self preprocessReply: (self sendWithRetry: [ llmAdapter sendConversationStep: aConversation ])
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleFindGemStoneClassTag: reply [
	"Handle a <jadeiteaction:findgemstoneclass>ClassName</jadeiteaction:findgemstoneclass> tag.
	 Opens a GemStone browser navigated to the named class.
	 Returns the text after the closing tag so a subsequent jadeiteaction tag is processed."

	| openTag closeTag preText className |
	openTag := '<jadeiteaction:findgemstoneclass>'.
	closeTag := '</jadeiteaction:findgemstoneclass>'.
	preText := self extractTextBefore: openTag in: reply.
	className := (self extractExpressionFrom: reply openTag: openTag closeTag: closeTag) trimBlanks.
	(self isValidGemStoneClassName: className) ifFalse: [
		UIManager default defer: [
			self appendToTranscript: ('[Skipped ' , openTag , className , closeTag , ' — "' , className , '" is not a valid class name]') asText ].
		^ self stripTagPair: openTag closeTag: closeTag from: reply ].
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	UIManager default defer: [
		self appendToTranscript: ('[Opening GemStone browser: ' , className , ']') asText ].
	UIManager default defer: [
		| classService |
		classService := RowanClassService new
			name: className;
			meta: false.
		JadeiteBrowser openOn: JadeiteConsole currentConsole postOpen: [ :browserPresenter |
			browserPresenter
				updateAfterFindClass: classService
				methodService: nil
				onCompletion: [  ] ] ].
	^ self suffixAfterTag: closeTag in: reply
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleFindGemStoneMethodTag: reply [
	"Handle a <jadeiteaction:findgemstonemethod>ClassName>>selector</jadeiteaction:findgemstonemethod> tag.
	 Opens a GemStone browser navigated to the named class and method.
	 Returns the text after the closing tag so a subsequent jadeiteaction tag is processed."

	| openTag closeTag preText spec sepIdx className selector meta |
	openTag := '<jadeiteaction:findgemstonemethod>'.
	closeTag := '</jadeiteaction:findgemstonemethod>'.
	preText := self extractTextBefore: openTag in: reply.
	spec := (self extractExpressionFrom: reply openTag: openTag closeTag: closeTag) trimBlanks.
	(self isValidGemStoneMethodSpec: spec) ifFalse: [
		UIManager default defer: [
			self appendToTranscript: ('[Skipped ' , openTag , spec , closeTag , ' — "' , spec , '" is not a valid ClassName>>selector]') asText ].
		^ self stripTagPair: openTag closeTag: closeTag from: reply ].
	sepIdx := spec indexOfSubCollection: '>>' startingAt: 1 ifAbsent: [ 0 ].
	sepIdx = 0
		ifTrue: [
			className := spec.
			selector := '' ]
		ifFalse: [
			className := (spec copyFrom: 1 to: sepIdx - 1) trimBlanks.
			selector := (spec copyFrom: sepIdx + 2 to: spec size) trimBlanks ].
	meta := className endsWith: ' class'.
	meta ifTrue: [ className := (className copyFrom: 1 to: className size - 6) trimBlanks ].
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	UIManager default defer: [
		self appendToTranscript: ('[Opening GemStone browser: ' , className , '>>' , selector , ']') asText ].
	UIManager default defer: [
		JadeiteBrowser openOn: JadeiteConsole currentConsole postOpen: [ :browserPresenter |
			browserPresenter
				updateAfterFindClassName: className
				methodSelector: selector
				meta: meta
				onCompletion: [  ] ] ].
	^ self suffixAfterTag: closeTag in: reply
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleFindPharoClassTag: reply [
	"Handle a <jadeiteaction:findpharoclass>ClassName</jadeiteaction:findpharoclass> tag.
	 Opens the Pharo class browser on the named class. Terminal action."

	| openTag closeTag preText className cls |
	openTag := '<jadeiteaction:findpharoclass>'.
	closeTag := '</jadeiteaction:findpharoclass>'.
	preText := self extractTextBefore: openTag in: reply.
	className := (self extractExpressionFrom: reply openTag: openTag closeTag: closeTag) trimBlanks.
	className isEmpty ifTrue: [ ^ self stripTagPair: openTag closeTag: closeTag from: reply ].
	cls := Smalltalk at: className asSymbol ifAbsent: [ nil ].
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	cls
		ifNil: [
			UIManager default defer: [
				self appendToTranscript: ('[Error: Pharo class ' , className , ' not found]') asText ] ]
		ifNotNil: [
			UIManager default defer: [
				self appendToTranscript: ('[Opening Pharo browser: ' , className , ']') asText ].
			UIManager default defer: [ cls browse ] ].
	^ self suffixAfterTag: closeTag in: reply
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleFindPharoMethodTag: reply [
	"Handle a <jadeiteaction:findpharomethod>ClassName>>selector</jadeiteaction:findpharomethod> tag.
	 Supports both instance-side (ClassName>>sel) and class-side (ClassName class>>sel). Terminal action."

	| openTag closeTag preText spec sepIdx className selector meta cls lookupCls method |
	openTag := '<jadeiteaction:findpharomethod>'.
	closeTag := '</jadeiteaction:findpharomethod>'.
	preText := self extractTextBefore: openTag in: reply.
	spec := (self extractExpressionFrom: reply openTag: openTag closeTag: closeTag) trimBlanks.
	(self isValidGemStoneMethodSpec: spec) ifFalse: [
		UIManager default defer: [
			self appendToTranscript: ('[Skipped — "' , spec , '" is not a valid ClassName>>selector]') asText ].
		^ self stripTagPair: openTag closeTag: closeTag from: reply ].
	sepIdx := spec indexOfSubCollection: '>>' startingAt: 1 ifAbsent: [ 0 ].
	sepIdx = 0
		ifTrue: [
			className := spec.
			selector := '' ]
		ifFalse: [
			className := (spec copyFrom: 1 to: sepIdx - 1) trimBlanks.
			selector := (spec copyFrom: sepIdx + 2 to: spec size) trimBlanks ].
	meta := className endsWith: ' class'.
	meta ifTrue: [ className := (className copyFrom: 1 to: className size - 6) trimBlanks ].
	cls := Smalltalk at: className asSymbol ifAbsent: [ nil ].
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	cls ifNil: [
		UIManager default defer: [
			self appendToTranscript: ('[Error: Pharo class ' , className , ' not found]') asText ] ]
	ifNotNil: [
		selector isEmpty
			ifTrue: [
				UIManager default defer: [
					self appendToTranscript: ('[Opening Pharo browser: ' , className , ']') asText ].
				UIManager default defer: [ cls browse ] ]
			ifFalse: [
				lookupCls := meta ifTrue: [ cls class ] ifFalse: [ cls ].
				method := lookupCls lookupSelector: selector asSymbol.
				method
					ifNil: [
						UIManager default defer: [
							self appendToTranscript: ('[Error: ' , spec , ' not found in Pharo]') asText ] ]
					ifNotNil: [
						UIManager default defer: [
							self appendToTranscript: ('[Opening Pharo browser: ' , className , (meta ifTrue: [ ' class' ] ifFalse: [ '' ]) , '>>' , selector , ']') asText ].
						UIManager default defer: [ method browse ] ] ] ].
	^ self suffixAfterTag: closeTag in: reply
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleFindGemStonePackageTag: reply [
	"Handle a <jadeiteaction:findgemstonepackage>PackageName</jadeiteaction:findgemstonepackage> tag.
	 Opens a GemStone browser navigated to the named package. Terminal action."

	| openTag closeTag preText packageName |
	openTag := '<jadeiteaction:findgemstonepackage>'.
	closeTag := '</jadeiteaction:findgemstonepackage>'.
	preText := self extractTextBefore: openTag in: reply.
	packageName := (self
		                extractExpressionFrom: reply
		                openTag: openTag
		                closeTag: closeTag) trimBlanks.
	(self isValidGemStoneClassName: packageName) ifFalse: [
			UIManager default defer: [
					self appendToTranscript:
						('[Skipped ' , openTag , packageName , closeTag , ' — "'
						 , packageName , '" is not a valid package name]') asText ].
			^ self stripTagPair: openTag closeTag: closeTag from: reply ].
	preText isEmpty ifFalse: [
			UIManager default defer: [
				self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	UIManager default defer: [
			self appendToTranscript:
				('[Opening GemStone browser: package ' , packageName , ']') asText ].
	UIManager default defer: [
			JadeiteBrowser
				openOn: JadeiteConsole currentConsole
				postOpen: [ :browserPresenter |
						| projectService packageService |
						"Find the project and package services from the already-loaded project list.
			 Mirrors selectClassNamed:package:project:completionBlock: — events must be
			 suspended so selectProject: does not trigger updateProjectOnCompletion:."
						projectService := browserPresenter projectListPresenter list
							                  detect: [ :p |
							                  p sortedPackages anySatisfy: [ :pkg |
								                  pkg name = packageName ] ]
							                  ifNone: [ nil ].
						projectService ifNotNil: [
								packageService := projectService sortedPackages
									                  detect: [ :pkg | pkg name = packageName ]
									                  ifNone: [ nil ].
								packageService ifNotNil: [
										browserPresenter suspendSelectionEvents.
										[
											browserPresenter selectProject: projectService.
											browserPresenter packageListPresenter list:
												projectService sortedPackages ] ensure: [
											browserPresenter resumeSelectionEvents ].
										browserPresenter selectPackage: packageService ] ] ] ].
	^ self suffixAfterTag: closeTag in: reply
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleFindGemStoneProjectTag: reply [
	"Handle a <jadeiteaction:findgemstoneproject>ProjectName</jadeiteaction:findgemstoneproject> tag.
	 Opens a GemStone browser navigated to the named project. Terminal action."

	| openTag closeTag preText projectName |
	openTag := '<jadeiteaction:findgemstoneproject>'.
	closeTag := '</jadeiteaction:findgemstoneproject>'.
	preText := self extractTextBefore: openTag in: reply.
	projectName := (self extractExpressionFrom: reply openTag: openTag closeTag: closeTag) trimBlanks.
	(self isValidGemStoneClassName: projectName) ifFalse: [
		UIManager default defer: [
			self appendToTranscript: ('[Skipped ' , openTag , projectName , closeTag , ' — "' , projectName , '" is not a valid project name]') asText ].
		^ self stripTagPair: openTag closeTag: closeTag from: reply ].
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	UIManager default defer: [
		self appendToTranscript: ('[Opening GemStone browser: project ' , projectName , ']') asText ].
	UIManager default defer: [
		JadeiteBrowser openOn: JadeiteConsole currentConsole postOpen: [ :browserPresenter |
			browserPresenter selectProjectNamed: projectName ] ].
	^ self suffixAfterTag: closeTag in: reply
]

{ #category : 'private' }
JadeiteAIChatPresenter >> handleOpenInspectorTag: reply [
	"Handle a <jadeiteaction:openinspector>expression</jadeiteaction:openinspector> tag.
	 Evaluates the expression on GemStone and opens a Jadeite inspector on the result. Terminal action."

	| preText expr |
	preText := self extractTextBefore: '<jadeiteaction:openinspector>' in: reply.
	expr := (self extractExpressionFrom: reply openTag: '<jadeiteaction:openinspector>' closeTag: '</jadeiteaction:openinspector>') trimBlanks.
	preText isEmpty ifFalse: [
		UIManager default defer: [
			self appendToTranscript: '[AI] ' asText allBold , preText asText ] ].
	gciSession ifNil: [
		UIManager default defer: [
			self appendToTranscript: '[Error: Cannot open inspector — no GemStone session available]' asText ].
		^ self suffixAfterTag: '</jadeiteaction:openinspector>' in: reply ].
	UIManager default defer: [
		self appendToTranscript: ('[Inspecting: ' , expr , ']') asText ].
	UIManager default defer: [
		JadeiteInspectorApplication
			executeThenShowOn: expr
			session: gciSession
			context: 20
			onCompletion: [  ] ].
	^ self suffixAfterTag: '</jadeiteaction:openinspector>' in: reply
]


{ #category : 'private' }
JadeiteAIChatPresenter >> historyDown [
	"At the last line of input: advance forward through history.
	 Otherwise move the cursor down one line within the text."

	MessageHistory isEmpty ifTrue: [ ^ self ].
	self isInputAtLastLine ifFalse: [ self moveCursorDownLine. ^ self ].
	historyIndex := historyIndex + 1.
	historyIndex > MessageHistory size
		ifTrue: [
			historyIndex := MessageHistory size + 1.
			inputArea text: (draftInput ifNil: [ '' ]).
			draftInput := nil ]
		ifFalse: [ inputArea text: (MessageHistory at: historyIndex) ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> historyUp [
	"At the first line of input: step back through history.
	 Saves current input as a draft the first time, so returning to the bottom restores it.
	 Otherwise move the cursor up one line within the text."

	MessageHistory isEmpty ifTrue: [ ^ self ].
	self isInputAtFirstLine ifFalse: [ self moveCursorUpLine. ^ self ].
	historyIndex = (MessageHistory size + 1) ifTrue: [
		draftInput := [ inputArea adapter widget textMorph text ]
			on: Error do: [ inputArea text ] ].
	historyIndex := (historyIndex - 1) max: 1.
	inputArea text: (MessageHistory at: historyIndex)
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initialize [

	super initialize.
	conversation := JadeiteAIChatConversation new.
	transcriptContent := '' asText.
	MessageHistory ifNil: [ MessageHistory := OrderedCollection new ].
	historyIndex := MessageHistory size + 1.
	updatingModelList := false.
	gemstoneEnvVarCache := Dictionary new
]

{ #category : 'private' }
JadeiteAIChatPresenter >> fetchProjectPaths [
	"Populate projectPaths from the console singleton's project list. Synchronous — no async needed."

	| console list |
	console := JadeiteConsole currentConsole.
	console ifNil: [ ^ self ].
	list := [ console projectListPresenter list ]
		on: Error
		do: [ :e | OrderedCollection new ].
	projectPaths := (list select: [ :p | p projectUrl notNil and: [ p projectUrl notEmpty ] ])
		collect: [ :p | p name -> ((self stripFileScheme: p projectUrl) , '/rowan/src') ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> stripFileScheme: aUrlString [
	"Strip a leading 'file:' scheme from a URL string, returning a plain file path."

	(aUrlString size >= 5 and: [ (aUrlString copyFrom: 1 to: 5) = 'file:' ])
		ifTrue: [ ^ aUrlString copyFrom: 6 to: aUrlString size ].
	^ aUrlString
]

{ #category : 'private' }
JadeiteAIChatPresenter >> resolveEnvVars: aString [
	"Expand $VARNAME patterns using GemStone environment variable queries.
	 Must be called from a background thread (e.g. the LLM worker) — uses blocking GemStone calls."

	| result i |
	result := WriteStream on: String new.
	i := 1.
	[ i <= aString size ] whileTrue: [
		(aString at: i) = $$
			ifTrue: [
				| j varName |
				j := i + 1.
				[ j <= aString size and: [
					  (aString at: j) isAlphaNumeric or: [ (aString at: j) = $_ ] ] ]
					whileTrue: [ j := j + 1 ].
				varName := aString copyFrom: i + 1 to: j - 1.
				varName isEmpty
					ifTrue: [
						result nextPut: $$.
						i := i + 1 ]
					ifFalse: [
						result nextPutAll: (self gemEnvironmentVariable: varName).
						i := j ] ]
			ifFalse: [
				result nextPut: (aString at: i).
				i := i + 1 ] ].
	^ result contents
]

{ #category : 'private' }
JadeiteAIChatPresenter >> gemEnvironmentVariable: varName [
	"Return the value of a GemStone server environment variable using System gemEnvironmentVariable:.
	 Results are cached in gemstoneEnvVarCache to avoid redundant round-trips."

	| cached sem service value |
	cached := gemstoneEnvVarCache at: varName ifAbsent: [ nil ].
	cached ifNotNil: [ ^ cached ].
	gciSession ifNil: [ ^ '$' , varName ].
	sem := Semaphore new.
	value := '$' , varName.
	service := RowanAnsweringService new.
	[
		service
			exec: 'System gemEnvironmentVariable: ''' , varName , ''''
			in: gciSession
			onCompletion: [
				[ value := service answer ]
					on: Error
					do: [ :ex | value := '$' , varName ].
				sem signal ] ]
		on: Error
		do: [ :ex | sem signal ].
	sem waitTimeoutMilliseconds: 5000.
	(value notNil and: [ value notEmpty and: [ (value copyFrom: 1 to: 1) ~= '$' ] ])
		ifTrue: [ gemstoneEnvVarCache at: varName put: value ].
	^ value
]

{ #category : 'private' }
JadeiteAIChatPresenter >> buildProjectPathsContext [
	"Return a string listing registered project source roots for the LLM context.
	 The LLM uses bash with these absolute paths to navigate and read Tonel source.
	 Lazily fetches paths on the first call if they have not been populated yet."

	| ws |
	projectPaths isNil ifTrue: [ self fetchProjectPaths ].
	(projectPaths isNil or: [ projectPaths isEmpty ]) ifTrue: [ ^ '' ].
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'Registered GemStone project source roots (use bash with these absolute paths):';
		nextPutAll: String lf.
	projectPaths do: [ :assoc |
		ws
			nextPutAll: '  ' , assoc key , ': ' , (self resolveEnvVars: assoc value);
			nextPutAll: String lf ].
	^ ws contents
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

{ #category : 'private' }
JadeiteAIChatPresenter >> isValidGemStoneClassName: aString [
	"Return true if aString looks like a real GemStone class name rather than documentation text.
	 Class names have no whitespace, backticks, angle brackets, or newlines."

	aString isEmpty ifTrue: [ ^ false ].
	^ (aString includes: Character space) not
		and: [ (aString includes: Character lf) not
		and: [ (aString includes: Character cr) not
		and: [ (aString includes: $<) not
		and: [ (aString includesSubstring: '`') not ] ] ] ]
]

{ #category : 'private' }
JadeiteAIChatPresenter >> isValidGemStoneMethodSpec: aString [
	"Return true if aString looks like a real ClassName>>selector spec rather than documentation text."

	^ (aString includesSubstring: '>>')
		and: [ (aString includes: $<) not
		and: [ (aString includes: Character lf) not
		and: [ (aString includes: Character cr) not
		and: [ (aString includesSubstring: '`') not ] ] ] ]
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

	^ 12
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
	"Called on the UI thread after a successful LLM response.
	 Highlights the new [AI] block by computing its start position before appending."

	| anchor startPos |
	conversation addAssistantMessage: replyString.
	replyString trimBlanks isEmpty ifTrue: [ self enableInput. ^ self ].
	anchor := thinkingStart ifNil: [ transcriptContent size ].
	startPos := anchor = 0 ifTrue: [ 1 ] ifFalse: [ anchor + 2 ].
	self appendToTranscript: '[AI] ' asText allBold , replyString asText.
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
JadeiteAIChatPresenter >> parseClassNamesFromStack: aStackString [
	"Extract unique class names from GemStone stack frame lines.
	 Frame lines have the form:  N [expr] in ClassName >> selector
	                          or N [expr] in ClassName class >> selector
	 Returns an OrderedCollection in first-occurrence order."

	| names |
	names := OrderedCollection new.
	aStackString lines do: [ :line |
		| inIdx arrowIdx afterIn raw |
		inIdx := line indexOfSubCollection: ' in ' startingAt: 1 ifAbsent: [ 0 ].
		inIdx = 0 ifFalse: [
			afterIn := inIdx + 4.
			arrowIdx := line indexOfSubCollection: ' >> ' startingAt: afterIn ifAbsent: [ 0 ].
			arrowIdx > 0 ifTrue: [
				raw := (line copyFrom: afterIn to: arrowIdx - 1) trimBlanks.
				(raw endsWith: ' class') ifTrue: [
					raw := raw copyFrom: 1 to: raw size - 6 ].
				(raw notEmpty and: [ (names includes: raw) not ])
					ifTrue: [ names add: raw ] ] ] ].
	^ names
]

{ #category : 'private' }
JadeiteAIChatPresenter >> parseFramesFromStack: aStackString [
	"Extract unique ClassName>>selector pairs from GemStone stack frame lines.
	 Frame lines: N [expr] in ClassName >> selector @N line N
	           or N [expr] in ClassName class >> selector @N line N
	 Returns OrderedCollection of 'ClassName>>selector' strings, first-occurrence order."

	| frames |
	frames := OrderedCollection new.
	aStackString lines do: [ :line |
		| inIdx arrowIdx afterIn className selectorRaw atIdx selector key |
		inIdx := line indexOfSubCollection: ' in ' startingAt: 1 ifAbsent: [ 0 ].
		inIdx > 0 ifTrue: [
			afterIn := inIdx + 4.
			arrowIdx := line indexOfSubCollection: ' >> ' startingAt: afterIn ifAbsent: [ 0 ].
			arrowIdx > 0 ifTrue: [
				className := (line copyFrom: afterIn to: arrowIdx - 1) trimBlanks.
				(className endsWith: ' class') ifTrue: [
					className := className copyFrom: 1 to: className size - 6 ].
				selectorRaw := (line copyFrom: arrowIdx + 4 to: line size) trimBlanks.
				atIdx := selectorRaw indexOfSubCollection: ' @' startingAt: 1 ifAbsent: [ 0 ].
				selector := atIdx > 0
					ifTrue: [ (selectorRaw copyFrom: 1 to: atIdx - 1) trimBlanks ]
					ifFalse: [ selectorRaw ].
				(className notEmpty and: [ selector notEmpty ]) ifTrue: [
					key := className , '>>' , selector.
					(frames includes: key) ifFalse: [ frames add: key ] ] ] ] ].
	^ frames
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
					expr := (result copyFrom: contentStart to: lineEnd - 1) trimBlanks.
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
	"Grab input from inputArea and forward to sendText:."

	| userText |
	userText := inputArea text trimBlanks.
	userText isEmpty ifTrue: [ ^ self ].
	self sendText: userText
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> sendText: userText [
	"Send userText to the LLM using the full agent loop.
	 Called by sendMessage (from the UI) and by explainMethod: (programmatically)."

	MessageHistory addLast: userText.
	historyIndex := MessageHistory size + 1.
	draftInput := nil.
	transcriptContent isEmpty ifFalse: [ self appendToTranscript: '' ].
	self appendToTranscript: '[You] ' asText allBold , userText asText.
	inputArea text: ''.
	self disableInput.

	self resolveContextOnCompletion: [ :context |
		workerProcess := [
			| reply agentIteration queryMsgIndex bothEnvsRequested gemstoneExecuted pharoExecuted |
			[
				conversation contextMessage: (self buildContextMessage: context).
				conversation addUserMessage: userText.
				queryMsgIndex := conversation messages size.
				bothEnvsRequested := pharoCheckbox state and: [ gemstoneCheckbox state ].
				gemstoneExecuted := false.
				pharoExecuted := false.
				reply := self preprocessReply: (self sendWithRetry: [ llmAdapter sendConversation: conversation ]).

				agentIteration := 0.

				[ | hasGemstone hasPharo hasBash hasFindClass hasFindMethod hasInspector hasFindProject hasFindPackage hasFindPharoClass hasFindPharoMethod |
				  hasGemstone := reply includesSubstring: '<gemstone>'.
				  hasPharo := reply includesSubstring: '<pharo>'.
				  hasBash := reply includesSubstring: '<bash>'.
				  hasFindClass := reply includesSubstring: '<jadeiteaction:findgemstoneclass>'.
				  hasFindMethod := reply includesSubstring: '<jadeiteaction:findgemstonemethod>'.
				  hasInspector := reply includesSubstring: '<jadeiteaction:openinspector>'.
				  hasFindProject := reply includesSubstring: '<jadeiteaction:findgemstoneproject>'.
				  hasFindPackage := reply includesSubstring: '<jadeiteaction:findgemstonepackage>'.
				  hasFindPharoClass := reply includesSubstring: '<jadeiteaction:findpharoclass>'.
				  hasFindPharoMethod := reply includesSubstring: '<jadeiteaction:findpharomethod>'.
				  (hasGemstone or: [ hasPharo or: [ hasBash or: [ hasFindClass or: [ hasFindMethod or: [ hasInspector or: [ hasFindProject or: [ hasFindPackage or: [ hasFindPharoClass or: [ hasFindPharoMethod ] ] ] ] ] ] ] ] ])
				  and: [ agentIteration < self maxAgentIterations ] ]
				whileTrue: [
					| preText expr result feedbackResult feedbackMsg useGemstone tag errorTag label firstTag |
					agentIteration := agentIteration + 1.
					firstTag := #( '<bash>' '<jadeiteaction:findgemstoneclass>' '<jadeiteaction:findgemstonemethod>' '<jadeiteaction:openinspector>' '<jadeiteaction:findgemstoneproject>' '<jadeiteaction:findgemstonepackage>' '<jadeiteaction:findpharoclass>' '<jadeiteaction:findpharomethod>' '<gemstone>' '<pharo>' )
						inject: reply size + 1 -> ''
						into: [ :min :tag |
							| idx |
							idx := reply indexOfSubCollection: tag startingAt: 1 ifAbsent: [ reply size + 1 ].
							idx < min key ifTrue: [ idx -> tag ] ifFalse: [ min ] ].
					(firstTag value = '<bash>')
						ifTrue: [
							reply := self handleBashTag: reply conversation: conversation ]
						ifFalse: [ (firstTag value = '<jadeiteaction:findgemstoneclass>')
						ifTrue: [
							reply := self handleFindGemStoneClassTag: reply ]
						ifFalse: [ (firstTag value = '<jadeiteaction:findgemstonemethod>')
						ifTrue: [
							reply := self handleFindGemStoneMethodTag: reply ]
						ifFalse: [ (firstTag value = '<jadeiteaction:openinspector>')
						ifTrue: [
							reply := self handleOpenInspectorTag: reply ]
						ifFalse: [ (firstTag value = '<jadeiteaction:findgemstoneproject>')
						ifTrue: [
							reply := self handleFindGemStoneProjectTag: reply ]
						ifFalse: [ (firstTag value = '<jadeiteaction:findgemstonepackage>')
						ifTrue: [
							reply := self handleFindGemStonePackageTag: reply ]
						ifFalse: [ (firstTag value = '<jadeiteaction:findpharoclass>')
						ifTrue: [
							reply := self handleFindPharoClassTag: reply ]
						ifFalse: [ (firstTag value = '<jadeiteaction:findpharomethod>')
						ifTrue: [
							reply := self handleFindPharoMethodTag: reply ]
						ifFalse: [
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
													'. You were asked to evaluate in both environments. Execute in ' , otherEnv , ' now using ' , otherTag , ' — required.'
													, String lf , '[System: Output ONLY the tag ' , otherTag , ' with the expression. No prose, no markdown.]' ]
												ifFalse: [ '. If you need more data, use another tag. Otherwise give your final answer.'
													, String lf , '[System: Results shown are COMPLETE as returned — do NOT re-read a result you already have, even if it looks short. For GemStone selector discovery AND method source: use bash grep across ALL registered roots then cat — not <gemstone>sourceCodeAt:</gemstone>. Only use <gemstone> for live runtime values or classes not in any registered project.]'
													, String lf , '[System: To open a Jadeite window use the exact formats: <jadeiteaction:findgemstoneclass>ClassName</jadeiteaction:findgemstoneclass> or <jadeiteaction:findpharoclass>ClassName</jadeiteaction:findpharoclass> for browsers; <jadeiteaction:findgemstonemethod>ClassName>>selector</jadeiteaction:findgemstonemethod> or <jadeiteaction:findpharomethod>ClassName>>selector</jadeiteaction:findpharomethod> for methods; <jadeiteaction:openinspector>expr</jadeiteaction:openinspector> for inspector. NEVER use <gemstone> or <pharo> tags to open windows — they will fail.]' ] ]) ].
							conversation addAssistantMessage: preText.
							conversation addUserMessage: feedbackMsg.
							reply := self preprocessReply: (self sendWithRetry: [ llmAdapter sendConversationStep: conversation ]) ] ] ] ] ] ] ] ] ].

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

	MessageHistory addLast: displayText.
	historyIndex := MessageHistory size + 1.
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
			reply := self sendWithRetry: [ llmAdapter sendConversation: analysisConversation ].
			conversation addUserMessage: displayText.
			UIManager default defer: [ self onWorkerDone: reply ] ]
		on: Error
		do: [ :ex |
			UIManager default defer: [ self onWorkerError: ex messageText ] ] ]
	forkNamed: 'JadeiteAI-LLMWorker'
]


{ #category : 'private' }
JadeiteAIChatPresenter >> sendWithRetry: aBlock [
	"Call aBlock, retrying up to 3 times on Claude overloaded_error or rate_limit_error responses.
	 Updates the transcript between retries so the user knows what is happening."

	| attempt maxAttempts |
	maxAttempts := 4.
	attempt := 1.
	[ attempt < maxAttempts ] whileTrue: [
		[ ^ aBlock value ]
			on: Error
			do: [ :ex |
				((ex messageText includesSubstring: 'overloaded_error')
					or: [ ex messageText includesSubstring: 'rate_limit_error' ])
					ifTrue: [
						UIManager default defer: [
							self appendToTranscript:
								('[AI] Claude busy, retrying ('
								, attempt printString , '/'
								, (maxAttempts - 1) printString
								, ')...') asText allBold ].
						(Delay forSeconds: 5) wait ]
					ifFalse: [ ex pass ] ].
		attempt := attempt + 1 ].
	^ aBlock value
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
JadeiteAIChatPresenter >> stackAnalysisSystemPrompt [
	"System prompt for stack analysis — includes source-reading tag instructions so
	 Claude can look up relevant methods from registered projects."

	^ 'You are a helpful GemStone Smalltalk programming assistant.
Analyze the GemStone call stack and any method sources provided. Explain:
1. What went wrong — the root cause of the error
2. Which frame triggered the error and why
3. How to fix it

Be concise. Focus on the most relevant frames and the provided method sources.'
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

{ #category : 'private' }
JadeiteAIChatPresenter >> suffixAfterTag: closeTag in: reply [
	"Return the text that follows the first occurrence of closeTag in reply.
	 Used by jadeiteaction handlers so the agent loop can process a second tag
	 that appears after the one just handled."

	| closeIdx |
	closeIdx := reply indexOfSubCollection: closeTag startingAt: 1 ifAbsent: [ ^ '' ].
	^ reply copyFrom: closeIdx + closeTag size to: reply size
]

{ #category : 'private' }
JadeiteAIChatPresenter >> stripTagPair: openTag closeTag: closeTag from: reply [
	"Remove the first occurrence of openTag...closeTag from reply.
	 Used to discard invalid jadeiteaction tags so the agent loop can continue."

	| openIdx closeIdx |
	openIdx := reply indexOfSubCollection: openTag startingAt: 1 ifAbsent: [ ^ reply ].
	closeIdx := reply indexOfSubCollection: closeTag startingAt: openIdx ifAbsent: [ 0 ].
	closeIdx = 0 ifTrue: [
		^ (reply copyFrom: 1 to: openIdx - 1) , (reply copyFrom: openIdx + openTag size to: reply size) ].
	^ (reply copyFrom: 1 to: openIdx - 1) , (reply copyFrom: closeIdx + closeTag size to: reply size)
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
	"If the result is large, write it to a temp file and return a short pointer.
	 The LLM can then use <bash> tags (grep, cat, head) to analyze without size limits.
	 Falls back to plain truncation if the file write fails."

	| maxLen dumpPath |
	maxLen := 3000.
	aString size <= maxLen ifTrue: [ ^ aString ].
	dumpPath := '/tmp/jadeite_gs_result.txt'.
	[ dumpPath asFileReference writeStreamDo: [ :s | s nextPutAll: aString ] ]
		on: Error
		do: [ :ex |
			^ (aString copyFrom: 1 to: maxLen)
			  , String lf
			  , '[...truncated — ' , (aString size - maxLen) printString , ' more characters]' ].
	^ '[Result too large for inline display (' , aString size printString
	  , ' chars) — written to ' , dumpPath , '.'
	  , String lf
	  , 'Use <bash>cat ' , dumpPath , '</bash> or <bash>grep pattern ' , dumpPath , '</bash> to analyze.]'
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
