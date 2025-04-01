Class {
	#name : 'JadeiteBrowseMethodReferencesCommand',
	#superclass : 'SpBrowseMethodReferencesCommand',
	#traits : 'JadeiteMenuCommandTrait',
	#classTraits : 'JadeiteMenuCommandTrait classTrait',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseMethodReferencesCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseMethodReferencesCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseMethodReferencesCommand >> name [

	^ 'Literal references to ' , self browseMenuItemName
]
