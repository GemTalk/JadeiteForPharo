Class {
	#name : 'JadeiteHeadlessTestResource',
	#superclass : 'JadeiteTestResource',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteHeadlessTestResource >> basicUnloadProject: projectName [

	| projectNames browserService |
	projectNames := Array with: projectName.
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService onCompletion: [  ]
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> connectionProfile [
	| connectionProfile |
	connectionProfile := JadeiteConnectionProfile connectionProfile.
	^ connectionProfile
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> ensureLoggedIn [

	self isConnected ifFalse: [
		self login ]
]

{ #category : 'testing' }
JadeiteHeadlessTestResource >> isAvailable [

	self ensureLoggedIn. 
	^ self isConnected
]

{ #category : 'testing' }
JadeiteHeadlessTestResource >> isConnected [

	^ JadeiteConnectionProfile connectionProfile isConnected
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> login [

	GciSession current library: self connectionProfile connect.
	self
		basicUnloadProject: self sampleProject1Name;
		createRowanSample1Project
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> reset [

	[ self connectionProfile disconnect ] ensure: [
		GciSession current library: nil ]
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> setUp [

	self ensureLoggedIn
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> tearDown [

	self connectionProfile isConnected ifTrue: [
		self connectionProfile disconnect ].
]
