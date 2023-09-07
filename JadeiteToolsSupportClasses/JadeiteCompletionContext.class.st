Class {
	#name : 'JadeiteCompletionContext',
	#superclass : 'CoCompletionContext',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'testing' }
JadeiteCompletionContext >> completion [

	completion ifNotNil: [
		completion filter completionString: self completionToken.
		completion fetcher reset. 
		^ completion ].
	^ super completion
]

{ #category : 'initialization' }
JadeiteCompletionContext >> initialize [

	super initialize.
	completionBuilder := JadeiteResultSetBuilder initializeOnContext: self
]
