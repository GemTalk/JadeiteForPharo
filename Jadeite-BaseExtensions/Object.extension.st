Extension { #name : 'Object' }

{ #category : '*Jadeite-BaseExtensions' }
Object >> isBrowserService [	

	^false
]

{ #category : '*Jadeite-BaseExtensions' }
Object >> isInspectorService [	

	^false
]

{ #category : '*Jadeite-BaseExtensions' }
Object >> isRowanService [

	^false
]

{ #category : '*Jadeite-BaseExtensions' }
Object >> prepareForReplication [
]

{ #category : '*Jadeite-BaseExtensions' }
Object >> todo: aString [

	"place to leave a note to yourself to do something
	or to put a block of code in that won't execute which
	makes searching for unsent code easier"
]

{ #category : '*Jadeite-BaseExtensions' }
Object >> todo: aStringOrBlock inTheMeanTime: doThisInsteadBlock [

	"place to leave a note to yourself to do something
	or to put a block of code in that won't execute which
	makes searching for unsent code easier"
	
	^doThisInsteadBlock value
]

{ #category : '*Jadeite-BaseExtensions' }
Object >> update: browserUpdate withSelector: selector [ 
	browserUpdate
		updatesPerform: selector
		presenter: self.
]
