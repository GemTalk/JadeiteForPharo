Extension { #name : 'Collection' }

{ #category : '*Jadeite-BaseExtensions' }
Collection >> prepareForReplication [
	self do: [:element | element prepareForReplication]
]
