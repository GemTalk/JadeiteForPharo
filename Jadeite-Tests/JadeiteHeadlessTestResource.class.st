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
JadeiteHeadlessTestResource >> closeConnectionLaunchers [
	"the point of headless tests is that there is no gui so shut all windows"

	JadeiteConnectionLauncher allInstances do: [ :launcher |
		| profile |
		profile := launcher connectionProfile.
		profile isConnected ifTrue: [ profile disconnect ].
		(profile observablePropertyNamed: #connection) subscriptions:
			OrderedCollection new.
		self destroy: launcher ]
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> connectionProfile [
	| connectionProfile |
	connectionProfile := JadeiteConnectionLauncher lastConnectionProfile.
	connectionProfile ifNil: [
		connectionProfile := self class defaultGciConnectionProfile ].
	^ connectionProfile
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> ensureLoggedIn [

	self isConnected ifFalse: [
		self closeConnectionLaunchers.
		self login ]
]

{ #category : 'testing' }
JadeiteHeadlessTestResource >> isAvailable [

	self ensureLoggedIn. 
	^ self isConnected
]

{ #category : 'testing' }
JadeiteHeadlessTestResource >> isConnected [

	^ JadeiteConnectionLauncher lastConnectionProfile isConnected
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
	GciSession current library close.
	GciSession current library: nil. 
	self connectionProfile disconnect.
]

{ #category : 'support' }
JadeiteHeadlessTestResource >> setUp [

	self
		closeConnectionLaunchers;
		ensureLoggedIn;
		basicUnloadProject: self sampleProject1Name;
		createRowanSample1Project
]
