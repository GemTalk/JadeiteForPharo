Class {
	#name : 'RowanProjectServiceClient',
	#superclass : 'RowanProjectService',
	#instVars : [
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProjectServiceClient >> existsOnDisk: aBoolean [
	"for testing"
	existsOnDisk := aBoolean 
]

{ #category : 'accessing' }
RowanProjectServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanProjectServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanProjectServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^32
]

{ #category : 'accessing' }
RowanProjectServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^33
]

{ #category : 'accessing' }
RowanProjectServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'accessing' }
RowanProjectServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

{ #category : 'accessing' }
RowanProjectServiceClient >> sortedPackages [

	^ packages asSortedCollection: [ :x :y | x name < y name ]
]
