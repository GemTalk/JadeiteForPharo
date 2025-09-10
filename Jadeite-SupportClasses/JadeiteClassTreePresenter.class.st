Class {
	#name : 'JadeiteClassTreePresenter',
	#superclass : 'SpTreePresenter',
	#instVars : [
		'selectionBlock'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteClassTreePresenter class >> adapterName [

	^ #JadeiteTreeAdapter
]

{ #category : 'testing' }
JadeiteClassTreePresenter >> canExpand [

	self withAdapterDo: [ :anAdapter | ^ anAdapter canExpand ]
]

{ #category : 'actions' }
JadeiteClassTreePresenter >> clear [ 

	self roots: OrderedCollection new.
]

{ #category : 'testing' }
JadeiteClassTreePresenter >> contains: anObject [

	^ ((self pathIndexOf: (Array with: anObject)) first = 0) not
]

{ #category : 'private' }
JadeiteClassTreePresenter >> doActivateAtPath: aPath [
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
JadeiteClassTreePresenter >> initialize [ 
	super initialize. 
	roots := OrderedCollection new. 
]

{ #category : 'testing' }
JadeiteClassTreePresenter >> model [
	"trees are completely different in pharo. This is an experiment."
	^roots
]

{ #category : 'actions' }
JadeiteClassTreePresenter >> recalculateChildrenFor: path [
	"This will nil out the children for the FTBasicItem at the path so 
	a lazy initialization is done again. Not very good hooks to make trees dynamic. "

	self withAdapterDo: [ :anAdapter |
		anAdapter widgetDo: [ :w |
			(w dataSource itemAtPath: path)
				updateData;
				children ] ]
]

{ #category : 'selection' }
JadeiteClassTreePresenter >> resetSelection [ 
	self unselectAll
]

{ #category : 'selection' }
JadeiteClassTreePresenter >> scrollToSelection [
	self withAdapterPerformOrDefer: [ :anAdapter |
		adapter scrollToSelection  ]
]

{ #category : 'api - selection' }
JadeiteClassTreePresenter >> selectItem: anItem [

	self selection selectedItem = anItem ifFalse: [
		self selection selectItem: anItem ]
]

{ #category : 'api - selection' }
JadeiteClassTreePresenter >> selectPath: aPath [

	self selection selectedPath = aPath ifFalse: [
		self selection selectPath: aPath ]
]

{ #category : 'accessing' }
JadeiteClassTreePresenter >> selectionBlock [

	^ selectionBlock
]

{ #category : 'accessing' }
JadeiteClassTreePresenter >> selectionBlock: anObject [

	selectionBlock := anObject
]

{ #category : 'selection' }
JadeiteClassTreePresenter >> selectionIfNone: aBlock [

	^self selectedItem ifNil: [ aBlock value ]
]

{ #category : 'api - events' }
JadeiteClassTreePresenter >> whenSelectionChangedDo: aBlock [

	selectionBlock := aBlock.
	^ super whenSelectionChangedDo: aBlock
]
