Class {
	#name : 'JadeiteScrolledTextMorph',
	#superclass : 'SpRubScrolledTextMorph',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'as yet unclassified' }
JadeiteScrolledTextMorph >> drawOn: aCanvas [

	aCanvas
		fillRectangle: self bounds
		fillStyle: self fillStyle
		borderStyle: self borderStyle. "from super super drawOn:"
	JadeiteBrowserPresenter allInstances do: [ :browser | 
		"the ugliest of uglies!  We don't have access to the methodSource tab
	morph when we need to draw the dot on the tab label but when this 
	method is accessed, it's redrawing the text pane. "
		browser sourcePaneChanged ].
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

{ #category : 'as yet unclassified' }
JadeiteScrolledTextMorph >> segments: aCollection [

	self textArea segments: aCollection
]
