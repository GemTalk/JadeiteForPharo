Extension { #name : 'WriteStream' }

{ #category : '*Jadeite-BaseExtensions' }
WriteStream >> lftab: anInteger [
	"Used by Jadeite since we're working with 'lf' characters in the source panes, not crs
	for better or worse"

	self
		lf;
		tab: anInteger
]
