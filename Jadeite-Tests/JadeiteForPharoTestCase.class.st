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

{ #category : 'tests' }
JadeiteForPharoTestCase >> openBrowserOn: className [

	| sem projectsPresenter |
	RowanServiceUpdater uninstallTestUpdater.
	self destroy: projectsBrowser.
	projectsPresenter := self
		                     waitForNewPresenter:
		                     JadeiteBrowser browserPresenterClass
		                     while: [
		                     jadeiteShell findClassNamed: className ].
	projectsBrowser := projectsPresenter parentPresenter.
	sem := Semaphore new.
	[
		[
			projectsPresenter selectedClass
				ifNil: [ false ]
				ifNotNil: [ :classService | classService name = className ] ]
			whileFalse: [ (Delay forMilliseconds: 10) wait ].
		sem signal ] fork.

	sem waitTimeoutSeconds: 2.
	^ projectsPresenter
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
]

{ #category : 'support' }
JadeiteForPharoTestCase >> tearDown [

	savedSettings ifNotNil: [ JadeitePreferences current: savedSettings ].
	super tearDown
]

{ #category : 'support' }
JadeiteForPharoTestCase >> waitForNewPresenter: presenterClass while: aBlock [

	| existing new count |
	RsrGarbageCollector maximumReclamation.
	existing := presenterClass allInstances.
	aBlock forkAt: Processor activePriority + 1.
	count := 0.
	[
	count > 50 or: [
		(new := presenterClass allInstances asOrderedCollection) size
		> existing size ] ] whileFalse: [
		WorldMorph doOneCycle.
		count := count + 1.
		(Delay forMilliseconds: 50) wait ].
	new removeAll: existing.
	self
		deny: new isEmpty
		description: presenterClass printString , ' was not opened!'.
	new isEmpty ifTrue: [ ^ nil ].
	^ new first
]
