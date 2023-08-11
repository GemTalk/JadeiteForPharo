Class {
	#name : 'RowanFrameService',
	#superclass : 'RowanService',
	#instVars : [
		'label',
		'method',
		'stepPoint',
		'vars',
		'oop',
		'homeMethodSelector',
		'homeMethodClassName',
		'classIsResolvable',
		'name'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFrameService class >> templateClassName [ 

	^#RowanFrameService
]

{ #category : 'public' }
RowanFrameService >> breaks [

	^method breakPoints
]

{ #category : 'accessing' }
RowanFrameService >> classIsResolvable [
	^classIsResolvable
]

{ #category : 'public' }
RowanFrameService >> copyBasicsFrom: oldService [

	method := RowanMethodService new copyBasicsFrom: oldService method.

]

{ #category : 'displaying' }
RowanFrameService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'public' }
RowanFrameService >> gsMethod [

	^method
]

{ #category : 'accessing' }
RowanFrameService >> homeMethodClassName [

	^homeMethodClassName
]

{ #category : 'accessing' }
RowanFrameService >> homeMethodSelector [

	^homeMethodSelector
]

{ #category : 'public' }
RowanFrameService >> indexOfSubCollection: aString [ 

	^method source indexOfSubCollection: aString 
]

{ #category : 'public' }
RowanFrameService >> isExecutedBlockContext [

	^method className isNil
]

{ #category : 'public' }
RowanFrameService >> isUpdatableService [
	^false
]

{ #category : 'accessing' }
RowanFrameService >> label [

	^label
]

{ #category : 'constants' }
RowanFrameService >> maxPrint [
	^200
]

{ #category : 'public' }
RowanFrameService >> method [
	^method
]

{ #category : 'accessing' }
RowanFrameService >> name [
	^name
]

{ #category : 'accessing' }
RowanFrameService >> name: aString [
	name := aString asString
]

{ #category : 'public' }
RowanFrameService >> offsets [

	^method stepPoints collect: [:each | each key start]
]

{ #category : 'accessing' }
RowanFrameService >> oop [
	^oop
]

{ #category : 'accessing' }
RowanFrameService >> oop: anObject [
	oop := anObject
]

{ #category : 'public' }
RowanFrameService >> printOn: aStream [

	aStream nextPutAll: (label ifNil: ['?'])

]

{ #category : 'printing' }
RowanFrameService >> printOn: aStream at: index [

	^ aStream
		  cr;
		  nextPut: $[;
		  nextPutAll: index printString;
		  nextPut: $];
		  space;
		  nextPutAll: self printString
]

{ #category : 'printing' }
RowanFrameService >> printVariable: variableService on: stream [

	| valueString maxPrintSize |
	stream
		cr;
		tab;
		nextPutAll: variableService key value asString;
		space;
		nextPutAll: 'oop(';
		print: variableService key key asString asNumber;
		nextPut: $);
		space;
		nextPutAll: '==';
		space.
	valueString := variableService value asString.
	maxPrintSize := valueString size min: self maxPrint.
	stream nextPutAll: (valueString copyFrom: 1 to: maxPrintSize).
	valueString size > self maxPrint ifTrue: [ stream nextPutAll: '...' ]
]

{ #category : 'printing' }
RowanFrameService >> printVarsOn: aStream [ 

	| sortedVars sortedInstVars sortedTempsAndParms |
	aStream
		cr;
		nextPutAll: '----------------------------------------------------'.
	self printVariable: self vars first on: aStream.
	sortedVars := (self vars copyFrom: 2 to: self vars size)
		              asSortedCollection: [ :x :y |
		              x key value <= y key value ].
	sortedInstVars := sortedVars select: [ :var |
		                  var key value first = $- ].
	aStream
		cr;
		cr;
		nextPutAll: 'instance variables:'.
	self printVariable: sortedInstVars on: aStream.
	sortedTempsAndParms := sortedVars reject: [ :var |
		                       var key value first = $- ].
	aStream
		cr;
		cr;
		nextPutAll: 'temporary variables and parameters:'.
	self printVariable: sortedTempsAndParms on: aStream
]

{ #category : 'accessing' }
RowanFrameService >> sortAspect [

	^name
]

{ #category : 'public' }
RowanFrameService >> source [

	^method source
]

{ #category : 'public' }
RowanFrameService >> stepPoint [
	^stepPoint
]

{ #category : 'public' }
RowanFrameService >> vars [
	^vars
]
