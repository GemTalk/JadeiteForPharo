Class {
	#name : 'JadeiteClassStyle',
	#superclass : 'SpClassStyle',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'adding' }
JadeiteClassStyle >> addPropertyDrawWith: aBlock [ 
	
	self addProperty: JadeiteDrawStyle with: aBlock
]
