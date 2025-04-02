Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseImplementorsCommand >> execute [

	self context doBrowseImplementors: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self jadeiteMenuNameFromSelector
]
