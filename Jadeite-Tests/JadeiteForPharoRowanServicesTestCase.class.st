Class {
	#name : 'JadeiteForPharoRowanServicesTestCase',
	#superclass : 'JadeiteForPharoHeadlessTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoRowanServicesTestCase >> test_answeringServiceAutoCommit [
	| answeringService | 
	
	answeringService := RowanAnsweringServiceClient new. 
	answeringService command: #autoCommit. 
]

{ #category : 'tests' }
JadeiteForPharoRowanServicesTestCase >> test_serviceNew [

	| service |
	service := RowanAnsweringService new.
	self assert: service class equals: RowanAnsweringServiceClient.
	self assert: service commandArgs equals: Array new. "did initialize run?"
	self assert: (service inCommand isKindOf: RowanSemaphore)
]
