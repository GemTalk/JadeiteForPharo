Extension { #name : 'String' }

{ #category : '*Jadeite-BaseExtensions' }
String >> encompassJadeiteParagraph: anInterval [
	"Jadeite acknowledges Character>>lf"
	| left right |
	left := (self lastIndexOf: Character lf startingAt: anInterval first - 1 ifAbsent:[0]) + 1.
	right := (self indexOf: Character lf startingAt: (anInterval last max: anInterval first) ifAbsent: [self size]).
	^left to: right
]

{ #category : '*Jadeite-BaseExtensions' }
String >> maxSkinnyPrintWidth [

	^ 80
]

{ #category : '*Jadeite-BaseExtensions' }
String >> replaceCrLfWithLf [

	^self 
		copyReplaceAll: Character cr asString , Character lf asString 
		with: Character lf asString.

]

{ #category : '*Jadeite-BaseExtensions' }
String >> replaceCrWithLf [

	^ self
		  copyReplaceAll: Character cr asString
		  with: Character lf asString
]

{ #category : '*Jadeite-BaseExtensions' }
String >> replaceLfWithCr [

	^self 
		copyReplaceAll: Character lf asString 
		with: Character cr asString
]

{ #category : '*Jadeite-BaseExtensions' }
String >> replaceLfWithCrLf [

	^self 
		copyReplaceAll: Character lf asString 
		with: Character cr asString , Character lf asString.
]

{ #category : '*Jadeite-BaseExtensions' }
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

{ #category : '*Jadeite-BaseExtensions' }
String >> subStrings: aString [
	
	^self substrings: aString
]

{ #category : '*Jadeite-BaseExtensions' }
String >> trimBlanks [

	^ self trimBoth
]
