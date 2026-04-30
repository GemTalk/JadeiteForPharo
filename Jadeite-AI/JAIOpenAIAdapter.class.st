"
JAIOpenAIAdapter — HTTP adapter for Ollama's OpenAI-compatible chat completions API.

Ollama exposes the same REST interface as OpenAI on localhost:11434/v1,
so this adapter works for both without any code changes.

Default model:  qwen2.5-coder:7b  (~5 GB, good at Smalltalk/GemStone code analysis)
Lighter model:  llama3.2  (~2 GB, use on machines with less RAM)

Pull a model once with:  ollama pull qwen2.5-coder:7b
Switch model:   JAIOpenAIAdapter forOllamaWithModel: 'llama3.2'
"
Class {
	#name : 'JAIOpenAIAdapter',
	#superclass : 'JAIHttpAdapter',
	#instVars : [
		'apiKey',
		'baseUrl',
		'model'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JAIOpenAIAdapter class >> forOllama [

	^ self new
		  apiKey: 'ollama';
		  baseUrl: 'http://localhost:11434/v1';
		  model: 'qwen2.5-coder:7b';
		  yourself
]

{ #category : 'instance creation' }
JAIOpenAIAdapter class >> forOllamaWithModel: aModelString [

	^ self new
		  apiKey: 'ollama';
		  baseUrl: 'http://localhost:11434/v1';
		  model: aModelString;
		  yourself
]

{ #category : 'initialization' }
JAIOpenAIAdapter >> initialize [

	baseUrl := 'http://localhost:11434/v1'.
	apiKey := 'ollama'.
	model := 'llama3.2'
]

{ #category : 'accessing' }
JAIOpenAIAdapter >> apiKey [

	^ apiKey
]

{ #category : 'accessing' }
JAIOpenAIAdapter >> apiKey: aString [

	apiKey := aString
]

{ #category : 'accessing' }
JAIOpenAIAdapter >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
JAIOpenAIAdapter >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'accessing' }
JAIOpenAIAdapter >> model [

	^ model
]

{ #category : 'accessing' }
JAIOpenAIAdapter >> model: aString [

	model := aString
]

{ #category : 'building' }
JAIOpenAIAdapter >> buildRequestBody: aConversation [
	"Return a JSON string for the /chat/completions endpoint."

	| payload |
	payload := OrderedDictionary new.
	payload at: 'model' put: model.
	payload at: 'messages' put: aConversation toApiMessages asArray.
	payload at: 'temperature' put: aConversation temperature.
	payload at: 'max_tokens' put: aConversation maxTokens.
	^ NeoJSONWriter toString: payload
]

{ #category : 'parsing' }
JAIOpenAIAdapter >> parseResponse: responseString [
	"Extract the assistant content string from the JSON response."

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
JAIOpenAIAdapter >> sendConversation: aConversation [
	"POST to Ollama and return the assistant reply string.
	 Uses ZnClient (Zinc HTTP, built into Pharo)."

	| body responseString |
	body := self buildRequestBody: aConversation.
	responseString := ZnClient new
		                  beOneShot;
		                  url: baseUrl , '/chat/completions';
		                  headerAt: 'Authorization' put: 'Bearer ' , apiKey;
		                  entity: (ZnStringEntity json: body);
		                  timeout: 120;
		                  post.
	^ self parseResponse: responseString
]
