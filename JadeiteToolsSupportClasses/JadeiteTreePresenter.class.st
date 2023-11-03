Class {
	#name : 'JadeiteTreePresenter',
	#superclass : 'SpTreePresenter',
	#category : 'JadeiteToolsSupportClasses'
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

	self roots: Array new.
]

{ #category : 'testing' }
JadeiteTreePresenter >> contains: anObject [

	^ ((self pathIndexOf: (Array with: anObject)) first = 0) not
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
	self withAdapterDo:[:anAdapter |
		anAdapter widgetDo:[:w | (w dataSource itemAtPath: path) updateData]]
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

{ #category : 'selection' }
JadeiteTreePresenter >> selectionIfNone: aBlock [

	^self selectedItem ifNil: [ aBlock value ]
]
