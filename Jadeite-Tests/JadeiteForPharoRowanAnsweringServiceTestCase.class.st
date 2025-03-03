Class {
	#name : 'JadeiteForPharoRowanAnsweringServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoRowanAnsweringServiceTestCase >> setUp [ 

	super setUp. 
	updater := RowanServiceUpdater current. 
]

{ #category : 'tests' }
JadeiteForPharoRowanAnsweringServiceTestCase >> test_answeringServiceAutoCommit [
	| answeringService1 answeringService2 | 
	
	answeringService1 := RowanAnsweringServiceClient new. 
	answeringService1 command: #autoCommit. 
	updater issueCommand: answeringService1 session: session. 
	answeringService2 := RowanAnsweringServiceClient new. 
	answeringService2 exec: 'RowanService autoCommit' in: session onCompletion: [  ].
	self assert: answeringService2 answer equals: answeringService1 answer. 
	
]

{ #category : 'tests' }
JadeiteForPharoRowanAnsweringServiceTestCase >> test_serviceNew [
	"create any service, verify that the instantiated class is *Client"

	| service |
	service := RowanAnsweringService new.
	self assert: service class equals: RowanAnsweringServiceClient.
	self assert: service commandArgs equals: Array new. "did initialize run?"
	self assert: (service inCommand isKindOf: RowanSemaphore)
]
