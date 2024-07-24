"
This class contains auto commit tests. 
"
Class {
	#name : 'JadeiteForPharoAutoCommitTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser [
	"Not a very good test but the last service logged should not be an #updateAutoCommit command which was the bug"

	| loggingState |
	loggingState := RowanServiceUpdater current isLogging.
	RowanServiceUpdater current isLogging: true.

	[
	projectsBrowser ifNil: [ self setupProjectBrowser ].

	[
	RowanServiceUpdater current loggingService services do: [ :service |
		self deny: (service updateType includes: #updateAutoCommitButton) ] ]
		ensure: [ self destroy: projectsBrowser ] ] ensure: [
		RowanServiceUpdater current isLogging: loggingState ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitInAdHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeiteWorkspace showOnSession: session.
	workspace text: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self
		assert: workspace codePane documentPresenter text asString
		equals: '123 "123"' ] ensure: [
		session executeString: 'UserGlobals removeKey: #TestCommit'.
		self commitTransaction.
		self setRemoteAutoCommit: false.
		workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitInAdHocExecution [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeiteWorkspace showOnSession: session.
	workspace setDocumentData: '''doSomething'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]') "TestCommit was committed" ]
		ensure: [
			session executeString: 'UserGlobals removeKey: #TestCommit'.
			self commitTransaction.
			self setRemoteAutoCommit: false.
			workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitOffInAdHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeiteWorkspace showOnSession: session.
	workspace text: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self
		assert: workspace codePane documentPresenter text
		equals: '123 "123"' ] ensure: [ workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitOffInAdHocExecution [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeiteWorkspace showOnSession: session.
	workspace setDocumentData: '''doSomething'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]') ]
		ensure: [ workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitUpdatedInSession [

	self setRemoteAutoCommit: false.
	session flipAutoCommit.
	self assert: session autoCommit.
	session flipAutoCommit.
	self deny: session autoCommit
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitUpdatesButtons [

	self
		testsJadeiteForPharoIssue: #issue20
		title: 'Could us an autocommit status indication in Console'.


	self setRemoteAutoCommit: false.
	[
	session flipAutoCommit.
	self assert: session autoCommit value.
	JadeiteConsole allInstances do: [ :console |
		console window ifNotNil: [ :window |
			window isOpen ifTrue: [
				self
					assert: console autoCommitButton label
					equals: 'Auto Commit - true' ] ] ].
	JadeiteBrowser allInstances do: [ :browser |
		browser window ifNotNil: [ :window |
			window isOpen ifTrue: [
				self
					assert: browser autoCommitButton label
					equals: 'Auto Commit - true' ] ] ] ] ensure: [
		session flipAutoCommit.
		self deny: session autoCommit value.
		JadeiteConsole allInstances do: [ :console |
			console window ifNotNil: [ :window |
				window isOpen ifTrue: [
					self
						assert: console autoCommitButton label
						equals: 'Auto Commit - false' ] ] ].
		JadeiteBrowser allInstances do: [ :browser |
			browser window ifNotNil: [ :window |
				window isOpen ifTrue: [
					self
						assert: browser autoCommitButton label
						equals: 'Auto Commit - false' ] ] ] ]
]
