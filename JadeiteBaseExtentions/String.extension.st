Extension { #name : 'String' }

{ #category : '*JadeiteBaseExtentions' }
String >> replaceCrLfWithLf [

	^self 
		copyReplaceAll: Character cr asString , Character lf asString 
		with: Character lf asString.

]

{ #category : '*JadeiteBaseExtentions' }
String >> replaceCrWithLf [

	^ self
		  copyReplaceAll: Character cr asString
		  with: Character lf asString
]

{ #category : '*JadeiteBaseExtentions' }
String >> subStrings: aString [
	
	^self substrings: aString
]
