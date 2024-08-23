Class {
	#name : 'JadeiteForPharoInspectorTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'inspector'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> openWorkspaceAndInspect: aString [

	workspace := JadeiteWorkspace showOnSession: GciSession current.
	workspace text: aString.
	inspector := workspace
		             executeSelectionOrLineInspectingResult: aString
		             shouldDebug: false
]

{ #category : 'support' }
JadeiteForPharoInspectorTestCase >> tearDown [ 

	super tearDown. 
	self destroy: inspector 
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_adHocExecution [

	self openWorkspaceAndInspect: 'Array with: 1 with: 2'.
	inspector codePane value: 'self size'.
	inspector codePane jadeDisplay.
	self dismissPopoverAndPrint. 
	self assert: inspector codePane text equals: 'self size "2"'
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_caption [

	self openWorkspaceAndInspect: '123'.
	self assert: ('Jadeite Inspector on SmallInteger on*' match: inspector owner title).
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_openProjectsBrowser [

	self openWorkspaceAndInspect: 'RowanClassService new'.
	projectsBrowser := inspector browseClass.
	self assert: (projectsBrowser isKindOf: JadeiteBrowser)
]
