"
Can't subclass SpCodeInspectItCommand because code context menus are built by iterating over the subclasses of SpCodeInspectItCommand. Therefore, must duplicate code here.
"
Class {
	#name : 'JadeiteCodeInspectItCommand',
	#superclass : 'SpToolCommand',
	#category : 'Jadeite-Inspector'
}

{ #category : 'accessing - defaults' }
JadeiteCodeInspectItCommand class >> defaultDescription [

	^ 'Evaluate selection and inspect the result.'
]

{ #category : 'accessing - defaults' }
JadeiteCodeInspectItCommand class >> defaultIconName [

	^ #smallInspectIt
]

{ #category : 'accessing - defaults' }
JadeiteCodeInspectItCommand class >> defaultName [

	^ 'Inspect it'
]

{ #category : 'accessing - defaults' }
JadeiteCodeInspectItCommand class >> defaultShortcutKey [

	^ $i command mac 
		| $i control win
		| $i control unix
]

{ #category : 'executing' }
JadeiteCodeInspectItCommand >> asSpecCommand [

	^ SpToolCurrentApplicationCommand decorate: super asSpecCommand
]

{ #category : 'executing' }
JadeiteCodeInspectItCommand >> evaluate: aString andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke 
	 aBlock with the result."

	aBlock value: (self context 
		evaluateInspectingResult: aString
		onCompileError: [ ^ self ]
		onError: [ :e | e pass ]).
]

{ #category : 'executing' }
JadeiteCodeInspectItCommand >> evaluateSelectionAndDo: aBlock [
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
JadeiteCodeInspectItCommand >> execute [
	"copied from SpCodeInspectItCommand>>execute. 
	Cannot subclass from SpCodeInspectItCommand because the Spec2 framework instantiates
	the menu items from it's subclasses which causes problems."
	self evaluateSelectionAndDo: [ :result | 
		"do nothing for now. inspection done earlier"] 
]

{ #category : 'executing' }
JadeiteCodeInspectItCommand >> inspectObject: anArray [

	anArray first
		ifTrue: [ 
			self context
				inspectOop: (anArray at: 2)]
		ifFalse: [ 
			self context insertPrintPopoverAfterCurrentSelection:
				(anArray at: 2) ]
]

{ #category : 'executing' }
JadeiteCodeInspectItCommand >> selectedTextOrLine [

	^ self context selectedTextOrLine
]
