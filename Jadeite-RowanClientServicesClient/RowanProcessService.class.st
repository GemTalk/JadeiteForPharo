Class {
	#name : 'RowanProcessService',
	#superclass : 'RowanService',
	#instVars : [
		'frames',
		'oop',
		'status',
		'name',
		'errorMessage',
		'priority',
		'serverPrintString'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProcessService class >> templateClassName [ 

	^#RowanProcessService
]

{ #category : 'operations' }
RowanProcessService >> changePriority: newPriority onCompletion: completionBlock [

	self
		command: #priority:;
		commandArgs: (Array with: newPriority).
	RowanServiceUpdater current
		issueCommand: self
		session: GciSession current
		onCompletion: completionBlock
]

{ #category : 'displaying' }
RowanProcessService >> displayName [
	"for logging. for now"

	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'GsProcess(oop=';
		nextPutAll: self oop printString;
		nextPut: $,;
		nextPutAll: 'status=';
		nextPutAll: self status printString;
		nextPut: $,;
		nextPutAll: 'priority=';
		nextPutAll: self priority printString;
		nextPut: $).
	^ ws contents
]

{ #category : 'printing' }
RowanProcessService >> dumpStackOn: aStream [

	aStream
		nextPutAll: errorMessage;
		nextPutAll: self lineDelimiter.
	self printShortStackOn: aStream.
	aStream
		nextPutAll: self lineDelimiter;
		nextPutAll: '==============================================='.
	self printFullStackOn: aStream
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
		frameService printVarsOn: aStream.
		aStream
			nextPutAll: self lineDelimiter;
			nextPutAll: '----------------------------------------------------' ]
]

{ #category : 'printing' }
RowanProcessService >> printOn: aStream [

	aStream
		nextPutAll: 'RowanProcessService(';
		print: oop;
		nextPutAll: ')';
		space;
		nextPutAll: status; 
		space; 
		nextPutAll: (name ifNil: [ String new ])
]

{ #category : 'printing' }
RowanProcessService >> printShortStackOn: aStream [

	1 to: frames size do: [ :index |
	(frames at: index) printOn: aStream at: index ]
]

{ #category : 'accessing' }
RowanProcessService >> priority [

	^ priority
]

{ #category : 'accessing' }
RowanProcessService >> priority: anObject [

	priority := anObject
]

{ #category : 'accessing' }
RowanProcessService >> serverPrintString [

	^ serverPrintString
]

{ #category : 'accessing' }
RowanProcessService >> serverPrintString: anObject [

	serverPrintString := anObject
]

{ #category : 'accessing' }
RowanProcessService >> sortAspect [

	^name
]

{ #category : 'public' }
RowanProcessService >> stack [
	^frames ifNil: [Array new] ifNotNil: [frames collect: [:each | each printString]]
]

{ #category : 'accessing' }
RowanProcessService >> status [

	^ status
]

{ #category : 'accessing' }
RowanProcessService >> status: anObject [

	status := anObject
]

{ #category : 'operations' }
RowanProcessService >> terminate [

	self command: #terminate.
	RowanServiceUpdater current
		issueCommand: self
		session: GciSession current
		onCompletion: [  ]
]

{ #category : 'operations' }
RowanProcessService >> terminateOnCompletion: completionBlock [

	self command: #terminate.
	RowanServiceUpdater current
		issueCommand: self
		session: GciSession current
		onCompletion: completionBlock
]
