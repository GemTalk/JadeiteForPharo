Class {
	#name : 'JadeiteRemoveMethodCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'execution' }
JadeiteRemoveMethodCommand >> execute [
	^context removeMethod
]
