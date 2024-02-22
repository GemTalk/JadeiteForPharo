"
Superclass for Jaded's presenters. 
Provides things like hooks to register presenters for updates.
"
Class {
	#name : 'JadeitePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'gciSession'
	],
	#category : 'Jadeite-SupportClasses'
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

{ #category : 'accessing' }
JadeitePresenter >> gciSession [

	^ gciSession 
]

{ #category : 'accessing' }
JadeitePresenter >> gciSession: aGciSession [

	gciSession := aGciSession
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
