Class {
	#name : 'RowanPackageServiceClient',
	#superclass : 'RowanPackageService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanPackageServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanPackageServiceClient >> inCommand: anObject [

	inCommand := anObject
]
