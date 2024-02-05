Class {
	#name : 'RowanProjectServiceClient',
	#superclass : 'RowanProjectService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProjectServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanProjectServiceClient >> inCommand: anObject [

	inCommand := anObject
]
