Extension { #name : 'Object' }

{ #category : '*JadeiteBaseExtentions' }
Object >> prepareForReplication [
]

{ #category : '*JadeiteBaseExtentions' }
Object >> todo: aString [

	"place to leave a note to yourself to do something
	or to put a block of code in that won't execute which
	makes searching for unsent code easier"
]

{ #category : '*JadeiteBaseExtentions' }
Object >> todo: aStringOrBlock inTheMeanTime: doThisInsteadBlock [

	"place to leave a note to yourself to do something
	or to put a block of code in that won't execute which
	makes searching for unsent code easier"
	
	^doThisInsteadBlock value
]
