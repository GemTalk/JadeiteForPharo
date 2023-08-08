Class {
	#name : 'JadeiteTreeAdapter',
	#superclass : 'SpMorphicTreeAdapter',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
JadeiteTreeAdapter class >> adaptingName [
	
	^#JadeiteTreeAdapter
]

{ #category : 'instance creation' }
JadeiteTreeAdapter >> newDataSource [ 

	^ JadeiteTreeTableDataSource new
		model: self model; 
		rootItem: (self rootForItems: self model roots);
		childrenBlock: [ :data :item | self model childrenFor: data ];
		yourself
]
