Class {
	#name : 'JadeiteFormatSourceCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'accessing - defaults' }
JadeiteFormatSourceCommand class >> defaultName [
	^'Format Source'
]

{ #category : 'execution' }
JadeiteFormatSourceCommand >> execute [

	context formatSource 
]
