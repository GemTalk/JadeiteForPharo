Extension { #name : 'RubAbstractTextArea' }

{ #category : '*JadeiteToolsSupportClasses' }
RubAbstractTextArea >> newJadeiteEditor [

	editor := JaditeSmalltalkEditor forTextArea: self.
	editor gciSession: GciSession current 
]
