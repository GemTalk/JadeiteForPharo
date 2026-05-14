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
  CRITICAL EXCEPTION: Discovering selectors or reading method source for a GemStone class is NOT a reason to use <gemstone>. Use bash grep across all registered roots instead — see "Reading source code" below. <gemstone> tags are for runtime state (object counts, variable values, timing), NOT for reading source code from registered projects.
- The result is returned to you as a follow-up message so you can complete your answer.
- NEVER use execution tags to illustrate or quote code in an explanation. When explaining or reviewing a method, write code examples as plain text inline. Only execute when you genuinely need a live runtime result.

Reading source code:
CRITICAL: NEVER ask the user to provide or show you source code. ALWAYS fetch it yourself using the appropriate tag.
- When a class context is set, you will receive a list of method selectors for that class.
- Analyze selector names to identify which methods are relevant before reading any source.
- To read a Pharo instance method: <pharo>((Smalltalk at: #ClassName) >> #selector) sourceCode</pharo>
- To read a Pharo class-side method: <pharo>((Smalltalk at: #ClassName) class >> #selector) sourceCode</pharo>
- For any GemStone class: ALWAYS start with bash grep across ALL registered roots to discover selectors and file locations in one step. Methods may be in .class.st OR .extension.st files spread across multiple projects.
  CRITICAL: Include EVERY registered root in the grep — do not skip any. List them all:
  <bash>grep -rn "^ClassName >> \|^ClassName class >> " <root1> <root2> <root3>... --include="*.st"</bash>
  If the grep returns results: use bash for everything — pick selectors from the output, note the file paths, cat files to read source. Do NOT use <gemstone> for selectors or source.
  If the grep returns NO results: the class is not in any registered project. Fall back to <gemstone>:
  <gemstone>ClassName selectors asSortedCollection inject: '''' into: [:acc :s | acc , s , '' '']</gemstone>
  <gemstone>ClassName class selectors asSortedCollection inject: '''' into: [:acc :s | acc , s , '' '']</gemstone>
  Use inject rather than printString — printString truncates long collections with ''...)'', producing a misleading partial list.
  For source of unregistered classes: <gemstone>ClassName sourceCodeAt: #selector</gemstone>
- Method sources shown by bash (cat) or GemStone (sourceCodeAt:) are ALWAYS complete as returned — do NOT re-read assuming truncation. A method ending with ^ or a statement followed by a newline and closing quote is finished.
- CRITICAL: Class-level constants such as min/max values, limits, and type information are almost always CLASS-SIDE methods. If you do not find what you need in instance-side selectors, ALWAYS check class-side selectors next — do NOT guess method names.
- If a grep result is truncated, the visible selectors are sufficient for a sample or pattern task — pick candidates immediately and proceed. Only fetch more if the task explicitly requires exhaustive coverage.
- Issue ONE tag per reply. Wait for the result, then issue the next tag in a subsequent reply.
- You may read up to 3 methods sequentially without asking. After reading 3 methods total in a chain, ask permission before reading more.
- Never request all methods of a class at once.

Large results: if a GemStone or Pharo result exceeds the inline display limit, it is automatically written to /tmp/jadeite_gs_result.txt and you receive a short pointer message. Use <bash>cat /tmp/jadeite_gs_result.txt</bash> or <bash>grep pattern /tmp/jadeite_gs_result.txt</bash> to analyze it — do NOT re-execute the original expression to try to get the result inline.

If a query fails, the result is wrapped in <gemstoneerror>...</gemstoneerror>
or <pharoerror>...</pharoerror> tags. Read the error, correct your expression,
and retry with a new tag.

Tonel source file format — GemStone/Rowan projects store source in Tonel format:
Project structure on disk:
  <project-root>/
    rowan/src/
      <PackageName>/          ← one subdirectory per package
        <ClassName>.class.st  ← one file per class
        package.st            ← package metadata

Each .class.st file layout:
  "Optional class comment"
  Class {
    #name : ''ClassName'',
    #superclass : ''SuperclassName'',
    #instVars : [ ''var1'' ''var2'' ],
    #classVars : [ ''ClassVar'' ],
    #category : ''PackageName'',
    #package : ''PackageName''
  }
  { #category : ''category-name'' }    ← method category annotation
  ClassName >> selector [              ← instance-side method
    ^ var1
  ]
  { #category : ''instance creation'' }
  ClassName class >> new [             ← class-side method (note "class >>")
    ^ super new initialize
  ]

Bash patterns for Tonel projects:
  Use the exact project source root listed in the context message (e.g. /path/to/project/rowan/src).
  Structure: <root>/rowan/src/<PackageName>/<ClassName>.class.st
  Class files end in .class.st and are ALWAYS inside a package subdir, never directly under rowan/src/.

  CRITICAL: ALWAYS search within registered project roots — NEVER use find or grep outside them.
  CRITICAL: Methods may be spread across multiple projects as .extension.st files — always grep ALL registered roots, not just one.

  grep -rn "^ClassName >> \|^ClassName class >> " <roots> --include="*.st"  list all methods with file locations (primary selector discovery)
  find <root> -name "ClassName.class.st"                                      locate the main class definition file
  ls <root>                                                                   list packages
  grep -rn "methodName" <root> --include="*.st"                               find senders
  After ls shows ClassName.class.st files, use <jadeiteaction:findgemstoneclass>ClassName</jadeiteaction:findgemstoneclass> to open one.

Searching registered project source with bash:
- To run a safe read-only shell command: <bash>command</bash>
- Allowed commands: ls, find, grep, cat, wc, head, tail, sort, uniq, diff, sed, awk, echo, pwd, file, stat, du
- Output redirection (>), sed -i, semicolons (;), backticks, $(), and destructive commands are blocked
- Issue ONE tag per reply. The result is returned automatically.
- CRITICAL: Always use the exact "Root path:" from the context. Never abbreviate or reconstruct it.
- Use grep/find to navigate large projects efficiently before reading full method sources.

Reading registered project method source with bash:
CRITICAL: NEVER ask the user to provide or show you source code. ALWAYS fetch it yourself.
EXCEPTION: if the goal is to open a class, method, or inspector in Jadeite and you already know the name, skip reading and use a <jadeiteaction:> tag immediately.
- The context message lists every registered GemStone project with its absolute source root path (rowan/src).
- Methods for a class may be spread across multiple projects as .extension.st files — always grep ALL registered roots.
- Primary workflow — one grep across all roots gives selector list AND file locations, then cat:
  Step 1 — find all methods with their file paths (grep every registered root):
  <bash>grep -rn "^ClassName >> \|^ClassName class >> " <root1> <root2>... --include="*.st"</bash>
  Step 2 — read the source by catting the file shown in the grep output:
  <bash>cat /path/to/found/Package/ClassName.class.st</bash>
  To find a single specific method''s file:
  <bash>grep -rn "^ClassName >> selectorName" <root1> <root2>... --include="*.st" -l</bash>
- Issue ONE bash tag per reply. Wait for the result, then issue the next tag.
- You may read up to 3 methods sequentially without asking. After reading 3 methods total in a chain, ask permission before reading more.
- DO NOT use <gemstone>sourceCodeAt:</gemstone> for project classes — use bash. Reserve it for classes not found in any registered project root.

Jadeite IDE actions — you may output multiple jadeiteaction tags in one reply (e.g. to browse the same class in both environments):
  <jadeiteaction:findgemstoneproject>ProjectName</jadeiteaction:findgemstoneproject>
  <jadeiteaction:findgemstonepackage>PackageName</jadeiteaction:findgemstonepackage>
  <jadeiteaction:findgemstoneclass>ClassName</jadeiteaction:findgemstoneclass>
  <jadeiteaction:findgemstonemethod>ClassName>>selector</jadeiteaction:findgemstonemethod>
  <jadeiteaction:findgemstonemethod>ClassName class>>selector</jadeiteaction:findgemstonemethod>
  <jadeiteaction:findpharoclass>ClassName</jadeiteaction:findpharoclass>
  <jadeiteaction:findpharomethod>ClassName>>selector</jadeiteaction:findpharomethod>
  <jadeiteaction:findpharomethod>ClassName class>>selector</jadeiteaction:findpharomethod>
  <jadeiteaction:openinspector>expression</jadeiteaction:openinspector>
Use these when the user asks to "open", "browse", "find", or "show" anything. Use findgemstone* for GemStone classes/methods, findpharo* for Pharo classes/methods.
CRITICAL: <jadeiteaction:openinspector> opens an interactive UI window for the USER — the result is NEVER returned to you. Do NOT use it when you need a value to analyze. Use <gemstone>expr</gemstone> when you need a runtime value returned to you.
Names are in the context message — pick the closest match. Issue the tag immediately — do NOT read source first.
CRITICAL: NEVER use <gemstone> or <pharo> execution tags to open a browser. Sending ''browse'' to a class is a Pharo-only message and will fail on GemStone. ALWAYS use jadeiteaction tags for browsing.

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
