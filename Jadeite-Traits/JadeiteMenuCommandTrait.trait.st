Trait {
	#name : 'JadeiteMenuCommandTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'instance creation' }
JadeiteMenuCommandTrait classSide >> forSpecContext: anObject lastClickPosition: aPoint [

	^ (self new lastClickPosition: aPoint)
		  context: anObject;
		  asSpecCommand
]

{ #category : 'accessing' }
JadeiteMenuCommandTrait >> browseMenuItemName [

	| sel p |
	(self context adapter isNil or: [ self context adapter widget isNil ])
		ifTrue: [ ^ String new ].
	sel := self context selectedText.
	sel isEmpty ifFalse: [ ^ sel ]. "use selected text otherwise try to find selected word"
	p := self context adapter widget paragraph characterBlockAtPoint:
		     self lastClickPosition.
	self context adapter widget textArea markBlock: p pointBlock: p.
	self context adapter widget textArea editor selectWord.
	sel := self context selectedText.
	self context unselectAll.
	sel isEmpty ifTrue: [ sel := 'it' ].
	^ sel
]

{ #category : 'accessing' }
JadeiteMenuCommandTrait >> jadeiteMenuNameFromSelector [

	| dynamicName abbreviatedName offset |
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
	^ abbreviatedName
]
