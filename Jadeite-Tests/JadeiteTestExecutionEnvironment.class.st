Class {
	#name : 'JadeiteTestExecutionEnvironment',
	#superclass : 'TestExecutionEnvironment',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'controlling' }
JadeiteTestExecutionEnvironment >> activated [
	"do not start the watchdog to preserve RSR threads"

	mainTestProcess := Processor activeProcess.
	self registerDefaultServices
]

{ #category : 'controlling' }
JadeiteTestExecutionEnvironment >> runTestCase: aTestCase [
	"don't signal the watchdog"
	testCase := aTestCase.
	maxTimeForTest := testCase defaultTimeLimit.
	testCompleted := false.
	[self runTestCaseUnderWatchdog: aTestCase] ensure: [
		testCompleted := true.
		self cleanUpAfterTest	]
]
