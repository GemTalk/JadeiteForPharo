Class {
	#name : 'RowanVariableService',
	#superclass : 'RowanService',
	#instVars : [
		'oop',
		'key',
		'value',
		'className',
		'name'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'rsr' }
RowanVariableService class >> templateClassName [ 

	^#RowanVariableService
]

{ #category : 'public' }
RowanVariableService >> _key [

	^key
]

{ #category : 'public' }
RowanVariableService >> className [

	^className
]

{ #category : 'displaying' }
RowanVariableService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'printing' }
RowanVariableService >> displayOop [

	^oop printString
]

{ #category : 'printing' }
RowanVariableService >> displayStringOn: displayThing [
]

{ #category : 'public' }
RowanVariableService >> isDisplayLabel [
	^false
]

{ #category : 'public' }
RowanVariableService >> isUpdatableService [
	^false
]

{ #category : 'testing' }
RowanVariableService >> isVariableDisplayLabel [

	^false
]

{ #category : 'public' }
RowanVariableService >> key [
	"provided to match expectation of UI for JadeDebugger"

	^key
]

{ #category : 'accessing' }
RowanVariableService >> name [
	^name
]

{ #category : 'accessing' }
RowanVariableService >> name: aString [
	name := aString asString
]

{ #category : 'public' }
RowanVariableService >> oop [

	^oop
]

{ #category : 'printing' }
RowanVariableService >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '( ';
		print: key;
		space;
		nextPutAll: '->';
		space;
		print: value;
		nextPutAll: ' )'
]

{ #category : 'accessing' }
RowanVariableService >> sortAspect [

	^name
]

{ #category : 'public' }
RowanVariableService >> updateVariable: listPresenter debugger: debugger [
	listPresenter list
		do: [:variableService | variableService _key = key ifTrue: [variableService replicateFrom: self]].
	listPresenter list: listPresenter list.
	listPresenter view invalidate.
]

{ #category : 'public' }
RowanVariableService >> value [
	^value
]
