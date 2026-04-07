Class {
	#name : 'JadeiteTablePresenter',
	#superclass : 'SpTablePresenter',
	#instVars : [
		'searchSelector'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'specs' }
JadeiteTablePresenter class >> adapterName [ 
	^#JadeiteTableAdapter
]

{ #category : 'instance creation' }
JadeiteTablePresenter class >> new [

	^super new beResizable 
]

{ #category : 'testing' }
JadeiteTablePresenter >> canDiscardEdits [

	^self owner canDiscardEdits
]

{ #category : 'testing' }
JadeiteTablePresenter >> canDiscardSelectionEdits [

	^self owner canDiscardSelectionEdits
]

{ #category : 'testing' }
JadeiteTablePresenter >> hasSelection [

	^ self selectionOrNil notNil
]

{ #category : 'displaying' }
JadeiteTablePresenter >> invalidate [
	self refresh.	
]

{ #category : 'displaying' }
JadeiteTablePresenter >> jadeiteSelections [

	^self selectedItems
]

{ #category : 'accessing' }
JadeiteTablePresenter >> jaditeSelection [

	^self selectedItem
]

{ #category : 'accessing' }
JadeiteTablePresenter >> list [

	^self model
]

{ #category : 'accessing' }
JadeiteTablePresenter >> list: aListModel [

	self model: aListModel
]

{ #category : 'accessing' }
JadeiteTablePresenter >> newEmptyModel [

	^ ListModel on: OrderedCollection new
]

{ #category : 'removing' }
JadeiteTablePresenter >> removeAll: removals [

	self model removeAll: removals 
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> resetSelection [ 
	self unselectAll
]

{ #category : 'accessing' }
JadeiteTablePresenter >> searchSelector [

	^ searchSelector
]

{ #category : 'accessing' }
JadeiteTablePresenter >> searchSelector: anObject [

	searchSelector := anObject
]

{ #category : 'private' }
JadeiteTablePresenter >> searchValueOf: item [

	^ searchSelector
		  ifNil: [ super searchValueOf: item ]
		  ifNotNil: [ :sel | item perform: sel ]
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> selectFirstIndex [

	self list notEmpty ifTrue: [ self selectionByIndex: 1 ]
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> selectFirstMethod [

	self todo: 'this should probably not be in a generic list presenter'.
	self selectFirstIndex
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> selectionByIndex: anIndex [

	self selectIndex: anIndex
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> selectionIfNone: aBlock [

	^self selectionOrNil ifNil: [ aBlock value ]
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> selectionOrNil [
	model isNil ifTrue:[^nil]. 
	model isEmpty ifTrue:[^nil]. 
	self selections isEmpty ifTrue:[^nil]. 
	self selection selectedIndexes max > model size ifTrue:[^nil]. 
 	^self selectedItem
]

{ #category : 'api - selection' }
JadeiteTablePresenter >> selections [
	"there are bugs in the Spec2 lists"
 	model isEmpty ifTrue:[^OrderedCollection new]. 
	self selectionMode selectedIndexes isEmpty ifTrue:[^OrderedCollection new].
	self selectionMode selectedIndexes max > model size ifTrue:[^Array new].
 	^self selectionMode selectedItems
]
