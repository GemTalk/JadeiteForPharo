Class {
	#name : 'JadeiteClassStyle',
	#superclass : 'SpClassStyle',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'adding' }
JadeiteClassStyle >> addPropertyDrawWith: aBlock [ 
	
	self addProperty: JadeiteDrawStyle with: aBlock
]
