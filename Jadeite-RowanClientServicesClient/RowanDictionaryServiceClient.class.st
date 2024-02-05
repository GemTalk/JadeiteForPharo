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

	^ inCommand
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand: anObject [

	inCommand := anObject
]
