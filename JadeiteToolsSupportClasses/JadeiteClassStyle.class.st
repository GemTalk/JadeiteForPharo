Class {
	#name : 'JadeiteClassStyle',
	#superclass : 'SpClassStyle',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'adding' }
JadeiteClassStyle >> addPropertyDrawWith: aBlock [ 
	
	self addProperty: JadeiteDrawStyle with: aBlock
]
