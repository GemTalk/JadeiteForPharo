Class {
	#name : 'JadeiteTestsRunnerConfiguration',
	#superclass : 'DTTestsRunnerConfiguration',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'converting' }
JadeiteTestsRunnerConfiguration >> asTestSuite [
	|newTestSuite|
	newTestSuite := JadeiteTestSuite new.
	self items
		reject: #drTestsIsAbstract "This method allows to either test a test case instance or a test suite depending on kind of item."
		thenDo: [ :item | newTestSuite addTest: item drTestsSuite "This method allows to either add a test case instance or a test suite depending on kind of item." ].
	^ newTestSuite
]
