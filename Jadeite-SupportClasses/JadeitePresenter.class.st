Class {
	#name : 'JadeitePresenter',
	#superclass : 'SpPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'actions' }
JadeitePresenter >> abortTransaction [

	^self application abortTransaction
]

{ #category : 'initialization' }
JadeitePresenter >> caption: aString [

	self owner title: aString
]

{ #category : 'actions' }
JadeitePresenter >> commitTransaction [

	^self application commitTransaction
]

{ #category : 'as yet unclassified' }
JadeitePresenter >> confirmDisconnect [

	| shouldClose |
	JadeiteConnectionProfile connectionProfile isConnected ifFalse: [
		^ true ].
	shouldClose := UIManager default confirm:
		               'Really close window? This will disconnect and close all Jadeite windows.'.
	shouldClose ifFalse: [ ^ false ].
	JadeiteConnectionProfile connectionProfile disconnect.
	^ true
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
