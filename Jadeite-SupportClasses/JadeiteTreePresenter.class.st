Class {
	#name : 'JadeiteTreePresenter',
	#superclass : 'SpTreePresenter',
	#instVars : [
		'selectionBlock'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteTreePresenter class >> adapterName [

	^ #JadeiteTreeAdapter
]

{ #category : 'testing' }
JadeiteTreePresenter >> canExpand [

	self withAdapterDo: [ :anAdapter | ^ anAdapter canExpand ]
]

{ #category : 'actions' }
JadeiteTreePresenter >> clear [ 

	self roots: OrderedCollection new.
]

{ #category : 'testing' }
JadeiteTreePresenter >> contains: anObject [

	^ ((self pathIndexOf: (Array with: anObject)) first = 0) not
]

{ #category : 'private' }
JadeiteTreePresenter >> doActivateAtPath: aPath [
	"activate will handle selection activities"

	| selBlock |
	self itemAtPath: aPath ifAbsent: [ ^ self ].
	selBlock := selectionBlock.
	[
	self whenSelectionChangedDo: [  ].
	activationBlock cull: ((SpTreeSingleSelectionMode on: self)
			 selectPath: aPath;
			 yourself) ] ensure: [ self whenSelectionChangedDo: selBlock ]
]

{ #category : 'initialization' }
JadeiteTreePresenter >> initialize [ 
	super initialize. 
	roots := OrderedCollection new. 
]

{ #category : 'testing' }
JadeiteTreePresenter >> model [
	"trees are completely different in pharo. This is an experiment."
	^roots
]

{ #category : 'actions' }
JadeiteTreePresenter >> recalculateChildrenFor: path [
	"This will nil out the children for the FTBasicItem at the path so 
	a lazy initialization is done again. Not very good hooks to make trees dynamic. "

	self withAdapterDo: [ :anAdapter |
		anAdapter widgetDo: [ :w |
			(w dataSource itemAtPath: path)
				updateData;
				children ] ]
]

{ #category : 'selection' }
JadeiteTreePresenter >> resetSelection [ 
	self unselectAll
]

{ #category : 'selection' }
JadeiteTreePresenter >> scrollToSelection [
	self withAdapterPerformOrDefer: [ :anAdapter |
		adapter scrollToSelection  ]
]

{ #category : 'api - selection' }
JadeiteTreePresenter >> selectItem: anItem [

	self selection selectedItem = anItem ifFalse: [
		self selection selectItem: anItem ]
]

{ #category : 'api - selection' }
JadeiteTreePresenter >> selectPath: aPath [

	self selection selectedPath = aPath ifFalse: [
		self selection selectPath: aPath ]
]

{ #category : 'accessing' }
JadeiteTreePresenter >> selectionBlock [

	^ selectionBlock
]

{ #category : 'accessing' }
JadeiteTreePresenter >> selectionBlock: anObject [

	selectionBlock := anObject
]

{ #category : 'selection' }
JadeiteTreePresenter >> selectionIfNone: aBlock [

	^self selectedItem ifNil: [ aBlock value ]
]

{ #category : 'api - events' }
JadeiteTreePresenter >> whenSelectionChangedDo: aBlock [

	selectionBlock := aBlock.
	^ super whenSelectionChangedDo: aBlock
]
