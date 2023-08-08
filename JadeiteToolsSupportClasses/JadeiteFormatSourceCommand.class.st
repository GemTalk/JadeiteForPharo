Class {
	#name : 'JadeiteFormatSourceCommand',
	#superclass : 'JadeiteCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing - defaults' }
JadeiteFormatSourceCommand class >> defaultName [
	^'Format Source'
]

{ #category : 'execution' }
JadeiteFormatSourceCommand >> execute [

	context formatSource 
]
