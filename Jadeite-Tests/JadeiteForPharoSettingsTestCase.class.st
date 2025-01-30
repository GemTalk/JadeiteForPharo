Class {
	#name : 'JadeiteForPharoSettingsTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoSettingsTestCase >> setUp [

	super setUp.
	JadeiteConnectionProfile connectionProfile disconnect.
]

{ #category : 'support' }
JadeiteForPharoSettingsTestCase >> tearDown [

	JadeiteConnectionProfile connectionProfile disconnect.
	self deny: JadeiteConnectionProfile connectionProfile isConnected.
	super tearDown
]

{ #category : 'tests' }
JadeiteForPharoSettingsTestCase >> test_autoCommitSetting [

	| prefs |
	prefs := JadeitePreferences current.
	prefs autocommitEnabled: true.
	JadeiteConnectionProfile connectionProfile connect.
	self assert: JadeiteConnectionProfile connectionProfile isConnected.
	[ GciSession current autoCommit contents ] whileFalse: [
		(Delay forMilliseconds: 1) wait ].
	self assert: GciSession current autoCommit contents.
	JadeiteConnectionProfile connectionProfile disconnect.
	self deny: JadeiteConnectionProfile connectionProfile isConnected.
	prefs autocommitEnabled: false.
	JadeiteConnectionProfile connectionProfile connect.
	[ GciSession current autoCommit contents ] whileTrue: [
		(Delay forMilliseconds: 1) wait ].
	self deny: GciSession current autoCommit contents
]

{ #category : 'tests' }
JadeiteForPharoSettingsTestCase >> test_openBrowserOnClassSetting [

	| prefs |
	prefs := JadeitePreferences current.
	prefs openBrowserOnClass: 'RowanService'.
	self waitForNewBrowserWhile: [
		JadeiteConnectionProfile connectionProfile connect.
		self assert: JadeiteConnectionProfile connectionProfile isConnected ].
	[
	self projectsPresenter
		ifNil: [ false ]
		ifNotNil: [ :pres | pres selectedClass notNil ] ] whileFalse: [
		(Delay forMilliseconds: 1) wait ].
	self
		assert: self projectsPresenter selectedClass name
		equals: 'RowanService'
]

{ #category : 'tests' }
JadeiteForPharoSettingsTestCase >> test_openBrowserOnInvalidClassSetting [
	"not a great test, but at least don't give an error"

	| prefs |
	prefs := JadeitePreferences current.
	prefs openBrowserOnClass: 'GrumbleFlumps'. "should not exist"
	self waitForNewBrowserWhile: [
		JadeiteConnectionProfile connectionProfile connect ].
	(Delay forSeconds: 1) wait. 
	self assertIsNil: self projectsPresenter selectedClass
]
