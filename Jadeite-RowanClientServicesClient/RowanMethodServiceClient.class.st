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

	^ inCommand
]

{ #category : 'accessing' }
RowanMethodServiceClient >> inCommand: anObject [

	inCommand := anObject
]
