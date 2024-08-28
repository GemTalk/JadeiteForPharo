Class {
	#name : 'JadeiteForPharoTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
JadeiteForPharoTestCase class >> defaultTimeLimit [

	^ 30 seconds
]

{ #category : 'support' }
JadeiteForPharoTestCase >> closeConnectionLaunchers [ 

	self testResourceClass current closeConnectionLaunchers
]

{ #category : 'as yet unclassified' }
JadeiteForPharoTestCase >> issueCommand: service onCompletion: completionBlock [

	RowanServiceUpdater current
		issueCommands: (Array with: service)
		session: session
		onCompletion: completionBlock
]

{ #category : 'running' }
JadeiteForPharoTestCase >> runCaseManaged [
	"In order to preserve RSR connections across test boundaries
	(to speed up the tests and expose bugs) we can't let the 
	watchdog loose. The watchdog is started by the test execution process"

	^DefaultExecutionEnvironment beActiveDuring: [ self runCase]
]
