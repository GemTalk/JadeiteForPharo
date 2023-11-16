Class {
	#name : 'JadeiteClassStyle',
	#superclass : 'SpClassStyle',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'adding' }
JadeiteClassStyle >> addPropertyDrawWith: aBlock [ 
	
	self addProperty: JadeiteDrawStyle with: aBlock
]
