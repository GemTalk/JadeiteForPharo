Extension { #name : 'MCDefinition' }

{ #category : '*JadeiteBaseExtensions' }
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

{ #category : '*JadeiteBaseExtensions' }
MCDefinition >> packageName [

	^packageName
]

{ #category : '*JadeiteBaseExtensions' }
MCDefinition >> selector [

	^String new
]
