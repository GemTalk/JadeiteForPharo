Class {
	#name : 'RowanAnsweringServiceClient',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanAnsweringServiceClient >> inCommand: anObject [

	inCommand := anObject
]
