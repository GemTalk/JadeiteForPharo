Class {
	#name : 'JadeiteShell',
	#superclass : 'Shell',
	#instVars : [
		'gciSession',
		'myPresenter'
	],
	#category : 'Jadeite-PortedClasses'
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
JadeiteShell >> createComponents [

	super createComponents.
	self presenterClass ifNotNil: [:class | myPresenter := self add: class new name: 'myPresenter'].

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

{ #category : 'private' }
JadeiteShell >> onViewOpened [
	"If we have a presenter that is responsible for the entire window, then let it set up the MenuBar"

	super onViewOpened.
	[
		| menuBar |
		menuBar := self view menuBar.
		menuBar isNil ifTrue: [menuBar := MenuBar new].
		myPresenter notNil ifTrue: [myPresenter updateMenuBar: menuBar].
		self view menuBar: menuBar.
	] on: Error do: [:ex | 
		SessionManager current logError: ex.
		MessageBox
			notify: ex description 
			caption: 'Unable to Open ' , self class name.
		SessionManager current pause.
		self view close.
	].


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
