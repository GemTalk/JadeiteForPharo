Class {
	#name : 'JadeiteInspectInstVarCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-Inspector',
	#package : 'Jadeite-Inspector'
}

{ #category : 'executing' }
JadeiteInspectInstVarCommand >> execute [
	"Execute the actions that should be done by the command.
	 This method expect that the context has been put in #context inst. var. if any context is relevant."
	self halt
]
