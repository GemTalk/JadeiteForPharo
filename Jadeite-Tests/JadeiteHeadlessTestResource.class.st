Class {
	#name : 'JadeiteHeadlessTestResource',
	#superclass : 'JadeiteTestResource',
	#category : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteHeadlessTestResource >> basicUnloadProject: projectName [

	| projectNames browserService |
	projectNames := Array with: projectName.
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> connectionProfile [
	| connectionProfile |
	connectionProfile := JadeiteConnectionLauncher connectionProfile.
	connectionProfile ifNil: [
		connectionProfile := self class defaultGciConnectionProfile ].
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

	^ JadeiteConnectionLauncher connectionProfile isConnected
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
