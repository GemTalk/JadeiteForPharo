Class {
	#name : 'JadeiteRemoveMethodCommand',
	#superclass : 'JadeiteCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'execution' }
JadeiteRemoveMethodCommand >> execute [
	^context removeMethod
]
