Extension { #name : 'Object' }

{ #category : '*JadeiteBaseExtensions' }
Object >> isBrowserService [	

	^false
]

{ #category : '*JadeiteBaseExtensions' }
Object >> isInspectorService [	

	^false
]

{ #category : '*JadeiteBaseExtensions' }
Object >> isRowanService [

	^false
]

{ #category : '*JadeiteBaseExtensions' }
Object >> prepareForReplication [
]

{ #category : '*JadeiteBaseExtensions' }
Object >> todo: aString [

	"place to leave a note to yourself to do something
	or to put a block of code in that won't execute which
	makes searching for unsent code easier"
]

{ #category : '*JadeiteBaseExtensions' }
Object >> todo: aStringOrBlock inTheMeanTime: doThisInsteadBlock [

	"place to leave a note to yourself to do something
	or to put a block of code in that won't execute which
	makes searching for unsent code easier"
	
	^doThisInsteadBlock value
]

{ #category : '*JadeiteBaseExtensions' }
Object >> update: browserUpdate withSelector: selector [ 
	browserUpdate
		updatesPerform: selector
		presenter: self.
]
