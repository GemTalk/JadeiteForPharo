Extension { #name : 'RubAbstractTextArea' }

{ #category : '*JadeiteToolsSupportClasses' }
RubAbstractTextArea >> editor: anEditor [
	editor := self newEditor
]

{ #category : '*JadeiteToolsSupportClasses' }
RubAbstractTextArea >> newJadeiteEditor [

	editor := JadeiteSmalltalkEditor forTextArea: self.
	editor gciSession: GciSession current 
]
