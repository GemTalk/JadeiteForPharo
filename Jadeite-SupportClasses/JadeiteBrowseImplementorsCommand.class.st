Class {
	#name : 'JadeiteBrowseImplementorsCommand',
	#superclass : 'SpBrowseImplementorsCommand',
	#traits : 'JadeiteMenuCommandTrait',
	#classTraits : 'JadeiteMenuCommandTrait classTrait',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseImplementorsCommand >> name [

	^ 'Implementors of ' , self jadeiteMenuNameFromSelector
]
