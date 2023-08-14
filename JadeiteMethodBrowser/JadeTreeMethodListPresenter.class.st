Class {
	#name : 'JadeTreeMethodListPresenter',
	#superclass : 'JadeMethodListPresenter',
	#instVars : [
		'treeMethodsPresenter',
		'treeMethodsMap',
		'historyEntries',
		'entriesIndex'
	],
	#category : 'JadeiteMethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> addList [
	| node |

	node := Prompter prompt: 'Enter List Name'.
	node ifNil: [^self].
	node isEmpty ifTrue: [].

	treeMethodsPresenter model add: node asChildOf: treeMethodsPresenter selectionOrNil.

	treeMethodsPresenter expand: treeMethodsPresenter selectionOrNil.

	treeMethodsMap at: node put: SortedCollection new.

	^node
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> addTreeListRoot: methodName type: browseType [
	| node |

	node := self getLabelForMethod: methodName type: browseType .

	treeMethodsPresenter model: (TreeModel withRoots: (Array with: node)).

	^node
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> browse: performSelector method: aGsMethodOrString [

	| string |
	(aGsMethodOrString isKindOf: String) ifTrue: [
		self browse: performSelector methodSelector: aGsMethodOrString.
		string := aGsMethodOrString.
	] ifFalse: [
		self browse: performSelector gsMethod: aGsMethodOrString.
		string := aGsMethodOrString name.
	].
	self selecting: string.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> buildHistoryBackMenu [

	^(self buildHistoryMenuWith: (historyEntries copyFrom: 1 to: entriesIndex) command: #historyBack:)
		text: 'Backward';
		yourself
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> buildHistoryForwardMenu [

	^(self buildHistoryMenuWith: (historyEntries copyFrom: entriesIndex to: historyEntries size) command: #historyForward:)
		text: 'Forward';
		yourself
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> buildHistoryMenuWith: entryCollection command: command [
	| popup subMenu classesNames |

	classesNames := Set new.
	popup := Menu new.

	(entryCollection select: [:each | each notNil]) do: [:historyEntry | 
		(classesNames includes: historyEntry getClassName) 
		ifFalse: [subMenu := popup addSubmenu: historyEntry getClassName.
				classesNames add: historyEntry getClassName].
		subMenu addCommand: (Message selector: command argument: historyEntry) description: historyEntry getMethodName.
		subMenu setDefault: 1
	].

	popup setDefault: 1.
	^popup
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> createComponents [

	super createComponents.

	treeMethodsPresenter := self add: TreePresenter new name: 'treeMethods'.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> createSchematicWiring [

	super createSchematicWiring.

	treeMethodsPresenter 
		when: #selectionChanged send: #onTreeListChanged to: self;
		when: #dragOver: send: #onDragOverMethodsTree: to: self;
		when: #drop: send: #onDropMethodsTree: to: self;
		when: #drag: send: #onDragMethodsTree: to: self.

	methodListPresenter when: #methodSelectionChanged send: #onMethodSelectionChanged to: self.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> deleteHistory [

	historyEntries := OrderedCollection new.
	entriesIndex := 1.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> dropGsMethod: aDragDropSession [ 

	(treeMethodsMap at: aDragDropSession suggestedTarget ifAbsent: [^self]) add: aDragDropSession suggestedSource.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> dropNode: aDragDropSession [

	treeMethodsPresenter model move: aDragDropSession suggestedSource asChildOf: aDragDropSession suggestedTarget.

	treeMethodsPresenter expand: aDragDropSession suggestedTarget.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> entriesIndex [
	^entriesIndex
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> entriesIndex: anObject [
	entriesIndex := anObject
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> getLabelForMethod: methodName type: browseType [

	^(browseType = #definitions) ifTrue: ['Implementors of ', methodName] ifFalse: ['Senders of ', methodName]
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> gsBrowse: performSelector methodSelector: aString [

	^self gciSession serverPerform: performSelector with: aString
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> hasTreeListSelection [

	^treeMethodsPresenter hasSelection
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> historyBack [

	entriesIndex := entriesIndex - 1.
	(entriesIndex <= 0) ifTrue: [entriesIndex := 1].

	(historyEntries size = 0) ifTrue: [^self].

	self restoreFrom: (historyEntries at: entriesIndex).
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> historyBack: aJadeHistoryEntry [
	
	self restoreFrom: aJadeHistoryEntry
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> historyEntries [
	^historyEntries
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> historyEntries: anObject [
	historyEntries := anObject
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> historyForward [

	entriesIndex := entriesIndex + 1.
	(entriesIndex > historyEntries size) ifTrue: [entriesIndex := 1].

	(historyEntries size = 0) ifTrue: [^self].

	self restoreFrom: (historyEntries at: entriesIndex).
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> historyForward: aJadeHistoryEntry [

	self restoreFrom: aJadeHistoryEntry
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> initialize [

	super initialize.

	historyEntries := OrderedCollection new.
	entriesIndex := 1.
	treeMethodsMap := Dictionary new.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> onDragMethodsTree: aDragDropSession [


]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> onDragOverMethodsTree: aDragDropSession [

	aDragDropSession operation: nil.
	aDragDropSession dragObjects isEmpty ifTrue: [^self].

	aDragDropSession
		supportedOperations: #(#'move');
		operation: #'move';
		yourself.
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> onHistoryDropDown: aToolbarButton [ 
	"Private - The receiver's toolbar has sent a notification that a button's drop-down arrow
	has been pressed. Generate and pop-up the appropriate menu."
	| popup |

	aToolbarButton command == #historyBack ifTrue: [popup :=  self buildHistoryBackMenu].
	aToolbarButton command == #historyForward ifTrue: [popup := self buildHistoryForwardMenu].
	popup queryAllFromView: self topShell view.
	popup showIn: self topShell position: aToolbarButton screenRectangle bottomLeft.

	^0
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> onMethodSelectionChanged [
	| entry |

	self selectedMethod ifNil: [^self].

	entry := JadeMethodExplorerHistoryEntry newFrom: self.

	(historyEntries anySatisfy: [:each | each gsMethod == entry gsMethod]) ifFalse: [historyEntries add: entry].
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> onTreeListChanged [

	self hasTreeListSelection ifFalse: [^methodListPresenter model: ListModel new].

	methodListPresenter list: (treeMethodsMap at: treeMethodsPresenter selection ifAbsent: [#()]).

	"methodListPresenter selectFirstMethod"

]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> onViewOpened [
	| toolbar |

	super onViewOpened.

	methodSourcePresenter documentPresenter view styler: SmalltalkMethodStyler new.

	toolbar := self topShell view viewNamed: 'historyToolbar'.

	toolbar presenterConnectionPoint 
		when: #dropDown:
		send: #onHistoryDropDown:
		to: self.

]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> removeQueryElement [

	treeMethodsPresenter hasSelection ifFalse: [^self].

	treeMethodsPresenter model remove: treeMethodsPresenter selection ifAbsent: []
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> restoreFrom: aJadeHistoryEntry [

	treeMethodsPresenter selection: aJadeHistoryEntry treeSelection ifAbsent: [].

	methodListPresenter selectMethod: aJadeHistoryEntry gsMethod
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> selectedExplorerNode [

	^treeMethodsPresenter selectionOrNil
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> selectedMethod [

	^methodListPresenter selectionOrNil
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> treeListHasSelection [

	^treeMethodsPresenter hasSelection
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> treeMethodsMap [
	^treeMethodsMap
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> treeMethodsMap: anObject [
	treeMethodsMap := anObject
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> treeMethodsPresenter [
	^treeMethodsPresenter
]

{ #category : 'as yet unclassified' }
JadeTreeMethodListPresenter >> treeMethodsPresenter: anObject [
	treeMethodsPresenter := anObject
]
