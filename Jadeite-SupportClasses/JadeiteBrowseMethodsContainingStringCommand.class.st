Class {
	#name : 'JadeiteBrowseMethodsContainingStringCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'defaults' }
JadeiteBrowseMethodsContainingStringCommand class >> defaultShortcutKey [

	^ $e shift command mac 
		| $e shift control win
		| $e shift control unix
]

{ #category : 'execution' }
JadeiteBrowseMethodsContainingStringCommand >> execute [

	self context doBrowseMethodsContainingString: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseMethodsContainingStringCommand >> name [

	^ 'Method source with ' , self browseMenuItemName
]
