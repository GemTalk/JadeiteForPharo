Class {
	#name : 'JadeiteBrowseClassCommand',
	#superclass : 'SpBrowseClassCommand',
	#traits : 'JadeiteMenuCommandTrait',
	#classTraits : 'JadeiteMenuCommandTrait classTrait',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseClassCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseClassCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseClassCommand >> name [

	^ 'Browse ' , self browseMenuItemName
]
