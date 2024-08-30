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

{ #category : 'support' }
JadeiteForPharoGUITestCase >> setUp [

	| launchers |
	launchers := JadeiteConnectionLauncher allInstances.
	launchers
		ifEmpty: [ JadeiteConnectionApplication new start ]
		ifNotEmpty: [
			(launchers noneSatisfy: [ :launcher | launcher window isOpen ])
				ifTrue: [ JadeiteConnectionApplication new start ] ].
	super setUp
]

{ #category : 'support' }
JadeiteForPharoGUITestCase >> tearDown [
	super tearDown.
	workspace
		ifNotNil: 
			[workspace isModified: false.
			self destroy: workspace]
]
