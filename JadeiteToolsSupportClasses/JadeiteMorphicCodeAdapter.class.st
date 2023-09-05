Class {
	#name : 'JadeiteMorphicCodeAdapter',
	#superclass : 'SpMorphicCodeAdapter',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'private' }
JadeiteMorphicCodeAdapter >> newCompletionEngine: anInteractionModel [

	^ JadeiteMorphicCodeCompletionEngine new 
		smartCharacters: self presenter hasSmartCharacters;
		scripting: anInteractionModel isScripting;
		doItRequestor: anInteractionModel;
		doItContext: anInteractionModel doItContext;
		completionClass: anInteractionModel selectedClassOrMetaClass;
		yourself
]
