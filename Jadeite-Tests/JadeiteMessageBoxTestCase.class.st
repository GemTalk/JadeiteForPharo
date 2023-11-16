"
Jadeite tests go around MessageBox's to make testing predictable. 

Test that this test infrastructure change works. 
"
Class {
	#name : 'JadeiteMessageBoxTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#category : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteMessageBoxTestCase >> setUp [
	super setUp.
	TestMessageBox enableJadeiteTestMessageBox
]

{ #category : 'as yet unclassified' }
JadeiteMessageBoxTestCase >> tearDown [
	super tearDown.
	TestMessageBox disableJadeiteTestMessageBox
]

{ #category : 'as yet unclassified' }
JadeiteMessageBoxTestCase >> testClearResultAfterEachUse [
	TestMessageBox plannedResult: #oneTime.
	self assert: TestMessageBox plannedResult == #oneTime.
	self assertIsNil: TestMessageBox plannedResult
]

{ #category : 'as yet unclassified' }
JadeiteMessageBoxTestCase >> testEnableTestMessageBox [
	TestMessageBox disableJadeiteTestMessageBox.
	self assert: MessageBox new isKindOf: MessageBox.
	TestMessageBox enableJadeiteTestMessageBox. 
	self assert: MessageBox new isKindOf: TestMessageBox.
	
]

{ #category : 'as yet unclassified' }
JadeiteMessageBoxTestCase >> testMessageBox [
	"remember that the debugging this test may be problematic
	if you don't turn off the test message box first. 
	TestMessageBox disableJadeiteTestMessageBox"

	| boolean answer |
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	boolean := MessageBox confirm: 'Do you want some ice cream?'.
	self assert: boolean.
	boolean := TestMessageBox plannedResult: #no.
	boolean := MessageBox confirm: 'Did you shave the yak today?'.
	self deny: boolean.
	TestMessageBox plannedResult: #noAnswer.
	answer := MessageBox notify: 'There will be no answer'.
	self assert: answer == MessageBox.
	TestMessageBox plannedResult: #noAnswer.
	answer := MessageBox notify: 'Warnings do not return answer'.
	self assert: answer == MessageBox
]

{ #category : 'as yet unclassified' }
JadeiteMessageBoxTestCase >> testRemoveGlobalHook [
	TestMessageBox disableJadeiteTestMessageBox.
	self assertIsNil: (Smalltalk at: #JadeiteTestsActive ifAbsent:[]).
	TestMessageBox enableJadeiteTestMessageBox. 
	self assert: (Smalltalk at: #JadeiteTestsActive).
	
]
