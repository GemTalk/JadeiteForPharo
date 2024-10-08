Class {
	#name : 'JadeiteConnectionApplication',
	#superclass : 'JadePresenterA',
	#classVars : [
		'Singleton'
	],
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'world menu' }
JadeiteConnectionApplication class >> menuCommandOn: aBuilder [
	"Add a custom menu item to the world menu"

	<worldMenu>
	(aBuilder item: #'Jadeite Launcher')
		order: 4.0;
		icon: nil;
		parent: #Tools;
		"This appears as the Library menu option for whatever reason"
		keyText: 'J';
		"hot key doesn't work yet"help:
			'Open a Jadeite Connections Launcher';
		action: [ self openOnlyOneLauncher ]
]

{ #category : 'instance creation' }
JadeiteConnectionApplication class >> openOnlyOneLauncher [

	Singleton ifNil: [ ^ Singleton := self new start ].
	Singleton window adapter widget restoreAndActivate
]

{ #category : 'accessing' }
JadeiteConnectionApplication class >> singleton: anObject [ 

	Singleton := anObject
]

{ #category : 'actions' }
JadeiteConnectionApplication >> start [

	| inst |
	inst := self new: JadeiteConnectionLauncher.
	inst addStyle: 'jadeiteTextBackgroundColor'.
	inst open.
	^inst
]

{ #category : 'actions' }
JadeiteConnectionApplication >> windowClosed: aWindow [

	super windowClosed: aWindow.
	self class singleton: nil.
	JadeiteConnectionProfile connectionProfile isConnected ifFalse: [
		^ self ].
	JadeiteConnectionProfile connectionProfile disconnect
]
