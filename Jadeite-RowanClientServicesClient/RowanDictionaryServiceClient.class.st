Class {
	#name : 'RowanDictionaryServiceClient',
	#superclass : 'RowanDictionaryService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand: anObject [

	inCommand := anObject
]
