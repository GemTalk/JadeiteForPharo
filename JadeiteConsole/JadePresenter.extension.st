Extension { #name : 'JadePresenter' }

{ #category : '*JadeiteConsole' }
JadePresenter class >> raiseConsole [
	| transcript |
	transcript := JadeiteConsole allInstances
				detect: [:trans | trans gciSession = GciSession current]
				ifNone: [^self].
	transcript view setFocus
]
