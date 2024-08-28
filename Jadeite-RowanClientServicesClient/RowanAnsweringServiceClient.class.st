Class {
	#name : 'RowanAnsweringServiceClient',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'inCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
RowanAnsweringServiceClient class >> newInCompletionBlock [

	^ self new inCompletionBlock: true
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCompletionBlock [

	^ inCompletionBlock
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCompletionBlock: anObject [

	inCompletionBlock := anObject
]

{ #category : 'initialization' }
RowanAnsweringServiceClient >> initialize [

	super initialize.
	inCompletionBlock := false
]

{ #category : 'testing' }
RowanAnsweringServiceClient >> notInCompletionBlock [

	^ self inCompletionBlock not
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
