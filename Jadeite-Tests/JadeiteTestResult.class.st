Class {
	#name : 'JadeiteTestResult',
	#superclass : 'TestResult',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'running' }
JadeiteTestResult >> runCase: aTestCase [

	aTestCase currentResource isJadeiteTestResource ifFalse: [
		^ super runCase: aTestCase ].
	aTestCase currentResource connectAsSystemUser.
	super runCase: aTestCase.
	aTestCase class runAsDataCurator ifTrue: [
			aTestCase currentResource connectAsDataCurator.
			super runCase: aTestCase ].
	aTestCase currentResource connectAsSystemUser
]

{ #category : 'running' }
JadeiteTestResult >> runCaseForDebug: aTestCase [

	aTestCase currentResource isJadeiteTestResource ifFalse: [
		^ super runCaseForDebug: aTestCase ].
	aTestCase currentResource connectAsSystemUser.
	super runCaseForDebug: aTestCase.
	aTestCase class runAsDataCurator ifTrue: [
			aTestCase currentResource connectAsDataCurator.
			super runCase: aTestCase ].
	aTestCase currentResource connectAsSystemUser
]
