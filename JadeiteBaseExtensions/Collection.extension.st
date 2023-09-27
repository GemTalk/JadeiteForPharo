Extension { #name : 'Collection' }

{ #category : '*JadeiteBaseExtensions' }
Collection >> prepareForReplication [
	self do: [:element | element prepareForReplication]
]
