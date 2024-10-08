Class {
	#name : 'JadeiteForPharoTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'savedSettings'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
JadeiteForPharoTestCase class >> defaultTimeLimit [

	^ 30 seconds
]

{ #category : 'tests' }
JadeiteForPharoTestCase class >> testCount [
	"self testCount
	show and count the number of tests in my subclasses"

	| testDictionary allTestCount count |
	testDictionary := Dictionary new.
	allTestCount := 0.
	'======================' traceCr.
	self traceCr.
	count := 0.
	self localMethods do: [ :method |
		('test_*' match: method selector) ifTrue: [
			count := count + 1.
			Character tab trace. method selector traceCr ] ].
	allTestCount := allTestCount + count.
	'--------------------' traceCr.
	(self name, 'test count - ' , allTestCount printString) traceCr.
	'======================' traceCr.
	^allTestCount 
]

{ #category : 'support' }
JadeiteForPharoTestCase >> closeConnectionLaunchers [ 

	self testResourceClass current closeConnectionLaunchers
]

{ #category : 'as yet unclassified' }
JadeiteForPharoTestCase >> issueCommand: service onCompletion: completionBlock [

	RowanServiceUpdater current
		issueCommands: (Array with: service)
		session: session
		onCompletion: completionBlock
]

{ #category : 'running' }
JadeiteForPharoTestCase >> runCaseManaged [
	"In order to preserve RSR connections across test boundaries
	(to speed up the tests and expose bugs) we can't let the 
	watchdog loose. The watchdog is started by the test execution process"

	^DefaultExecutionEnvironment beActiveDuring: [ self runCase]
]

{ #category : 'support' }
JadeiteForPharoTestCase >> setUp [

	super setUp.
	savedSettings := JadeitePreferences current copy
]

{ #category : 'support' }
JadeiteForPharoTestCase >> tearDown [

	JadeitePreferences current: savedSettings.
	super tearDown.
]
