"
JAIOllamaAdapter — HTTP adapter for Ollama running on localhost.

Ollama is free, requires no account or API key, and runs entirely on your machine.
Install from https://ollama.com

Default model:  qwen2.5-coder:7b  (~5 GB, good at Smalltalk/GemStone code analysis)
Lighter model:  llama3.2  (~2 GB, use on machines with less RAM)

Pull a model once with:  ollama pull qwen2.5-coder:7b
Switch model:            JAIOllamaAdapter forModel: 'llama3.2'
"
Class {
	#name : 'JAIOllamaAdapter',
	#superclass : 'JAIHttpAdapter',
	#instVars : [
		'baseUrl',
		'model'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JAIOllamaAdapter class >> default [

	^ self new
]

{ #category : 'instance creation' }
JAIOllamaAdapter class >> forModel: aModelString [

	^ self new
		  model: aModelString;
		  yourself
]

{ #category : 'initialization' }
JAIOllamaAdapter >> initialize [

	baseUrl := 'http://localhost:11434/v1'.
	model := 'qwen2.5-coder:7b'
]

{ #category : 'accessing' }
JAIOllamaAdapter >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
JAIOllamaAdapter >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'accessing' }
JAIOllamaAdapter >> model [

	^ model
]

{ #category : 'accessing' }
JAIOllamaAdapter >> model: aString [

	model := aString
]

{ #category : 'building' }
JAIOllamaAdapter >> buildRequestBody: aConversation [

	| payload |
	payload := OrderedDictionary new.
	payload at: 'model' put: model.
	payload at: 'messages' put: aConversation toApiMessages asArray.
	payload at: 'temperature' put: aConversation temperature.
	payload at: 'max_tokens' put: aConversation maxTokens.
	^ NeoJSONWriter toString: payload
]

{ #category : 'parsing' }
JAIOllamaAdapter >> parseResponse: responseString [

	| json choices message |
	json := NeoJSONReader fromString: responseString.
	choices := json at: 'choices' ifAbsent: [
		Error signal: 'Unexpected response — no choices key: ' , responseString ].
	choices isEmpty ifTrue: [ Error signal: 'Ollama returned empty choices array' ].
	message := choices first at: 'message' ifAbsent: [
		Error signal: 'Unexpected response — no message key' ].
	^ message at: 'content' ifAbsent: [ '' ]
]

{ #category : 'api' }
JAIOllamaAdapter >> sendConversation: aConversation [
	"POST to the local Ollama server and return the assistant reply string."

	| body responseString |
	body := self buildRequestBody: aConversation.
	responseString := ZnClient new
		                  beOneShot;
		                  url: baseUrl , '/chat/completions';
		                  entity: (ZnStringEntity json: body);
		                  timeout: 120;
		                  post.
	^ self parseResponse: responseString
]
