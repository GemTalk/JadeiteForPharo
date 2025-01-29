Class {
	#name : 'JadeiteForPharoLauncherTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'launcher'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> setUp [

	super setUp.
	launcher := JadeiteConnectionLauncher allInstances detect: [
		            :aLauncher | aLauncher window isOpen ]
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_buttonEnablement [

	JadeiteConnectionProfile connectionProfile disconnect.
	self assert: launcher connectButton isEnabled.
	self deny: launcher disconnectButton isEnabled.
	JadeiteConnectionProfile connectionProfile connect.
	self deny: launcher connectButton isEnabled.
	self assert: launcher disconnectButton isEnabled
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_closeDisconnects [

	self assert: JadeiteConnectionProfile connectionProfile isConnected.
	[ launcher window close ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: true ].
	self assert: launcher window isClosed.
	self deny: JadeiteConnectionProfile connectionProfile isConnected
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_fixedPort [
	| profile |
	profile := JadeiteConnectionProfile connectionProfile.
	profile disconnect.
	self deny: profile isConnected.
	profile port: '2000'. "1024 and above should always be valid"
	profile connect.
	self assert: profile isConnected.
	profile disconnect.
	
	profile port: '1023'.
	self should: [ profile connect ] raise: Error. 
	self deny: profile isConnected.
	
	profile port: String new. 
	profile connect.
	self assert: profile isConnected.
	profile disconnect.
	
	profile port: nil.
	profile connect.
	self assert: profile isConnected.
	profile disconnect.
]
