Class {
	#name : 'RowanProcessService',
	#superclass : 'RowanService',
	#instVars : [
		'frames',
		'oop',
		'status',
		'name',
		'errorMessage'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProcessService class >> templateClassName [ 

	^#RowanProcessService
]

{ #category : 'displaying' }
RowanProcessService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'printing' }
RowanProcessService >> dumpStackOn: aStream [

	aStream
		nextPutAll: errorMessage;
		cr.
	self printShortStackOn: aStream.
	aStream
		cr;
		nextPutAll: '==============================================='.
	self printFullStackOn: aStream.
	aStream
		cr;
		nextPutAll: '==============================================='
]

{ #category : 'public' }
RowanProcessService >> frameForLevel: anInteger [ 

	^frames at: anInteger
]

{ #category : 'public' }
RowanProcessService >> frames [

	^frames
]

{ #category : 'public' }
RowanProcessService >> gsProcessForSession: session [
	^GsProcess session: session oopType: self oopType
]

{ #category : 'public' }
RowanProcessService >> isUpdatableService [
	^false
]

{ #category : 'accessing' }
RowanProcessService >> name [
	^name
]

{ #category : 'accessing' }
RowanProcessService >> name: aString [
	name := aString asString
]

{ #category : 'public' }
RowanProcessService >> oop [

	^oop
]

{ #category : 'public' }
RowanProcessService >> oop: oopInteger [

	oop := oopInteger
]

{ #category : 'public' }
RowanProcessService >> oopType [

	^OopType64 fromInteger: oop
]

{ #category : 'printing' }
RowanProcessService >> printFullStackOn: aStream [

	1 to: self stack size do: [ :index |
		| frameService |
		frameService := frames at: index.
		frameService printOn: aStream at: index.
		frameService printVarsOn: aStream ].
	aStream
		cr;
		nextPutAll: '----------------------------------------------------'
]

{ #category : 'printing' }
RowanProcessService >> printOn: aStream [
	aStream
		nextPutAll: 'RowanProcessService(';
		print: oop;
		nextPutAll: ')';
		yourself
]

{ #category : 'printing' }
RowanProcessService >> printShortStackOn: aStream [

	1 to: frames size do: [ :index |
	(frames at: index) printOn: aStream at: index ]
]

{ #category : 'accessing' }
RowanProcessService >> sortAspect [

	^name
]

{ #category : 'public' }
RowanProcessService >> stack [
	^frames ifNil: [Array new] ifNotNil: [frames collect: [:each | each printString]]
]

{ #category : 'operations' }
RowanProcessService >> terminate [
	"temporary until debugger is rewritten"

	"During logout, it's possible that the session may no longer be a session"

	(GciSession current isKindOf: GciSession) ifFalse: [^self].
	(GsProcess session: GciSession current oopType: (GciSession current oopTypeWithOop: oop)) terminate
]
