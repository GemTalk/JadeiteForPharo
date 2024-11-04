Class {
	#name : 'MCRowanOrganizationDefinition',
	#superclass : 'MCOrganizationDefinition',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
MCRowanOrganizationDefinition >> detailsString [

^'Organization Definition'
]

{ #category : 'initialization' }
MCRowanOrganizationDefinition >> initialize: aStream [
	packageName := aStream upTo: Character tab. 
	aStream next. "lf"

]

{ #category : 'initialization' }
MCRowanOrganizationDefinition >> jadeiteClassName [

^nil
]
