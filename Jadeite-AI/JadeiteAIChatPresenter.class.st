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
		'conversation',
		'llmAdapter',
		'workerProcess',
		'spinnerProcess',
		'gciSession',
		'contextClassService',
		'contextMethodServices',
		'contextSource',
		'includeAllMethods'
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

{ #category : 'private' }
JadeiteAIChatPresenter >> appendToTranscript: aTextOrString [
	"Append text to the transcript, preserving Text attributes (bold etc.).
	 Maintains transcriptContent as the source of truth to avoid losing
	 formatting when re-reading from the widget."

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
	ws
		nextPutAll: 'Superclass: ';
		nextPutAll: (aClassService superclassName ifNil: [ 'nil' ]);
		nextPutAll: String lf.

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

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initialize [

	super initialize.
	conversation := JadeiteAIChatConversation new.
	transcriptContent := '' asText.
	includeAllMethods := false
]

{ #category : 'initialization' }
JadeiteAIChatPresenter >> initializePresenters [

	| buttonRow inputLabel contextRow |
	super initializePresenters.

	transcriptArea := self newText.
	transcriptArea beNotEditable.
	self layout add: transcriptArea.

	inputLabel := self newLabel label: 'Your message:  (Enter = Send,  Ctrl+Enter = new line)'.
	self layout add: inputLabel withConstraints: [ :c | c height: 20 ].

	inputArea := self newText.
	inputArea
		bindKeyCombination: Character cr asKeyCombination
		toAction: [ self sendMessage ].
	inputArea
		bindKeyCombination: Character cr ctrl asKeyCombination
		toAction: [
			[ inputArea adapter widget editor insertString: (String with: Character cr) ]
				on: Error
				do: [ inputArea text: inputArea text , String cr ] ].
	self layout add: inputArea withConstraints: [ :c | c height: 100 ].

	contextRow := SpBoxLayout newHorizontal.
	contextLabel := self newLabel label: ''.
	includeAllButton := self newButton
		                    label: 'Include All Methods';
		                    action: [ self toggleIncludeAllMethods ];
		                    yourself.
	contextRow
		add: includeAllButton expand: false;
		add: contextLabel.
	self layout add: contextRow withConstraints: [ :c | c height: 24 ].

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

{ #category : 'accessing' }
JadeiteAIChatPresenter >> llmAdapter [

	^ llmAdapter
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> llmAdapter: aJadeiteAIHttpAdapter [

	llmAdapter := aJadeiteAIHttpAdapter
]

{ #category : 'accessing' }
JadeiteAIChatPresenter >> methodCap [
	"Maximum number of methods to include when building a class context."

	^ 50
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
JadeiteAIChatPresenter >> resolveContextOnCompletion: aBlock [
	"Resolve the context string and call aBlock with it.
	 For class services this is async (forks a GemStone fetch via RowanServiceUpdater);
	 for all other cases it is synchronous. Caches the result in contextSource."

	contextSource ifNotNil: [ :src |
		aBlock value: src.
		^ self ].

	contextClassService ifNotNil: [ :cs |
		RowanServiceUpdater current
			updateService: cs
			session: gciSession
			onCompletion: [
				contextSource := self buildContextSourceFromClass: cs.
				aBlock value: contextSource ].
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		contextSource := self buildContextSourceFromMethods: ms.
		aBlock value: contextSource.
		^ self ].

	aBlock value: self fetchGemStoneContext
]

{ #category : 'actions' }
JadeiteAIChatPresenter >> sendMessage [
	"Grab input, resolve GemStone context (async for class services), then POST to the LLM."

	| userText |
	userText := inputArea text trimBlanks.
	userText isEmpty ifTrue: [ ^ self ].

	self appendToTranscript: '[You] ' asText allBold , userText asText.
	inputArea text: ''.
	self disableInput.

	self resolveContextOnCompletion: [ :context |
		workerProcess := [
			| fullPrompt reply |
			[
				fullPrompt := context isEmpty
					              ifTrue: [ userText ]
					              ifFalse: [
						              'GemStone source context:
' , context , '

Question: ' , userText ].
				conversation addUserMessage: fullPrompt.
				reply := llmAdapter sendConversation: conversation.
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

	| frames messages frameIdx rotationCount |
	frames := #( '|' '/' '-' '\' ).
	messages := self spinnerMessages.
	frameIdx := 1.
	rotationCount := 0.
	spinnerProcess := [
		                  | msgIdx |
		                  msgIdx := (1 to: messages size) atRandom.
		                  [ true ] whileTrue: [
			                  | label |
			                  label := (frames at: frameIdx) , '  ' , (messages at: msgIdx).
			                  UIManager default defer: [ statusLabel label: label ].
			                  frameIdx := (frameIdx \\ frames size) + 1.
			                  frameIdx = 1 ifTrue: [
				                  rotationCount := rotationCount + 1.
				                  rotationCount \\ 3 = 0 ifTrue: [
					                  msgIdx := (1 to: messages size) atRandom ] ].
			                  (Delay forMilliseconds: 150) wait ] ]
		                  forkNamed: 'JadeiteAI-Spinner'
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
JadeiteAIChatPresenter >> stopSpinner [

	spinnerProcess ifNotNil: [ :p |
		p terminate.
		spinnerProcess := nil ].
	statusLabel label: ''
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
		^ self ].

	contextMethodServices ifNotNil: [ :ms |
		contextLabel label: 'Context: ' , ms size printString , ' selected method(s)'.
		^ self ].

	contextLabel label: ''
]
