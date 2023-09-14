Extension { #name : 'RubAbstractTextArea' }

{ #category : '*JadeiteToolsSupportClasses' }
RubAbstractTextArea >> editor: anEditor [
	editor := self newEditor
]

{ #category : '*JadeiteToolsSupportClasses' }
RubAbstractTextArea >> newJadeiteEditor [

	editor := JaditeSmalltalkEditor forTextArea: self.
	editor gciSession: GciSession current 
]
