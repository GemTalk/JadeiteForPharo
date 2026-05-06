"
JadeiteAIHttpAdapter — abstract base for LLM HTTP adapters.
Subclass and implement #sendConversation: for each provider.
Dependency-inject a subclass instance into JadeiteAIChatPresenter for testing (use JadeiteAIMockAdapter).
"
Class {
	#name : 'JadeiteAIHttpAdapter',
	#superclass : 'Object',
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'testing' }
JadeiteAIHttpAdapter >> isAvailable [

	^ true
]

{ #category : 'api' }
JadeiteAIHttpAdapter >> sendConversation: aJadeiteAIChatConversation [
	"Send aJadeiteAIChatConversation to the LLM and return the assistant reply as a String.
	 Raise an Error on network failure or non-2xx response."

	^ self subclassResponsibility
]

{ #category : 'api' }
JadeiteAIHttpAdapter >> sendConversationStep: aJadeiteAIChatConversation [
	"Agent-loop iteration send — subclasses should override to omit the system prompt
	 and save context-window tokens. Default falls back to the full send."

	^ self sendConversation: aJadeiteAIChatConversation
]

{ #category : 'lifecycle' }
JadeiteAIHttpAdapter >> unsubscribe [
	"No-op. Spec 2 calls unsubscribe on all presenter instance variables during teardown."
]
