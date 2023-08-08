Extension { #name : 'Collection' }

{ #category : '*JadeiteToolsSupportClasses' }
Collection >> prepareForReplication [
	self do: [:element | element prepareForReplication]
]
