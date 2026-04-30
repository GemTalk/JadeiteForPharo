"
JadeiteAIMockAdapter — test double for JadeiteAIHttpAdapter.
Inject into JadeiteAIChatPresenter to avoid real HTTP calls in tests.

  adapter := JadeiteAIMockAdapter returning: 'Hello from mock'.
  presenter adapter: adapter.
"
Class {
	#name : 'JadeiteAIMockAdapter',
	#superclass : 'JadeiteAIHttpAdapter',
	#instVars : [
		'cannedReply',
		'delayMilliseconds',
		'lastConversationReceived'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'instance creation' }
JadeiteAIMockAdapter class >> returning: aString [

	^ self new
		  cannedReply: aString;
		  yourself
]

{ #category : 'instance creation' }
JadeiteAIMockAdapter class >> returningAfterDelay: milliseconds reply: aString [
	"Use to test that the UI is not blocked during a slow response."

	^ self new
		  cannedReply: aString;
		  delayMilliseconds: milliseconds;
		  yourself
]

{ #category : 'accessing' }
JadeiteAIMockAdapter >> cannedReply [

	^ cannedReply
]

{ #category : 'accessing' }
JadeiteAIMockAdapter >> cannedReply: aString [

	cannedReply := aString
]

{ #category : 'accessing' }
JadeiteAIMockAdapter >> delayMilliseconds [

	^ delayMilliseconds
]

{ #category : 'accessing' }
JadeiteAIMockAdapter >> delayMilliseconds: anInteger [

	delayMilliseconds := anInteger
]

{ #category : 'initialization' }
JadeiteAIMockAdapter >> initialize [

	cannedReply := 'Mock reply'.
	delayMilliseconds := 0
]

{ #category : 'accessing' }
JadeiteAIMockAdapter >> lastConversationReceived [

	^ lastConversationReceived
]

{ #category : 'api' }
JadeiteAIMockAdapter >> sendConversation: aConversation [

	lastConversationReceived := aConversation.
	delayMilliseconds > 0 ifTrue: [
		(Delay forMilliseconds: delayMilliseconds) wait ].
	^ cannedReply
]
