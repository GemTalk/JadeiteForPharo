"
I exist solely (today) so that #asString can be implemented. #asString is used in list hot keys and the JfP dialog file lists are associations. 
"
Class {
	#name : 'JadeiteAssociation',
	#superclass : 'Association',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'instance creation' }
JadeiteAssociation class >> fromAssociation: anAssociation [

	^ self new key: anAssociation key value: anAssociation value
]

{ #category : 'as yet unclassified' }
JadeiteAssociation >> asString [
	"assumes string key"

	^ self key
]
