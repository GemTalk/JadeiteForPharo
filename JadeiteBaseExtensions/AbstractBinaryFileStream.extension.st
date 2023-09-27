Extension { #name : 'AbstractBinaryFileStream' }

{ #category : '*JadeiteBaseExtensions' }
AbstractBinaryFileStream >> space [

	self nextPut: Character space asInteger
]
