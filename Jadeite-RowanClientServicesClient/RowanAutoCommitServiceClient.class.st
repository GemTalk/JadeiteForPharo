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

	^ inCommand
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> inCommand: anObject [

	inCommand := anObject
]
