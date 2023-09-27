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
String >> subStrings: aString [
	
	^self substrings: aString
]
