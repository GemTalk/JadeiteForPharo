Extension { #name : 'AbstractBinaryFileStream' }

{ #category : '*JadeiteBaseExtentions' }
AbstractBinaryFileStream >> space [

	self nextPut: Character space asInteger
]
