Class {
	#name : 'JadeiteTestManager',
	#superclass : 'MorphicUIManager',
	#instVars : [
		'previousManager'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'instance creation' }
JadeiteTestManager class >> replacing: aUIManager [

	^ self new replacing: aUIManager
]

{ #category : 'ui TEasilyThemed' }
JadeiteTestManager >> alert: aStringOrText [

	(ProvideAnswerNotification signal: aStringOrText) ifNotNil: [ :answer |
		^ answer ].
	^ super alert: aStringOrText
]

{ #category : 'accessing' }
JadeiteTestManager >> previousManager [

	^ previousManager
]

{ #category : 'accessing' }
JadeiteTestManager >> previousManager: anObject [

	previousManager := anObject
]

{ #category : 'instance creation' }
JadeiteTestManager >> replacing: aUIManager [

	previousManager := aUIManager.
	self beDefault
]
