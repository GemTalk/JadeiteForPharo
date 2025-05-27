Class {
	#name : 'JadeiteForPharoConnectionLauncherTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'clientLibariesPath'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoConnectionLauncherTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor"

	^ { JadeiteConnectionLauncher }
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> profile [

	^ JadeiteGCIConnectionProfile connectionProfile
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> setUp [

	super setUp.
	JadeiteTestManager replacing: self uiManager
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> tearDown [

	super tearDown.
	self uiManager previousManager ifNotNil: [:manager | manager beDefault]. 
	clientLibariesPath ifNotNil: [
		JadeiteGCIConnectionProfile clientLibrariesPath: clientLibariesPath.
		JadeiteConnectionLauncher soleInstance window close.
		JadeiteConnectionApplication new start ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesMissing [

	| launcher |
	self profile isConnected ifTrue: [ self profile disconnect ].
	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	JadeiteGCIConnectionProfile clientLibrariesPath: String new.

	[ launcher connect ]
		on: ProvideAnswerNotification
		do: [ :notification |
			self assert:
				('Client library could not be found. Error message:*' match:
					 notification messageText) ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesPath [

	| launcher changedPathRef originalPath |
	self profile isConnected ifTrue: [ self profile disconnect ].
	JadeiteConnectionLauncher soleInstance window close.

	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	originalPath := 'testPath'.
	JadeiteGCIConnectionProfile clientLibrariesPath: originalPath.
	JadeiteConnectionApplication new start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: originalPath.
	changedPathRef := 'clientLibrariesChanged.txt' asFileReference.
	[ launcher setPath ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: changedPathRef ].
	launcher window close.
	JadeiteConnectionApplication new start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: changedPathRef fullName
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
