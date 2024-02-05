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

	^ inCommand
]

{ #category : 'accessing' }
RowanPackageServiceClient >> inCommand: anObject [

	inCommand := anObject
]
