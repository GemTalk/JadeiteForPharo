Class {
	#name : 'JadeiteScrolledTextMorph',
	#superclass : 'SpRubScrolledTextMorph',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'drawing' }
JadeiteScrolledTextMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	self hasUnacceptedEdits
		ifTrue: [
		aCanvas fillColor: JadeiteApplication changedTextBackgroundColor ]
		ifFalse: [
		aCanvas fillColor: JadeiteApplication defaultBackgroundColor ].
	self drawHighlightsOn: aCanvas
]

{ #category : 'model protocol' }
JadeiteScrolledTextMorph >> resetState [

	"do nothing. Don't want the hasUnacceptedEdits: to change because
	we're probably actually changing the text now. This seems to be a 
	bug in Pharo"
]
