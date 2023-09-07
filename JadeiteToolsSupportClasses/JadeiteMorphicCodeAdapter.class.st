Class {
	#name : 'JadeiteMorphicCodeAdapter',
	#superclass : 'SpMorphicCodeAdapter',
	#instVars : [
		'completionEngine'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'private' }
JadeiteMorphicCodeAdapter >> newCompletionEngine: anInteractionModel [

	^ completionEngine ifNil: [
		  completionEngine := JadeiteMorphicCodeCompletionEngine new
			                      smartCharacters:
				                      self presenter hasSmartCharacters;
			                      scripting: anInteractionModel isScripting;
			                      doItRequestor: anInteractionModel;
			                      doItContext: anInteractionModel doItContext;
			                      completionClass:
				                      anInteractionModel selectedClassOrMetaClass;
			                      yourself ]
]
