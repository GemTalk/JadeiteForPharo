Class {
	#name : 'JadeiteBrowseClassReferencesCommand',
	#superclass : 'SpBrowseClassReferencesCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseClassReferencesCommand >> name [

	^ 'Class references to ' , self browseMenuItemName
]
