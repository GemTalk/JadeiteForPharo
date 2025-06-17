Class {
	#name : 'JadeiteRubTextFieldMorph',
	#superclass : 'SpRubTextFieldMorph',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'drawing' }
JadeiteRubTextFieldMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	color := self hasUnacceptedEdits
		         ifTrue: [
		         self theme jadeiteChangedTextBackgroundColor alpha: 1.0 ]
		         ifFalse: [ self theme jadeiteBackgroundColor alpha: 1.0 ].
	aCanvas fillRectangle: self scrollBounds color: color.
	self color: color
]

{ #category : 'model protocol' }
JadeiteRubTextFieldMorph >> hasUnacceptedEdits: aBoolean [
	"Set the hasUnacceptedEdits flag to the given value. "

	self basicHasUnacceptedEdits: aBoolean. 
]
