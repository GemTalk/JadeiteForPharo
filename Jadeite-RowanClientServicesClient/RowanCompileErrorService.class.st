Class {
	#name : 'RowanCompileErrorService',
	#superclass : 'RowanService',
	#instVars : [
		'gsArguments'
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

{ #category : 'rsr' }
RowanCompileErrorService >> signalCompileError [
	GsCompileError signal: self gsArguments
]
