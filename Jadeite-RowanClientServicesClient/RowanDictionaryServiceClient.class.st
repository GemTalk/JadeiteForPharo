Class {
	#name : 'RowanDictionaryServiceClient',
	#superclass : 'RowanDictionaryService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^18
]
