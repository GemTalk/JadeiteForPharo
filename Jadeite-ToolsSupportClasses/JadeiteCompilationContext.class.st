Class {
	#name : 'JadeiteCompilationContext',
	#superclass : 'CompilationContext',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteCompilationContext >> initialize [ 
	"the targetingClass: was RowanService. Not sure if that was correct or not.
	Reverting to nil class" 
	super initialize. 
	semanticScope := JadeiteMethodSemanticScope targetingClass: nil class
]
