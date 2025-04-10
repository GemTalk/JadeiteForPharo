Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'JadeiteBrowseSelectorCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseImplementorsCommand >> execute [

	self context doBrowseImplementors: fullSelector
]

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self jadeiteMenuNameFromSelector
]
