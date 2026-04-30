"
JAIHttpAdapter — abstract base for LLM HTTP adapters.
Subclass and implement #sendConversation: for each provider.
Dependency-inject a subclass instance into JAIChatPresenter for testing (use JAIMockAdapter).
"
Class {
	#name : 'JAIHttpAdapter',
	#superclass : 'Object',
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'testing' }
JAIHttpAdapter >> isAvailable [

	^ true
]

{ #category : 'lifecycle' }
JAIHttpAdapter >> unsubscribe [
	"No-op. Spec 2 calls unsubscribe on all presenter instance variables during teardown."
]

{ #category : 'api' }
JAIHttpAdapter >> sendConversation: aJAIChatConversation [
	"Send aJAIChatConversation to the LLM and return the assistant reply as a String.
	 Raise an Error on network failure or non-2xx response."

	^ self subclassResponsibility
]
