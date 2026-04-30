"
JAIChatConversation — in-memory conversation model.
Holds an ordered list of JAIChatMessage turns plus model settings.
No persistence in Phase 1; GemStone persistence is Phase 2.
"
Class {
	#name : 'JAIChatConversation',
	#superclass : 'Object',
	#instVars : [
		'messages',
		'model',
		'systemPrompt',
		'temperature',
		'maxTokens'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JAIChatConversation class >> new [

	^ super new initialize
]

{ #category : 'adding' }
JAIChatConversation >> addAssistantMessage: aString [

	| msg |
	msg := JAIChatMessage role: #assistant content: aString.
	messages add: msg.
	^ msg
]

{ #category : 'adding' }
JAIChatConversation >> addMessage: aJAIChatMessage [

	messages add: aJAIChatMessage.
	^ aJAIChatMessage
]

{ #category : 'adding' }
JAIChatConversation >> addUserMessage: aString [

	| msg |
	msg := JAIChatMessage role: #user content: aString.
	messages add: msg.
	^ msg
]

{ #category : 'initialization' }
JAIChatConversation >> initialize [

	messages := OrderedCollection new.
	model := 'gpt-3.5-turbo'.
	temperature := 0.7.
	maxTokens := 2048.
	systemPrompt := 'You are a helpful GemStone Smalltalk programming assistant.
You understand Pharo Smalltalk, GemStone/S, and the Jadeite IDE.
When shown source code, analyze it and answer questions about it concisely.'
]

{ #category : 'accessing' }
JAIChatConversation >> maxTokens [

	^ maxTokens
]

{ #category : 'accessing' }
JAIChatConversation >> maxTokens: anInteger [

	maxTokens := anInteger
]

{ #category : 'accessing' }
JAIChatConversation >> messages [

	^ messages
]

{ #category : 'accessing' }
JAIChatConversation >> model [

	^ model
]

{ #category : 'accessing' }
JAIChatConversation >> model: aString [

	model := aString
]

{ #category : 'accessing' }
JAIChatConversation >> systemPrompt [

	^ systemPrompt
]

{ #category : 'accessing' }
JAIChatConversation >> systemPrompt: aString [

	systemPrompt := aString
]

{ #category : 'accessing' }
JAIChatConversation >> temperature [

	^ temperature
]

{ #category : 'accessing' }
JAIChatConversation >> temperature: aFloat [

	temperature := aFloat
]

{ #category : 'building' }
JAIChatConversation >> toApiMessages [
	"Return messages array in OpenAI/Ollama format for the HTTP payload."

	| result |
	result := OrderedCollection new.
	systemPrompt ifNotEmpty: [
		result add: (Dictionary new
			at: 'role' put: 'system';
			at: 'content' put: systemPrompt;
			yourself) ].
	messages do: [ :msg |
		result add: (Dictionary new
			at: 'role' put: msg role;
			at: 'content' put: msg content;
			yourself) ].
	^ result
]
