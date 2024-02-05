Class {
	#name : 'RowanFillerClassServiceClient',
	#superclass : 'RowanFillerClassService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFillerClassServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanFillerClassServiceClient >> inCommand: anObject [

	inCommand := anObject
]
