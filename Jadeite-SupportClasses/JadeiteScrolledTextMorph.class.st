Class {
	#name : 'JadeiteScrolledTextMorph',
	#superclass : 'SpRubScrolledTextMorph',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'as yet unclassified' }
JadeiteScrolledTextMorph >> drawOn: aCanvas [

	aCanvas
		fillRectangle: self bounds
		fillStyle: self fillStyle
		borderStyle: self borderStyle. "from super super drawOn:"
	self hasUnacceptedEdits
		ifTrue: [
			aCanvas
				fillRectangle: self scrollBounds
				color: (JadeiteApplication changedTextBackgroundColor alpha: 1.0) ]
		ifFalse: [
			aCanvas
				fillRectangle: self scrollBounds
				color: (JadeiteApplication defaultBackgroundColor alpha: 1.0) ].
	self drawHighlightsOn: aCanvas
]

{ #category : 'model protocol' }
JadeiteScrolledTextMorph >> resetState [

	"do nothing. Don't want the hasUnacceptedEdits: to change because
	we're probably actually changing the text now. This seems to be a 
	bug in Pharo"
]
