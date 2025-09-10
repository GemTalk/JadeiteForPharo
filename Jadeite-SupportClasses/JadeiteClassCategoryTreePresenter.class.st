Class {
	#name : 'JadeiteClassCategoryTreePresenter',
	#superclass : 'SpTreePresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'specs' }
JadeiteClassCategoryTreePresenter class >> adapterName [

	^ #JadeiteClassCategoryTreeAdapter
]

{ #category : 'api' }
JadeiteClassCategoryTreePresenter >> beMultipleSelection [

	self selectionMode: (JadeiteTreeMultipleSelectionMode on: self)
]
