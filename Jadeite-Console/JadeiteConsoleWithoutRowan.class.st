Class {
	#name : 'JadeiteConsoleWithoutRowan',
	#superclass : 'JadeiteConsole',
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'actions' }
JadeiteConsoleWithoutRowan >> basicUnloadProjects: projectNames onCompletion: completionBlock [

	"nothing to do when rowan not available"
]

{ #category : 'registration' }
JadeiteConsoleWithoutRowan >> browseMonticelloChanges [

	| monticelloService |
	monticelloService := RowanMonticelloService new.
	monticelloService packageChanges: self gciSession application: self application

]

{ #category : 'initialization' }
JadeiteConsoleWithoutRowan >> initializeBrowseMenu [

	^ self newBrowseMethodsConsoleMenu
		  addItem: [ :item |
			  item
				  name: 'Find Class ...';
				  shortcut: $f shift ctrl;
				  action: [ self findClass ] ];
		  addItem: [ :item |
			  item
				  name: 'Find Class References ...';
				  shortcut: $r shift ctrl;
				  action: [ self findClassReferences ] ];
		  addItem: [ :item |
			  item
				  name: 'Browse Monticello Changes ...';
				  shortcut: $r shift ctrl;
				  action: [ self browseMonticelloChanges ] ];
			yourself
]

{ #category : 'initialization' }
JadeiteConsoleWithoutRowan >> initializeProjectListPresenter: tabs [

	projectListPresenter := JadeiteTablePresenter new
]

{ #category : 'registration' }
JadeiteConsoleWithoutRowan >> registerPresentersForUpdates [
]
