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

{ #category : 'selection' }
JadeiteTreePresenter >> scrollToSelection [
	self withAdapterPerformOrDefer: [ :anAdapter |
		adapter scrollToSelection  ]
]

{ #category : 'selection' }
JadeiteTreePresenter >> selectionIfNone: aBlock [

	^self selectedItem ifNil: [ aBlock value ]
]
