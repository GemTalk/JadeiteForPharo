Class {
	#name : 'JadeiteBrowseCommand',
	#superclass : 'JadeiteCommand',
	#instVars : [
		'lastClickPosition',
		'selectedText'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'instance creation' }
JadeiteBrowseCommand class >> forSpecContext: anObject lastClickPosition: aPoint [

	^ (self new lastClickPosition: aPoint)
		  context: anObject;
		  asSpecCommand
]

{ #category : 'accessing' }
JadeiteBrowseCommand >> browseMenuItemName [

	| p verticalScrollBarValue |
	(self context adapter isNil or: [ self context adapter widget isNil ])
		ifTrue: [ ^ String new ].
	selectedText := self context selectedText.
	selectedText isEmpty ifFalse: [ ^ selectedText ]. "use selected text otherwise try to find selected word"
	p := self context adapter widget paragraph characterBlockAtPoint:
		     self lastClickPosition.
	self context adapter widget textArea markBlock: p pointBlock: p.
	self context adapter widget textArea editor selectWord.
	selectedText := self context selectedText.
	verticalScrollBarValue := self context adapter widget scrollPane
		                          vScrollbarValue.
	self context unselectAll.
	self context adapter widget scrollPane vScrollbarValue:
		verticalScrollBarValue.
	selectedText isEmpty ifTrue: [ selectedText := 'it' ].
	^ selectedText
]

{ #category : 'accessing' }
JadeiteBrowseCommand >> jadeiteMenuNameFromSelector [

	| dynamicName abbreviatedName offset |
	self context adapter ifNil: [ ^ String new ].
	self context adapter widget ifNil: [ ^ String new ].
	offset := (self context adapter widget paragraph
		           characterBlockAtPoint: self lastClickPosition)
		          stringIndex.
	dynamicName := ((self context selectedSelector: offset) ifNil: [
		                'it' ]) asString.
	abbreviatedName := dynamicName
		                   copyFrom: 1
		                   to: (dynamicName size min: 40).
	abbreviatedName = dynamicName ifFalse: [
		abbreviatedName := abbreviatedName , ' ...' ].
	^ selectedText := abbreviatedName
]

{ #category : 'accessing' }
JadeiteBrowseCommand >> lastClickPosition [

	^ lastClickPosition
]

{ #category : 'accessing' }
JadeiteBrowseCommand >> lastClickPosition: anObject [

	lastClickPosition := anObject
]

{ #category : 'accessing' }
JadeiteBrowseCommand >> selectedText [

	^ selectedText
]

{ #category : 'accessing' }
JadeiteBrowseCommand >> selectedText: anObject [

	selectedText := anObject
]
