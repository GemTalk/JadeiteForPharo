Class {
	#name : 'RowanAnsweringServiceClient',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock',
		'alwaysForked'
	],
	#classVars : [
		'IsRowanLoaded'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'testing' }
RowanAnsweringServiceClient class >> isRowanLoaded [ 

	^IsRowanLoaded ifNil: [ IsRowanLoaded := false ]
]

{ #category : 'testing' }
RowanAnsweringServiceClient class >> isRowanLoaded: aBoolean [
	"IsRowanLoaded := true.
	IsRowanLoaded := false"
	IsRowanLoaded := aBoolean
]

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
RowanAnsweringServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand: anObject [

	inCommand := anObject
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
