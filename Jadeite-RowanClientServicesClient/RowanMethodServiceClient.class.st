Class {
	#name : 'RowanMethodServiceClient',
	#superclass : 'RowanMethodService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanMethodServiceClient >> serviceCompletionBlock [

	^serviceCompletionBlock
]

{ #category : 'accessing' }
RowanMethodServiceClient >> serviceCompletionBlock: aBlock [

	serviceCompletionBlock := aBlock 
]

{ #category : 'accessing' }
RowanMethodServiceClient >> stepPointRanges [

	^ stepPoints collect: [ :array | self stepPointRangeFrom: array ]
]
