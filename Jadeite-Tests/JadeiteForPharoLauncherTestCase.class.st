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
