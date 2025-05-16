Class {
	#name : 'JadeiteForPharoConnectionLauncherTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoConnectionLauncherTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor"

	^ { JadeiteConnectionLauncher }
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> tearDown [ 
	
	^super tearDown
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_soleInstance [

	| launchers launcherSingleton |
	self assert: JadeiteConnectionProfile connectionProfile isConnected.
	JadeiteConnectionProfile connectionProfile disconnect.
	launchers := JadeiteConnectionLauncher allInstances select: [
		             :launcher |
		             launcher window notNil and: [ launcher window isOpen ] ].
	self assert: launchers size equals: 1.

	launcherSingleton := launchers first window.
	self
		assert: JadeiteConnectionLauncher soleInstance
		identicalTo: launcherSingleton.

	launcherSingleton window close.

	launchers := JadeiteConnectionLauncher allInstances select: [
		             :launcher |
		             launcher window notNil and: [ launcher window isOpen ] ].
	self assert: launchers isEmpty.
	self assertIsNil: JadeiteConnectionLauncher soleInstance.

	self ensureLauncherOpened "for the next test"
]
