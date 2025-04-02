Class {
	#name : 'JadeiteBrowseClassCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseClassCommand >> execute [

	self context doBrowseClass: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseClassCommand >> name [

	^ 'Browse class ' , self browseMenuItemName
]
