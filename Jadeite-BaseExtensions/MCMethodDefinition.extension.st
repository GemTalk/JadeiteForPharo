Extension { #name : 'MCMethodDefinition' }

{ #category : '*Jadeite-BaseExtensions' }
MCMethodDefinition >> detailsString [

	^category
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

{ #category : '*Jadeite-BaseExtensions' }
MCMethodDefinition >> revertAddition: session [

	| classService methodService |
	classService := (RowanClassService named: className asString) meta:
		                classIsMeta.
	methodService := RowanMethodService new
		                 className: className asString;
		                 selector: selector asSymbol;
		                 meta: classIsMeta.
	classService
		command: #removeMethods:;
		commandArgs: (Array with: (Array with: methodService)).
	RowanServiceUpdater current
		issueCommand: classService
		session: session
]
