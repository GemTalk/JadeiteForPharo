Class {
	#name : 'RowanAnsweringServiceClient',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand: anObject [

	inCommand := anObject
]
