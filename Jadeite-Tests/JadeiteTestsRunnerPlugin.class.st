Class {
	#name : 'JadeiteTestsRunnerPlugin',
	#superclass : 'DTTestsRunnerPlugin',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'api - accessing' }
JadeiteTestsRunnerPlugin class >> pluginName [
	^ 'Jadeite Tests Runner'
]

{ #category : 'configuration building' }
JadeiteTestsRunnerPlugin >> buildConfigurationFrom: aDrTests [
	"Builds a configuration from the plugin by reading the information held by the UI (aDrTests)."

	^ JadeiteTestsRunnerConfiguration
		  items: aDrTests selectedItems
		  packages: aDrTests packagesSelected
]

{ #category : 'ui' }
JadeiteTestsRunnerPlugin >> pluginPresenterClass [

	^ JadeiteTestsRunnerPluginPresenter
]

{ #category : 'api' }
JadeiteTestsRunnerPlugin >> runForConfiguration: aDTpluginConfiguration [

	| results |
	[
	results := self pluginResultClass new
		           testResults:
			           (self runTestSuites:
					            { aDTpluginConfiguration asTestSuite });
		           yourself ]
		on: JadeiteTestSuiteError
		do: [ ^ DTMockPluginResult new ].
	^ aDTpluginConfiguration handleResults: results for: self
]

{ #category : 'tests' }
JadeiteTestsRunnerPlugin >> runSuite: aTestSuite withResult: aResult [

	aTestSuite when: TestAnnouncement do: [ :testAnnouncement |
		self flag: #TODO. "Dirty"
		testAnnouncement test class = JadeiteTestSuite ifTrue: [  "<<<<< Jadeite change"
			self announceStatusChanged:
				('Running test {1}.' format: { testAnnouncement test name }) ] ]
		for: self.
	[ aResult mergeWith: (aTestSuite run) ] ensure: [
		aTestSuite unsubscribe: TestAnnouncement ]
]

{ #category : 'private' }
JadeiteTestsRunnerPlugin >> runTestSuites: testSuites [

	| result |
	result := JadeiteTestAsserter classForTestResult new. "<<<<<<Jadeite change"
	CurrentExecutionEnvironment runTestsBy: [
		testSuites
			do: [ :testSuite |
				| specificResult |
				specificResult := testSuite resultClass new.
				self runSuite: testSuite withResult: specificResult.
				result mergeWith: specificResult ]
			displayingProgress: 'Running Tests' ].
	^ result
]

{ #category : 'tests' }
JadeiteTestsRunnerPlugin >> testSuiteOf: aSetOfTest withName: aString [

	^ aSetOfTest collect: [ :each |
		  JadeiteTestSuite new
			  in: [ :suite |
				  suite
					  addTest: each;
					  name: (self label: aString forSuite: suite) ];
			  yourself ]
]
