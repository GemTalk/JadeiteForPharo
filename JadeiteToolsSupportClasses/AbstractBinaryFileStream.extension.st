Extension { #name : 'AbstractBinaryFileStream' }

{ #category : '*JadeiteToolsSupportClasses' }
AbstractBinaryFileStream >> space [

	self nextPut: Character space asInteger
]
