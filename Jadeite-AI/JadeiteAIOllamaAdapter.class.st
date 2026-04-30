"
JadeiteAIOllamaAdapter — HTTP adapter for Ollama running on localhost.

Ollama is free, requires no account or API key, and runs entirely on your machine.
Install from https://ollama.com

Default model:  qwen2.5-coder:7b  (~5 GB, good at Smalltalk/GemStone code analysis)
Lighter model:  llama3.2  (~2 GB, use on machines with less RAM)

Pull a model once with:  ollama pull qwen2.5-coder:7b
Switch model:            JadeiteAIOllamaAdapter forModel: 'llama3.2'

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

{ #category : 'initialization' }
JadeiteAIOllamaAdapter >> initialize [

	baseUrl := 'http://localhost:11434/v1'.
	model := 'qwen2.5-coder:7b'
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> model [

	^ model
]

{ #category : 'accessing' }
JadeiteAIOllamaAdapter >> model: aString [

	model := aString
]

{ #category : 'json' }
JadeiteAIOllamaAdapter >> jsonEncodeString: aString [
	"Return aString as a JSON string literal including surrounding double-quotes.
	 Escapes backslash, double-quote, and common control characters."

	| ws v escape |
	ws := WriteStream on: String new.
	ws nextPut: $".
	aString do: [ :c |
		v := c value.
		escape := nil.
		v = 34 ifTrue: [ escape := '\"' ].   "double-quote"
		v = 92 ifTrue: [ escape := '\\' ].   "backslash"
		v = 10 ifTrue: [ escape := '\n' ].   "newline"
		v = 13 ifTrue: [ escape := '' ].   "strip CR - prevents invalid JSON on CRLF content"
		v =  9 ifTrue: [ escape := '\t' ].   "tab"
		escape isNil
			ifTrue:  [ ws nextPut: c ]
			ifFalse: [ ws nextPutAll: escape ] ].
	ws nextPut: $".
	^ ws contents
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
	ws nextPut: $}.
	^ ws contents
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
	 Returns the unescaped string content."

	| ws idx c |
	ws := WriteStream on: String new.
	idx := startIndex.
	[ idx <= aString size and: [ (aString at: idx) ~= $" ] ] whileTrue: [
		c := aString at: idx.
		c = $\ ifTrue: [
			idx := idx + 1.
			idx <= aString size ifTrue: [
				c := aString at: idx.
				c = $n ifTrue:  [ ws nextPut: (Character value: 10) ] ifFalse: [
				c = $r ifTrue:  [ ws nextPut: (Character value: 13) ] ifFalse: [
				c = $t ifTrue:  [ ws nextPut: (Character value: 9)  ] ifFalse: [
				ws nextPut: c ] ] ] ] ]
		ifFalse: [
			ws nextPut: c ].
		idx := idx + 1 ].
	^ ws contents
]

{ #category : 'api' }
JadeiteAIOllamaAdapter >> sendConversation: aConversation [
	"POST to the local Ollama server and return the assistant reply string."

	| body responseString |
	body := self buildRequestBody: aConversation.
	body := body copyWithout: Character cr.
	responseString := ZnClient new
		                  beOneShot;
		                  url: baseUrl , '/chat/completions';
		                  entity: (ZnStringEntity json: body);
		                  timeout: 120;
		                  post.
	^ self parseResponse: responseString
]
