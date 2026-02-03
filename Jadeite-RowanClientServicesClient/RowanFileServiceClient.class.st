Class {
	#name : 'RowanFileServiceClient',
	#superclass : 'RowanFileService',
	#instVars : [
		'session',
		'inCommand',
		'serviceCompletionBlock',
		'alwaysForked',
		'catchBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'commands' }
RowanFileServiceClient >> / aString [

	| sem |
	sem := Semaphore new.
	command := #/.
	commandArgs := Array with: aString.
	self issueFileServiceCommandOnCompletion: [ sem signal ].
	sem wait.
	^ answer
]

{ #category : 'accessing' }
RowanFileServiceClient >> alwaysForked [

	^ alwaysForked
]

{ #category : 'accessing' }
RowanFileServiceClient >> alwaysForked: anObject [

	alwaysForked := anObject
]

{ #category : 'accessing' }
RowanFileServiceClient >> catchBlock [

	^ catchBlock ifNil: [ super catchBlock ]
]

{ #category : 'accessing' }
RowanFileServiceClient >> catchBlock: aBlock [

	catchBlock := aBlock
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

	| sem |
	sem := Semaphore new.
	command := #exists.
	commandArgs := Array new.
	self issueFileServiceCommandOnCompletion: [ sem signal ].
	sem wait.
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

	| sem |
	sem := Semaphore new.
	command := #extension.
	commandArgs := Array new.
	self issueFileServiceCommandOnCompletion: [ sem signal ].
	sem wait.
	^ answer
]

{ #category : 'commands' }
RowanFileServiceClient >> fileContents [

	RowanServiceUpdater current critical: [
		command := #fileContents.
		commandArgs := Array new.
		self issueFileServiceCommand ].
	^ answer
]

{ #category : 'commands' }
RowanFileServiceClient >> fileContentsOnCompletion: completionBlock [

	RowanServiceUpdater current critical: [
		command := #fileContents.
		commandArgs := Array new.
		self issueFileServiceCommandOnCompletion: completionBlock ]
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
RowanFileServiceClient >> fileInOnCompletion: completionBlock [

	command := #fileIn:.
	commandArgs := Array with: path.
	self issueFileServiceCommandOnCompletion: completionBlock
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

	| sem |
	sem := Semaphore new.
	command := #isDirectory.
	commandArgs := Array new.
	self issueFileServiceCommandOnCompletion: [ sem signal ].
	sem wait.
	^ answer
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
RowanFileServiceClient >> isWritable [
	command := #isWritable.
	commandArgs := Array new. 
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileServiceClient >> issueFileServiceCommand [

	self issueFileServiceCommandOnCompletion: [  ]
]

{ #category : 'commands' }
RowanFileServiceClient >> issueFileServiceCommandOnCompletion: completionBlock [

	RowanServiceUpdater current
		issueCommand: self
		session: self session
		onCompletion: completionBlock
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
			answer ifNotNil: [ self shortNames ].
			self session announcer announce: JadeiteFileOperationCompleted new ]
]

{ #category : 'commands' }
RowanFileServiceClient >> popWith: directoryContentsList with: pathText [

	command := #pop.
	commandArgs := Array new.
	self issueFileServiceCommandOnCompletion: [
			answer ifNotNil: [
					self uiManager defer: [
							directoryContentsList list: self shortNames.
							pathText text: path.
							self session announcer announce:
								JadeiteFileOperationCompleted new ] ] ]
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

	RowanServiceUpdater current critical: [
		command := #pathStringFor:.
		commandArgs := Array with: fileName.
		self issueFileServiceCommandOnCompletion: [ path := answer ] ]
]
