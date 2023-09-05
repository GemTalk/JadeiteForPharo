Class {
	#name : 'JadeiteMorphicCodeCompletionEngine',
	#superclass : 'SpMorphicCodeCompletionEngine',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteMorphicCodeCompletionEngine >> initialize [

	super initialize.
	contextClass := JadeiteCompletionContext
]
