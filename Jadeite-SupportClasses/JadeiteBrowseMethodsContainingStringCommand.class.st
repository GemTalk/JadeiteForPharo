Class {
	#name : 'JadeiteBrowseMethodsContainingStringCommand',
	#superclass : 'SpBrowseMethodsContainingStringCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseMethodsContainingStringCommand >> name [

	^ 'Method Source with ' , self browseMenuItemName
]
