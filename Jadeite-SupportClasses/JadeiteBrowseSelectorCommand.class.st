Class {
	#name : 'JadeiteBrowseSelectorCommand',
	#superclass : 'JadeiteBrowseCommand',
	#instVars : [
		'fullSelector'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteBrowseSelectorCommand >> computeFullSelector [

	| offset |
	offset := (self context adapter widget paragraph
		           characterBlockAtPoint: self lastClickPosition)
		          stringIndex.
	fullSelector := ((self context selectedSelector: offset) ifNil: [
		                 'it' ]) asString.
	^ fullSelector
]

{ #category : 'execution' }
JadeiteBrowseSelectorCommand >> execute [

	self recomputeLastClickPosition.
	self computeFullSelector
]

{ #category : 'accessing' }
JadeiteBrowseSelectorCommand >> fullSelector [

	^ fullSelector
]

{ #category : 'accessing' }
JadeiteBrowseSelectorCommand >> fullSelector: anObject [

	fullSelector := anObject
]

{ #category : 'accessing' }
JadeiteBrowseSelectorCommand >> jadeiteMenuNameFromSelector [

	| abbreviatedName |
	self context adapter ifNil: [ ^ String new ].
	self context adapter widget ifNil: [ ^ String new ].
	selectedText := self computeFullSelector.
	abbreviatedName := fullSelector
		                   copyFrom: 1
		                   to: (fullSelector size min: 40).
	abbreviatedName = fullSelector ifFalse: [
		abbreviatedName := abbreviatedName , ' ...' ].
	^ abbreviatedName
]

{ #category : 'as yet unclassified' }
JadeiteBrowseSelectorCommand >> recomputeLastClickPosition [

	lastClickPosition := (context adapter isNil or: [
		                      context adapter widget isNil ])
		                     ifTrue: [ 0 @ 0 ]
		                     ifFalse: [
				                     context adapter widget scrollPane textArea
					                     lastClickPosition ifNil: [ 0 @ 0 ] ]
]
