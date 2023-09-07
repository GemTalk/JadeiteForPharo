Class {
	#name : 'JadeiteMorphicCodeCompletionEngine',
	#superclass : 'SpMorphicCodeCompletionEngine',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'menu morph' }
JadeiteMorphicCodeCompletionEngine >> createContext [

	^context ifNil: [ context := super createContext ]
]

{ #category : 'initialization' }
JadeiteMorphicCodeCompletionEngine >> initialize [

	super initialize.
	contextClass := JadeiteCompletionContext
]

{ #category : 'menu morph' }
JadeiteMorphicCodeCompletionEngine >> menuClosed [
	"don't nil the context"
	menuMorph := nil.

]
