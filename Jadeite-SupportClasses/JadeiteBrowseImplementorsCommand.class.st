Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'SpBrowseImplementorsCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self browseMenuItemName
]
