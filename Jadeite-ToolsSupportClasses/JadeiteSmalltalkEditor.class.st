"
Redirect Morphic menu items to a GemStone equivalent
"
Class {
	#name : 'JadeiteSmalltalkEditor',
	#superclass : 'RubSmalltalkEditor',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'gciSession'
	],
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'completion engine' }
JadeiteSmalltalkEditor class >> completionEngineClass [

	^JadeiteCompletionEngine
]

{ #category : 'accessing' }
JadeiteSmalltalkEditor >> application [ 

	^JadeiteApplication new
]

{ #category : 'editing keys' }
JadeiteSmalltalkEditor >> browseClassOfExpression [

	self evaluateSelectionAndDo: [ :result |
		| classService browser |
		classService := RowanClassService new name: result.
		browser := self openBrowser.
		browser activePresenter updateAfterFindClass: classService ].
	^ true
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> classCommentsContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> classNamesContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'completion engine' }
JadeiteSmalltalkEditor >> completionEngine [

	^ completionEngine ifNil: [
		CompletionEngineClass ifNotNil: [
			self completionEngine: JadeiteCompletionEngine new.
			completionEngine ] ]
]

{ #category : 'accessing' }
JadeiteSmalltalkEditor >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteSmalltalkEditor >> gciSession: anObject [

	gciSession := anObject
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> implementorsOf: aSelector [

	self browseImplementorsOf: aSelector
]

{ #category : 'menus' }
JadeiteSmalltalkEditor >> inspectIt [

	self halt.
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodCaseSensitiveStringsContainingIt [
	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseLiteralReferences: self selection string
	
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodNamesContainingIt [

	MessageBox notify: 'Not implemented yet'
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodSourceContainingIt [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseMethodsContaining: self selection string
	
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> methodStringsContainingit [
	"for now, just do a case sensitive search"
	self lineSelectAndEmptyCheck: [ ^ self ].
	self browseLiteralReferences: self selection string
	
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> referencesTo: className [

	self browseClassReferences: className
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> sendersOf: aSelector [

	self browseSendersOf: aSelector
]

{ #category : 'menu messages' }
JadeiteSmalltalkEditor >> sendersOfIt [

	| selectedSelector |
	(selectedSelector := self selectedSelector) ifNil: [
		^ textArea flash ].
	self sendersOf: selectedSelector
]
