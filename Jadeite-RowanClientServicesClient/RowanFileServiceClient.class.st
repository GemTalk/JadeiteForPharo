Class {
	#name : 'RowanFileServiceClient',
	#superclass : 'RowanFileService',
	#instVars : [
		'session',
		'inCommand'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'commands' }
RowanFileServiceClient >> fileIn [
	command := #fileIn:.
	commandArgs := Array with: path.
	self issueFileServiceCommand
]

{ #category : 'accessing' }
RowanFileServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := Semaphore forMutualExclusion ]
]

{ #category : 'accessing' }
RowanFileServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'commands' }
RowanFileServiceClient >> isDirectory: directory [
	command := #isDirectory:.
	commandArgs := Array with: path , '/' , directory.
	self issueFileServiceCommand.
	^answer
]

{ #category : 'accessing' }
RowanFileServiceClient >> path [
	^path
]

{ #category : 'accessing' }
RowanFileServiceClient >> path: anObject [
	path := anObject
]

{ #category : 'accessing' }
RowanFileServiceClient >> session [
	^session
]

{ #category : 'accessing' }
RowanFileServiceClient >> session: anObject [
	session := anObject
]
