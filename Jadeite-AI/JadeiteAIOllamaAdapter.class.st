"
JadeiteAIOllamaAdapter — HTTP adapter for Ollama running on localhost.

Ollama is free, requires no account or API key, and runs entirely on your machine.
Install from https://ollama.com

Default model:  qwen2.5-coder:14b  (~9 GB, better instruction-following for multi-step queries)
Lighter model:  qwen2.5-coder:7b   (~5 GB, use on machines with less RAM)

Pull a model once with:  ollama pull qwen2.5-coder:14b
Switch model:            JadeiteAIOllamaAdapter forModel: 'qwen2.5-coder:7b'

JSON is built and parsed manually to avoid NeoJSON load-order issues.
"
Class {
	#name : 'JadeiteAIOllamaAdapter',
	#superclass : 'JadeiteAIHttpAdapter',
	#instVars : [
		'baseUrl',
		'model'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JadeiteAIOllamaAdapter class >> default [

	^ self new
]

{ #category : 'instance creation' }
JadeiteAIOllamaAdapter class >> forModel: aModelString [

	^ self new
		  model: aModelString;
		  yourself
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'building' }
JadeiteAIOllamaAdapter >> buildRequestBody: aConversation [
	"Build the JSON request body for the /chat/completions endpoint.
	 Written manually to avoid NeoJSON load-order issues."

	| ws first |
	ws := WriteStream on: String new.
	ws nextPutAll: '{"model":'.
	ws nextPutAll: (self jsonEncodeString: model).
	ws nextPutAll: ',"messages":['.
	first := true.
	aConversation toApiMessages do: [ :msg |
		first ifFalse: [ ws nextPut: $, ].
		first := false.
		ws nextPutAll: '{"role":'.
		ws nextPutAll: (self jsonEncodeString: (msg at: 'role')).
		ws nextPutAll: ',"content":'.
		ws nextPutAll: (self jsonEncodeString: (msg at: 'content')).
		ws nextPut: $} ].
	ws nextPutAll: '],"temperature":'.
	ws nextPutAll: aConversation temperature printString.
	ws nextPutAll: ',"max_tokens":'.
	ws nextPutAll: aConversation maxTokens printString.
	ws nextPutAll: ',"stream":false'.
	ws nextPut: $}.
	^ ws contents
]

{ #category : 'initialization' }
JadeiteAIOllamaAdapter >> initialize [

	baseUrl := 'http://localhost:11434/v1'.
	model := 'qwen2.5-coder:14b'
]

{ #category : 'json' }
JadeiteAIOllamaAdapter >> jsonEncodeString: aString [
	"Return aString as a JSON string literal including surrounding double-quotes.
	 Uses copyReplaceAll:with: for reliability. Backslash must be escaped first
	 so that the backslashes added by later steps are not double-escaped."

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
JadeiteAIOllamaAdapter >> model [

	^ model
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> model: aString [

	model := aString
]

{ #category : 'parsing' }
JadeiteAIOllamaAdapter >> normalizeAngleBrackets: aString [
	"Replace JSON Unicode escapes for < and > that some LLMs emit.
	 Handles both lowercase (<) and uppercase (<) variants.
	 Uses Character value: to avoid any source-encoding ambiguity."

	| backslashU lt gt s |
	backslashU := String with: (Character value: 92) with: $u.
	lt := String with: (Character value: 60).
	gt := String with: (Character value: 62).
	s := aString copyReplaceAll: backslashU , '003c' with: lt.
	s := s copyReplaceAll: backslashU , '003C' with: lt.
	s := s copyReplaceAll: backslashU , '003e' with: gt.
	s := s copyReplaceAll: backslashU , '003E' with: gt.
	^ s
]

{ #category : 'parsing' }
JadeiteAIOllamaAdapter >> parseResponse: responseString [
	"Extract the assistant content string from the Ollama JSON response.
	 Scans for the 'content' key and reads the JSON string value after it.
	 Written manually to avoid NeoJSON load-order issues."

	| idx content |
	(responseString includesSubstring: '"error":') ifTrue: [
		Error signal: 'Ollama error: ' , responseString ].
	idx := responseString indexOfSubCollection: '"content":' startingAt: 1 ifAbsent: [
		Error signal: 'No content key in Ollama response: ' , responseString ].
	idx := idx + 10. "skip past the 10-character content key"

	"skip optional whitespace"
	[ idx <= responseString size and: [ (responseString at: idx) isSeparator ] ]
		whileTrue: [ idx := idx + 1 ].

	(idx > responseString size or: [ (responseString at: idx) ~= $" ])
		ifTrue: [ Error signal: 'Expected string value for content key' ].
	idx := idx + 1. "skip opening quote"

	content := self readJsonStringFrom: responseString startingAt: idx.
	^ content
]

{ #category : 'parsing' }
JadeiteAIOllamaAdapter >> readJsonStringFrom: aString startingAt: startIndex [
	"Read a JSON string value starting at startIndex (after the opening quote).
	 Returns the unescaped string content.
	 Handles \\n \\r \\t \\\\ and \\uXXXX (e.g. \\u003c -> <)."

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
JadeiteAIOllamaAdapter >> sendConversation: aConversation [
	"POST to the local Ollama server and return the assistant reply string."

	| body responseString |
	body := self buildRequestBody: aConversation.
	body := body copyWithout: Character cr.
	body := body copyWithout: (Character value: 9).
	responseString := ZnClient new
		                  beOneShot;
		                  url: baseUrl , '/chat/completions';
		                  entity: (ZnStringEntity json: body);
		                  timeout: 120;
		                  post.
	"Some LLMs JSON-encode < and > as < / >.
	 Normalise before parsing so the agent-loop tag detection works."
	responseString := self normalizeAngleBrackets: responseString.
	^ self parseResponse: responseString
]
