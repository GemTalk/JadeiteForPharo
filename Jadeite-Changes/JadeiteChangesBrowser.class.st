Class {
	#name : 'JadeiteChangesBrowser',
	#superclass : 'JadeitePresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'name',
		'diffsPresenter',
		'patch',
		'toolbar',
		'operationsListPresenter',
		'leftTextPresenter',
		'leftMemoPresenter',
		'rightTextPresenter',
		'rightMemoPresenter'
	],
	#category : 'Jadeite-Changes'
}

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser class >> showOn: aRowanPatch name: aString application: application [

	| changesBrowser |
	changesBrowser := self on: aRowanPatch.
	changesBrowser
		name: aString;
		gciSession: aRowanPatch gciSession.
	changesBrowser operationsListPresenter items: aRowanPatch operations. 
	changesBrowser open.
	changesBrowser owner application: application. 
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

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> browseImplementors [
	| selection shell methodListPresenter changedMethod modifiedSelector |
	selection := operationListPresenter selectionOrNil.
	selection isNil ifTrue: [^MessageBox notify: 'Nothing to browse'].
	selection isMethod ifFalse: [^MessageBox notify: 'Cannot browse implementors of a non-method'].
	modifiedSelector := self modifiedSelectorForBrowsing: selection.
	
	[shell := JadePresenter browseImplementorsOf: modifiedSelector session: self gciSession.
	methodListPresenter := shell primaryPresenter methodListPresenter methodListPresenter.
	changedMethod := methodListPresenter list
				detect: [:methodService | methodService className = selection className]
				ifNone: [^shell].
	methodListPresenter selection: changedMethod]
			on: Error
			do: 
				[:ex |
				shell destroy.
				MessageBox notify: 'The change you have selected cannot be browsed'].
	^shell
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> browseSenders [
	| selection shell modifiedSelector |
	selection := operationListPresenter selectionOrNil.
	selection isNil ifTrue: [^MessageBox notify: 'Nothing to browse'].
	selection isMethod ifFalse: [^MessageBox notify: 'Cannot browse senders of a non-method'].
	modifiedSelector := self modifiedSelectorForBrowsing: selection.
	[shell := JadePresenter browseSendersOf: modifiedSelector session: self gciSession] on: Error
		do: 
			[:ex |
			shell destroy.
			MessageBox notify: 'The change you have selected cannot be browsed'].
	^shell
]

{ #category : 'actions' }
JadeiteChangesBrowser >> commitTransaction [
	^self application commitTransaction
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> connectPresenters [

	super connectPresenters.
	operationsListPresenter whenSelectionChangedDo: [ :selection | 
		self operationSelected ]
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> createSchematicWiring [
	super createSchematicWiring.
	includeIdenticalPresenter
		when: #valueChanged
		send: #refreshIdenticalSource
		to: self.
	operationListPresenter
		when: #selectionChanged
		send: #operationSelected
		to: self
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
	includeIdenticalPresenter := ValueHolder with: true
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeDiffsPresenter [
	diffsPresenter := JadeiteDiffPresenter new. 
	self layout add: diffsPresenter
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
						  subMenu: self initializeJadeiteMenu  ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeOperationsListPresenter [

	operationsListPresenter := JadeiteTablePresenter new.
	operationsListPresenter addColumn: (SpStringTableColumn
			 title: 'Type'
			 evaluated: [ :operation | operation typeString ]).

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

	self layout add: operationsListPresenter
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializePresenters [

	super initializePresenters.
	self layout spacing: 10.
	self initializeToolbar.
	self initializeOperationsListPresenter.
	self initializeDiffsPresenter. 
]

{ #category : 'initialization' }
JadeiteChangesBrowser >> initializeToolbar [

	toolbar := self newJadeiteToolbar.
	self layout
		add: #toolbar
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
	substrings := selection selector subStrings.
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
	operations := projectService basicChangesUsing: gciSession. 
	operationsListPresenter items: operations asSortedCollection
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> refreshIdenticalSource [
	operationListPresenter
		resetSelection;
		list: self operationsList;
		yourself
]

{ #category : 'as yet unclassified' }
JadeiteChangesBrowser >> revert [
	| operation afterTitle |
	
	[operation := operationListPresenter selection.
	operation revert: gciSession.
	operation clearObsoletionMemo.
	afterTitle := self afterTitle: operation.
	diffsPresenter beforePresenter value: String new.	"resetting value first seems to be necessary to clear highlighting even though indicators get cleared"
	diffsPresenter afterPresenter value: String new.
	diffsPresenter
		clearDiffs;
		afterTitle: afterTitle;
		compare: operation obsoletionMemo with: operation modificationMemo.
	diffsPresenter view invalidate.
	operationListPresenter view invalidate]
			on: Error
			do: [:ex | MessageBox notify: 'Not able to revert this item yet']
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
