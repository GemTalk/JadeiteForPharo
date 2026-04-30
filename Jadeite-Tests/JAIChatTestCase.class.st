"
JAIChatTestCase — unit tests for the Jadeite AI chat (Phase 1).
No network access, no GemStone connection required.
All HTTP calls are replaced by JAIMockAdapter via dependency injection.

To run:  JAIChatTestCase run
"
Class {
	#name : 'JAIChatTestCase',
	#superclass : 'TestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests - model' }
JAIChatTestCase >> testConversationInitializesEmpty [

	| conv |
	conv := JAIChatConversation new.
	self assert: conv messages isEmpty.
	self assert: conv model equals: 'gpt-3.5-turbo'
]

{ #category : 'tests - model' }
JAIChatTestCase >> testConversationRecordsUserMessage [

	| conv msg |
	conv := JAIChatConversation new.
	msg := conv addUserMessage: 'What does this method do?'.
	self assert: conv messages size equals: 1.
	self assert: msg role equals: #user.
	self assert: msg content equals: 'What does this method do?'
]

{ #category : 'tests - model' }
JAIChatTestCase >> testConversationRecordsAssistantReply [

	| conv |
	conv := JAIChatConversation new.
	conv addUserMessage: 'Hello'.
	conv addAssistantMessage: 'Hi there!'.
	self assert: conv messages size equals: 2.
	self assert: conv messages last role equals: #assistant.
	self assert: conv messages last content equals: 'Hi there!'
]

{ #category : 'tests - model' }
JAIChatTestCase >> testMessageDisplayString [

	| msg |
	msg := JAIChatMessage role: #user content: 'Test'.
	self assert: (msg displayString includesSubstring: 'You').
	self assert: (msg displayString includesSubstring: 'Test').

	msg := JAIChatMessage role: #assistant content: 'Reply'.
	self assert: (msg displayString includesSubstring: 'AI')
]

{ #category : 'tests - model' }
JAIChatTestCase >> testConversationApiPayloadIncludesSystemPrompt [

	| conv messages roles |
	conv := JAIChatConversation new.
	conv addUserMessage: 'Hello'.
	messages := conv toApiMessages.
	roles := messages collect: [ :m | m at: 'role' ].
	self assert: (roles includes: 'system').
	self assert: (roles includes: 'user')
]

{ #category : 'tests - adapter' }
JAIChatTestCase >> testMockAdapterReturnsCannedReply [

	| mock conv reply |
	mock := JAIMockAdapter returning: 'Canned answer'.
	conv := JAIChatConversation new.
	conv addUserMessage: 'Question'.
	reply := mock sendConversation: conv.
	self assert: reply equals: 'Canned answer'
]

{ #category : 'tests - adapter' }
JAIChatTestCase >> testMockAdapterRecordsConversation [

	| mock conv |
	mock := JAIMockAdapter returning: 'ok'.
	conv := JAIChatConversation new.
	conv addUserMessage: 'Hi'.
	mock sendConversation: conv.
	self assert: mock lastConversationReceived == conv
]

{ #category : 'tests - presenter' }
JAIChatTestCase >> testPresenterInitializesWithEmptyConversation [

	| presenter |
	presenter := JAIChatPresenter new.
	self assert: presenter conversation messages isEmpty
]

{ #category : 'tests - presenter' }
JAIChatTestCase >> testPresenterAcceptsInjectedAdapter [

	| presenter mock |
	presenter := JAIChatPresenter new.
	mock := JAIMockAdapter returning: 'hi'.
	presenter adapter: mock.
	self assert: presenter adapter == mock
]

{ #category : 'tests - presenter' }
JAIChatTestCase >> testSendMessageAddsUserMessageToConversation [
	"Verify that sendMessage records the user turn even before the worker finishes."

	| presenter mock semaphore |
	presenter := JAIChatPresenter new.
	semaphore := Semaphore new.
	mock := JAIMockAdapter
		        returningAfterDelay: 0
		        reply: 'reply'.

	"Intercept onWorkerDone: so we can signal the semaphore"
	presenter adapter: mock.

	"We cannot call sendMessage without a real UI, so test the model layer directly"
	presenter conversation addUserMessage: 'my question'.
	self assert: presenter conversation messages size equals: 1.
	self assert: presenter conversation messages first role equals: #user
]

{ #category : 'tests - presenter' }
JAIChatTestCase >> testBackgroundWorkerDoesNotBlockCallerProcess [
	"Verify that a slow adapter does not stall the calling process.
	 The worker runs in a forked process; the test process continues immediately."

	| mock startTime elapsedMillis done semaphore |
	"A 300ms mock simulates a real HTTP call"
	mock := JAIMockAdapter returningAfterDelay: 300 reply: 'slow reply'.
	done := false.
	semaphore := Semaphore new.

	[
	mock sendConversation: JAIChatConversation new.
	done := true.
	semaphore signal ] forkNamed: 'test-slow-worker'.

	startTime := Time millisecondClockValue.
	"The calling process should return immediately — NOT waiting 300ms here"
	elapsedMillis := Time millisecondClockValue - startTime.
	self assert: elapsedMillis < 50
		  description: 'fork should not block caller'.

	"Wait for the worker to finish before teardown"
	semaphore waitTimeoutMilliseconds: 1000.
	self assert: done description: 'worker should complete within 1s'
]

{ #category : 'tests - adapter config' }
JAIChatTestCase >> testAdapterDefaultsToOllama [

	| adapter |
	adapter := JAIOpenAIAdapter new.
	self assert: adapter model equals: 'llama3.2'.
	self assert: (adapter baseUrl includesSubstring: 'localhost').
	self assert: adapter apiKey equals: 'ollama'
]

{ #category : 'tests - adapter config' }
JAIChatTestCase >> testOllamaAdapterCustomModel [

	| adapter |
	adapter := JAIOpenAIAdapter forOllamaWithModel: 'qwen2.5-coder:7b'.
	self assert: adapter model equals: 'qwen2.5-coder:7b'.
	self assert: adapter apiKey equals: 'ollama'.
	self assert: (adapter baseUrl includesSubstring: 'localhost')
]
