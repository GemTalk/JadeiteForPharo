"
JAIChatPresenter — Spec 2 chat UI for the Jadeite AI assistant.

Menu path:  Console > AI Chat
Setup:      Install Ollama from https://ollama.com, then run: ollama pull qwen2.5-coder:7b
            No account or API key needed. If Ollama is not running, a setup
            dialog explains exactly what to do.
Tests:      JAIChatTestCase run

The presenter is self-contained:
  - transcript area shows alternating user / assistant turns
  - input area accepts multi-line prompts
  - Send forks a background worker so the UI stays responsive
  - GemStone source context is injected automatically when a browser is open

Note: the instance variable is named llmAdapter (not adapter) to avoid
shadowing SpPresenter>>adapter which Spec 2 uses for its Morphic backend.
"
Class {
	#name : 'JAIChatPresenter',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'transcriptArea',
		'inputArea',
		'sendButton',
		'stopButton',
		'statusLabel',
		'conversation',
		'llmAdapter',
		'workerProcess',
		'gciSession'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JAIChatPresenter class >> openWithSession: aGciSession [
	"Open a new AI chat window.
	 Resolves the LLM adapter automatically via JAISettings.
	 Shows a setup dialog if Ollama is not running."

	| resolvedAdapter presenter |
	resolvedAdapter := JAISettings resolveAdapter.
	resolvedAdapter isNil ifTrue: [
		UIManager default alert: JAISettings configurationHelpMessage.
		^ nil ].

	presenter := self new.
	aGciSession ifNotNil: [ presenter gciSession: aGciSession ].
	presenter llmAdapter: resolvedAdapter.
	^ presenter open
]

{ #category : 'private' }
JAIChatPresenter >> appendToTranscript: aString [
	"Append aString to the read-only transcript and scroll to the end.
	 Must be called from the UI process."

	| current |
	current := transcriptArea text.
	transcriptArea text: (current isEmpty
		ifTrue: [ aString ]
		ifFalse: [ current , String lf , aString ]).
	[ transcriptArea adapter widget scrollToBottom ]
		on: Error
		do: [ "ignore if widget not yet realized" ]
]

{ #category : 'accessing' }
JAIChatPresenter >> conversation [

	^ conversation
]

{ #category : 'layout' }
JAIChatPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'private' }
JAIChatPresenter >> disableInput [

	sendButton enabled: false.
	inputArea enabled: false.
	stopButton enabled: true.
	statusLabel label: 'Waiting for response...'
]

{ #category : 'private' }
JAIChatPresenter >> enableInput [

	sendButton enabled: true.
	inputArea enabled: true.
	stopButton enabled: false.
	statusLabel label: ''
]

{ #category : 'private' }
JAIChatPresenter >> fetchGemStoneContext [
	"Return source of the currently-selected method from any open Jadeite browser,
	 or empty string if nothing is selected or no session is available.
	 Source is already in the Pharo image — no extra GemStone round-trip needed."

	gciSession ifNil: [ ^ '' ].
	JadeiteBrowserPresenter allInstances do: [ :browser |
		| src |
		src := [
			browser selectedMethod
				ifNotNil: [ :m | m source ]
				ifNil: [ nil ] ]
			on: Error
			do: [ nil ].
		(src notNil and: [ src notEmpty ]) ifTrue: [ ^ src ] ].
	^ ''
]

{ #category : 'accessing' }
JAIChatPresenter >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JAIChatPresenter >> gciSession: aGciSession [

	gciSession := aGciSession
]

{ #category : 'initialization' }
JAIChatPresenter >> initialize [

	super initialize.
	conversation := JAIChatConversation new
]

{ #category : 'initialization' }
JAIChatPresenter >> initializePresenters [

	| buttonRow inputLabel |
	super initializePresenters.

	transcriptArea := self newText.
	transcriptArea beNotEditable.
	self layout add: transcriptArea.

	inputLabel := self newLabel label: 'Your message:'.
	self layout add: inputLabel withConstraints: [ :c | c height: 20 ].

	inputArea := self newText.
	inputArea
		bindKeyCombination: $u meta asKeyCombination
		toAction: [ self sendMessage ].
	self layout add: inputArea withConstraints: [ :c | c height: 100 ].

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
	statusLabel := self newLabel label: ''.
	buttonRow
		add: sendButton expand: false;
		add: stopButton expand: false;
		add: statusLabel.
	self layout add: buttonRow withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JAIChatPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'AI Chat — Jadeite'.
	aWindowPresenter initialExtent: 700 @ 520
]

{ #category : 'accessing' }
JAIChatPresenter >> llmAdapter [

	^ llmAdapter
]

{ #category : 'accessing' }
JAIChatPresenter >> llmAdapter: aJAIHttpAdapter [

	llmAdapter := aJAIHttpAdapter
]

{ #category : 'event handling' }
JAIChatPresenter >> onWorkerDone: replyString [
	"Called on the UI thread after a successful LLM response."

	conversation addAssistantMessage: replyString.
	self appendToTranscript: '[AI] ' , replyString.
	self enableInput
]

{ #category : 'event handling' }
JAIChatPresenter >> onWorkerError: errorString [
	"Called on the UI thread when the worker catches an error."

	self appendToTranscript: '[Error] ' , errorString.
	self enableInput
]

{ #category : 'actions' }
JAIChatPresenter >> sendMessage [
	"Grab input, inject GemStone context if available, fork the HTTP worker."

	| userText context fullPrompt |
	userText := inputArea text trimBlanks.
	userText isEmpty ifTrue: [ ^ self ].

	context := self fetchGemStoneContext.
	fullPrompt := context isEmpty
		              ifTrue: [ userText ]
		              ifFalse: [
				              'GemStone source context:
' , context , '

Question: ' , userText ].

	conversation addUserMessage: fullPrompt.
	self appendToTranscript: '[You] ' , userText.
	inputArea text: ''.
	self disableInput.

	workerProcess := [
		                 | reply |
		                 [
			                 reply := llmAdapter sendConversation: conversation.
			                 UIManager default defer: [
				                 self onWorkerDone: reply ] ]
			                 on: Error
			                 do: [ :ex |
				                 UIManager default defer: [
					                 self onWorkerError: ex messageText ] ] ]
		                 forkNamed: 'JAI-LLMWorker'
]

{ #category : 'actions' }
JAIChatPresenter >> stopWorker [
	"Terminate the in-flight LLM request and re-enable input."

	workerProcess ifNotNil: [ :p |
		p terminate.
		workerProcess := nil ].
	self appendToTranscript: '[Stopped]'.
	self enableInput
]
