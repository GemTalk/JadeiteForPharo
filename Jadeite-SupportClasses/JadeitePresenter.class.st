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
