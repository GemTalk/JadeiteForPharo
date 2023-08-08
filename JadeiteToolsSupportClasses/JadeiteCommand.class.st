Class {
	#name : 'JadeiteCommand',
	#superclass : 'SpToolCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'execution' }
JadeiteCommand >> execute [ 
	^self subclassResponsibility
]
