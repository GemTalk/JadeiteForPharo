Extension { #name : 'MCClassDefinition' }

{ #category : '*JadeiteBaseExtentions' }
MCClassDefinition >> detailsString [

	^ 'Class Definition'
]

{ #category : '*JadeiteBaseExtentions' }
MCClassDefinition >> initialize: aStream [
	| i j | 
	packageName := aStream upTo: Character tab.
	definition := (aStream upTo: Character lf) copyReplaceAll: Character cr asString
				with: Character cr asString , Character lf asString.
	name := (definition substrings includes: 'rwSubclass:')
				ifTrue: [definition substrings fourth copyWithoutAll: #($')]
				ifFalse: 
					[i := definition indexOf: $#.
					j := definition indexOf: Character cr.
					definition copyFrom: i + 1 to: j - 1]
]
