Class {
	#name : 'JadeiteBrowseMethodsContainingStringCommand',
	#superclass : 'SpBrowseMethodsContainingStringCommand',
	#traits : 'JadeiteMenuCommandTrait',
	#classTraits : 'JadeiteMenuCommandTrait classTrait',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseMethodsContainingStringCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseMethodsContainingStringCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseMethodsContainingStringCommand >> name [

	^ 'Method Source with ' , self browseMenuItemName
]
