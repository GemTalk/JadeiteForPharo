Class {
	#name : 'JadeiteTestAsserter',
	#superclass : 'TestAsserter',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'asserting' }
JadeiteTestAsserter class >> classForTestResult [

	^ JadeiteTestResult
]

{ #category : 'factory' }
JadeiteTestAsserter class >> suiteClass [
	^JadeiteTestSuite
]
