Extension { #name : 'String' }

{ #category : '*JadeiteBaseExtensions' }
String >> replaceCrLfWithLf [

	^self 
		copyReplaceAll: Character cr asString , Character lf asString 
		with: Character lf asString.

]

{ #category : '*JadeiteBaseExtensions' }
String >> replaceCrWithLf [

	^ self
		  copyReplaceAll: Character cr asString
		  with: Character lf asString
]

{ #category : '*JadeiteBaseExtensions' }
String >> replaceLfWithCr [

	^self 
		copyReplaceAll: Character lf asString 
		with: Character cr asString
]

{ #category : '*JadeiteBaseExtensions' }
String >> replaceLfWithCrLf [

	^self 
		copyReplaceAll: Character lf asString 
		with: Character cr asString , Character lf asString.
]

{ #category : '*JadeiteBaseExtensions' }
String >> subStrings: aString [
	
	^self substrings: aString
]
