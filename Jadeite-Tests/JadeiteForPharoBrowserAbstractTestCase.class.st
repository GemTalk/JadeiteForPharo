Class {
	#name : 'JadeiteForPharoBrowserAbstractTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'secondBrowser',
		'methodListBrowser',
		'secondPresenter',
		'transcriptWritesWereEnabled'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteForPharoBrowserAbstractTestCase >> isAbstract [

	^self == JadeiteForPharoBrowserAbstractTestCase
]

{ #category : 'support' }
JadeiteForPharoBrowserAbstractTestCase >> runCaseManaged [
	"In order to preserve RSR connections across test boundaries
	(to speed up the tests and expose bugs) we can't let the 
	watchdog loose. The watchdog is started by the test execution process"

	^DefaultExecutionEnvironment beActiveDuring: [ self runCase]
]

{ #category : 'support' }
JadeiteForPharoBrowserAbstractTestCase >> setUp [
	super setUp.
	self jadeiteLog: 'setUp complete'.
	self setupProjectBrowser.
	self jadeiteLog: 'setupProjectBrowser complete'.
]

{ #category : 'support' }
JadeiteForPharoBrowserAbstractTestCase >> tearDown [
	super tearDown.
	session isValidSession
		ifTrue: [transcriptWritesWereEnabled == true ifTrue: [transcript flipTranscript]].
	methodListBrowser
		ifNotNil: 
			[self destroy: methodListBrowser.
			methodListBrowser := nil].
	secondBrowser
		ifNotNil: 
			[self destroy: secondBrowser.
			secondBrowser := nil]
]
