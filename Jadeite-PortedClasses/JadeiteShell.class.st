Class {
	#name : 'JadeiteShell',
	#superclass : 'Shell',
	#instVars : [
		'gciSession',
		'myPresenter'
	],
	#category : 'Jadeite-PortedClasses',
	#package : 'Jadeite-PortedClasses'
}

{ #category : 'constants' }
JadeiteShell class >> defaultAdditionalAccelerators [
	^#(#(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'public' }
JadeiteShell class >> icon [

	^Icon fromFile: 'icons\GS32.ico'.

]

{ #category : 'public' }
JadeiteShell class >> showOnSession: aGciSession [

	aGciSession hasServer ifFalse: [
		MessageBox
			warning: 'Server initialization failed at login.'
			caption: 'Unable to Open Browser'.
	].
	^self new 
		gciSession: aGciSession;
		createView: self defaultView;
		showShell;
		yourself.

]

{ #category : 'constants' }
JadeiteShell >> additionalAccelerators [
	^#(#(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'private' }
JadeiteShell >> gciSession [

	^gciSession
]

{ #category : 'private' }
JadeiteShell >> gciSession: aGciSession [

	gciSession := aGciSession.
	myPresenter notNil ifTrue: [myPresenter gciSession: aGciSession].
	gciSession
		when: #'logoutRequested:'			send: #'logoutRequested:'	to: self;
		when: #'logoutPending'			send: #'exit'			to: self;
		when: #forceJadeiteWindowClose	send: #exit			to: self;		
		yourself.

]

{ #category : 'pharo specific layer' }
JadeiteShell >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter. 
	self updateCaption. 
]

{ #category : 'private' }
JadeiteShell >> logoutRequested: aValueHolder [
	"Private - Opportunity to save changes."

	aValueHolder value: true.

]

{ #category : 'private' }
JadeiteShell >> onViewClosed [

	gciSession notNil ifTrue: [
		| temp |
		temp := gciSession.
		gciSession := nil.
		temp removeEventsTriggeredFor: self.
	].
	super onViewClosed.

]

{ #category : 'overrides' }
JadeiteShell >> presenterClass [

	^nil.

]

{ #category : 'public' }
JadeiteShell >> primaryPresenter [

	^myPresenter
]

{ #category : 'overrides' }
JadeiteShell >> shellName [

	^'Jadeite Shell'.

]

{ #category : 'overrides' }
JadeiteShell >> updateCaption [

	self caption: (gciSession titleBarFor: self shellName).

]

{ #category : 'overrides' }
JadeiteShell >> updateCaption: string [
	self caption: (gciSession titleBarFor: string)
]
