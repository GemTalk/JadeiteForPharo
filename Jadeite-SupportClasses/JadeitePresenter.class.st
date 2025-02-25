Class {
	#name : 'JadeitePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'waitIndicator'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'actions' }
JadeitePresenter >> abortTransaction [

	^self application abortTransaction
]

{ #category : 'testing' }
JadeitePresenter >> canDiscardSelectionEdits [
	"Let subclasses handle. If we get here, because of
	an unhandled selection change, just assume it's ok
	to disregard selection edits"

	^ true
]

{ #category : 'initialization' }
JadeitePresenter >> caption: aString [

	self owner title: aString
]

{ #category : 'actions' }
JadeitePresenter >> commitTransaction [

	^self application commitTransaction
]

{ #category : 'initialization' }
JadeitePresenter >> initializeWaitPresenter [

	| box |
	box := SpBoxLayout newVertical.
	waitIndicator := self newProgressBar.
	waitIndicator indeterminate.
	box add: waitIndicator withConstraints: [ :constraints |
		constraints height: 3 * StandardFonts defaultFont pointSize ].
	self showNotWait.
	^ box
]

{ #category : 'actions' }
JadeitePresenter >> preUpdate: services [
]

{ #category : 'registration' }
JadeitePresenter >> registerPresentersForUpdates [
]

{ #category : 'constants' }
JadeitePresenter >> shellName [

	self subclassResponsibility

]

{ #category : 'waiting' }
JadeitePresenter >> showNotWait [

	waitIndicator ifNotNil: [ :indicator | indicator hide ].
	WorldMorph doOneCycle
]

{ #category : 'waiting' }
JadeitePresenter >> showWait [

	JadeitePreferences showProgressBar ifTrue: [
		waitIndicator ifNotNil: [ :indicator | indicator show ] ].
	WorldMorph doOneCycle
]

{ #category : 'initialization' }
JadeitePresenter >> updateCaption [
	self caption: (GciSession current titleBarFor: self shellName)
]

{ #category : 'initialization' }
JadeitePresenter >> updatePresenter [

	super updatePresenter.
	self registerPresentersForUpdates 
]

{ #category : 'accessing' }
JadeitePresenter >> view [

	^self
]
