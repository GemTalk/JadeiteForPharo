Extension { #name : 'MCDefinition' }

{ #category : '*JadeiteToolsSupportClasses' }
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

{ #category : '*JadeiteToolsSupportClasses' }
MCDefinition >> packageName [

	^packageName
]

{ #category : '*JadeiteToolsSupportClasses' }
MCDefinition >> selector [

	^String new
]
