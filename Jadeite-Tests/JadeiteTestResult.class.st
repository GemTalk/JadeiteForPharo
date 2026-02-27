Class {
	#name : 'JadeiteTestResult',
	#superclass : 'TestResult',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'running' }
JadeiteTestResult >> runCase: aTestCase [

	aTestCase currentResource connectAsSystemUser.
	super runCase: aTestCase.
	aTestCase currentResource connectAsDataCurator.
	super runCase: aTestCase.
	aTestCase currentResource connectAsSystemUser
]

{ #category : 'running' }
JadeiteTestResult >> runCaseForDebug: aTestCase [

	aTestCase currentResource connectAsSystemUser.
	super runCaseForDebug: aTestCase.
	aTestCase currentResource connectAsDataCurator.
	super runCaseForDebug: aTestCase.
	aTestCase currentResource connectAsSystemUser.
]
