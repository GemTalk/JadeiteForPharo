Class {
	#name : 'RowanFileServiceClient',
	#superclass : 'RowanFileService',
	#instVars : [
		'session',
		'inCommand',
		'serviceCompletionBlock',
		'alwaysForked'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFileServiceClient >> alwaysForked [

	^ alwaysForked
]

{ #category : 'accessing' }
RowanFileServiceClient >> alwaysForked: anObject [

	alwaysForked := anObject
]

{ #category : 'commands' }
RowanFileServiceClient >> directoryPath [
	command := #directoryPath.
	commandArgs := Array new.
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileServiceClient >> exists [

	command := #exists.
	commandArgs := Array new.
	self issueFileServiceCommand.
	^ answer
]

{ #category : 'commands' }
RowanFileServiceClient >> expandPath [
	command := #expandPath.
	commandArgs := Array new. 
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileServiceClient >> extension [

	command := #extension.
	commandArgs := Array new.
	self issueFileServiceCommand.
	^ answer
]

{ #category : 'commands' }
RowanFileServiceClient >> fileContents [
	command := #fileContents.
	commandArgs := Array new. 
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileServiceClient >> fileIn [
	command := #fileIn:.
	commandArgs := Array with: path.
	self issueFileServiceCommand
]

{ #category : 'commands' }
RowanFileServiceClient >> fileInChunk: aString [
	command := #fileInChunk:.
	commandArgs := Array with: aString.
	self issueFileServiceCommand
]

{ #category : 'commands' }
RowanFileServiceClient >> fileName [

	command := #fileName.
	commandArgs := Array new.
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileServiceClient >> fileOutDictionaries: array [
	self
		command: #fileoutDictionaries:;
		commandArgs: (Array with: array).
	self issueFileServiceCommand
]

{ #category : 'commands' }
RowanFileServiceClient >> fileOutMethods: array [
	self
		command: #fileoutMethods:;
		commandArgs: (Array with: array).
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
RowanFileServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^14
]

{ #category : 'accessing' }
RowanFileServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^15
]

{ #category : 'initialization' }
RowanFileServiceClient >> initialize [

	super initialize.
	alwaysForked := false
]

{ #category : 'commands' }
RowanFileServiceClient >> isDirectory [
	command := #isDirectory.
	commandArgs := Array new. 
	self issueFileServiceCommand.
	^answer
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

	self issueFileServiceCommandOnCompletion: [  ]
]

{ #category : 'commands' }
RowanFileServiceClient >> issueFileServiceCommandOnCompletion: completionBlock [

	RowanServiceUpdater current critical: [
		RowanServiceUpdater current
			issueCommand: self
			session: self session
			onCompletion: completionBlock ]
]

{ #category : 'testing' }
RowanFileServiceClient >> notAlwaysForked [

	^ self alwaysForked not
]

{ #category : 'accessing' }
RowanFileServiceClient >> path [
	^path
]

{ #category : 'accessing' }
RowanFileServiceClient >> path: anObject [
	path := anObject
]

{ #category : 'commands' }
RowanFileServiceClient >> pathStringFor: fileName [

	command := #pathStringFor:.
	commandArgs := Array with: fileName.
	self issueFileServiceCommandOnCompletion: [  ].
	^ answer
]

{ #category : 'commands' }
RowanFileServiceClient >> pop [

	command := #pop.
	commandArgs := Array new.
	self issueFileServiceCommandOnCompletion: [
		answer ifNotNil: [ self shortNames ] ]
]

{ #category : 'commands' }
RowanFileServiceClient >> popWith: directoryContentsList with: pathText [

	| sem |
	command := #pop.
	commandArgs := Array new.
	sem := Semaphore new.
	self issueFileServiceCommandOnCompletion: [ sem signal ].
	sem wait.
	answer ifNotNil: [
		directoryContentsList list: self shortNames.
		pathText text: path ]
]

{ #category : 'commands' }
RowanFileServiceClient >> remove [
	command := #remove.
	commandArgs := Array new.
	self issueFileServiceCommand
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

{ #category : 'commands' }
RowanFileServiceClient >> setPathFor: fileName [

	command := #pathStringFor:.
	commandArgs := Array with: fileName.
	self issueFileServiceCommandOnCompletion: [ path := answer ]
]
