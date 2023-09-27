Extension { #name : 'MCDefinition' }

{ #category : '*JadeiteBaseExtentions' }
MCDefinition class >> fromStream: aStream [

	| char class |
	char := aStream next.
	aStream next.
	class := 
		char = $M ifTrue: [MCMethodDefinition] ifFalse: [
		char = $O ifTrue: [MCOrganizationDefinition] ifFalse: [
		char = $C ifTrue: [MCRowanClassDefinition] ifFalse: [
		self error: 'Invalid MCDefinition']]].
	^class new
		initialize: aStream;
		yourself.
]

{ #category : '*JadeiteBaseExtentions' }
MCDefinition >> packageName [

	^packageName
]

{ #category : '*JadeiteBaseExtentions' }
MCDefinition >> selector [

	^String new
]
