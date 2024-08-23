"
This class contains tests for Jadeite for Pharo that (presumably) should pass. 

Other tests in the JadeiteAbstractTestCase hierarchy were ported from Jadeite for Dolphin and are not known to work in pharo yet. 
"
Class {
	#name : 'JadeiteForPharoGUITestCase',
	#superclass : 'JadeiteForPharoTestCase',
	#instVars : [
		'workspace'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoGUITestCase class >> testCount [
	"self testCount
	show and count the number of tests in my subclasses"

	| testDictionary allTestCount |
	testDictionary := Dictionary new.
	allTestCount := 0.
	self allSubclassesDo: [ :sub |
		| count |
		sub traceCr.
		count := 0.
		sub localMethods do: [ :method |
			('test_*' match: method selector) ifTrue: [
				count := count + 1.
				method selector traceCr ] ].
		'--------------------' traceCr.
		('Test count for ' , sub name , ' - ' , count printString) traceCr.
		String new traceCr.
		allTestCount := allTestCount + count ].
	'--------------------' traceCr.
	'--------------------' traceCr.
	('Total tests - ' , allTestCount printString) traceCr
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> dismissPopoverAndPrint [

	SpCodePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ].
	JadeitePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> displayAndPrint [

	workspace codePane jadeDisplay.
	self dismissPopoverAndPrint
]

{ #category : 'running' }
JadeiteForPharoGUITestCase >> runCaseManaged [
	"In order to preserve RSR connections across test boundaries
	(to speed up the tests and expose bugs) we can't let the 
	watchdog loose. The watchdog is started by the test execution process"

	^DefaultExecutionEnvironment beActiveDuring: [ self runCase]
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> tearDown [
	super tearDown.
	workspace
		ifNotNil: 
			[workspace isModified: false.
			self destroy: workspace]
]
