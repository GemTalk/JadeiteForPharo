Class {
	#name : 'JadeInspector',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'instVarListPresenter',
		'className'
	],
	#classVars : [
		'DefaultInspectorClass'
	],
	#category : 'Jadeite-Inspector'
}

{ #category : 'as yet unclassified' }
JadeInspector class >> setDefaultInspectorClass: aJadeInspectorClass [

	DefaultInspectorClass := aJadeInspectorClass

]

{ #category : 'as yet unclassified' }
JadeInspector class >> setNormalInspector [

	self setDefaultInspectorClass: JadeInspector
]

{ #category : 'as yet unclassified' }
JadeInspector >> contextObject [
	^model
]

{ #category : 'as yet unclassified' }
JadeInspector >> createView: string [
	| newView |
	newView := super createView: string.
	(model isKindOf: self expectedModelClass)
		ifTrue: [self registerWindow: newView handle rootObject: model oop].
	^newView
]

{ #category : 'as yet unclassified' }
JadeInspector >> displayError: ex [
	| errorString instVarNames |
	errorString := 'Error inspecting object ' , model printString , '. Error text: ' , ex printString.
	instVarNames := OrderedCollection new.
	instVarNames add: 'self' -> errorString.
	(model isKindOf: ExternalInteger) ifTrue: [instVarNames add: '-.asOop' -> model value].
	instVarListPresenter
		list: instVarNames;
		selection: instVarNames first. 
]

{ #category : 'as yet unclassified' }
JadeInspector >> displayInstVarError: ex instVar: anObject [
	^'Error inspecting object ' , anObject printString , '. Error text: ' , ex printString
]

{ #category : 'as yet unclassified' }
JadeInspector >> displaySpecials [
	| instVarNames |
	((model isKindOf: Character) and: [model asInteger > 255])
		ifTrue: [^self displayUndisplayableCharacter].
	className := model class name.
	documentPresenter value: model.
	instVarNames := OrderedCollection with: 'self' -> model printString.
	instVarNames add: '-.asOop' -> (gciSession executeString: model printString , ' asOop printString').
	instVarListPresenter
		list: instVarNames;
		selection: instVarNames first.
	^instVarNames
]

{ #category : 'as yet unclassified' }
JadeInspector >> displayUndisplayableCharacter [
	| instVarNames |
	className := model class name.
	instVarNames := OrderedCollection with: 'self' -> 'Character not displayable'.
	instVarListPresenter
		list: instVarNames;
		selection: instVarNames first.
	^instVarNames
]

{ #category : 'as yet unclassified' }
JadeInspector >> expectedModelClass [

	^ExternalInteger

	
]

{ #category : 'as yet unclassified' }
JadeInspector >> inspectInstVar [	
	JadeInspector 
		showOn: instVarListPresenter selection value 
		session: gciSession.

]

{ #category : 'as yet unclassified' }
JadeInspector >> instVarListPresenter [
	^instVarListPresenter
]

{ #category : 'as yet unclassified' }
JadeInspector >> isModified [

	^false.

]

{ #category : 'as yet unclassified' }
JadeInspector >> model: anObject [
	"often a GsObject, but could be an Integer, String, etc."

	| object |
	object := (anObject isKindOf: String) ifTrue: [anObject replaceLfWithCrLf] ifFalse: [anObject].
	(anObject isKindOf: Symbol) ifTrue: [object := object asSymbol].
	model := object.
	codePane model: object
]

{ #category : 'event handlers' }
JadeInspector >> onViewClosed [
	RowanServiceUpdater current logComment: 'Closing Inspector {' , self identityHash printString , '}'.
	RowanBrowserService new releaseWindow: self view handle value session: self gciSession.
	super onViewClosed
]

{ #category : 'event handlers' }
JadeInspector >> onViewOpened [
	super onViewOpened.
	self updateCaption.
	RowanServiceUpdater current logComment: 'Opening Inspector {' , self identityHash printString , '}'
]

{ #category : 'as yet unclassified' }
JadeInspector >> saveDocument [
	self rowanFixMe. "this would be very handy"
	MessageBox notify: 'This feature not yet implemented'
]

{ #category : 'as yet unclassified' }
JadeInspector >> setDocumentPresenterLabel [
	(model isKindOf: String) ifTrue: [
		documentPresenter value: model.
		self view caption: 'String (' , model size printString , ' characters)'.
		^self.
	].
	(model isKindOf: ByteArray) ifTrue: [
		documentPresenter value: model printString.
		self view caption: model class name , ' (' , model size printString , ' bytes)'.
		^self.
	].
	(model isKindOf: Integer) ifTrue: [
		documentPresenter value: model printString.
		self view caption: 'Integer'.
		^self.
	].
	model isNil ifTrue: [
		documentPresenter value: model printString.
		self view caption: 'UndefinedObject'.
		^self.
	].
	(model isKindOf: Boolean) ifTrue: [
		documentPresenter value: model printString.
		self view caption: 'Boolean'.
		^self.
	]. 
	(model isKindOf: Character) ifTrue: [
		documentPresenter value: model printString.
		self view caption: 'Character'.
		^self.
	]. 
	(model isKindOf: Float) ifTrue: [
		documentPresenter value: model printString.
		self view caption: 'Float'.
		^self.
	].
	(model isKindOf: Fraction) ifTrue: [
		documentPresenter value: model printString.
		self view caption: 'Fraction'.
		^self.
	].

]

{ #category : 'as yet unclassified' }
JadeInspector >> setLastGsShape: name [
	codePane setDocumentPresenterWith: (self registry getClass: name)
]

{ #category : 'as yet unclassified' }
JadeInspector >> shellNameExtraInfo [
	(model isKindOf: String) ifTrue: [^' (' , model size printString , ' characters)'].
	(model isKindOf: ByteArray) ifTrue: [^' (' , model size printString , ' bytes)'].
	^String new
]
