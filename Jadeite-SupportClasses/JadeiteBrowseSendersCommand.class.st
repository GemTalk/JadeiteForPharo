Class {
	#name : 'JadeiteBrowseSendersCommand',
	#superclass : 'SpBrowseSendersCommand',
	#traits : 'JadeiteMenuCommandTrait',
	#classTraits : 'JadeiteMenuCommandTrait classTrait',
	#instVars : [
		'lastClickPosition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseSendersCommand >> name [

	^ 'Senders of ' , self jadeiteMenuNameFromSelector
]
