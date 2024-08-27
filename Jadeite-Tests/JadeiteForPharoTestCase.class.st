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

	JadeiteConnectionLauncher allInstances do: [ :launcher |
		| profile |
		profile := launcher connectionProfile.
		profile isConnected ifTrue: [ profile disconnect ].
		self destroy: launcher ].
]

{ #category : 'running' }
JadeiteForPharoTestCase >> runCaseManaged [
	"In order to preserve RSR connections across test boundaries
	(to speed up the tests and expose bugs) we can't let the 
	watchdog loose. The watchdog is started by the test execution process"

	^DefaultExecutionEnvironment beActiveDuring: [ self runCase]
]
