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
		target: self;
		order: 4.0;
		icon: nil;
		parent: #Tools;
		"see WorldState class>>#libraryWorldMenuOn:"keyText: 'o, j';
		help: 'Open a Jadeite Connections Launcher';
		action: [ self new start ]
]

{ #category : 'actions' }
JadeiteConnectionApplication >> start [

	| inst windowPresenter |
	JadeiteConnectionLauncher soleInstance ifNotNil: [ :launcher |
		^ launcher adapter widget restoreAndActivate ].
	inst := self new: JadeiteConnectionLauncher.
	inst addStyle: 'jadeiteTextBackgroundColor'.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]

{ #category : 'actions' }
JadeiteConnectionApplication >> windowClosed: aWindow [

	super windowClosed: aWindow.
	JadeiteConnectionProfile connectionProfile isConnected ifTrue: [
		JadeiteConnectionProfile connectionProfile disconnect ]
]
