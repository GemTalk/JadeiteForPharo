Class {
	#name : 'JadeiteForPharoReplicationTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoReplicationTestCase >> test_methodServiceReplicationIndices [
	"Inst var lookups are slower than indexed lookups
	so RowanClientServices replication uses indexes. 
	This can be broken when new inst vars are added. 
	Test that indexes actually represent the inst vars intended."

	| methodService theClass |
	theClass := RowanMethodServiceClient.
	methodService := theClass new.
	self
		assert: (theClass methodDictionary keys select: [ :key |
				 'indexOf*' match: key ]) size
		equals: 6.
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
		(theClass allInstVarNames at: methodService indexOfInCommandInstVar)
		equals: #inCommand.
	self
		assert: (theClass allInstVarNames at:
				 methodService indexOfFirstReferenceInstVar)
		equals: #firstReference.
	self
		assert:
		(theClass allInstVarNames at: methodService indexOfSourceInstVar)
		equals: #source.
	self
		assert:
		(theClass allInstVarNames at: methodService indexOfStepPointsInstVar)
		equals: #stepPoints.
	self
		assert:
		(theClass allInstVarNames at: methodService indexOfTestResultInstVar)
		equals: #testResult
]

{ #category : 'tests' }
JadeiteForPharoReplicationTestCase >> test_packageServiceReplicationIndices [
	"Inst var lookups are slower than indexed lookups
	so RowanClientServices replication uses indexes. 
	This can be broken when new inst vars are added. 
	Test that indexes actually represent the inst vars intended."

	| packageService theClass |
	theClass := RowanPackageServiceClient.
	self
		assert: (theClass methodDictionary keys select: [ :key |
				 'indexOf*' match: key ]) size
		equals: 2.
	packageService := theClass new.
	self
		assert:
		(theClass allInstVarNames at: packageService indexOfInCommandInstVar)
		equals: #inCommand.
	self
		assert: (theClass allInstVarNames at:
				 packageService indexOfServiceCompletionBlock)
		equals: #serviceCompletionBlock
]

{ #category : 'tests' }
JadeiteForPharoReplicationTestCase >> test_projectServiceReplicationIndices [
	"Inst var lookups are slower than indexed lookups
	so RowanClientServices replication uses indexes. 
	This can be broken when new inst vars are added. 
	Test that indexes actually represent the inst vars intended."

	| projectService theClass |
	theClass := RowanProjectServiceClient.
	projectService := theClass new.
	self
		assert:
		(theClass allInstVarNames at: projectService indexOfInCommandInstVar)
		equals: #inCommand.
	self
		assert: (theClass allInstVarNames at:
				 projectService indexOfServiceCompletionBlock)
		equals: #serviceCompletionBlock
]
