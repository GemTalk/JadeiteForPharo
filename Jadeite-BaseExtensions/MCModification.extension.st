Extension { #name : 'MCModification' }

{ #category : '*Jadeite-BaseExtensions' }
MCModification >> hasEquivalentText [
	| left right |
	left := obsoletion source trimBlanks.
	right := modification source trimBlanks.
	^(RBParser parseMethod: left onError: [:string :pos | ^false])
		equalTo: (RBParser parseMethod: right onError: [:string :pos | ^false])
		exceptForVariables: #()
]
