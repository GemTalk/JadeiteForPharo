Class {
	#name : 'RowanTestServiceUpdater',
	#superclass : 'RowanServiceUpdater',
	#classVars : [
		'ConnectionLost',
		'CurrentTestName'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
RowanTestServiceUpdater class >> connectionLost [

	^ ConnectionLost ifNil: [ false ]
]

{ #category : 'accessing' }
RowanTestServiceUpdater class >> currentTestName [

	^ CurrentTestName ifNil: [ 'unknown test' ]
]

{ #category : 'accessing' }
RowanTestServiceUpdater class >> currentTestName: aString [

	CurrentTestName := aString
]

{ #category : 'instance creation' }
RowanTestServiceUpdater class >> installTestUpdater [
	"RowanTestServiceUpdater installTestUpdater"
	self resetConnectionLost.
	self adoptInstance: self current
]

{ #category : 'accessing' }
RowanTestServiceUpdater class >> resetConnectionLost [

	ConnectionLost := false
]

{ #category : 'commands' }
RowanTestServiceUpdater >> basicIssueCommand: service [
	"Don't block the morphic process.
	Any sending process has to use completion blocks"

	| sem processingCommand connectionError monitorFork |
	self class connectionLost ifTrue: [ ^ self ].
	sem := Semaphore new.
	processingCommand := true.
	connectionError := nil.
	Processor activeProcess name = 'Morphic UI Process' ifTrue: [
		[
		[ MorphicRenderLoop new doOneCycleWhile: [ processingCommand ] ]
			on: Error
			do: [ :ex |
				processingCommand := false.
				ex pass "stop the render loop and let a debugger open" ] ] fork ].
	[
	[ [ self _basicIssueCommand: service ]
		on: Error
		do: [ :ex |
			(ex messageText includesSubstring: 'Connection is not open')
				ifTrue: [ connectionError := ex ]
				ifFalse: [ ex pass ] ] ]
	ensure: [
		processingCommand := false.
		sem signal ] ] fork.
	"Monitor session validity; if the connection drops while the command fork is
	 blocked on service inCommand wait, signal it so the fork can exit cleanly."
	monitorFork := [
		[ processingCommand and: [ GciSession current isValidSession ] ] whileTrue: [
			(Delay forMilliseconds: 100) wait ].
		processingCommand ifTrue: [
			connectionError := connectionError
				ifNil: [ Error new messageText: 'Connection is not open' ].
			service inCommand signal ] ] fork.
	sem wait.
	monitorFork terminate.
	connectionError ifNotNil: [ :e |
		ConnectionLost ifFalse: [
			ConnectionLost := true.
			JadeiteConnectionLostError
				signal:
				'Connection lost in ' , self class currentTestName , ': '
					, e messageText ] ]
]

{ #category : 'commands' }
RowanTestServiceUpdater >> invalidSessionAction [
	"no action - tests can sometimes get invalid sessions and we don't want to disconnect."


]
