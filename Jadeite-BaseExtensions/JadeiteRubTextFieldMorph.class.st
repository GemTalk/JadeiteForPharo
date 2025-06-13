Class {
	#name : 'JadeiteRubTextFieldMorph',
	#superclass : 'SpRubTextFieldMorph',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'drawing' }
JadeiteRubTextFieldMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.
	self hasUnacceptedEdits traceCr
		ifTrue: [
			aCanvas
				fillRectangle: self scrollBounds
				color: (self theme jadeiteChangedTextBackgroundColor alpha: 1.0) ]
		ifFalse: [
			aCanvas
				fillRectangle: self scrollBounds
				color: (self theme jadeiteBackgroundColor alpha: 1.0) ].
	
	
]

{ #category : 'model protocol' }
JadeiteRubTextFieldMorph >> hasUnacceptedEdits: aBoolean [
	"Set the hasUnacceptedEdits flag to the given value. "

	self basicHasUnacceptedEdits: aBoolean. 
]
