Class {
	#name : 'JadeiteListPresenter',
	#superclass : 'SpListPresenter',
	#instVars : [
		'browser'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
JadeiteListPresenter class >> adapterName [

	^ #JadeiteListAdapter
]

{ #category : 'instance creation' }
JadeiteListPresenter class >> newFor: aBrowser [

	| inst |
	inst := super new.
	inst browser: aBrowser.
	^ inst
]

{ #category : 'instance creation' }
JadeiteListPresenter class >> newNameSortedList [

	| inst |
	inst := self new
		        display: [ :m | m displayString ];
		        sortBlock: [ :x :y | x name < y name ].
	^ inst
]

{ #category : 'instance creation' }
JadeiteListPresenter class >> newNameSortedListFor: aBrowser [

	| inst |
	inst := (self newFor: aBrowser)
		        display: [ :m | m displayString ];
		        sortBlock: [ :x :y | x name < y name ].
	^ inst
]

{ #category : 'drag & drop' }
JadeiteListPresenter >> acceptDrop [ 

	self postDrop. 
	^super acceptDrop
]

{ #category : 'api' }
JadeiteListPresenter >> add: anObject [

	self model add: anObject
]

{ #category : 'api' }
JadeiteListPresenter >> addIfAbsent: anObject [

	(self model includes: anObject) ifFalse: [ self model add: anObject ]
]

{ #category : 'sorting' }
JadeiteListPresenter >> beSorted [

	model beSorted
]

{ #category : 'accessing' }
JadeiteListPresenter >> browser [

	^ browser
]

{ #category : 'accessing' }
JadeiteListPresenter >> browser: anObject [

	browser := anObject
]

{ #category : 'testing' }
JadeiteListPresenter >> canDiscardEdits [

	^self owner canDiscardEdits
]

{ #category : 'testing' }
JadeiteListPresenter >> canDiscardSelectionEdits [

	^self owner canDiscardSelectionEdits
]

{ #category : 'selection' }
JadeiteListPresenter >> clear [
	
	self model removeAll.
	self unselectAll. 
]

{ #category : 'testing' }
JadeiteListPresenter >> hasSelection [
	model isEmpty ifTrue:[^false].
	model size < self selection selectedIndex ifTrue:[^false]. 
	^self selectedItem notNil
]

{ #category : 'api' }
JadeiteListPresenter >> invalidate [
	self refresh.	
]

{ #category : 'as yet unclassified' }
JadeiteListPresenter >> jadeiteSelections [

	^self selectedItems
]

{ #category : 'as yet unclassified' }
JadeiteListPresenter >> jaditeSelection [

	^self selectedItem
]

{ #category : 'api' }
JadeiteListPresenter >> list [

	self items ifNil: [ self model: self newEmptyModel ].
	^self items
]

{ #category : 'api' }
JadeiteListPresenter >> list: aListModel [

	aListModel isCollection
		ifTrue: [ self items: aListModel ]
		ifFalse: [ self items: aListModel collection ]
]

{ #category : 'private' }
JadeiteListPresenter >> newEmptyModel [

	^ ListModel on: OrderedCollection new
]

{ #category : 'api' }
JadeiteListPresenter >> parentPresenter [

	^self owner
]

{ #category : 'selection' }
JadeiteListPresenter >> postDrop [
	"morphic seems to leave a zombie selection after doing a drag/drop.
	This code seems to clear it. 
	As will all things related to zombies, I don't understand it. "

	self adapter ifNotNil: [ :theAdapter |
		theAdapter widget
			initializeSelectedIndexes;
			refresh ]
]

{ #category : 'api' }
JadeiteListPresenter >> remove: anObject [

	self model remove: anObject
]

{ #category : 'api' }
JadeiteListPresenter >> removeAll [

	self model removeAllItems 
]

{ #category : 'api' }
JadeiteListPresenter >> removeAll: collection [ 

	self model removeAll: collection
]

{ #category : 'api' }
JadeiteListPresenter >> resetSelection [

	self unselectAll
]

{ #category : 'sorting' }
JadeiteListPresenter >> resortOnLastColumnClicked [
	self todo: 'how to handle sorting on columns?'
]

{ #category : 'api' }
JadeiteListPresenter >> retrievePresenter [

	^self
]

{ #category : 'testing' }
JadeiteListPresenter >> selectIndex: anArray [

	self canDiscardEdits ifFalse: [ ^ self ].
	^ super selectIndex: anArray
]

{ #category : 'selection' }
JadeiteListPresenter >> selection: anObject [
	self canDiscardEdits ifFalse:[^self]. 
	^self selectItem: anObject 
]

{ #category : 'selection' }
JadeiteListPresenter >> selectionIfNone: aBlock [
self hasSelection ifFalse: [ ^aBlock value ].
	^self selectedItem ifNil: [ aBlock value ]
]

{ #category : 'selection' }
JadeiteListPresenter >> selectionOrNil [
	model isNil ifTrue:[^nil]. 
	model isEmpty ifTrue:[^nil]. 
	self selections isEmpty ifTrue:[^nil]. 
	self selection selectedIndexes max > model size ifTrue:[^nil]. 
 	^self selectedItem
]

{ #category : 'selection' }
JadeiteListPresenter >> selections [
	"there are bugs in the Spec2 lists"
 	model isEmpty ifTrue:[^OrderedCollection new]. 
	self selectionMode selectedIndexes isEmpty ifTrue:[^OrderedCollection new].
	self selectionMode selectedIndexes max > model size ifTrue:[^Array new].
 	^self selectionMode selectedItems
]

{ #category : 'selection' }
JadeiteListPresenter >> selections: aCollection [ 
	self canDiscardEdits ifFalse:[^self]. 
	self selectItems: aCollection 
]

{ #category : 'sorting' }
JadeiteListPresenter >> sortBlock: aBlock [
	self list: (ListModel on: (self list asSortedCollection: aBlock))
	
]

{ #category : 'api' }
JadeiteListPresenter >> update [
	self refresh.	
]

{ #category : 'events' }
JadeiteListPresenter >> whenNoneSelectedAndEventsNotSuspendedDo: aBlock [

	^ super whenNoneSelectedDo: [
		  browser areSelectionEventsSuspended ifFalse: [ aBlock value ] ]
]

{ #category : 'events' }
JadeiteListPresenter >> whenSelectionChangedAndEventsNotSuspendedDo: aBlock [

	^ super whenSelectionChangedDo: [ :selection |
		  browser areSelectionEventsSuspended ifFalse: [
			  aBlock cull: selection ] ]
]

{ #category : 'private - utilities' }
JadeiteListPresenter >> withWidgetDo: aValuable [

	^self withAdapterDo: [ :adaptor |
			adaptor widgetDo: aValuable]
]
