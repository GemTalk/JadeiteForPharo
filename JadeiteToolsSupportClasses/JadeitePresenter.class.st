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
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'initialization' }
JadeitePresenter >> caption: aString [

	self owner title: aString
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
	self caption: (self gciSession titleBarFor: self shellName)
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
