Class {
	#name : 'RowanPackageServiceClient',
	#superclass : 'RowanPackageService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanPackageServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanPackageServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanPackageServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^23
]

{ #category : 'accessing' }
RowanPackageServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^24
]

{ #category : 'accessing' }
RowanPackageServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanPackageServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

{ #category : 'as yet unclassified' }
RowanPackageServiceClient >> sortedClasses [

	^ classes
		  ifNil: [ OrderedCollection new ]
		  ifNotNil: [
		  classes asSortedCollection: [ :x :y | x name < y name ] ]
]
