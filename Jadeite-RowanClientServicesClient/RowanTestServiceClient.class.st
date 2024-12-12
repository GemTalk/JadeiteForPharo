Class {
	#name : 'RowanTestServiceClient',
	#superclass : 'RowanTestService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'inCommand' }
RowanTestServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'inCommand' }
RowanTestServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanTestServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^12
]

{ #category : 'accessing' }
RowanTestServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^13
]

{ #category : 'service completion' }
RowanTestServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'service completion' }
RowanTestServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
