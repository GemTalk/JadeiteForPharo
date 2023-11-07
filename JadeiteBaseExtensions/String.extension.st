Extension { #name : 'String' }

{ #category : '*JadeiteBaseExtensions' }
String >> maxSkinnyPrintWidth [

	^ 80
]

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
String >> skinnyPrintOn: writeStream [

	| lookingForSeparator |
	lookingForSeparator := false.
	self doWithIndex: [ :element :index |
		(lookingForSeparator and: [ element isSeparator ]) ifTrue: [
			writeStream nextPut: Character cr.
			lookingForSeparator := false ].
		writeStream nextPut: element.
		index \\\ self maxSkinnyPrintWidth = 0 ifTrue: [
			lookingForSeparator := true ] ].
	^ writeStream contents
]

{ #category : '*JadeiteBaseExtensions' }
String >> subStrings: aString [
	
	^self substrings: aString
]
