"
JAIMockAdapter — test double for JAIHttpAdapter.
Inject into JAIChatPresenter to avoid real HTTP calls in tests.

  adapter := JAIMockAdapter returning: 'Hello from mock'.
  presenter adapter: adapter.
"
Class {
	#name : 'JAIMockAdapter',
	#superclass : 'JAIHttpAdapter',
	#instVars : [
		'cannedReply',
		'delayMilliseconds',
		'lastConversationReceived'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JAIMockAdapter class >> returning: aString [

	^ self new
		  cannedReply: aString;
		  yourself
]

{ #category : 'instance creation' }
JAIMockAdapter class >> returningAfterDelay: milliseconds reply: aString [
	"Use to test that the UI is not blocked during a slow response."

	^ self new
		  cannedReply: aString;
		  delayMilliseconds: milliseconds;
		  yourself
]

{ #category : 'accessing' }
JAIMockAdapter >> cannedReply [

	^ cannedReply
]

{ #category : 'accessing' }
JAIMockAdapter >> cannedReply: aString [

	cannedReply := aString
]

{ #category : 'accessing' }
JAIMockAdapter >> delayMilliseconds [

	^ delayMilliseconds
]

{ #category : 'accessing' }
JAIMockAdapter >> delayMilliseconds: anInteger [

	delayMilliseconds := anInteger
]

{ #category : 'initialization' }
JAIMockAdapter >> initialize [

	cannedReply := 'Mock reply'.
	delayMilliseconds := 0
]

{ #category : 'accessing' }
JAIMockAdapter >> lastConversationReceived [

	^ lastConversationReceived
]

{ #category : 'api' }
JAIMockAdapter >> sendConversation: aConversation [

	lastConversationReceived := aConversation.
	delayMilliseconds > 0 ifTrue: [
		(Delay forMilliseconds: delayMilliseconds) wait ].
	^ cannedReply
]
