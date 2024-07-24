Class {
	#name : 'GsCompileError',
	#superclass : 'GsError',
	#instVars : [
		'gsArguments'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
GsCompileError class >> signal: gsArguments [

	| error |
	error := self new gsArguments: gsArguments. 
	^error signal

	
]

{ #category : 'accessing' }
GsCompileError >> gsArguments [

	^ gsArguments
]

{ #category : 'accessing' }
GsCompileError >> gsArguments: anObject [

	gsArguments := anObject
]
