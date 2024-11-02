Class {
	#name : 'MCRowanOrganizationDefinition',
	#superclass : 'MCOrganizationDefinition',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
MCRowanOrganizationDefinition >> initialize: aStream [
	packageName := aStream upTo: Character tab. 

]
