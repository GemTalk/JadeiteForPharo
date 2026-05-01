"
JadeiteAIChatConversation — in-memory conversation model.
Holds an ordered list of JadeiteAIChatMessage turns plus model settings.
No persistence in Phase 1; GemStone persistence is Phase 2.
"
Class {
	#name : 'JadeiteAIChatConversation',
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
JadeiteAIChatConversation class >> new [

	^ super new initialize
]

{ #category : 'adding' }
JadeiteAIChatConversation >> addAssistantMessage: aString [

	| msg |
	msg := JadeiteAIChatMessage role: #assistant content: aString.
	messages add: msg.
	^ msg
]

{ #category : 'adding' }
JadeiteAIChatConversation >> addMessage: aJadeiteAIChatMessage [

	messages add: aJadeiteAIChatMessage.
	^ aJadeiteAIChatMessage
]

{ #category : 'adding' }
JadeiteAIChatConversation >> addUserMessage: aString [

	| msg |
	msg := JadeiteAIChatMessage role: #user content: aString.
	messages add: msg.
	^ msg
]

{ #category : 'initialization' }
JadeiteAIChatConversation >> initialize [

	messages := OrderedCollection new.
	model := 'gpt-3.5-turbo'.
	temperature := 0.7.
	maxTokens := 2048.
	systemPrompt := 'You are a helpful GemStone Smalltalk programming assistant.
You understand Pharo Smalltalk, GemStone/S, and the Jadeite IDE.
When shown source code, analyze it and answer questions about it concisely.

You have the ability to execute Smalltalk expressions in two environments:

1. On the live GemStone server — wrap the expression in <gemstone>...</gemstone> tags.
   Example:  <gemstone>Array allInstances size</gemstone>

2. In the local Pharo image — wrap the expression in <pharo>...</pharo> tags.
   Example:  <pharo>Smalltalk version</pharo>

The result is returned to you as a follow-up message so you can complete your answer.
Use printString on complex objects for readable output.
Put the tags on their own line with nothing else on that line.

When the user asks you to run, execute, or evaluate a Smalltalk expression,
use the appropriate tag — do not say you cannot run code.

If a query fails, the result will be wrapped in <gemstoneerror>...</gemstoneerror>
or <pharoerror>...</pharoerror> tags. Read the error, correct your expression,
and retry with a new tag.'
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> maxTokens [

	^ maxTokens
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> maxTokens: anInteger [

	maxTokens := anInteger
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> messages [

	^ messages
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> model [

	^ model
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> model: aString [

	model := aString
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> systemPrompt [

	^ systemPrompt
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> systemPrompt: aString [

	systemPrompt := aString
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> temperature [

	^ temperature
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> temperature: aFloat [

	temperature := aFloat
]

{ #category : 'building' }
JadeiteAIChatConversation >> toApiMessages [
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
