Class {
	#name : 'JadeiteCompletionContext',
	#superclass : 'CoCompletionContext',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteCompletionContext >> initialize [

	super initialize.
	completionBuilder := JadeiteResultSetBuilder initializeOnContext: self
]
