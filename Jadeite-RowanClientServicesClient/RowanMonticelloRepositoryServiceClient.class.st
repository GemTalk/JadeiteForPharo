Class {
	#name : 'RowanMonticelloRepositoryServiceClient',
	#superclass : 'RowanMonticelloRepositoryService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloRepositoryServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanMonticelloRepositoryServiceClient >> catchBlock: anObject [

	catchBlock := anObject
]

{ #category : 'accessing' }
RowanMonticelloRepositoryServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanMonticelloRepositoryServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanMonticelloRepositoryServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMonticelloRepositoryServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
