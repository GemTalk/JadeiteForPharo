Class {
	#name : 'JadeiteRemoveMethodCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteRemoveMethodCommand >> execute [
	^context removeMethod
]
