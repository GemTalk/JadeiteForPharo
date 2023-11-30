"
ExpectedResult is used for testing code that might raise a user dialog. 
Wrap test code in #expectResult:during: to return the expected result to the application instead of raising a dialog box. 
"
Class {
	#name : 'MessageBox',
	#superclass : 'DolphinClass',
	#classVars : [
		'ExpectedResult'
	],
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'pharo specific layer' }
MessageBox class >> confirm: aString [

	ExpectedResult ifNotNil: [ ^ ExpectedResult ].
	^ UIManager default confirm: aString
]

{ #category : 'pharo specific layer' }
MessageBox class >> confirm: aString caption: ignore [

	^self confirm: aString
]

{ #category : 'testing support' }
MessageBox class >> expectResult: resultBlock during: aBlock [

	ExpectedResult := resultBlock value.
	aBlock ensure: [ ExpectedResult := nil ]
]

{ #category : 'pharo specific layer' }
MessageBox class >> notify: aString [

	^UIManager default inform: aString
]

{ #category : 'pharo specific layer' }
MessageBox class >> warning: aString [

	^UIManager default alert: aString
]
