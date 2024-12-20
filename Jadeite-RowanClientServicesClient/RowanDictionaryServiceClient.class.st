Class {
	#name : 'RowanDictionaryServiceClient',
	#superclass : 'RowanDictionaryService',
	#instVars : [
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'actions' }
RowanDictionaryServiceClient >> addClass: classService [
	"normally classes is maintained by the server but in the 
	interests of performance, we sometimes need to add a class manually"

	(self classes includes: classService) ifTrue: [ ^ self ].
	self classes: (self classes asOrderedCollection
			 add: classService;
			 yourself)
]

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
