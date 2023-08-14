"
Client test support service
"
Class {
	#name : 'RowanTestService',
	#superclass : 'RowanService',
	#instVars : [
		'name'
	],
	#category : 'RowanClientServicesClient'
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
	BrowserUpdate current issueCommand: answeringService session: session.
	^answeringService answer value "key is whether result compiled" 
]

{ #category : 'accessing' }
RowanTestService >> sortAspect [

	^name
]
