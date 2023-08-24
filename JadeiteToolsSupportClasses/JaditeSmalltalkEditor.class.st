"
Redirect Morphic menu items to a GemStone equivalent
"
Class {
	#name : 'JaditeSmalltalkEditor',
	#superclass : 'RubSmalltalkEditor',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'gciSession'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'accessing' }
JaditeSmalltalkEditor >> application [ 

	^JadeiteApplication new
]

{ #category : 'editing keys' }
JaditeSmalltalkEditor >> browseClassOfExpression [

	self evaluateSelectionAndDo: [ :result |
		| classService browser |
		classService := RowanClassService new name: result.
		browser := self openBrowser.
		browser activePresenter updateAfterFindClass: classService ].
	^ true
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> classCommentsContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> classNamesContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'accessing' }
JaditeSmalltalkEditor >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JaditeSmalltalkEditor >> gciSession: anObject [

	gciSession := anObject
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> implementorsOf: aSelector [

	self browseImplementorsOf: aSelector
]

{ #category : 'menus' }
JaditeSmalltalkEditor >> inspectIt [

	self halt.
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> methodCaseSensitiveStringsContainingIt [
	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseLiteralReferences: self selection string
	
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> methodNamesContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> methodSourceContainingIt [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseMethodsContaining: self selection string
	
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> methodStringsContainingit [
	"for now, just do a case sensitive search"
	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseLiteralReferences: self selection string
	
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> referencesTo: className [

	self browseClassReferences: className
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> sendersOf: aSelector [

	self browseSendersOf: aSelector
]

{ #category : 'menu messages' }
JaditeSmalltalkEditor >> sendersOfIt [

	| selectedSelector |
	(selectedSelector := self selectedSelector) ifNil: [
		^ textArea flash ].
	self sendersOf: selectedSelector
]
