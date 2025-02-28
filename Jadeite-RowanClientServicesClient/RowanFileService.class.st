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

{ #category : 'private' }
RowanFileService >> excludedInstVars [

	^super excludedInstVars , #('session')
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
