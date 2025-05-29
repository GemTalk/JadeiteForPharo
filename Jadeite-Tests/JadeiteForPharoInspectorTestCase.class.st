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

{ #category : 'coverage' }
JadeiteForPharoInspectorTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor.
	Currently don't look at super classes"

	^ { JadeiteInspector }
]

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
		             shouldDebug: false.
	^ inspector
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
JadeiteForPharoInspectorTestCase >> selectSlotNamed: slotName [
	"not sure if this is correct"

	| array index |
	inspector instVarListPresenter unselectAll.
	array := inspector instVarListPresenter list detect: [
		         :twoElementArray |
		         (twoElementArray first copyWithout: $-) = slotName ].
	index := inspector instVarListPresenter list indexOf: array.
	inspector instVarListPresenter selectIndex: index
]

{ #category : 'support' }
JadeiteForPharoInspectorTestCase >> tearDown [

	super tearDown.
	[ self destroy: inspector ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: true ].

	[ self destroy: secondInspector ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: true ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_abortTransactionInInspector [

	self
		testsIssue: #issue383
		withTitle:
		'(3.0.53) the commit button on the SUnit browser is silent'.
	self openWorkspaceAndInspect: '123'.
	self assertProjectInList: 'RowanSample1'.
	inspector abortTransaction.
	self denyProjectInList: 'RowanSample1'
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
JadeiteForPharoInspectorTestCase >> test_adHocInspect [

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
JadeiteForPharoInspectorTestCase >> test_browseClass [

	self openWorkspaceAndInspect: 'RowanClassService new'.
	projectsBrowser := inspector browseClass.
	self assert: (projectsBrowser isKindOf: JadeiteBrowser).
	self
		assert: projectsBrowser projectListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: projectsBrowser packageListPresenter selectedItem name
		equals: 'Rowan-Services-Core'.
	self
		assert: projectsBrowser classListPresenter selectedItem name
		equals: 'RowanClassService'.
	self deny: projectsBrowser activePresenter isClassSideSelected.
	self assert: projectsBrowser activePresenter isCategoryTabSelected
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_browseProjects [

	self openWorkspaceAndInspect:
		'''test toolbar button from inspector'''.

	projectsBrowser := inspector openBrowser.
	self assert: projectsBrowser isKindOf: JadeiteBrowser
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_browseSelectionClass [

	| sem |
	sem := Semaphore new.
	self openWorkspaceAndInspect: 'RowanClassService new'.
	self selectSlotNamed: 'isNewClass'.
	self assert: inspector codePane text equals: 'false'.
	self waitForNewBrowserWhile: [ inspector browseClassOfSelection ].
	self assert: (projectsBrowser isKindOf: JadeiteBrowser).
	self
		waitFor: [ self projectsPresenter isNil ]
		errorMessage: 'projectBrowser not built in time'.
	self
		waitFor: [
		self projectsPresenter classListPresenter selectedItem isNil ]
		errorMessage: 'class not found in time'.

	self
		assert: self projectsPresenter classListPresenter selectedItem name
		equals: 'Boolean'.
	self deny: self projectsPresenter isClassSideSelected.
	self assert: self projectsPresenter isCategoryTabSelected
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_canDiscardSelectionEdits [

	| hitException |
	self
		testsIssue: #issue162
		withTitle: 'Unsaved changes warning rather alarming'. "https://github.com/GemTalk/JadeiteForPharo/issues/162"
	self openWorkspaceAndInspect:
		'Array with: (Dictionary new at: #oc put: (OrderedCollection with: #leaf); yourself)'.
	self assert: inspector instVarListPresenter selectedItem first equals: 'self'.
	inspector codePane text: 'change the text pane'.
	self assert: inspector codePane adapter widget hasUnacceptedEdits.
	hitException := false.
	[ inspector instVarListPresenter adapter selectIndex: 2 ]
		on: ProvideAnswerNotification
		do: [ :ex |
			hitException := true.
			self assert: ex messageText equals: 'canDiscardSelectionEdits'.
			ex resume: true ].
	self assert: hitException.
	self assert: inspector instVarListPresenter selectedItem first equals: '-.asOop'
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
JadeiteForPharoInspectorTestCase >> test_closeWithUnsavedChanges [

	self
		testsIssue: #issue722
		withTitle:
		'Unsaved inspector code pane changes get lost on inspector window close'.
	self openWorkspaceAndInspect: 'Bag new add: ''abc''; yourself'.
	inspector codePane value: 'nil'.
	inspector codePane hasUnacceptedEdits: true.
	[ inspector window close ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: false ].
	[
	self assert: inspector window isOpen.
	inspector codePane hasUnacceptedEdits: false.
	self destroy: inspector.
	self deny: inspector window isOpen.
	self destroy: workspace.
	self openWorkspaceAndInspect: 'Bag new add: ''abc''; yourself'.
	self destroy: inspector.
	self deny: inspector window isOpen ] ensure: [
		inspector codePane hasUnacceptedEdits: false ]
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
JadeiteForPharoInspectorTestCase >> test_dynamicInstVars [

	self openWorkspaceAndInspect:
		'Array new dynamicInstVarAt: #foo put: ''bar''; yourself'.
	self selectInstVarAtIndex: #( 3 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '--foo'.
	self
		assert: inspector codePane text
		equals: '''bar'''
]

{ #category : 'tests' }
JadeiteForPharoInspectorTestCase >> test_forwardBack [
	| ocIndex |
	self testsIssue: #issue153 withTitle: 'Inspector Back goes too far'.
	self openWorkspaceAndInspect: 'Array with: (Dictionary new at: #oc put: (OrderedCollection with: #leaf); yourself)'.
	inspector instVarListPresenter unselectAll. 
	inspector instVarListPresenter selectIndex: 3. "dictionary"
	inspector dive. 
	self assert: inspector codePane text equals:	'aDictionary( #''oc''->anOrderedCollection( #''leaf''))'.
	ocIndex := inspector instVarListPresenter list
				indexOf: (inspector instVarListPresenter list detect: [:item | item key = '#''oc''']).
	inspector instVarListPresenter unselectAll. 
	inspector instVarListPresenter selectIndex: ocIndex. 
	inspector dive. 
	self assert: inspector codePane text equals:	'anOrderedCollection( #''leaf'')'.
	inspector instVarListPresenter unselectAll. 
	inspector instVarListPresenter selectIndex: 3. "symbol"
	inspector dive. 
	self assert: inspector codePane text equals: '#''leaf'''. 
	inspector getPreviousObject.	"ordered collection"
	self assert: inspector codePane text equals:	'anOrderedCollection( #''leaf'')'.
	inspector getPreviousObject.	"dictionary"
	self assert: inspector codePane text equals:	'aDictionary( #''oc''->anOrderedCollection( #''leaf''))'.
	inspector getPreviousObject.	"array - root"
	self assert: inspector codePane text equals:	'anArray( aDictionary( #''oc''->anOrderedCollection( #''leaf'')))'.

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

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_inspectInstVarInNewWindow [

	self testsIssue: #issue720 withTitle: 'Would like inspect button in inspector'.
	self openWorkspaceAndInspect: '(Array with: 123) dynamicInstVarAt: #foo put: ''abc''; yourself'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector codePane text equals: '123'.
	secondInspector := inspector inspectInstVar.
	
	[self assert: secondInspector instVarListPresenter selection selectedIndex  equals: 1.
	self assert: secondInspector codePane text equals: '123']
			ensure: [self closeBrowser: secondInspector].
	self selectInstVarAtIndex: #(3).
	self assert: inspector codePane text equals: '''abc'''.
	secondInspector := inspector inspectInstVar.
	
	[self assert: secondInspector instVarListPresenter selection selectedIndex  equals: 1.
	self assert: secondInspector codePane text equals: '''abc''']
			ensure: [self closeBrowser: secondInspector].
	self selectInstVarAtIndex: 2.
	self assert: inspector instVarListPresenter selections first key equals: '-.asOop'.
	self assert: inspector isInstVarComputed.
	secondInspector := inspector inspectInstVar.
	self assertIsNil: secondInspector. 

	self selectInstVarAtIndex: 1.
	self assert: inspector instVarListPresenter selections first key equals: 'self'.
	secondInspector := inspector inspectInstVar.
	
	[self assert: secondInspector instVarListPresenter selection selectedIndex  equals: 1.
	self assert: secondInspector codePane text equals: 'anArray( 123)']
			ensure: [self closeBrowser: secondInspector]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_inspectRcIdentityBag [

	| keys |
	self openWorkspaceAndInspect:
		'RcIdentityBag with: 1 with: ''abc'' with: $k'.
	self assert: (inspector isKindOf: JadeiteInspector).
	self
		assert: inspector documentPresenter text
		equals: 'aRcIdentityBag( 1, $k, ''abc'')'.
	keys := (inspector instVarListPresenter list collect: [ :ea | ea key ])
		        asArray.
	self
		assert: (keys copyFrom: 1 to: 7)
		equals:
			#( 'self' '-.asOop' '-_varyingSize' '-_numEntries' '-_indexedPaths'
			   '-_levels' '-components' ).
	"not sure about order in an identity bag. Might need to test differently"
	self
		assert: (keys copyFrom: 8 to: 10) asSortedCollection asArray
		equals:  #('$k' '''abc''' '1')
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_inspectRcQueue [

	self openWorkspaceAndInspect: 'RcQueue new add: 1; yourself'.
	self assert: inspector codePane text equals: 'aRcQueue( 1)'.
	self assert: inspector instVarListPresenter list size equals: 23	"self + asOop + 1 inst var + default new size 20"
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_inspectSet [

	self openWorkspaceAndInspect: 'Set new add: ''abc''; yourself'.
	self
		assert: inspector codePane text
		equals: 'aSet( ''abc'')'.
	self selectInstVarAtIndex: #( 2 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '-.asOop'.
	self selectInstVarAtIndex: #( 3 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '-_varyingSize'.
	self selectInstVarAtIndex: #( 4 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '-_numEntries'.
	self selectInstVarAtIndex: #( 5 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '-_indexedPaths'.
	self selectInstVarAtIndex: #( 6 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '-_levels'.
	self selectInstVarAtIndex: #( 7 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '-dict'.
	self selectInstVarAtIndex: #( 8 ).
	self
		assert: inspector instVarListPresenter selectedItem first
		equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 8
]

{ #category : 'as yet unclassified' }
JadeiteForPharoInspectorTestCase >> test_inspectString [

	self openWorkspaceAndInspect: '''abc'''.
	self assert: (inspector isKindOf: JadeInspector).
	self assert: (session executeString:
			 'Object _objectForOop: ' , inspector oopsCollection first printString)
		= 'abc'
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

{ #category : 'support' }
JadeiteForPharoInspectorTestCase >> toolUsedForCommonTests [

	^ inspector ifNil: [ self openWorkspaceAndInspect: '3+4' ]
]
