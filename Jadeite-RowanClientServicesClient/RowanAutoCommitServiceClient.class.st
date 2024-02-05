Class {
	#name : 'RowanAutoCommitServiceClient',
	#superclass : 'RowanAutoCommitService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> inCommand: anObject [

	inCommand := anObject
]
