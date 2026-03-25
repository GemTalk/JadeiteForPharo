Class {
	#name : 'RowanMonticelloServiceClient',
	#superclass : 'RowanMonticelloService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'inCommand' }
RowanMonticelloServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'inCommand' }
RowanMonticelloServiceClient >> inCommand: anObject [

	inCommand := anObject
]
