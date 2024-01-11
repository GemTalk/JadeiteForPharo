Class {
	#name : 'JadeiteCodePrintItCommand',
	#superclass : 'JadeiteCodeExecutionCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteCodePrintItCommand class >> defaultDescription [

	^ 'Evaluate selection and print the result.'
]

{ #category : 'default' }
JadeiteCodePrintItCommand class >> defaultIconName [

	^ #smallPrintIt
]

{ #category : 'default' }
JadeiteCodePrintItCommand class >> defaultName [

	^ 'Print it'
]

{ #category : 'default' }
JadeiteCodePrintItCommand class >> defaultShortcutKey [

	^ $p command mac
		| $p control win
		| $p control unix
]

{ #category : 'executing' }
JadeiteCodePrintItCommand >> evaluate: aString andDo: aBlock [

	^ self context
		  executeSelectionOrLine: aString
		  shouldDebug: false
		  onCompileError: [ ^ self ]
		  showResult: true
]

{ #category : 'executing' }
JadeiteCodePrintItCommand >> execute [
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."

	self evaluateSelectionAndDo: [ :result | 
		self printObject: result ]
]

{ #category : 'executing' }
JadeiteCodePrintItCommand >> printObject: anObject [

	self context insertPrintPopoverAfterCurrentSelection: anObject
]

{ #category : 'executing' }
JadeiteCodePrintItCommand >> toPrintableString: printString [

	self flag: #TODO. "This is maybe not the best? 
	I think I need to add a popover, but that then means I need to 
	have a special way to handle this special 'insertion' (to transmit the correct insertion 
	to the presenter's adapter)."
	^ String streamContents: [ :stream |
		stream << ' ' << printString  ]
]
