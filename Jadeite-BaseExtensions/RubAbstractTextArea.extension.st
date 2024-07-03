Extension { #name : 'RubAbstractTextArea' }

{ #category : '*Jadeite-BaseExtensions' }
RubAbstractTextArea >> editor: anEditor [
	editor := self newEditor
]

{ #category : '*Jadeite-BaseExtensions' }
RubAbstractTextArea >> newJadeiteEditor [

	editor := JadeiteSmalltalkEditor forTextArea: self.
	editor gciSession: GciSession current 
]

{ #category : '*Jadeite-BaseExtensions' }
RubAbstractTextArea >> recomputeSelection [
	"Jadeite override - stop the big red box"

	[self markIndex: self markIndex pointIndex: self pointIndex] on: Error do:[^self]
]

{ #category : '*Jadeite-BaseExtensions' }
RubAbstractTextArea >> segments: aCollection [ 

	segments := aCollection
]
