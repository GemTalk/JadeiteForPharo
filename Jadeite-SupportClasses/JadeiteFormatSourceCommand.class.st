Class {
	#name : 'JadeiteFormatSourceCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing - defaults' }
JadeiteFormatSourceCommand class >> defaultName [
	^'Format Source'
]

{ #category : 'execution' }
JadeiteFormatSourceCommand >> execute [

	context formatSource 
]

{ #category : 'accessing' }
JadeiteFormatSourceCommand >> shortcutKey [

	^ $f alt
]
