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
JadeiteBrowseSelectorCommand >> jadeiteMenuNameFromSelector [

	| abbreviatedName offset |
	self context adapter ifNil: [ ^ String new ].
	self context adapter widget ifNil: [ ^ String new ].
	offset := (self context adapter widget paragraph
		           characterBlockAtPoint: self lastClickPosition)
		          stringIndex.
	fullSelector := ((self context selectedSelector: offset) ifNil: [
		                 'it' ]) asString.
	selectedText := fullSelector.
	abbreviatedName := fullSelector
		                   copyFrom: 1
		                   to: (fullSelector size min: 40).
	abbreviatedName = fullSelector ifFalse: [
		abbreviatedName := abbreviatedName , ' ...' ].
	^ abbreviatedName
]
