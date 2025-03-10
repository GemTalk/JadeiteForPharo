Class {
	#name : 'JadeiteForPharoRowanClassServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoRowanClassServiceTestCase >> test_classServiceCategoryReplication [
	"method categories come in as strings then converted to JadeiteCategory's in the presenter.
	Confirm that categories always are replicated as strings"

	| service answeringService |
	service := RowanClassServiceClient named: 'Collection'.
	updater updateService: service session: session onCompletion: [  ].
	answeringService := RowanAnsweringServiceClient new.
	answeringService
		execReturningObject:
		'Collection categoryNames asSortedCollection asOrderedCollection'
		in: session.
	self assert: service categories equals: answeringService answer
]

{ #category : 'tests' }
JadeiteForPharoRowanClassServiceTestCase >> test_classServiceReplicationIndices [
	"Inst var lookups are slower than indexed lookups
	so RowanClientServices replication uses indexes. 
	This can be broken when new inst vars are added. 
	Test that indexes actually represent the inst vars intended."

	| methodService theClass |
	theClass := RowanClassServiceClient.
	methodService := theClass new.
	self
		assert: (theClass methodDictionary keys select: [ :key |
				 'indexOf*' match: key ]) size
		equals: 4.
	self
		assert:
		(theClass allInstVarNames at: methodService indexOfInCommandInstVar)
		equals: #inCommand.
	self
		assert: (theClass allInstVarNames at:
				 methodService indexOfServiceCompletionBlock)
		equals: #serviceCompletionBlock.
	self
		assert:
		(theClass allInstVarNames at: methodService indexOfMetaInstVar)
		equals: #meta.
	self
		assert:
		(theClass allInstVarNames at: methodService indexOfMethodsInstVar)
		equals: #methods
]
