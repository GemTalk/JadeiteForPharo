Extension { #name : 'FileReference' }

{ #category : '*Jadeite-BaseExtensions' }
FileReference >> asJadeiteFileReference [

	^ JadeiteFileReference fileSystem: filesystem path: self path
]
