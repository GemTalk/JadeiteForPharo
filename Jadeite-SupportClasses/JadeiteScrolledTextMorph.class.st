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
	self setTabIcon.
	self hasUnacceptedEdits
		ifTrue: [
			aCanvas
				fillRectangle: self scrollBounds
				color: (JadeiteApplication changedTextBackgroundColor alpha: 1.0) ]
		ifFalse: [
			aCanvas
				fillRectangle: self scrollBounds
				color: (Smalltalk ui theme jadeiteBackgroundColor alpha: 1.0) ].
	self drawHighlightsOn: aCanvas
]

{ #category : 'model protocol' }
JadeiteScrolledTextMorph >> hasUnacceptedEdits: aBoolean [
	"Set the hasUnacceptedEdits flag to the given value. "

	self basicHasUnacceptedEdits: aBoolean. 
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

{ #category : 'as yet unclassified' }
JadeiteScrolledTextMorph >> setTabIcon [

	(self presenter owner class canUnderstand: #pageAt:) ifFalse: [
		^ self ].
	self presenter owner pages do: [ :page |
		page activePresenter ifNotNil: [ :pres |
			(pres class canUnderstand: #isModified) ifTrue: [
				pres isModified
					ifTrue: [ page icon: (self iconNamed: #protocolPrivate) ]
					ifFalse: [ page icon: nil ] ] ] ]
]
