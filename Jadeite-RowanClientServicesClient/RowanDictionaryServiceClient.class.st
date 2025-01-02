Class {
	#name : 'RowanDictionaryServiceClient',
	#superclass : 'RowanDictionaryService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'actions' }
RowanDictionaryServiceClient >> addClass: classService [
	"normally classes is maintained by the server but in the 
	interests of performance, we sometimes need to add a class manually.
	
	In case we find the class, we remove then add it back in case the class category changed "

	| oc |
	oc := self classes asOrderedCollection.
	(self classes includes: classService) ifTrue: [
		oc remove: classService ].
	self classes: (oc
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

{ #category : 'accessing' }
RowanDictionaryServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanDictionaryServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
