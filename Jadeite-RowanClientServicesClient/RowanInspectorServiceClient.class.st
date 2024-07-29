Class {
	#name : 'RowanInspectorServiceClient',
	#superclass : 'RowanInspectorService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanInspectorServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanInspectorServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'service completion' }
RowanInspectorServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'service completion' }
RowanInspectorServiceClient >> serviceCompletionBlock: anObject [ 

	serviceCompletionBlock := anObject
]
