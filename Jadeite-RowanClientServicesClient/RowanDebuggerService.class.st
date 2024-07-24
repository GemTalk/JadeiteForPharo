Class {
	#name : 'RowanDebuggerService',
	#superclass : 'RowanService',
	#instVars : [
		'initialProcessOop',
		'processes',
		'name'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
RowanDebuggerService class >> onProcess: aGsProcess [

	^self basicNew
		initialize: aGsProcess;
		yourself
]

{ #category : 'displaying' }
RowanDebuggerService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'public' }
RowanDebuggerService >> initialize: aGsProcess [

	initialProcessOop := aGsProcess oopType value.

]

{ #category : 'accessing' }
RowanDebuggerService >> name [
	^name
]

{ #category : 'accessing' }
RowanDebuggerService >> name: aString [
	name := aString asString
]

{ #category : 'Debugger' }
RowanDebuggerService >> processListUpdate: aPresenter [
	aPresenter parentPresenter gsProcess ifNil:[^self]. 
	aPresenter parentPresenter gsProcess oop = processes first oop ifFalse: [^self].
	aPresenter list: processes
]

{ #category : 'accessing' }
RowanDebuggerService >> processes [
	^processes
]

{ #category : 'accessing' }
RowanDebuggerService >> sortAspect [

	^name
]
