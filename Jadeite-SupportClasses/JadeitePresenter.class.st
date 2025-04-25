Class {
	#name : 'JadeitePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'waitIndicator',
		'stopWaitButton'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'actions' }
JadeitePresenter >> abortTransaction [

	^self application abortTransaction
]

{ #category : 'initialization' }
JadeitePresenter >> addWindowBorderStyle: aString [

	self window addStyle: aString
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
	"for whatever reason, the progress bar won't stretch to full width unless it's in it's own vertical box. Weird."

	| box horizontalBox |
	horizontalBox := SpBoxLayout newHorizontal.
	box := SpBoxLayout newVertical.
	waitIndicator := self newProgressBar.
	waitIndicator indeterminate.
	box add: waitIndicator withConstraints: [ :constraints |
		constraints height: 3 * StandardFonts defaultFont pointSize ].
	self showNotWait.
	horizontalBox add: box.
	stopWaitButton := self newButton
		                  icon: (self iconNamed: #halt);
		                  help: 'Stop Progress Bar';
		                  action: [
			                  RowanServiceUpdater current stopProgressBar ].
	horizontalBox add: stopWaitButton withConstraints: [ :constraints |
		constraints
			height: 3 * StandardFonts defaultFont pointSize;
			width: 25 ].
	^ horizontalBox
]

{ #category : 'actions' }
JadeitePresenter >> preUpdate: services [
]

{ #category : 'registration' }
JadeitePresenter >> registerPresentersForUpdates [
]

{ #category : 'initialization' }
JadeitePresenter >> resetCurrentPackageFor: aService [
]

{ #category : 'initialization' }
JadeitePresenter >> resetCurrentProjectFor: aService [
]

{ #category : 'find' }
JadeitePresenter >> resumeSelectionEvents [

	
]

{ #category : 'constants' }
JadeitePresenter >> shellName [

	self subclassResponsibility

]

{ #category : 'waiting' }
JadeitePresenter >> showNotWait [

	waitIndicator ifNotNil: [ :indicator | indicator hide ].
	stopWaitButton ifNotNil: [ :button | button hide ]
]

{ #category : 'waiting' }
JadeitePresenter >> showWait [

	JadeitePreferences showProgressBar ifFalse: [ ^ self ].
	waitIndicator ifNotNil: [ :indicator | indicator show ].
	stopWaitButton ifNotNil: [ :button | button show ].
]

{ #category : 'find' }
JadeitePresenter >> suspendSelectionEvents [

	
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
