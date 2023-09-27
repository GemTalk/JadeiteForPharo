Class {
	#name : 'MCRowanClassDefinition',
	#superclass : 'MCClassDefinition',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
MCRowanClassDefinition >> classDefinitionString [
	^String new
]

{ #category : 'accessing' }
MCRowanClassDefinition >> comment [

	^String new
]

{ #category : 'accessing' }
MCRowanClassDefinition >> commentStamp [

	^String new
]

{ #category : 'printing' }
MCRowanClassDefinition >> printDefinitionOn: stream [
	stream nextPutAll: definition
]
