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
