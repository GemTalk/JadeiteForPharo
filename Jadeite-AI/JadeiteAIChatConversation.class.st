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
		'maxTokens',
		'contextMessage'
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

{ #category : 'accessing' }
JadeiteAIChatConversation >> compactFrom: anIndex [
	"Remove all messages added after position anIndex, keeping messages 1..anIndex.
	 Called after each agent loop to strip intermediate code-execution turns so
	 subsequent queries start with a lean context."

	[ messages size > anIndex ] whileTrue: [ messages removeLast ]
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> contextMessage [

	^ contextMessage
]

{ #category : 'accessing' }
JadeiteAIChatConversation >> contextMessage: aStringOrNil [

	contextMessage := aStringOrNil
]

{ #category : 'initialization' }
JadeiteAIChatConversation >> initialize [

	messages := OrderedCollection new.
	model := 'gpt-3.5-turbo'.
	temperature := 0.7.
	maxTokens := 512.
	contextMessage := nil.
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
- When the user provides an expression and asks you to execute or evaluate it, ALWAYS use the appropriate tag. Never answer from training knowledge when code execution is explicitly requested.
- Use execution tags when you need a live value FROM the runtime (object state, allInstances, system time, etc.).
- Execute ONE tag per reply. Once you receive the result, answer directly using that value.
- Do NOT execute more code to perform arithmetic on a result you already have. If the result is 4755 and the user asked you to add 13, answer "4755 + 13 = 4768" — do not run another tag.
- "on the server", "in GemStone", "on GemStone" → use <gemstone> tags.
- "in Pharo", "on Pharo", "locally", "in the local image" → use <pharo> tags.
- When no environment is specified and an expression involves live object state, use <gemstone> tags.
- The result is returned to you as a follow-up message so you can complete your answer.

Reading source code:
- When a class context is set, you will receive a list of method selectors for that class.
- Analyze selector names to identify which methods are relevant before reading any source.
- To read a Pharo instance method: <pharo>((Smalltalk at: #ClassName) >> #selector) sourceCode</pharo>
- To read a Pharo class-side method: <pharo>((Smalltalk at: #ClassName) class >> #selector) sourceCode</pharo>
- To read a GemStone instance method: <gemstone>((ClassName methodDictForEnv: 0) at: #selector) sourceString</gemstone>
- To read a GemStone class-side method: <gemstone>((ClassName class methodDictForEnv: 0) at: #selector) sourceString</gemstone>
- ALWAYS use the fetch expression above. NEVER write method source code from memory inside a tag — you will get a compile error. The tag must contain only the fetch expression, not the method body.
- Issue ONE tag per reply. The result is returned to you so you can issue the next tag.
- You may read up to 3 methods sequentially without asking. After reading 3 methods total in a chain, ask permission before reading more.
- Never request all methods of a class at once.

If a query fails, the result is wrapped in <gemstoneerror>...</gemstoneerror>
or <pharoerror>...</pharoerror> tags. Read the error, correct your expression,
and retry with a new tag.

Reading registered project source:
- To read a class skeleton (header + method signatures, no bodies) from a registered project: <readgemstoneclass>ClassName</readgemstoneclass>
- To read a single method body from a registered project: <readgemstonemethod>ClassName>>selector</readgemstonemethod>
- Prefer <readgemstonemethod> over <readgemstoneclass> when you only need one or two methods — it uses far fewer tokens.
- Available projects and their class names are listed in the context message when projects are registered.
- Issue ONE tag per reply. The result is returned to you so you can issue the next tag.
- You may read up to 3 methods sequentially without asking. After reading 3 methods total in a chain, ask permission before reading more.

Pharo specific instructions: 
- When asked to time results in Pharo use the format [ <expression> ] timeToRun

GemStone specific instructions: 
- When asked to time results in GemStone use the format Time millisecondsToRun: [ <expression> ] 

'
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
	"Return messages array in OpenAI/Ollama format, including the system prompt
	 and any one-shot context message. Used only for the first call per user query;
	 agent-loop steps use toApiMessagesNoSystem which omits both."

	| result |
	result := OrderedCollection new.
	systemPrompt ifNotEmpty: [
		result add: (Dictionary new
			at: 'role' put: 'system';
			at: 'content' put: systemPrompt;
			yourself) ].
	contextMessage ifNotNil: [ :ctx |
		result add: (Dictionary new
			at: 'role' put: 'user';
			at: 'content' put: ctx;
			yourself) ].
	messages do: [ :msg |
		result add: (Dictionary new
			at: 'role' put: msg role;
			at: 'content' put: msg content;
			yourself) ].
	^ result
]

{ #category : 'building' }
JadeiteAIChatConversation >> toApiMessagesNoSystem [
	"Return messages array without the system prompt.
	 Used for agent-loop iterations where the system prompt was already sent."

	| result |
	result := OrderedCollection new.
	messages do: [ :msg |
		result add: (Dictionary new
			at: 'role' put: msg role;
			at: 'content' put: msg content;
			yourself) ].
	^ result
]
