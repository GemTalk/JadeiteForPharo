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
JadeiteForPharoConnectionLauncherTestCase >> tearDown [

	super tearDown.
	clientLibariesPath ifNotNil: [
		JadeiteGCIConnectionProfile clientLibrariesPath: clientLibariesPath.
		JadeiteConnectionLauncher soleInstance window close.
		JadeiteConnectionApplication new start ]
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
