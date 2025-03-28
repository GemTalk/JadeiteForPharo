Class {
	#name : 'RowanAnsweringServiceClient',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'alwaysForked',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
RowanAnsweringServiceClient class >> newForked [

	^ self new alwaysForked: true
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> alwaysForked [

	^ alwaysForked
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> alwaysForked: anObject [

	alwaysForked := anObject
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> catchBlock: aBlock [

	catchBlock := aBlock
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'constants' }
RowanAnsweringServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^12
]

{ #category : 'constants' }
RowanAnsweringServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^13
]

{ #category : 'initialization' }
RowanAnsweringServiceClient >> initialize [

	super initialize.
	alwaysForked := false.
]

{ #category : 'testing' }
RowanAnsweringServiceClient >> notAlwaysForked [

	^ self alwaysForked not
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
