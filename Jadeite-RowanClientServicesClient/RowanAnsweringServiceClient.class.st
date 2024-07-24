Class {
	#name : 'RowanAnsweringServiceClient',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
