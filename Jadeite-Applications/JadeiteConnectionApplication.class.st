Class {
	#name : 'JadeiteConnectionApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications'
}

{ #category : 'world menu' }
JadeiteConnectionApplication class >> menuCommandOn: aBuilder [ 
	"Add a custom menu item to the world menu"	
	<worldMenu> 
	
	(aBuilder item: #'Jadeite Launcher')
		order: 4.0; 
		icon: nil;  
		parent: #'Tools'; "This appears as the Library menu option for whatever reason"
		keyText: 'J'; "hot key doesn't work yet" 
		help: 'Open a Jadeite Connections Launcher';
		action: [ JadeiteConnectionApplication new start ]
]

{ #category : 'actions' }
JadeiteConnectionApplication >> start [

	| inst |
	inst := self new: JadeiteConnectionLauncher.
	inst addStyle: 'jadeiteTextBackgroundColor'.
	inst open
]
