Class {
	#name : 'RowanCompileErrorService',
	#superclass : 'RowanService',
	#instVars : [
		'gsArguments',
		'messageText'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanCompileErrorService class >> templateClassName [ 

	^#RowanCompileErrorService
]

{ #category : 'accessing' }
RowanCompileErrorService >> gsArguments [

	^ gsArguments
]

{ #category : 'accessing' }
RowanCompileErrorService >> gsArguments: anObject [

	gsArguments := anObject
]

{ #category : 'testing' }
RowanCompileErrorService >> isCompileError [

	^true
]

{ #category : 'accessing' }
RowanCompileErrorService >> messageText [

	^ messageText
]

{ #category : 'accessing' }
RowanCompileErrorService >> messageText: anObject [

	messageText := anObject
]

{ #category : 'rsr' }
RowanCompileErrorService >> signalCompileError [

	| error |
	error := GsCompileError new
		         messageText: self messageText;
		         gsArguments: self gsArguments.
	error signal "for older code signal the arguments"
]
