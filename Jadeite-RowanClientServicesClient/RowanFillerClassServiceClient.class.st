Class {
	#name : 'RowanFillerClassServiceClient',
	#superclass : 'RowanFillerClassService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFillerClassServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanFillerClassServiceClient >> inCommand: anObject [

	inCommand := anObject
]
