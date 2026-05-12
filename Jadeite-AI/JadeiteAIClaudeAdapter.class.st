"
JadeiteAIClaudeAdapter — HTTP adapter for the Anthropic Claude API.

Requires an Anthropic API key set in the environment:
  export ANTHROPIC_API_KEY='sk-ant-...'

Default model: claude-sonnet-4-6

Switch model:  JadeiteAIClaudeAdapter forModel: 'claude-haiku-4-5-20251001'

The Anthropic messages API differs from the OpenAI-compatible format Ollama uses:
  - 'system' is a top-level field, not a message role
  - Response is content[0].text, not choices[0].message.content
  - Auth via x-api-key and anthropic-version headers

JSON is built and parsed manually to avoid NeoJSON load-order issues.
"
Class {
	#name : 'JadeiteAIClaudeAdapter',
	#superclass : 'JadeiteAIHttpAdapter',
	#instVars : [
		'model'
	],
	#classVars : [
		'ApiKey'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'accessing' }
JadeiteAIClaudeAdapter class >> apiKey [
	"Return the cached key, falling back to the environment variable."

	ApiKey ifNotNil: [ ^ ApiKey ].
	^ OSEnvironment current at: 'ANTHROPIC_API_KEY' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
JadeiteAIClaudeAdapter class >> apiKey: aString [

	ApiKey := aString
]

{ #category : 'instance creation' }
JadeiteAIClaudeAdapter class >> default [

	^ self new
]

{ #category : 'instance creation' }
JadeiteAIClaudeAdapter class >> forModel: aModelString [

	^ self new
		  model: aModelString;
		  yourself
]

{ #category : 'accessing' }
JadeiteAIClaudeAdapter class >> requestApiKey [
	"Prompt the user to enter their API key and cache it for the session.
	 Returns the key string, or nil if the user cancelled."

	| key |
	key := UIManager default
		       request: 'Enter your Anthropic API key:'
		       initialAnswer: ''.
	(key isNil or: [ key trimBlanks isEmpty ]) ifTrue: [ ^ nil ].
	ApiKey := key trimBlanks.
	^ ApiKey
]

{ #category : 'accessing' }
JadeiteAIClaudeAdapter >> apiKey [

	^ self class apiKey
]

{ #category : 'building' }
JadeiteAIClaudeAdapter >> buildMessagesJson: messages [

	| ws first |
	ws := WriteStream on: String new.
	ws nextPut: $[.
	first := true.
	messages do: [ :msg |
		first ifFalse: [ ws nextPut: $, ].
		first := false.
		ws nextPutAll: '{"role":'.
		ws nextPutAll: (self jsonEncodeString: (msg at: 'role')).
		ws nextPutAll: ',"content":'.
		ws nextPutAll: (self jsonEncodeString: (msg at: 'content')).
		ws nextPut: $} ].
	ws nextPut: $].
	^ ws contents
]

{ #category : 'building' }
JadeiteAIClaudeAdapter >> buildMessagesJsonWithCache: messages [
	"Build messages JSON, marking the first user message for prompt caching.
	 The first user message is typically the class/project context block, which is
	 stable within a conversation and worth caching.
	 Only caches when there are 2+ messages so the live query is never cached."

	| ws |
	ws := WriteStream on: String new.
	ws nextPut: $[.
	messages doWithIndex: [ :msg :i |
		i > 1 ifTrue: [ ws nextPut: $, ].
		ws nextPutAll: '{"role":'.
		ws nextPutAll: (self jsonEncodeString: (msg at: 'role')).
		ws nextPutAll: ',"content":'.
		(i = 1 and: [ messages size > 1 and: [ (msg at: 'role') = 'user' ] ])
			ifTrue: [
				ws nextPutAll: '[{"type":"text","text":'.
				ws nextPutAll: (self jsonEncodeString: (msg at: 'content')).
				ws nextPutAll: ',"cache_control":{"type":"ephemeral"}}]' ]
			ifFalse: [
				ws nextPutAll: (self jsonEncodeString: (msg at: 'content')) ].
		ws nextPut: $} ].
	ws nextPut: $].
	^ ws contents
]

{ #category : 'building' }
JadeiteAIClaudeAdapter >> buildRequestBody: aConversation [
	"Anthropic format with prompt caching on the system prompt and context message.
	 System is sent as an array so cache_control can be attached to it."

	| ws messages |
	messages := aConversation toApiMessages
		            reject: [ :m | (m at: 'role') = 'system' ].
	ws := WriteStream on: String new.
	ws nextPutAll: '{"model":'.
	ws nextPutAll: (self jsonEncodeString: model).
	ws nextPutAll: ',"max_tokens":8192,"system":[{"type":"text","text":'.
	ws nextPutAll: (self jsonEncodeString: aConversation systemPrompt).
	ws nextPutAll: ',"cache_control":{"type":"ephemeral"}}]'.
	ws nextPutAll: ',"messages":'.
	ws nextPutAll: (self buildMessagesJsonWithCache: messages).
	ws nextPut: $}.
	^ ws contents
]

{ #category : 'building' }
JadeiteAIClaudeAdapter >> buildRequestBodyNoSystem: aConversation [
	"Agent-loop version: omit system so it is not repeated each iteration."

	| ws messages |
	messages := aConversation toApiMessagesNoSystem.
	ws := WriteStream on: String new.
	ws nextPutAll: '{"model":'.
	ws nextPutAll: (self jsonEncodeString: model).
	ws nextPutAll: ',"max_tokens":8192,"messages":'.
	ws nextPutAll: (self buildMessagesJson: messages).
	ws nextPut: $}.
	^ ws contents
]

{ #category : 'initialization' }
JadeiteAIClaudeAdapter >> initialize [

	model := 'claude-sonnet-4-6'
]

{ #category : 'testing' }
JadeiteAIClaudeAdapter >> isAvailable [

	| key |
	key := self apiKey.
	^ key notNil and: [ key notEmpty ]
]

{ #category : 'json' }
JadeiteAIClaudeAdapter >> jsonEncodeString: aString [
	"Return aString as a JSON string literal including surrounding double-quotes.
	 Backslash must be escaped first so later steps do not double-escape it."

	| s bs dq |
	bs := String with: $\.
	dq := String with: (Character value: 34).
	s := aString copyReplaceAll: bs with: bs , bs.
	s := s copyReplaceAll: dq with: bs , dq.
	s := s copyWithout: Character cr.
	s := s copyReplaceAll: (String with: (Character value: 10)) with: bs , 'n'.
	s := s copyReplaceAll: (String with: (Character value: 9))  with: bs , 't'.
	^ dq , s , dq
]

{ #category : 'accessing' }
JadeiteAIClaudeAdapter >> model [

	^ model
]

{ #category : 'accessing' }
JadeiteAIClaudeAdapter >> model: aString [

	model := aString
]

{ #category : 'parsing' }
JadeiteAIClaudeAdapter >> parseResponse: responseString [
	"Extract the text from Claude's response: {content: [{type:'text', text:'...'}]}"

	| idx |
	((responseString includesSubstring: '"type":"error"')
		or: [ responseString includesSubstring: '"type": "error"' ])
		ifTrue: [ Error signal: 'Claude error: ' , responseString ].
	idx := responseString indexOfSubCollection: '"text":' startingAt: 1 ifAbsent: [
		Error signal: 'No text key in Claude response: ' , responseString ].
	idx := idx + 7.
	[ idx <= responseString size and: [ (responseString at: idx) isSeparator ] ]
		whileTrue: [ idx := idx + 1 ].
	(idx > responseString size or: [ (responseString at: idx) ~= $" ])
		ifTrue: [ Error signal: 'Expected string value for text key' ].
	idx := idx + 1.
	^ self readJsonStringFrom: responseString startingAt: idx
]

{ #category : 'api' }
JadeiteAIClaudeAdapter >> postBody: aBody [
	"POST to the Anthropic messages endpoint and return the parsed reply string."

	| body responseString |
	body := aBody copyWithout: Character cr.
	body := body copyWithout: (Character value: 9).
	responseString := ZnClient new
		                  beOneShot;
		                  url: 'https://api.anthropic.com/v1/messages';
		                  headerAt: 'x-api-key' put: self apiKey;
		                  headerAt: 'anthropic-version' put: '2023-06-01';
		                  headerAt: 'anthropic-beta' put: 'prompt-caching-2024-07-31';
		                  entity: (ZnStringEntity json: body);
		                  timeout: 300;
		                  post.
	^ self parseResponse: responseString
]

{ #category : 'json' }
JadeiteAIClaudeAdapter >> readJsonStringFrom: aString startingAt: startIndex [
	"Read a JSON string value starting at startIndex (after the opening quote).
	 Returns the unescaped string content. Handles \\n \\r \\t \\\\ and \\uXXXX."

	| ws idx c |
	ws := WriteStream on: String new.
	idx := startIndex.
	[ idx <= aString size and: [ (aString at: idx) ~= $" ] ] whileTrue: [
		c := aString at: idx.
		c = $\ ifTrue: [
			idx := idx + 1.
			idx <= aString size ifTrue: [
				c := aString at: idx.
				c = $n ifTrue: [ ws nextPut: (Character value: 10) ]
				ifFalse: [ c = $r ifTrue: [ ws nextPut: (Character value: 13) ]
				ifFalse: [ c = $t ifTrue: [ ws nextPut: (Character value: 9) ]
				ifFalse: [ c = $u ifTrue: [
					idx + 4 <= aString size ifTrue: [
						| cp |
						cp := 0.
						1 to: 4 do: [ :i |
							cp := cp * 16 + (aString at: idx + i) digitValue ].
						ws nextPut: (Character value: cp).
						idx := idx + 4 ] ]
				ifFalse: [ ws nextPut: c ] ] ] ] ] ]
		ifFalse: [ ws nextPut: c ].
		idx := idx + 1 ].
	^ ws contents
]

{ #category : 'api' }
JadeiteAIClaudeAdapter >> sendConversation: aConversation [

	^ self postBody: (self buildRequestBody: aConversation)
]

{ #category : 'api' }
JadeiteAIClaudeAdapter >> sendConversationStep: aConversation [

	^ self postBody: (self buildRequestBodyNoSystem: aConversation)
]
