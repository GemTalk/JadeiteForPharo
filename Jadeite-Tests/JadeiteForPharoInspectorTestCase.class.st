Class {
	#name : 'JadeiteForPharoInspectorTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'inspector',
		'secondInspector'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'not working tests' }
JadeiteForPharoInspectorTestCase >> _test_displayAll [
	self todo: 'need large inspector work to be completed'.
	self
		testsIssue: #issue668
		withTitle: 'More efficient handling of large collections. #668'.
	self openWorkspaceAndInspect: '| coll oop inspectorService |
coll := Array new.
1 to: 20000 do: [:i |
coll add: ''entry'', i asString].
oop := coll asOop.
coll
 '.
	self
		assert: inspector statusText
		equals: 'Displaying 1000 of 20000 variable inst vars'.
	self assert: inspector instVarListPresenter list size equals: 1002.
	inspector displayAll.
	self
		assert: inspector statusText
		equals: 'Displaying 20000 of 20000 variable inst vars'.
	self assert: inspector instVarListPresenter list size equals: 20002
]

{ #category : 'support' }
JadeiteForPharoInspectorTestCase >> diveAt: index [
	| instVarPresenter |
	instVarPresenter := inspector instVarListPresenter.
	self selectInstVarAtIndex: index.
	^inspector dive
]

{ #category : 'support' }
JadeiteForPharoInspectorTestCase >> inspectInstVarAt: index [
	| instVarPresenter |
	instVarPresenter := inspector instVarListPresenter.
	self selectInstVarAtIndex: index.
	^inspector inspectInstVar
]

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
	self destroy: inspector.
	self destroy: secondInspector
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_adHocExecution [

	self openWorkspaceAndInspect: 'Array with: 1 with: 2'.
	inspector codePane value: 'self size'.
	inspector codePane jadeDisplay.
	self dismissPopoverAndPrint. 
	self assert: inspector codePane text equals: 'self size "2"'
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_adHocInspect [

	| methodListBrowser |
	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.
	self
		testsIssue: #issue712
		withTitle:
		'Inspect UserGlobals from Method list, get ByteArray DNE asHexString'.

	self openProjectBrowser.

	self selectRowanSample1Test.
	self
		saveMethod: 'bartooee  ^UserGlobals size'
		in: 'RowanSample1Test'
		category: 'deleteme'.
	self selectMethodNamed: #bartooee.
	self projectsPresenter methodSourcePresenter selectionInterval:
		(12 to: 22).
	inspector := self inspectMethodSourceSelectionIn:
		             self projectsPresenter.
	[
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: 'self'.
	self
		assert: inspector codePane text
		equals: 'aSymbolDictionary( name: #''UserGlobals'' )' ] ensure: [
		self destroy: inspector ].
	methodListBrowser := self projectsPresenter browseImplementors.
	[
	methodListBrowser methodSourcePresenter selectionInterval:
		(12 to: 22).
	inspector := self inspectMethodSourceSelectionIn: methodListBrowser.
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: 'self'.
	self
		assert: inspector codePane text
		equals: 'aSymbolDictionary( name: #''UserGlobals'' )' ] ensure: [
		self destroy: methodListBrowser ]
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
	self assert: ('Inspector on SmallInteger for*' match: inspector owner title).
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_captionChange [

	| ocIndex |
	self
		testsIssue: #issue154
		withTitle: 'Change inspector title on dive #154'.
	self openWorkspaceAndInspect:
		'Array with: (Dictionary new at: #oc put: (OrderedCollection with: #leaf); yourself)'.
	self assert: ('Inspector on Array for*' match: inspector caption).
	self diveAt: 3.
	self assert:
		('Inspector on Dictionary for*' match: inspector caption).
	ocIndex := inspector instVarListPresenter list indexOf:
		           (inspector instVarListPresenter list detect: [ :item |
			            item first = '#''oc''' ]).
	self diveAt: ocIndex.
	self assert:
		('Inspector on OrderedCollection for*' match: inspector caption).
	self diveAt: 3.
	self assert: ('Inspector on Symbol for*' match: inspector caption).
	inspector getPreviousObject.
	self assert:
		('Inspector on OrderedCollection for*' match: inspector caption).
	inspector getPreviousObject.
	self assert:
		('Inspector on Dictionary for*' match: inspector caption).
	inspector getPreviousObject.
	self assert: ('Inspector on Array for*' match: inspector caption)
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_deselectClearsPane [
	self openWorkspaceAndInspect: '97'.
	inspector instVarListPresenter selectIndex: 1.
	self assert: inspector codePane text equals: '97'.
	inspector instVarListPresenter view selectAll.
	self assert: inspector instVarListPresenter selections size equals: 2.
	self assert: inspector codePane text equals: 'self: 97
-.asOop: 778
'.
	inspector instVarListPresenter view selections: #().
	self assert: inspector codePane text equals: String new. 
	
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_inspectBag [

	self openWorkspaceAndInspect: 'Bag new add: ''abc''; yourself'.
	self
		assert:inspector codePane text
		equals: 'aBag( ''abc'')'.
	self selectInstVarAtIndex: #( 2 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-.asOop'.
	self selectInstVarAtIndex: #( 3 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_varyingSize'.
	self selectInstVarAtIndex: #( 4 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_numEntries'.
	self selectInstVarAtIndex: #( 5 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_indexedPaths'.
	self selectInstVarAtIndex: #( 6 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_levels'.
	self selectInstVarAtIndex: #( 7 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-dict'.
	self selectInstVarAtIndex: #( 8 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-size'.
	self selectInstVarAtIndex: #( 9 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 9
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_inspectIdentityBag [

	self openWorkspaceAndInspect: '| abc | 
				abc := ''abc''. 
				IdentityBag new add: abc; add: abc; yourself'.
	self
		assert: inspector codePane text
		equals: 'anIdentityBag( ''abc'', ''abc'')'.
	self selectInstVarAtIndex: #( 2 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-.asOop'.
	self selectInstVarAtIndex: #( 3 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_varyingSize'.
	self selectInstVarAtIndex: #( 4 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_numEntries'.
	self selectInstVarAtIndex: #( 5 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_indexedPaths'.
	self selectInstVarAtIndex: #( 6 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '-_levels'.
	self selectInstVarAtIndex: #( 7 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '''abc'''.
	self selectInstVarAtIndex: #( 8 ).
	self
		assert: inspector instVarListPresenter selectedItem key
		equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 8
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_openProjectsBrowser [

	self openWorkspaceAndInspect: 'RowanClassService new'.
	projectsBrowser := inspector browseClass.
	self assert: (projectsBrowser isKindOf: JadeiteBrowser)
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_selectAll [

	self openWorkspaceAndInspect: '97'.
	inspector instVarListPresenter view selectAll.
	self assert: inspector instVarListPresenter selections size equals: 2.
	self assert: inspector codePane text equals: 'self: 97
-.asOop: 778
'
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
