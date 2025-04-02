Class {
	#name : 'JadeiteBrowseClassReferencesCommand',
	#superclass : 'JadeiteBrowseCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteBrowseClassReferencesCommand >> execute [

	self context doBrowseClassReferences: selectedText
]

{ #category : 'accessing' }
JadeiteBrowseClassReferencesCommand >> name [

	^ 'Browse class references to ' , self browseMenuItemName
]
