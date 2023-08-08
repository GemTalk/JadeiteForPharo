Extension { #name : 'MCMethodDefinition' }

{ #category : '*JadeiteToolsSupportClasses' }
MCMethodDefinition >> detailsString [

	^category
]

{ #category : '*JadeiteToolsSupportClasses' }
MCMethodDefinition >> initialize: aStream [
	| size |
	timeStamp := aStream upTo: Character tab.
	packageName := aStream upTo: Character tab. 
	className := aStream upTo: Character tab. 
	classIsMeta := (aStream upTo: Character tab) = 'true'.
	category := aStream upTo: Character tab.
	selector := aStream upTo: Character tab.
	size := (aStream upTo: Character tab) asNumber + 1.
	source := (aStream next: size) copyReplaceAll: (Array with: Character cr) with: (Array with: Character lf).
	source := source copyFrom: 1 to: (source size - 1 max: 1)	"remove trailing lf"
]
