Class {
	#name : 'MCRowanClassDefinition',
	#superclass : 'MCClassDefinition',
	#instVars : [
		'definition'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
MCRowanClassDefinition >> classDefinitionString [
	^String new
]

{ #category : 'accessing' }
MCRowanClassDefinition >> classIsMeta [ 
	^false
]

{ #category : 'accessing' }
MCRowanClassDefinition >> comment [

	^String new
]

{ #category : 'accessing' }
MCRowanClassDefinition >> commentStamp [

	^String new
]

{ #category : 'initialization' }
MCRowanClassDefinition >> initialize: aStream [

	| i j |
	packageName := aStream upTo: Character tab.
	definition := (aStream upTo: Character lf)
		              copyReplaceAll: Character cr asString
		              with: Character lf asString.
	name := (definition substrings includes: 'rwSubclass:')
		        ifTrue: [
		        definition substrings fourth copyWithoutAll: #( $' ) ]
		        ifFalse: [
			        i := definition indexOf: $#.
			        j := definition indexOf: Character lf.
			        definition copyFrom: i + 1 to: j - 1 ]
]

{ #category : 'accessing' }
MCRowanClassDefinition >> jadeiteClassName [

	^name
]

{ #category : 'printing' }
MCRowanClassDefinition >> printDefinitionOn: stream [
	stream nextPutAll: definition
]
