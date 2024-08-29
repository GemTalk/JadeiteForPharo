Class {
	#name : 'RowanFileServiceClient',
	#superclass : 'RowanFileService',
	#instVars : [
		'session',
		'inCommand',
		'serviceCompletionBlock',
		'inCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'commands' }
RowanFileServiceClient >> fileIn [
	command := #fileIn:.
	commandArgs := Array with: path.
	self issueFileServiceCommand
]

{ #category : 'accessing' }
RowanFileServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanFileServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanFileServiceClient >> inCompletionBlock [

	^ inCompletionBlock
]

{ #category : 'accessing' }
RowanFileServiceClient >> inCompletionBlock: anObject [

	inCompletionBlock := anObject
]

{ #category : 'initialization' }
RowanFileServiceClient >> initialize [

	super initialize.
	inCompletionBlock := false
]

{ #category : 'commands' }
RowanFileServiceClient >> isDirectory: directory [
	command := #isDirectory:.
	commandArgs := Array with: path , '/' , directory.
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileServiceClient >> isDirectory: directory onCompletion: completionBlock [

	command := #isDirectory:.
	commandArgs := Array with: path , '/' , directory.
	self issueFileServiceCommandOnCompletion: completionBlock.
]

{ #category : 'commands' }
RowanFileServiceClient >> issueFileServiceCommand [

	RowanServiceUpdater current
		issueCommand: self
		session: self session
		onCompletion: [  ]
]

{ #category : 'commands' }
RowanFileServiceClient >> issueFileServiceCommandOnCompletion: completionBlock [

	self inCompletionBlock: true.
	RowanServiceUpdater current
		issueCommand: self
		session: self session
		onCompletion: completionBlock
]

{ #category : 'testing' }
RowanFileServiceClient >> notInCompletionBlock [

	^ self inCompletionBlock not
]

{ #category : 'accessing' }
RowanFileServiceClient >> path [
	^path
]

{ #category : 'accessing' }
RowanFileServiceClient >> path: anObject [
	path := anObject
]

{ #category : 'service completion' }
RowanFileServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'service completion' }
RowanFileServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]

{ #category : 'accessing' }
RowanFileServiceClient >> session [
	^session
]

{ #category : 'accessing' }
RowanFileServiceClient >> session: anObject [
	session := anObject
]
