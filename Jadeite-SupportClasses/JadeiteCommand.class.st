Class {
	#name : 'JadeiteCommand',
	#superclass : 'SpToolCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteCommand >> execute [ 
	^self subclassResponsibility
]
