Class {
	#name : 'RowanMethodServiceClient',
	#superclass : 'RowanMethodService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand: anObject [

	inCommand := anObject
]
