Extension { #name : 'MCOrganizationDefinition' }

{ #category : '*Jadeite-BaseExtensions' }
MCOrganizationDefinition >> initialize: aStream [
	packageName := aStream upTo: Character tab. 
	aStream next. "lf"
]

{ #category : '*Jadeite-BaseExtensions' }
MCOrganizationDefinition >> jadeiteClassName [ 
^nil
]
