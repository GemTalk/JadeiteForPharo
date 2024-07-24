Class {
	#name : 'RowanTranscriptService',
	#superclass : 'RowanService',
	#instVars : [
		'string'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanTranscriptService class >> templateClassName [ 

	^#RowanTranscriptService
]

{ #category : 'actions' }
RowanTranscriptService >> installTranscript [

	| promise |
	promise := remoteSelf installTranscript.
	promise wait.
]
