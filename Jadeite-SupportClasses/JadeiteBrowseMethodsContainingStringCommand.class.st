Class {
	#name : 'JadeiteBrowseMethodsContainingStringCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseMethodsContainingStringCommand >> execute [

	self context doBrowseMethodsContainingString: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseMethodsContainingStringCommand >> name [

	^ 'Method source with ' , self browseMenuItemName
]
