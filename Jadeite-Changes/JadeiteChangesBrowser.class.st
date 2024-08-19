Class {
	#name : 'JadeiteChangesBrowser',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait + JadeiteMethodsTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait + JadeiteMethodsTrait classTrait',
	#instVars : [
		'name',
		'diffsPresenter',
		'patch',
		'toolbar',
		'operationsListPresenter',
		'leftTextPresenter',
		'leftMemoPresenter',
		'rightTextPresenter',
		'rightMemoPresenter',
		'includesIdenticalPresenter'
	],
	#category : 'Jadeite-Changes',
	#package : 'Jadeite-Changes'
}

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser class >> showOn: aRowanPatch name: aString application: application [

	| changesBrowser |
	changesBrowser := self on: aRowanPatch.
	changesBrowser
		name: aString;
		gciSession: aRowanPatch gciSession.
	changesBrowser operationsListPresenter items: aRowanPatch operations. 
	changesBrowser application: application. 
	changesBrowser open.
	^ changesBrowser
]

{ #category : 'actions' }
JadeiteChangesBrowser >> abortTransaction [

	| abortResults |
	abortResults := self application abortTransaction.
	self refresh.
	^ abortResults
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> additionalAccelerators [
	^#(#(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> afterTitle: operation [
	^operation obsoletionMemo = operation modificationMemo
		ifTrue: ['Image (no change)']
		ifFalse: ['Image']
]

{ #category : 'queries' }
JadeiteChangesBrowser >> browseMethodClass [

	| className |
	className := self operationsListPresenter jadeiteSelections first
		             className.
	self openBrowser findClassNamed: className
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> browseSenders [
	| selection shell modifiedSelector |
	selection := operationsListPresenter selectionOrNil.
	selection isNil ifTrue: [^MessageBox notify: 'Nothing to browse'].
	selection isClassPatch ifTrue: [^MessageBox notify: 'Cannot browse senders of a non-method'].
	modifiedSelector := self modifiedSelectorForBrowsing: selection.
	[shell := self browseSendersOf: modifiedSelector] on: Error
		do: 
			[:ex |
			shell destroy.
			MessageBox notify: 'The change you have selected cannot be browsed'].
	^shell
]

{ #category : 'testing' }
JadeiteChangesBrowser >> canDiscardEdits [

	^ true
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> connectPresenters [

	super connectPresenters.
	operationsListPresenter whenSelectionChangedDo: [ :selection |
		self operationSelected ].
	includesIdenticalPresenter whenChangedDo: [ :state | self refresh ]
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> flipIdenticalSource [
	includeIdenticalPresenter value: includeIdenticalPresenter value not
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> initialize [
	super initialize.
	self todo: ["includeIdenticalPresenter := ValueHolder with: true"]
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeDiffsPresenterTo: panedLayout [
	diffsPresenter := JadeiteDiffPresenter new. 
	panedLayout add: diffsPresenter.
	diffsPresenter showOptions: false
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeJadeiteMenu [

	^ self newMenu
		  addItem: [ :item | 
			  item
				  name: 'Refresh';
				  action: [ self refresh ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Jadeite';
						  subMenu: self initializeJadeiteMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeOperationsContextMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu
		addGroup: [ :group |
			group addItem: [ :item |
					item
						name: 'Browse Class';
						action: [ self browseMethodClass ];
						enabled: [ self operationsListPresenter selections size = 1 ] ].
			group addItem: [ :item1 |
				item1
					name: 'Browse Implementors';
					action: [ self browseImplementors ];
					enabled: [
						self operationsListPresenter selections size = 1 and: [
								self operationsListPresenter selectedItem isClassPatch not ] ] ].
			group addItem: [ :item2 |
				item2
					name: 'Browse Senders';
					action: [ self browseSenders ];
					enabled: [
						self operationsListPresenter selections size = 1 and: [
								self operationsListPresenter selectedItem isClassPatch not ] ] ].
			self ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Revert';
					action: [ self revert ];
					enabled: [ self operationsListPresenter selections size = 1 ] ] ].

	self operationsListPresenter contextMenu: menu
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeOperationsListPresenterTo: panedLayout [

	| col |
	operationsListPresenter := JadeiteTablePresenter new.

	col := SpStringTableColumn
		       title: 'Type'
		       evaluated: [ :operation | operation typeString ].
	col displayColor: [ :operation |
		operation reverted ifTrue: [ Color green adjustBrightness: -0.5 ] ].
	operationsListPresenter addColumn: col.
	operationsListPresenter addColumn: (SpStringTableColumn
			 title: 'Package'
			 evaluated: [ :operation | operation packageName ]).

	operationsListPresenter addColumn: (SpStringTableColumn
			 title: 'Class'
			 evaluated: [ :operation | operation definition jadeiteClassName ]).
	operationsListPresenter addColumn: (SpStringTableColumn
			 title: 'Selector'
			 evaluated: [ :operation | operation selector ]).
	operationsListPresenter addColumn: (SpStringTableColumn
			 title: 'Detail'
			 evaluated: [ :operation | operation detailsString ]).

	panedLayout add: operationsListPresenter
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializePresenters [
	| panedLayout | 
	super initializePresenters.
	self layout spacing: 10.
	self initializeToolbar.
	panedLayout := SpPanedLayout newVertical positionOfSlider: 0.30.
	self initializeOperationsListPresenterTo: panedLayout.
	self initializeDiffsPresenterTo: panedLayout.
	self layout add: panedLayout. 
	self initializeOperationsContextMenu
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeToolbar [

	| toolbarBox |
	toolbar := self newJadeiteToolbar.
	toolbarBox := SpBoxLayout newHorizontal.
	toolbarBox add: toolbar.
	includesIdenticalPresenter := self newCheckBox
		                              label: 'Include Identical Source';
		                              state: true.
	toolbarBox
		add: includesIdenticalPresenter
		withConstraints: [ :constraints | constraints bePlacedAtEnd ].
	self layout
		add: toolbarBox
		expand: false
		fill: false
		padding: 0
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 1000 @ 1000;
		menu: self initializeMenubar.
	self updateCaption
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> modifiedSelectorForBrowsing: selection [
	| substrings |
	substrings := selection selector substrings.
	^substrings isEmpty ifTrue: [String new] ifFalse: [substrings first asSymbol]
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> name [
	^name
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> name: anObject [
	name := anObject
]

{ #category : 'instance creation' }
JadeiteChangesBrowser >> on: anMCPatch [

	patch := anMCPatch.
	self gciSession: anMCPatch gciSession 
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> operationSelected [
	| operation afterTitle |
	self showNoComparison.
	operationsListPresenter selectedItems isEmpty ifTrue: [^self].
	operation := operationsListPresenter selectedItem.
	self todo:[afterTitle := self afterTitle: operation].
	diffsPresenter
		leftLabel: 'Disk Equivalent';
		rightLabel: afterTitle;
		leftText: operation diffFromSource;
		rightText: operation diffToSource. 
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> operationsList [

	| list |
	list := operationListPresenter list. 
	includeIdenticalPresenter value ifFalse: [
		list := list reject: [:each | each hasEquivalentText].
	].
	^list asSortedCollection asArray.

]

{ #category : 'accessing' }
JadeiteChangesBrowser >> operationsListPresenter [

	^ operationsListPresenter
]

{ #category : 'accessing' }
JadeiteChangesBrowser >> operationsListPresenter: anObject [

	operationsListPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> queryCommand: aCommandQuery [
	| command |
	command := aCommandQuery command.
	command = #flipIdenticalSource
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: includeIdenticalPresenter value.
			^true].
	(#(#refresh) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	operationListPresenter selections isEmpty
		ifTrue: 
			[aCommandQuery isEnabled: false.
			^true].
	#revert = command
		ifTrue: 
			[| selection |
			selection := operationListPresenter selection.
			aCommandQuery isEnabled: selection canBeReverted.
			^true].
	^super queryCommand: aCommandQuery
]

{ #category : 'actions' }
JadeiteChangesBrowser >> refresh [

	| projectService operations |
	projectService := RowanProjectService new name: name.
	operations := projectService
		              basicChangesUsing: gciSession
		              onCompletion: [ :theOperations |
			              operations := includesIdenticalPresenter state
				                            ifTrue: [ theOperations ]
				                            ifFalse: [
				                            theOperations reject: [ :each |
					                            each hasEquivalentText ] ].
			
			              operationsListPresenter items:
				              operations asSortedCollection ]
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> refreshIdenticalSource [
	operationListPresenter
		resetSelection;
		list: self operationsList;
		yourself
]

{ #category : 'actions' }
JadeiteChangesBrowser >> revert [

	| operation revertedSource |
	operation := operationsListPresenter selectedItem.
	revertedSource := diffsPresenter leftText.
	operation isClassPatch ifTrue: [
		MessageBox notify:
			'Class definition changes cannot be reverted yet. Make changes in browser.'.
		^ self browseMethodClass ].
	operation revert: gciSession onCompletion: [
		diffsPresenter rightText: revertedSource.
		operationsListPresenter invalidate.
		self todo: [
			self
				on: Error
				do: [ :ex | MessageBox notify: 'Not able to revert this item yet' ] ] ]
]

{ #category : 'accessing' }
JadeiteChangesBrowser >> selectedMethodName [

	^self operationsListPresenter jadeiteSelections first selector
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> shellName [

	^name, ' Changes'

]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> showNoComparison [
	diffsPresenter
		leftLabel: 'Disk';
		rightLabel:  'Image'
]
