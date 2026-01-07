"
For tests that require the default environment to run. 
e.g. Tests that need to see the window close confirmation dialog would use this because the default Jadeite test environment doesn't open close dialogs
"
Class {
	#name : 'JadeiteForPharoDefaultEnvironmentTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoDefaultEnvironmentTestCase >> runCaseManaged [

	^ DefaultExecutionEnvironment beActiveDuring: [ self runCase ]
]

{ #category : 'tests' }
JadeiteForPharoDefaultEnvironmentTestCase >> test_close [
	"try to test that a dialog is opened before console is closed and that the answer does the right thing"

	| dialog |
	self
		testsIssue: #issue155
		withTitle: '[jfpWor] All JfP windows closed without a promprt'. "https://github.com/GemTalk/JadeiteForPharo/issues/155"

	self openProjectBrowser.
	self denyIsNil: projectsBrowser.
	[ jadeiteShell window close ] fork.
	dialog := self waitForCloseDialog.
	dialog no.
	self denyIsNil: projectsBrowser.
	self deny: jadeiteShell window isClosed.
	self assert: session connection isOpen.

	[ jadeiteShell window close ] fork.
	dialog := self waitForCloseDialog.
	dialog yes.
	(Delay forMilliseconds: 500) wait. "must give windows time to close"
	self assert: projectsBrowser window isClosed.
	self deny: session connection isOpen
]
