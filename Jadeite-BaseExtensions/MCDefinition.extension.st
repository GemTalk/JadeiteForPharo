Extension { #name : 'MCDefinition' }

{ #category : '*Jadeite-BaseExtensions' }
MCDefinition class >> fromStream: aStream [

	| char class |
	char := aStream next.
	aStream next.
	class := 
		char = $M ifTrue: [MCRowanMethodDefinition] ifFalse: [
		char = $O ifTrue: [MCRowanOrganizationDefinition] ifFalse: [
		char = $C ifTrue: [MCRowanClassDefinition] ifFalse: [
		self error: 'Invalid MCDefinition']]].
	^class new
		initialize: aStream;
		yourself.
]

{ #category : '*Jadeite-BaseExtensions' }
MCDefinition >> selector [

	^String new
]
