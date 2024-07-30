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
RowanTestServiceUpdater >> basicIssueCommand: service [
	"Don't block the morphic process.
	Any sending process has use completion blocks"

	| sem |
	sem := Semaphore new.
	disableCommands ifTrue: [ ^ self ].
	[ [ self _basicIssueCommand: service ] ensure: [ sem signal ] ] fork.
	sem wait
]

{ #category : 'commands' }
RowanTestServiceUpdater >> issueCommand: service session: session onCompletion: completionBlock [
	"remove this method once super class method doesn't have a halt in it for debugging"
	session ifNil: [ ^ nil ].
	service serviceCompletionBlock: completionBlock. 
	self basicIssueCommand: service
]
