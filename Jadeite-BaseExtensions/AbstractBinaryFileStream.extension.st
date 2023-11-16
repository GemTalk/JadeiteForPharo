Extension { #name : 'AbstractBinaryFileStream' }

{ #category : '*Jadeite-BaseExtensions' }
AbstractBinaryFileStream >> space [

	self nextPut: Character space asInteger
]
