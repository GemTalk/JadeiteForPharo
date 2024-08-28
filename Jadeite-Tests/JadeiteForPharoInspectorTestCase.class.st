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
JadeiteForPharoInspectorTestCase >> selectInstVarAtIndex: index [
	"needed an efficient way of converting a workaround for an old Dolphin selectionByIndex: bug
	When all senders of this method are converted to passing integers only, then we can remove the conditional"

	| theIndex |
	theIndex := index isInteger ifTrue: [index] ifFalse: [index first].
	inspector instVarListPresenter unselectAll. 
	inspector instVarListPresenter selectIndex: theIndex
]

{ #category : 'support' }
JadeiteForPharoInspectorTestCase >> tearDown [ 

	super tearDown. 
	self destroy: inspector 
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_adHocExecution [

	self openWorkspaceAndInspect: 'Array with: 1 with: 2'.
	inspector codePane value: 'self size'.
	inspector codePane jadeDisplay.
	self dismissPopoverAndPrint. 
	self assert: inspector codePane text equals: 'self size "2"'
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_addCharacterToString [
	"add a character to a string and expect to have it highlighted"

	self openWorkspaceAndInspect: '''abc'' copy'.
	self selectInstVarAtIndex: 1.
	inspector basicAddObject: '$-'.
	self
		assert: inspector instVarListPresenter selections first key
		equals: '1'. "self was seleted. add char at 1. select first index afterwards"
	self assert: inspector codePane text equals: '$-'.
	self selectInstVarAtIndex: 1.
	self assert: inspector codePane text equals: '''-abc'''.
	self selectInstVarAtIndex: 6.
	inspector basicAddObject: '$d'.
	self
		assert: inspector instVarListPresenter selections first key
		equals: '5'. "last index was seleted. add char at end. select added char afterwards"
	self selectInstVarAtIndex: 1.
	self assert: inspector codePane text equals: '''-abcd'''.
	self selectInstVarAtIndex: 4.
	self
		assert: inspector instVarListPresenter selections first key
		equals: '2'.
	inspector basicAddObject: '$<'.
	self
		assert: inspector instVarListPresenter selections first key
		equals: '3'. "last index was seleted. add char after this slot. select added char afterwards"
	self selectInstVarAtIndex: 1.
	self assert: inspector codePane text equals: '''-a<bcd'''
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_caption [

	self openWorkspaceAndInspect: '123'.
	self assert: ('Jadeite Inspector on SmallInteger on*' match: inspector owner title).
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_openProjectsBrowser [

	self openWorkspaceAndInspect: 'RowanClassService new'.
	projectsBrowser := inspector browseClass.
	self assert: (projectsBrowser isKindOf: JadeiteBrowser)
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_selectAllString [

	self openWorkspaceAndInspect: '''abc'' copy'.
	inspector instVarListPresenter view selectAll.
	self assert: inspector instVarListPresenter selections size equals: 5.
	self assert: ('self: ''abc''
-.asOop: *
1: $a
2: $b
3: $c' match: inspector value)
]
