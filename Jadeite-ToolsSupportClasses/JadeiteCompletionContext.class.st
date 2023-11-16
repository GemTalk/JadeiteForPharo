Class {
	#name : 'JadeiteCompletionContext',
	#superclass : 'CoCompletionContext',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteCompletionContext >> initialize [

	super initialize.
	completionBuilder := JadeiteResultSetBuilder initializeOnContext: self
]
