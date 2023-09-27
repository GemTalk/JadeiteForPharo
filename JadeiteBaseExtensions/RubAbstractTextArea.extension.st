Extension { #name : 'RubAbstractTextArea' }

{ #category : '*JadeiteBaseExtensions' }
RubAbstractTextArea >> editor: anEditor [
	editor := self newEditor
]

{ #category : '*JadeiteBaseExtensions' }
RubAbstractTextArea >> newJadeiteEditor [

	editor := JadeiteSmalltalkEditor forTextArea: self.
	editor gciSession: GciSession current 
]
