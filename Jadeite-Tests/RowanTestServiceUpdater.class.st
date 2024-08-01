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
	service jadeiteLog: 'enter'.
	service isInCommand ifTrue: [ ^ self ].
	service prepareForReplication.
	postExecutionBlock := [ :aService |
	                      [
	                      service jadeiteLog: 'enter completion block'.
	                      self possibleSignalCompileError: service.
	                      self applyUpdates: service. 
	                      service handleServiceCompletion.
	                      service inCommand signal.
	                      service jadeiteLog: 'exit completion block' ]
		                      on: GsCompileError
		                      do: [ :ex |
			                      service handleCompileError: ex.
			                      service inCommand signal ] ].
	service
		executeInSession: GciSession current
		onCompletion: postExecutionBlock
		semaphore: service inCommand.
	service jadeiteLog: 'wait'.
	service inCommand wait.
	service jadeiteLog: 'exit'
]

{ #category : 'commands' }
RowanTestServiceUpdater >> basicIssueCommand: service [
	"Don't block the morphic process.
	Any sending process has use completion blocks"

	| sem processingCommand |
	disableCommands ifTrue: [ ^ self ].
	sem := Semaphore new.
	processingCommand := true.
	Processor activeProcess name = 'Morphic UI Process' ifTrue: [
		[ MorphicRenderLoop new doOneCycleWhile: [ processingCommand ] ]
			fork ].
	service jadeiteLog:
		'------------------ enter ' , service printString
		, '------------------------------'.
	[
	service jadeiteLog: 'enter forked block'.
	[ self _basicIssueCommand: service ] ensure: [
		sem signal.
		processingCommand := false.
		service jadeiteLog: 'exit forked block' ] ] fork.
	sem wait.
	service jadeiteLog: '------------------ exit ' , service printString
		, '------------------------------'
]

{ #category : 'commands' }
RowanTestServiceUpdater >> issueCommand: service session: session onCompletion: completionBlock [
	"remove this method once super class method doesn't have a halt in it for debugging"
	session ifNil: [ ^ nil ].
	service serviceCompletionBlock: completionBlock. 
	self basicIssueCommand: service
]
