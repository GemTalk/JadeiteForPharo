Class {
	#name : 'RowanFileService',
	#superclass : 'RowanAnsweringService',
	#instVars : [
		'path'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanFileService class >> templateClassName [

	^#RowanFileService
]

{ #category : 'commands' }
RowanFileService >> directoryPath [
	command := #directoryPath.
	commandArgs := Array new.
	self issueFileServiceCommand.
	^answer
]

{ #category : 'private' }
RowanFileService >> excludedInstVars [

	^super excludedInstVars , #('session')
]

{ #category : 'commands' }
RowanFileService >> expandPath [
	command := #expandPath.
	commandArgs := Array new. 
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileService >> fileContents [
	command := #fileContents.
	commandArgs := Array new. 
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileService >> fileInChunk: aString [
	command := #fileInChunk:.
	commandArgs := Array with: aString.
	self issueFileServiceCommand
]

{ #category : 'commands' }
RowanFileService >> fileName [

	command := #fileName.
	commandArgs := Array new.
	self issueFileServiceCommand.
	^answer
]

{ #category : 'commands' }
RowanFileService >> fileOutDictionaries: array [
	self
		command: #fileoutDictionaries:;
		commandArgs: (Array with: array).
	self issueFileServiceCommand
]

{ #category : 'commands' }
RowanFileService >> fileOutMethods: array [
	self
		command: #fileoutMethods:;
		commandArgs: (Array with: array).
	self issueFileServiceCommand
]

{ #category : 'public' }
RowanFileService >> indexOfSessionInstVar [
	^10
]

{ #category : 'commands' }
RowanFileService >> parentDirectoryPath [

	| sem |
	sem := Semaphore new.
	command := #parentDirectoryPath.
	commandArgs := Array new.
	self issueFileServiceCommandOnCompletion: [ sem signal ].
	sem wait.
	^ answer
]

{ #category : 'commands' }
RowanFileService >> remove [
	command := #remove.
	commandArgs := Array new.
	self issueFileServiceCommand
]

{ #category : 'accessing' }
RowanFileService >> shortNames [

	^ self shortNamesFrom: answer
]

{ #category : 'accessing' }
RowanFileService >> shortNamesFrom: anObject [ 
	^anObject collect: 
			[:assoc |
			| readStream string |
			readStream := ReadStream on: assoc key.
			
			[string := readStream upTo: $/.
			readStream atEnd] whileFalse: [].
			string -> assoc value]
]

{ #category : 'public' }
RowanFileService >> shouldReplicateInstVarAtIndex: index newService: newService [
	(super shouldReplicateInstVarAtIndex: index newService: newService) ifFalse:[^false]. 
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true
]
