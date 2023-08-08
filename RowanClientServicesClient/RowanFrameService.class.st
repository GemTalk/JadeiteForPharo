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
