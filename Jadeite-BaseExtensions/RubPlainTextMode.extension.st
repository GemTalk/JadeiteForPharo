Extension { #name : 'RubPlainTextMode' }

{ #category : '*Jadeite-BaseExtensions' }
RubPlainTextMode >> parseSource: source [

	^RBParser parseFaultyMethod: source
]
