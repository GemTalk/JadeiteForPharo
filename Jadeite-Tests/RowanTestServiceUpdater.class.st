Class {
	#name : 'RowanTestServiceUpdater',
	#superclass : 'RowanServiceUpdater',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'instance creation' }
RowanTestServiceUpdater class >> installTestUpdater [ 

	self current: self new
]

{ #category : 'commands' }
RowanTestServiceUpdater >> _basicIssueCommand: service [

	| postExecutionBlock |
	service isInCommand ifTrue: [ ^ self ].
	service prepareForReplication.
	postExecutionBlock := [ :aService |
	                      [
	                      self possibleSignalCompileError: service.
	                      self applyUpdates: service.
	                      service handleServiceCompletion.
	                      service inCommand signal ]
		                      on: GsCompileError
		                      do: [ :ex |
			                      service handleCompileError: ex.
			                      service inCommand signal ] ].
	service
		executeInSession: GciSession current
		onCompletion: postExecutionBlock
		semaphore: service inCommand.
	service inCommand wait
]

{ #category : 'commands' }
RowanTestServiceUpdater >> basicIssueCommand: service [
	"Don't block the morphic process.
	Any sending process has use completion blocks"

	| sem processingCommand |
	sem := Semaphore new.
	processingCommand := true.
	Processor activeProcess name = 'Morphic UI Process' ifTrue: [
		[ MorphicRenderLoop new doOneCycleWhile: [ processingCommand ] ]
			fork ].
	[
	[ self _basicIssueCommand: service ] ensure: [
		processingCommand := false.
		sem signal ] ] fork.
	sem wait
]

{ #category : 'commands' }
RowanTestServiceUpdater >> issueCommand: service session: session onCompletion: completionBlock [
	"remove this method once super class method doesn't have a halt in it for debugging"
	session ifNil: [ ^ nil ].
	service serviceCompletionBlock: completionBlock. 
	self basicIssueCommand: service
]
