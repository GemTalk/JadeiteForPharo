Class {
	#name : 'RowanBrowserServiceClient',
	#superclass : 'RowanBrowserService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanBrowserServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
