"
testProfile - dummy profile used for testing
currentProfile - JfP profile being used for actual logins. 
"
Class {
	#name : 'JadeiteForPharoConnectionProfileTest',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'currentProfile',
		'testProfile'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoConnectionProfileTest >> setUp [
	currentProfile := JadeiteGCIConnectionProfile connectionProfile. "restore at end of test"
	testProfile := JadeiteGCIConnectionProfile new.
	JadeiteTestManager replacing: self uiManager
]

{ #category : 'support' }
JadeiteForPharoConnectionProfileTest >> tearDown [

	JadeiteGCIConnectionProfile connectionProfile: currentProfile.
	self uiManager previousManager ifNotNil: [ :manager |
		manager beDefault ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testConnectEstablishesRsrConnection [

	testProfile := JadeiteConnectionProfile connectionProfile.
	testProfile isConnected ifTrue: [ testProfile disconnect ].
	testProfile connect.

	self assert: testProfile isConnected.
	self assertIsNil: (testProfile instVarNamed: 'session'). "detached semantics nils the session after connection is established"
	self
		assert: (testProfile instVarNamed: 'connection')
		isKindOf: RsrConnection
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testConnectHandlesGciErrorGracefully [

	| errorMessage |
	currentProfile isConnected ifTrue: [ currentProfile disconnect ].
	currentProfile user: 'InvalidUser'.

	"Catch the re-signaled GciError"
	[ currentProfile connect ]
		on: GciError
		do: [ :ex | errorMessage := ex messageText ].

	self
		assert: errorMessage
		equals:
		'Login failed:  the userId/password combination is invalid or expired.'.
	self assert: (currentProfile instVarNamed: 'session') isNil. "don't leave session hanging around"
	self deny: currentProfile isConnected
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testPathReturnsClientLibrariesPath [

	| clientLibrariesPath |
	clientLibrariesPath := JadeiteGCIConnectionProfile
		                       clientLibrariesPath.
	JadeiteGCIConnectionProfile clientLibrariesPath: '/usr/lib/gemstone'.
	[ self assert: testProfile path equals: '/usr/lib/gemstone' ]
		ensure: [
			JadeiteGCIConnectionProfile clientLibrariesPath:
				clientLibrariesPath ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testSetAndGetNetldi [

	testProfile netldi: 'myNetldi'.
	self assert: testProfile netldi equals: 'myNetldi'
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testSetAndGetPassword [

	testProfile password: 'secret'.
	self assert: testProfile password equals: 'secret'
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testSetAndGetPort [

	testProfile port: 1234.
	self assert: testProfile port equals: 1234
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testSetAndGetStone [

	testProfile stone: 'devStone'.
	self assert: testProfile stone equals: 'devStone'
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testSetAndGetUser [

	testProfile user: 'admin'.
	self assert: testProfile user equals: 'admin'
]

{ #category : 'tests' }
JadeiteForPharoConnectionProfileTest >> testSetAndGetVersion [

	testProfile version: '3.6.1'.
	self assert: testProfile version equals: '3.6.1'
]
