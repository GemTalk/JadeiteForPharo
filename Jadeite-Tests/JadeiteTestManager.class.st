"
A unit test support manager used by Jadeite For Pharo to facilitate testing of dialogs, etc.

previousManager - system-wide manager replaced by JadeiteTestManager. 
previousManagerClass - If the previousManager is nil (for whatever reason), instantiate a new instance of this class to restore. 

Usage:
Unit tests should send this message during #setup. Then send #restore during #tearDown. 
JadeiteTestManager replacing: <current UI manager> 


"
Class {
	#name : 'JadeiteTestManager',
	#superclass : 'MorphicUIManager',
	#instVars : [
		'previousManager',
		'previousManagerClass'
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

{ #category : 'ui requests' }
JadeiteTestManager >> openComparisionFrom: targetMethodSource to: originalMethodSource belongingTo: aClass from: aChange [
	"to avoid abstract superclass display"

	^ super
		  openComparisionFrom: targetMethodSource
		  to: originalMethodSource
		  belongingTo: aClass
		  from: aChange
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
	previousManagerClass := aUIManager class.
	self beDefault
]

{ #category : 'window management' }
JadeiteTestManager >> restore [

	previousManager
		ifNil: [ previousManagerClass new beDefault ]
		ifNotNil: [ :manager | manager beDefault ].
	UIManager default == self ifTrue: [
		MorphicUIManager new beDefault "make absolutely sure it's not a test manager" ]
]
