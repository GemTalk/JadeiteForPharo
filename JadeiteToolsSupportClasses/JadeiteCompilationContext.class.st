Class {
	#name : 'JadeiteCompilationContext',
	#superclass : 'CompilationContext',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteCompilationContext >> initialize [ 

	super initialize. 
	semanticScope := JadeiteMethodSemanticScope targetingClass: RowanService
]
