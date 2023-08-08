Class {
	#name : 'MCRowanClassDefinition',
	#superclass : 'MCClassDefinition',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'printing' }
MCRowanClassDefinition >> classDefinitionString [
	^String new
]

{ #category : 'printing' }
MCRowanClassDefinition >> comment [

	^String new
]

{ #category : 'printing' }
MCRowanClassDefinition >> commentStamp [

	^String new
]

{ #category : 'printing' }
MCRowanClassDefinition >> printDefinitionOn: stream [
	stream nextPutAll: definition
]
