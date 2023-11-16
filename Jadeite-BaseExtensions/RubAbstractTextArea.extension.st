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
