Class {
	#name : 'JadeiteForPharoMiscellaneousTestCase',
	#superclass : 'JadeiteForPharoTestCase',
	#instVars : [
		'workspace'
	],
	#category : 'JadeiteTests'
}

{ #category : 'support' }
JadeiteForPharoMiscellaneousTestCase >> dismissPopoverAndPrint [

	SpCodePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ]
]

{ #category : 'support' }
JadeiteForPharoMiscellaneousTestCase >> displayAndPrint [

	workspace codePane jadeDisplay.
	self dismissPopoverAndPrint
]

{ #category : 'support' }
JadeiteForPharoMiscellaneousTestCase >> focusWidgetText [

	^ UIManager default world activeHand keyboardFocus model model text
]

{ #category : 'support' }
JadeiteForPharoMiscellaneousTestCase >> tearDown [
	super tearDown.
	workspace
		ifNotNil: 
			[workspace isModified: false.
			self destroy: workspace]
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_adHocCompileError [
	"When the popup is raised in the workspace, the focus widget should be the popover.
	We try to get that based on which widget is active as the workspace has no memory of the popover"

	self
		testsIssue: #issue688
		withTitle: '(3.0.92) Compile Errors in Workspace broken'.
	workspace := JadeiteWorkspace showOnSession: session.
	workspace setDocumentData: '#(1 2'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self
		assert: self focusWidgetText
		equals: '''expected a right parenthesis'''
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_adHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeiteWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeiteWorkspace).
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self
		assert: workspace codePane documentPresenter text
		equals: '123 "''123''"'
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_adHocExecute [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeiteWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeiteWorkspace).
	session executeString: 'UserGlobals removeKey: #foo ifAbsent:[]'.
	workspace setDocumentData: 'UserGlobals at: #foo put: ''bar'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self
		assert: workspace codePane documentPresenter text
		equals: 'UserGlobals at: #foo put: ''bar'''.
	self
		assert: (session executeString: 'UserGlobals at: #foo')
		equals: 'bar'
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser [
	"Not a very good test but the last service logged should not be an #updateAutoCommit command which was the bug"

	| loggingState |
	loggingState := RowanServiceUpdater current isLogging.
	RowanServiceUpdater current isLogging: true.
	
	[projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openBrowser]].
	
	[RowanServiceUpdater current loggingService services
		do: [:service | self deny: (service updateType includes: #updateAutoCommitButton)]]
			ensure: [self destroy: projectsBrowser]]
			ensure: [RowanServiceUpdater current isLogging: loggingState]
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_autoCommitInAdHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeiteWorkspace showOnSession: session.
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self
		assert: workspace codePane documentPresenter text
		equals: '123 "''123''"' ] ensure: [
		session executeString: 'UserGlobals removeKey: #TestCommit'.
		self commitTransaction.
		self setAutoCommit: false.
		workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_autoCommitInAdHocExecution [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setAutoCommit: true.
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
			self setAutoCommit: false.
			workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_autoCommitOffInAdHocDisplay [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeiteWorkspace showOnSession: session.
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self assert:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil:
		(session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self
		assert: workspace codePane documentPresenter text
		equals: '123 "''123''"' ] ensure: [ workspace isModified: false ]
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_autoCommitOffInAdHocExecution [

	self
		testsIssue: #issue427
		withTitle: '(3.0.60) autocommit not done after successful doits'.

	[
	self setAutoCommit: false.
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
JadeiteForPharoMiscellaneousTestCase >> test_autoCommitUpdatedInSession [
	| autoCommit |
	
	[autoCommit := session autoCommit value.
	self setAutoCommit: true.
	self assert: session autoCommit.
	self setAutoCommit: false.
	self deny: session autoCommit]
			ensure: [self setAutoCommit: autoCommit]
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_classServiceNameIsString [
	| classService |
	self testsIssue: #issue441
		withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	classService := RowanClassService named: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String.
	classService := RowanClassService new name: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_methodServiceClassNameIsString [
	| methodService |
	self testsIssue: #issue441
		withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	methodService := RowanMethodService new
				selector: 'fnoodle';
				className: 'JadeiteMiscellaneousTestCase';
				meta: false.
	self assert: methodService className isKindOf: String.
	methodService := RowanMethodService new
				selector: 'fnoodle';
				className: #JadeiteForPharoMiscellaneousTestCase;
				meta: false.
	self assert: methodService className isKindOf: String
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_returnedServices [
	"sanity test that we can use the returned services in other tests"

	workspace := JadeiteWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeiteWorkspace).
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self
		assert: workspace codePane documentPresenter text
		equals: '123 "''123''"'.
	self assert: RowanServiceUpdater current updates size equals: 1.
	self assert: (RowanServiceUpdater current updates first isKindOf:
			 RowanAnsweringService).
	self
		assert: RowanServiceUpdater current updates first answer last
		equals: '123'
]

{ #category : 'tests' }
JadeiteForPharoMiscellaneousTestCase >> test_serviceClassBookkeeping [
	"All service classes should have an entry in`Rowan platform serviceClasses`. 
	Only SystemUser can reference rowan services classes directly so other users
	must use indirection to look up the class. Hence the necessity of this extra
	bookkeeping"

	| testService remoteClassNameSymbols |
	self testsIssue: #issue687 withTitle: 'inspection as DataCurator broken'.
	"check all client service classes exist on server"
	RowanService subclasses do: 
			[:subclass |
			| remoteClassExists clientClassName |
			clientClassName := subclass name.
			remoteClassExists := session
						executeString: '| serviceClass | 
								serviceClass := Rowan platform serviceClasses detect:[:ea | ea name = '
								, clientClassName printString , '] ifNone:[].
								serviceClass notNil'.
			self assert: remoteClassExists].

	"check all remote service classes exist on client"
	remoteClassNameSymbols := session executeString: '(RowanService subclasses collect:[:cls | cls name]) asArray'.
	remoteClassNameSymbols do:[:className |
		self denyIsNil: (Smalltalk at: className ifAbsent: [  ])]

]

{ #category : 'support' }
JadeiteForPharoMiscellaneousTestCase >> writeUnicodeFile [
	"write out a text file with unicode characters"

	| service |
	service := RowanFileService new.
	service
		command: #writeFileWithUnicode;
		commandArgs: Array new.
	service issueCommand: service session: session
]
