Class {
	#name : 'JadeiteBrowseMethodReferencesCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseMethodReferencesCommand >> execute [

	self context doBrowseMethodReferences: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseMethodReferencesCommand >> name [

	^ 'Literal references to ' , self browseMenuItemName
]
