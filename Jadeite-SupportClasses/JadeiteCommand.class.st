Class {
	#name : 'JadeiteCommand',
	#superclass : 'SpToolCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteCommand >> execute [ 
	^self subclassResponsibility
]
