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

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanPackageServiceClient >> inCommand: anObject [

	inCommand := anObject
]
