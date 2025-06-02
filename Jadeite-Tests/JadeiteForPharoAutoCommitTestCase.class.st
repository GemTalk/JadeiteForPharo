"
This class contains auto commit tests. 
"
Class {
	#name : 'JadeiteForPharoAutoCommitTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoAutoCommitTestCase >> setUp [

	super setUp.
	JadeiteTestManager replacing: self uiManager
]

{ #category : 'support' }
JadeiteForPharoAutoCommitTestCase >> tearDown [

	self uiManager previousManager ifNotNil: [ :manager |
		manager beDefault ].
	RowanAnsweringService new setAutoCommit: false for: session
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser [
	"Not a very good test but the last service logged should not be an #updateAutoCommit command which was the bug"

	| loggingState |
	loggingState := RowanServiceUpdater current isLogging.
	RowanServiceUpdater current isLogging: true.

	[
	projectsBrowser ifNil: [ self setupProjectBrowser ].


	RowanServiceUpdater current loggingService services do: [ :service |
		self deny: (service updateType includes: #updateAutoCommitButton) ] ]
		ensure: [ RowanServiceUpdater current isLogging: loggingState ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitFailure [

	| transactionConflictInspector |
	self
		testsJadeiteForPharoIssue: #issue249
		title:
		'Autocommit commit conflicts brings up dialog, but ignoring dialog should not allow business as usual'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/249'.
	self setupProjectBrowser.
	RowanAnsweringService new setAutoCommit: false for: session.
	self
		assert: projectsBrowser autoCommitButton color
		equals: projectsBrowser autoCommitButton defaultColor.
	self
		assert: projectsBrowser autoCommitButton label
		equals: 'Auto Commit - false'.
	RowanAnsweringService new setAutoCommit: true for: session.
	self
		assert: projectsBrowser autoCommitButton color
		equals: Color green.
	[
	| service |
	service := RowanAutoCommitServiceClient new autoCommit: #failed.
	service autoCommitUpdate: self projectsPresenter.
	service postUpdateBlock value ]
		on: ProvideAnswerNotification
		do: [ :notification |
			self
				assert: notification messageText
				equals: RowanAutoCommitServiceClient autoCommitFailureMessage.
			notification resume: false "this simulates press 'No' on the dialog and auto commit will be turned off" ].

	[
	(transactionConflictInspector := JadeiteInspector allInstances
		                                 detect: [ :inspector |
			                                 ('Transaction Conflicts' match:
				                                  inspector window title) and: [
				                                 inspector window isOpen ] ]
		                                 ifNone: [  ]) isNil ] whileTrue: [
		(Delay forMilliseconds: 2) wait ].

	[ self denyIsNil: transactionConflictInspector ] ensure: [
		transactionConflictInspector window close ].
	"auto commit is turned off (but not really) so don't test the underlying value "
	self
		assert: projectsBrowser autoCommitButton color
		equals: projectsBrowser autoCommitButton defaultColor.
	self
		assert: projectsBrowser autoCommitButton label
		equals: 'Auto Commit - false'
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitInAdHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: true onCompletion: [].
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
		self setRemoteAutoCommit: false onCompletion: [].
		workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitInAdHocExecution [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: true onCompletion: [].
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
			self setRemoteAutoCommit: false onCompletion: [].
			workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoAutoCommitTestCase >> test_autoCommitOffInAdHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setRemoteAutoCommit: false onCompletion: [].
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
	self setRemoteAutoCommit: false onCompletion: [].
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

	self setRemoteAutoCommit: false onCompletion: [].
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

	self setRemoteAutoCommit: false onCompletion: [  ].
	[
	session flipAutoCommit.
	self assert: session autoCommit value.

	self
		assert: JadeiteConsole currentConsole autoCommitButton label
		equals: 'Auto Commit - true'.
	JadeiteBrowser allInstances do: [ :browser |
		browser window ifNotNil: [ :window |
			window isOpen ifTrue: [
				self
					assert: browser autoCommitButton label
					equals: 'Auto Commit - true' ] ] ] ] ensure: [
		session flipAutoCommit.
		self deny: session autoCommit value.

		self
			assert: JadeiteConsole currentConsole autoCommitButton label
			equals: 'Auto Commit - false' ].
	JadeiteBrowser allInstances do: [ :browser |
		browser window ifNotNil: [ :window |
			window isOpen ifTrue: [
				self
					assert: browser autoCommitButton label
					equals: 'Auto Commit - false' ] ] ]
]
