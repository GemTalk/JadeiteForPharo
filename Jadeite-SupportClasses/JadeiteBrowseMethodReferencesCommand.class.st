Class {
	#name : 'JadeiteBrowseMethodReferencesCommand',
	#superclass : 'SpBrowseMethodReferencesCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseMethodReferencesCommand >> name [

	^ 'Literal references to ' , self browseMenuItemName
]
