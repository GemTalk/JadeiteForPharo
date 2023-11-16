Class {
	#name : 'JadeiteCommand',
	#superclass : 'SpToolCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'execution' }
JadeiteCommand >> execute [ 
	^self subclassResponsibility
]
