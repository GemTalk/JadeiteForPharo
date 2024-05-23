Class {
	#name : 'JadeiteCodeExecutionCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'executing' }
JadeiteCodeExecutionCommand >> asSpecCommand [

	^ SpToolCurrentApplicationCommand decorate: super asSpecCommand
]

{ #category : 'executing' }
JadeiteCodeExecutionCommand >> evaluateSelectionAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result.
	If no selection is present select the current line."
	| selection | 
	selection := self selectedTextOrLine.
	selection ifEmpty: [ ^ '' ].
	
	^ self 
		evaluate: selection 
		andDo: aBlock
]

{ #category : 'executing' }
JadeiteCodeExecutionCommand >> execute [
	"Treat the current text selection as an expression; evaluate it."
	
	self evaluateSelectionAndDo: [ :result | ]
]

{ #category : 'executing' }
JadeiteCodeExecutionCommand >> selectedTextOrLine [

	^ self context selectedTextOrLine
]
