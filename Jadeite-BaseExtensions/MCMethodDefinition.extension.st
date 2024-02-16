Extension { #name : 'MCMethodDefinition' }

{ #category : '*Jadeite-BaseExtensions' }
MCMethodDefinition >> detailsString [

	^category
]

{ #category : '*Jadeite-BaseExtensions' }
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

{ #category : '*Jadeite-BaseExtensions' }
MCMethodDefinition >> jadeiteClassName [
	^ self classIsMeta
		  ifFalse: [ self className ]
		  ifTrue: [ self className , ' class' ]
]

{ #category : '*Jadeite-BaseExtensions' }
MCMethodDefinition >> revert: session [
	| classService |
	classService := (RowanClassService named: className asString) meta: classIsMeta.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: source with: category).
	RowanServiceUpdater current issueCommand: classService session: session
]
