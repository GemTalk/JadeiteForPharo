"
Client test support service
"
Class {
	#name : 'RowanTestService',
	#superclass : 'RowanService',
	#instVars : [
		'name'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'rsr' }
RowanTestService class >> templateClassName [ 

	^#RowanTestService
]

{ #category : 'displaying' }
RowanTestService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'public' }
RowanTestService >> execute: block overArrayOop: arrayOop session: session [
	"assume the oop is an array with simple elements. 
	Evaluate the block for each element"

	| size theOop |
	theOop := OopType64 fromInteger: arrayOop.
	size := session
				executeString: 'self size'
				fromContext: theOop
				environment: 0.
	1 to: size
		do: 
			[:index |
			| remoteElement |
			remoteElement := session
						executeString: 'self at: ' , index printString
						fromContext: theOop
						environment: 0.
			block value: remoteElement]
]

{ #category : 'accessing' }
RowanTestService >> name [
	^name
]

{ #category : 'accessing' }
RowanTestService >> name: aString [
	name := aString asString
]

{ #category : 'public' }
RowanTestService >> remoteServiceClassNamesOop: session [
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:context:;
		commandArgs: (Array with: 'Rowan platform serviceClasses collect:[:cls | cls name]' with: session oopNil value).
	RowanServiceUpdater current issueCommand: answeringService session: session.
	^answeringService answer value "key is whether result compiled" 
]

{ #category : 'accessing' }
RowanTestService >> sortAspect [

	^name
]

{ #category : 'updates' }
RowanTestService >> testServiceUpdate: anOrderedCollection [

	"Jadeite usually registers Presenters to receive updates from services,
	but there are no prohibitions on registering a non-presenter to receive 
	updates. So we will pass in anOrderedCollection, manipulate it in this 
	method and ensure that the collection is appropriately modified."

	anOrderedCollection add: #testServiceUpdate:. 
	
]
