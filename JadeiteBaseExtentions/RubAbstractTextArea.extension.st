Extension { #name : 'RubAbstractTextArea' }

{ #category : '*JadeiteBaseExtentions' }
RubAbstractTextArea >> editor: anEditor [
	editor := self newEditor
]

{ #category : '*JadeiteBaseExtentions' }
RubAbstractTextArea >> newJadeiteEditor [

	editor := JadeiteSmalltalkEditor forTextArea: self.
	editor gciSession: GciSession current 
]
