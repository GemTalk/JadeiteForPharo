Class {
	#name : 'JadeiteBrowseClassReferencesCommand',
	#superclass : 'SpBrowseClassReferencesCommand',
	#traits : 'JadeiteMenuCommandTrait',
	#classTraits : 'JadeiteMenuCommandTrait classTrait',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseClassReferencesCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseClassReferencesCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseClassReferencesCommand >> name [

	^ 'Class references to ' , self browseMenuItemName
]
