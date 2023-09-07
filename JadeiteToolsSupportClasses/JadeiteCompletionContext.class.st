Class {
	#name : 'JadeiteCompletionContext',
	#superclass : 'CoCompletionContext',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteCompletionContext >> initialize [

	super initialize.
	completionBuilder := JadeiteResultSetBuilder initializeOnContext: self
]
