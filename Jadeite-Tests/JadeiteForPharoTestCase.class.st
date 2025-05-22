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

	self jadeiteTestResourceClass current closeConnectionLaunchers
]

{ #category : 'running' }
JadeiteForPharoTestCase >> runCaseManaged [
	"In order to preserve RSR connections across test boundaries
	(to speed up the tests and expose bugs) we can't let the 
	watchdog loose. The watchdog is started by the test execution process"

	| testEnv |
	testEnv := JadeiteTestExecutionEnvironment new.
	^ testEnv beActiveDuring: [ testEnv runTestCase: self ]
]

{ #category : 'tests' }
JadeiteForPharoTestCase >> selectVariableNamed: varName [
	"can't just select string in list because SpCollectionListModel uses identity equality.
	Must get the actual item and select that"

	| var |
	var := self variableListPresenter items detect: [ :ea |
		       ea asString = varName ].
	self variableListPresenter selections: (Array with: var)
]

{ #category : 'support' }
JadeiteForPharoTestCase >> setUp [

	super setUp.
	savedSettings := JadeitePreferences current copy.
	JadeitePreferences isRowanLoaded: true "Not all test classes will run with rowan being available"
]

{ #category : 'support' }
JadeiteForPharoTestCase >> tearDown [

	savedSettings ifNotNil: [ JadeitePreferences current: savedSettings ].
	super tearDown
]
