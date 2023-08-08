Extension { #name : 'String' }

{ #category : '*JadeiteToolsSupportClasses' }
String >> replaceCrLfWithLf [

	^self 
		copyReplaceAll: Character cr asString , Character lf asString 
		with: Character lf asString.

]

{ #category : '*JadeiteToolsSupportClasses' }
String >> subStrings: aString [
	
	^self substrings: aString
]
