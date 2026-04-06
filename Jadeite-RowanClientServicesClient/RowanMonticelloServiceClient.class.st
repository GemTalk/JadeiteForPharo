Class {
	#name : 'RowanMonticelloServiceClient',
	#superclass : 'RowanMonticelloService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanMonticelloServiceClient >> catchBlock: anObject [

	catchBlock := anObject
]

{ #category : 'inCommand' }
RowanMonticelloServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'inCommand' }
RowanMonticelloServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanMonticelloServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMonticelloServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
