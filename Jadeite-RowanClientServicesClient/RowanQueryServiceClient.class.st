Class {
	#name : 'RowanQueryServiceClient',
	#superclass : 'RowanQueryService',
	#instVars : [
		'name',
		'inCommand',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'displaying' }
RowanQueryServiceClient >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'commands' }
RowanQueryServiceClient >> implementorsOfAll: selectors [
	command := #implementorsOfAll:.
	commandArgs := Array with: selectors.
	RowanServiceUpdater current
		issueCommand: self
		session: GciSession current
		onCompletion: serviceCompletionBlock
]

{ #category : 'accessing' }
RowanQueryServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanQueryServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanQueryServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^13
]

{ #category : 'accessing' }
RowanQueryServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^14
]

{ #category : 'accessing' }
RowanQueryServiceClient >> name [
	^name
]

{ #category : 'accessing' }
RowanQueryServiceClient >> name: aString [
	name := aString asString
]

{ #category : 'as yet unclassified' }
RowanQueryServiceClient >> perform: browseAction with: possibleSelectors completionBlock: aBlock [
	serviceCompletionBlock := aBlock.
	self perform: browseAction with: possibleSelectors
]

{ #category : 'commands' }
RowanQueryServiceClient >> sendersOfAll: selectors [

	command := #sendersOfAll:.
	commandArgs := Array with: selectors.
	RowanServiceUpdater current
		issueCommand: self
		session: GciSession current
		onCompletion: serviceCompletionBlock
]

{ #category : 'service completion' }
RowanQueryServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'service completion' }
RowanQueryServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

{ #category : 'accessing' }
RowanQueryServiceClient >> sortAspect [

	^name
]
