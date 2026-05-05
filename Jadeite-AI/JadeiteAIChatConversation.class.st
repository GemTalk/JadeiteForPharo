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
	maxTokens := 512.
	systemPrompt := 'You are a helpful GemStone Smalltalk programming assistant.
You understand Pharo Smalltalk, GemStone/S, and the Jadeite IDE.
When shown source code, analyze it and answer questions about it concisely.

You can execute Smalltalk code in two environments using these exact tag formats:

To run code on the GemStone server:
<gemstone>expression</gemstone>

To run code in the local Pharo image:
<pharo>expression</pharo>

Rules:
- Use ONLY the XML-like tags above. Do NOT use Markdown code fences (```).
- Put each tag pair on its own line with nothing else on that line.
- Write the expression directly inside the tags. Do NOT use Compiler or OpalCompiler.
- Always include the closing tag on the same line as the opening tag.
- Use printString on complex objects for readable output.

CRITICAL — when to use execution tags:
- Use execution tags when you need a live value FROM the runtime (object state, allInstances, system time, etc.).
- Execute AT MOST ONE tag per reply. Once you receive the result, answer directly using that value.
- Do NOT execute more code to add constants to a result you already have. If the result is 4755 and the user asked you to add 13, answer "4755 + 13 = 4768" — do not run another tag.
- "on the server", "in GemStone", "on GemStone" → use <gemstone> tags.
- "in Pharo", "on Pharo", "locally" → use <pharo> tags.
- When no environment is specified and an expression involves live object state, use <gemstone> tags.
- The result is returned to you as a follow-up message so you can complete your answer.

If a query fails, the result is wrapped in <gemstoneerror>...</gemstoneerror>
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

{ #category : 'accessing' }
JadeiteAIChatConversation >> compactFrom: anIndex [
	"Remove all messages added after position anIndex, keeping messages 1..anIndex.
	 Called after each agent loop to strip intermediate code-execution turns so
	 subsequent queries start with a lean context."

	[ messages size > anIndex ] whileTrue: [ messages removeLast ]
]

{ #category : 'building' }
JadeiteAIChatConversation >> toApiMessages [
	"Return messages array in OpenAI/Ollama format for the HTTP payload.
	 Appends any permanent knowledge from JadeiteAIKnowledgeBase to the system prompt."

	| result effectivePrompt knowledgeText |
	result := OrderedCollection new.
	knowledgeText := JadeiteAIKnowledgeBase current knowledgeText.
	effectivePrompt := knowledgeText isEmpty
		                   ifTrue: [ systemPrompt ]
		                   ifFalse: [ systemPrompt , knowledgeText ].
	effectivePrompt ifNotEmpty: [
		result add: (Dictionary new
			at: 'role' put: 'system';
			at: 'content' put: effectivePrompt;
			yourself) ].
	messages do: [ :msg |
		result add: (Dictionary new
			at: 'role' put: msg role;
			at: 'content' put: msg content;
			yourself) ].
	^ result
]
