Extension { #name : 'Collection' }

{ #category : '*JadeiteBaseExtentions' }
Collection >> prepareForReplication [
	self do: [:element | element prepareForReplication]
]
