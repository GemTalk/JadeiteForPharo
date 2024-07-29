Class {
	#name : 'RowanInspectorService',
	#superclass : 'RowanService',
	#instVars : [
		'oop',
		'objects',
		'myself',
		'className',
		'indexedSize',
		'visibleIndices',
		'nextIndices',
		'maxIndexedVars',
		'compileErrorArray',
		'isOop',
		'instVarNames',
		'instVarsAreRemovable',
		'isDictionary',
		'isVariable',
		'selectionOop',
		'isUnordered',
		'statusText',
		'isStringObject'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanInspectorService class >> templateClassName [

	^#RowanInspectorService
]

{ #category : 'comparison' }
RowanInspectorService >> = inspectorService [

	^ inspectorService isService and: [
		  inspectorService isInspectorService and: [
			  oop = inspectorService oop ] ]
]

{ #category : 'accessing' }
RowanInspectorService >> className [
	^className
]

{ #category : 'accessing' }
RowanInspectorService >> className: anObject [
	className := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> compileErrorArray [
	^compileErrorArray
]

{ #category : 'accessing' }
RowanInspectorService >> compileErrorArray: anObject [
	compileErrorArray := anObject
]

{ #category : 'constants' }
RowanInspectorService >> defaultIndexedSize [
	^1000
]

{ #category : 'inspecting' }
RowanInspectorService >> executeThenInspect: string context: anOop session: session windowHandle: handle debugger: debugger [

	self
		command: #executeThenInspect:inFrame:process:context:inWindow:;
		commandArgs: (Array
				 with: string
				 with: debugger frameListPresenter selectionByIndex
				 with: debugger gsProcess oop
				 with: anOop
				 with: handle).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'inspecting' }
RowanInspectorService >> executeThenInspect: string context: anOop session: session windowHandle: handle onCompletion: completionBlock [

	self
		command: #executeThenInspect:context:inWindow:;
		commandArgs: (Array with: string with: anOop with: handle).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: completionBlock
]

{ #category : 'comparison' }
RowanInspectorService >> hash [
	^oop hash
]

{ #category : 'accessing' }
RowanInspectorService >> indexedSize [
	^indexedSize
]

{ #category : 'accessing' }
RowanInspectorService >> indexedSize: anObject [
	indexedSize := anObject
]

{ #category : 'initialization' }
RowanInspectorService >> initialize [
	super initialize. 
	objects := OrderedCollection new. 
	maxIndexedVars := self defaultIndexedSize.
	indexedSize := 0.
	isOop := true. 
	isDictionary := false.
	isVariable := false. 
]

{ #category : 'inspecting' }
RowanInspectorService >> inspect: oopOrObject session: session [

	oop := (oopOrObject isKindOf: ExternalInteger)
		       ifTrue: [ oopOrObject value ]
		       ifFalse: [
			       isOop := false.
			       oopOrObject ].
	self
		command: #inspect:;
		commandArgs: (Array with: oop).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'inspecting' }
RowanInspectorService >> inspect: theOop session: session inWindow: handle [

	oop := theOop.
	self
		command: #inspect:inWindow:;
		commandArgs: (Array with: oop with: handle).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'inspecting' }
RowanInspectorService >> inspectBytes: oopOrObject session: session inWindow: handle [

	oop := (oopOrObject isKindOf: ExternalInteger)
		       ifTrue: [ oopOrObject value ]
		       ifFalse: [
			       isOop := false.
			       oopOrObject ].
	self
		command: #inspectBytes:inWindow:;
		commandArgs: (Array with: oop with: handle).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'accessing' }
RowanInspectorService >> instVarNames [
	^instVarNames
]

{ #category : 'accessing' }
RowanInspectorService >> instVarNames: anObject [
	instVarNames := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> instVarsAreRemovable [
	^instVarsAreRemovable
]

{ #category : 'accessing' }
RowanInspectorService >> instVarsAreRemovable: anObject [
	instVarsAreRemovable := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> isDictionary [
	^isDictionary
]

{ #category : 'public' }
RowanInspectorService >> isInspectorService [

	^true
]

{ #category : 'accessing' }
RowanInspectorService >> isOop [

	^ isOop
]

{ #category : 'accessing' }
RowanInspectorService >> isOop: anObject [

	isOop := anObject
]

{ #category : 'public' }
RowanInspectorService >> isShowingAllIndexedVars [

	^visibleIndices = indexedSize
]

{ #category : 'accessing' }
RowanInspectorService >> isStringObject [
	^isStringObject
]

{ #category : 'accessing' }
RowanInspectorService >> isUnordered [
	^isUnordered
]

{ #category : 'accessing' }
RowanInspectorService >> isUnordered: anObject [
	isUnordered := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> isVariable [
	^isVariable
]

{ #category : 'printing' }
RowanInspectorService >> logReceivedOn: aStream [
	| myselfString |
	myself ifNil: [^aStream nextPutAll: 'self is nil!'].
	myselfString := myself printString leftString: 50.
	aStream
		nextPutAll: myselfString;
		space.
	myself printString size > 50 ifTrue: [aStream nextPutAll: '... '].
	aStream nextPutAll: '<oop: ' , oop printString , '>'
]

{ #category : 'accessing' }
RowanInspectorService >> maxIndexedVars [
	^maxIndexedVars
]

{ #category : 'accessing' }
RowanInspectorService >> maxIndexedVars: anObject [
	maxIndexedVars := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> myself [
	^myself
]

{ #category : 'accessing' }
RowanInspectorService >> myself: anObject [
	myself := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> name [
	^name
]

{ #category : 'accessing' }
RowanInspectorService >> name: aString [
	name := aString asString
]

{ #category : 'inspecting' }
RowanInspectorService >> nextIndexedVarsFrom: indexStart to: indexStop session: session [

	self
		command: #nextIndexedVarsFrom:to:;
		commandArgs: (Array with: indexStart with: indexStop).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ nextIndices
]

{ #category : 'accessing' }
RowanInspectorService >> nextIndices [
	^nextIndices
]

{ #category : 'accessing' }
RowanInspectorService >> nextIndices: anObject [
	nextIndices := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> objects [
	^objects
]

{ #category : 'accessing' }
RowanInspectorService >> objects: anObject [
	objects := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> oop [
	^oop
]

{ #category : 'accessing' }
RowanInspectorService >> oop: anObject [
	oop := anObject
]

{ #category : 'printing' }
RowanInspectorService >> printOn: aStream [

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel
				 ifTrue: [ 'an ' ]
				 ifFalse: [ 'a ' ]);
		nextPutAll: title.
	[ 
	aStream
		space;
		nextPutAll: 'oop: (';
		nextPutAll: oop printString;
		nextPut: $) ]
		on: Error
		do: [ :ex | 
			aStream
				nextPutAll: 'Error printing service name: ';
				print: ex ]
]

{ #category : 'operations' }
RowanInspectorService >> removeDynamicInstVarsNamed: dynamicInstVarNames session: session [

	self
		command: #removeDynamicInstVars:;
		commandArgs: (Array with: dynamicInstVarNames).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'operations' }
RowanInspectorService >> removeIndexedInstVarsAt: indices session: session [

	self
		command: #removeIndexedInstVarsAt:;
		commandArgs: (Array with: indices).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'operations' }
RowanInspectorService >> removeKeys: keyOops session: session [

	self
		command: #removeKeys:;
		commandArgs: (Array with: keyOops).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'operations' }
RowanInspectorService >> removeOop: theOop session: session [

	self
		command: #removeOop:;
		commandArgs: (Array with: theOop).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'accessing' }
RowanInspectorService >> selectionOop [
	^selectionOop
]

{ #category : 'accessing' }
RowanInspectorService >> sortAspect [

	^name
]

{ #category : 'accessing' }
RowanInspectorService >> statusText [
	^statusText
]

{ #category : 'accessing' }
RowanInspectorService >> statusText: anObject [
	statusText := anObject
]

{ #category : 'accessing' }
RowanInspectorService >> visibleIndices [
	^visibleIndices
]

{ #category : 'accessing' }
RowanInspectorService >> visibleIndices: anObject [
	visibleIndices := anObject
]
