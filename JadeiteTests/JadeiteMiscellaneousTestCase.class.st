Class {
	#name : 'JadeiteMiscellaneousTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'workspace'
	],
	#category : 'JadeiteTests'
}

{ #category : 'support' }
JadeiteMiscellaneousTestCase >> dismissPopoverAndPrint [

	SpCodePopoverPrintPresenter allInstances do: [ :popup |
		popup dismissAndPrint ]
]

{ #category : 'support' }
JadeiteMiscellaneousTestCase >> displayAndPrint [

	workspace codePane jadeDisplay.
	self dismissPopoverAndPrint
]

{ #category : 'support' }
JadeiteMiscellaneousTestCase >> focusWidgetText [

	^ UIManager default world activeHand keyboardFocus model model text
]

{ #category : 'support' }
JadeiteMiscellaneousTestCase >> tearDown [
	super tearDown.
	workspace
		ifNotNil: 
			[self todo:[workspace codePane documentPresenter view isModified: false].
			self destroy: workspace]
]

{ #category : 'tests' }
JadeiteMiscellaneousTestCase >> test_adHocCompileError [
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
JadeiteMiscellaneousTestCase >> test_adHocDisplay [

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
JadeiteMiscellaneousTestCase >> test_adHocExecute [

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
JadeiteMiscellaneousTestCase >> test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser [
	"Not a very good test but the last service logged should not be an #updateAutoCommit command which was the bug"

	| loggingState |
	loggingState := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: true.
	
	[projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openBrowser]].
	
	[BrowserUpdate current loggingService services
		do: [:service | self deny: (service updateType includes: #updateAutoCommitButton)]]
			ensure: [self destroy: projectsBrowser]]
			ensure: [BrowserUpdate current isLogging: loggingState]
]

{ #category : 'tests' }
JadeiteMiscellaneousTestCase >> test_autoCommitInAdHocDisplay [

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
JadeiteMiscellaneousTestCase >> test_autoCommitInAdHocExecution [

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
JadeiteMiscellaneousTestCase >> test_autoCommitOffInAdHocDisplay [

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
JadeiteMiscellaneousTestCase >> test_autoCommitOffInAdHocExecution [

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
JadeiteMiscellaneousTestCase >> test_autoCommitUpdatedInSession [
	| autoCommit |
	
	[autoCommit := session autoCommit value.
	self setAutoCommit: true.
	self assert: session autoCommit.
	self setAutoCommit: false.
	self deny: session autoCommit]
			ensure: [self setAutoCommit: autoCommit]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_autocompleteCaseInsensitiveSearch [
	self testsIssue: #issue660
		withTitle: 'Class autocomplete is not case insensitive (fix #636 not complete in 3.0.91)'.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: true.
	self assert: ((JadeiteSearch new allClassesStartingWith: 'cp') includes: 'CPointer').
	self assert: ((JadeiteSearch new allClassesStartingWith: 'cp') includes: 'CPreprocessor').
	self assert: ((JadeiteSearch new allClassesStartingWith: 'e') includes: 'Error').
	self assert: ((JadeiteSearch new allClassesStartingWith: 'rowanan') includes: 'RowanAnsweringService')
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_autocompleteClearsSymbolsOnLogout [
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	self deny: JadeiteSearch allClassNames isEmpty.
	self deny: JadeiteSearch allSelectorSymbols isEmpty.
	TestMessageBox
		enableJadeiteTestMessageBox;
		plannedResult: #no.
	
	[
	[self destroy: transcript.
	self verifyWindowClosed: transcript]
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: JadeiteSearch allClassNames isEmpty.
	self assert: JadeiteSearch allSelectorSymbols isEmpty]
			ensure: [self ensureTestIsSetUpAfterLogout]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_autocompleteSaveClassSymbolAdded [
	self testsIssue: #issue647 withTitle: 'Adding class doesn''t update autocomplete symbols'.
	self openProjectBrowser.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: true.
	self deny: (JadeiteSearch allClassNames includes: #TestCacheSaveClassName).
	self selectRowanSample1Test.
	self
		saveClass: 'TestCacheSaveClassName'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Tests'.
	[self assert: (JadeiteSearch allClassNames includes: 'TestCacheSaveClassName')] ensure: 
			[self assert: self projectsPresenter selectedClass name equals: 'TestCacheSaveClassName'.
			self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
			JadeiteSearch allClassNames remove: 'TestCacheSaveClassName'.	"for test reruns"
			projectsBrowser view close.
			projectsBrowser := nil]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_autocompleteSaveMethodSymbolAdded [
	self openProjectBrowser.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: true.
	self deny: (JadeiteSearch allSelectorSymbols includes: #test_autocompleteSaveMethodSymbolAdded).
	self selectRowanSample1Test.
	self
		saveMethod: 'test_autocompleteSaveMethodSymbolAdded  ^''temp method to delete'''
		in: 'RowanSample1Test'
		category: 'other'.
	[self assert: (JadeiteSearch allSelectorSymbols includes: #test_autocompleteSaveMethodSymbolAdded)]
		ensure: 
			[JadeiteSearch allSelectorSymbols remove: #test_autocompleteSaveMethodSymbolAdded.	"for test reruns"
			projectsBrowser view close.
			projectsBrowser := nil]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_autocompleteSort [
	"shortest first"

	| search |
	search := JadeiteSearch new.
	self assert: (search sortForAutoCompletion: #('aaaaa' 'bbbb' 'ccc' 'dd')) asArray
		equals: #('dd' 'ccc' 'bbbb' 'aaaaa')
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_autocompleteSymbolsNotAddedToIfAutocompleteOff [
	self testsIssue: #issue732 withTitle: 'Wildcard method search broken if autcomplete off '.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: false.
	self assert: JadeiteSearch allSelectorSymbols isEmpty.
	self
		saveMethod: 'covid  ^19'
		in: 'RowanSample1'
		category: 'deleteme'.
	self assert: JadeiteSearch allSelectorSymbols isEmpty.	"new symbol #covid not added"
	JadeiteSearch autoCompleteEnabled: true.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	self assert: (JadeiteSearch allSelectorSymbols includes: #covid).	"picked up the new symbol"
	self deny: (JadeiteSearch allSelectorSymbols includes: #covid19).
	self
		saveMethod: 'covid19 ^#isHappeningNow'
		in: 'RowanSample1'
		category: 'deleteme'.
	self assert: (JadeiteSearch allSelectorSymbols includes: #covid19)
]

{ #category : 'tests' }
JadeiteMiscellaneousTestCase >> test_classServiceNameIsString [
	| classService |
	self testsIssue: #issue441
		withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	classService := RowanClassService named: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String.
	classService := RowanClassService new name: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_convertToPattern [
	| pattern |
	self testsIssue: #issue258
		withTitle: 'wildcard senders and implentors don''t return proper selection list'.
	pattern := JadePresenter convertToPattern: '*symboldict*'. 
	self assert: pattern equals: #('' $* 'symboldict' $*).
	pattern := JadePresenter convertToPattern: '*SymbolDict*'. 
	self assert: pattern equals: #('' $* 'SymbolDict' $*).
	pattern := JadePresenter convertToPattern: '*SymbolDict*:'. 
	self assert: pattern equals: #('' $* 'SymbolDict' $* ':').
	pattern := JadePresenter convertToPattern: 'symboldict*'. 
	self assert: pattern equals: #('symboldict' $*).
	
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_createProjectEditorCreateProject [
	| editor presenter newProjectServiceInTranscript newProjectServiceInBrowser |
	editor := JadeiteCreateProjectEditor showOnSession: session.
	
	[presenter := editor primaryPresenter.
	presenter propertyList list first at: 2 put: 'Test_createProjectEditorCreateProject'.
	editor createProject.
	projectsBrowser := presenter browser.
	newProjectServiceInTranscript := transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = #Test_createProjectEditorCreateProject]
				ifNone: [].
	self denyIsNil: newProjectServiceInTranscript.
	newProjectServiceInBrowser := self projectsPresenter projectListPresenter list
				detect: [:projectService | projectService name = #Test_createProjectEditorCreateProject]
				ifNone: [].
	self denyIsNil: newProjectServiceInBrowser]
			ensure: 
				[self abortTransaction.
				newProjectServiceInBrowser := self projectsPresenter projectListPresenter list
							detect: [:projectService | projectService name = #Test_createProjectEditorCreateProject]
							ifNone: [].
				self assertIsNil: newProjectServiceInBrowser.
				self destroy: projectsBrowser]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_createProjectEditorProjectsChanged [
	| editor presenter |
	editor := JadeiteCreateProjectEditor showOnSession: session.
	
	[presenter := editor primaryPresenter.
	self deny: presenter propertiesAreChanged.
	self assert: (presenter propertyList list first at: 1) equals: 'projectName'.
	presenter propertyList list first at: 2 put: 'Abc'.
	self assert: presenter propertiesAreChanged]
			ensure: 
				[TestMessageBox enableJadeiteTestMessageBox.
				TestMessageBox plannedResult: #yes.	"close anyway? message"
				editor cancel.
				TestMessageBox disableJadeiteTestMessageBox]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_dolphinStackDumpBanners [
	| timestampString stream |
	self testsIssue: #issue237 withTitle: 'time stamp at end of Dolphin stack dump would be useful'.
	timestampString := JadeSessionManager stackDumpTimeStampString.
	stream := WriteStream on: String new.
	JadeSessionManager prependStackStartMessage: timestampString on: stream.
	self assert: ('*' , timestampString , '*' match: stream contents).
	self assert: ('*Starting Dolphin stack dump at*' match: stream contents).
	stream := WriteStream on: String new.
	JadeSessionManager appendStackEndMessage: timestampString on: stream.
	self assert: ('*' , timestampString , '*' match: stream contents).
	self assert: ('*Ending Dolphin stack dump started at*' match: stream contents).
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_fileSaveDialog [
	"not much of a test but at least we exercise the save button" 
	| dialog |
	dialog := JadeiteServerFileSaveTestDialog showOnSession: session
				initialFileName: 'test_fileSaveDialog.txt'.
	dialog fileNamePresenter value: 'test_fileSaveDialog.txt2'.
	dialog save.
	self assert: dialog fileNamePresenter value equals: 'test_fileSaveDialog.txt2'
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_fileSaveDialogBasics [
	| dialog priorDirectoryContents |
	
	[dialog := JadeiteServerFileSaveTestDialog showOnSession: session
				initialFileName: 'test_fileSaveDialogBasics.txt'.
	self assert: dialog isKindOf: JadeiteServerFileSaveDialog.
	self assert: dialog pathText value equals: self rowanProjectsHome.	"default to rowan projects home directory env var"
	self assert: dialog fileNamePresenter value equals: 'test_fileSaveDialogBasics.txt'.	"initial file name should be what was passed in"
	priorDirectoryContents := dialog fileSelectorPresenter directoryContentsList list
				collect: [:assoc | assoc key].
	dialog fileSelectorPresenter pop.
	self deny: priorDirectoryContents
		equals: (dialog fileSelectorPresenter directoryContentsList list collect: [:assoc | assoc key])	"no way to know the contents of the directory so just ensure the contents changed - lousy test"]
			ensure: [dialog cancel]
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_fileSaveFromWorkspace [
	| sourcePath targetPath |
	targetPath := 'testJadeiteFileSave.txt'.
	self deny: (session executeString: 'GsFile existsOnServer: ''' , targetPath , '''').
	sourcePath := '/export/gcm/where/gemstone64/releases/3.6.1/x86_64.Linux/fast/product/version.txt'.
	workspace := JadeiteServerFileWorkspace showOnSession: session path: sourcePath.
	
	[workspace writeDocumentTo: 'testJadeiteFileSave.txt'.
	self assert: (session executeString: 'GsFile existsOnServer: ''' , targetPath , '''')]
			ensure: [session executeString: 'GsFile removeServerFile: ''' , targetPath , '''']
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_fileSaveWithUnicode [
	| service |
	self testsIssue: #issue988
		withTitle: '[3.2.13] Saving a server text file with extended characters is not good'.
	self writeUnicodeFile.
	workspace := JadeiteServerFileWorkspace showOnSession: session
				path: '/export/uffda2/users/ewinger/logs//testJadeiteUnicodeFile.txt'.
	
	[self assert: workspace codePane documentPresenter text
		equals: 'This is some unicode text
  
Ã½ Å¡

Another extended char - Ã  aaa Å' replaceCrWithLf.
	workspace codePane documentPresenter text: 'Ã² Ã³ Ã´ Ãµ Ã¶ Ã· Ã¸ Ã¹ Ãº Ã»'.
	workspace saveDocument]
			ensure: [self destroy: workspace].
	workspace := JadeiteServerFileWorkspace showOnSession: session
				path: '/export/uffda2/users/ewinger/logs//testJadeiteUnicodeFile.txt'.
	self assert: workspace codePane documentPresenter value
		equals: 'Ã² Ã³ Ã´ Ãµ Ã¶ Ã· Ã¸ Ã¹ Ãº Ã»' replaceCrLfWithLf.
	service := RowanFileService new.
	service
		command: #deleteFileWithUnicode;
		commandArgs: Array new.
	service issueCommand: service session: session
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_logoutFatalError [
	self testsIssue: #issue858 withTitle: 'better gci error reporting is needed'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok.
	
	[
	[session
		executeString: 'UserGlobals at: #foo put: Array new. 

1 to: 10000000 do:[:index | 
	(UserGlobals at: #foo) add: ''abcdefghijklmno'', index printString]']
			on: GsFatalError
			do: 
				[:ex |
				"don't pass fatal error to outer handler (TestResult) so error doesn't get recorded. Default action will execute code that we're testing"
				[ex defaultAction] on: TerminateProcess
					do: 
						[:ex2 |
						"ignore terminate signal so test continues"
						]]]
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: ('VM temporary object memory is full* old space overflow*Shutting session down'
				match: TestMessageBox lastMessageBox text).
	self deny: session isValidSession
]

{ #category : 'tests' }
JadeiteMiscellaneousTestCase >> test_methodServiceClassNameIsString [
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
				className: #JadeiteMiscellaneousTestCase;
				meta: false.
	self assert: methodService className isKindOf: String
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_releaseOops [
	| remoteObject service |
	self testsIssue: #issue413 withTitle: '(3.0.56 & 3.0.62) running out vm memory quickly'.
	session releaseAllOops.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Array new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	session releaseAllOops.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Dictionary new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	service := RowanAnsweringService new.
	service command: #isTranscriptInstalled.
	self issueCommand: service.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Object new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	service := RowanProjectService new name: 'Rowan'.
	BrowserUpdate current updateServices: (Array with: service) session: session.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	self auditAll
]

{ #category : 'tests' }
JadeiteMiscellaneousTestCase >> test_returnedServices [
	"sanity test that we can use the returned services in other tests"

	workspace := JadeiteWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeiteWorkspace).
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	self displayAndPrint.
	self
		assert: workspace codePane documentPresenter text
		equals: '123 "''123''"'.
	self assert: BrowserUpdate current updates size equals: 1.
	self assert: (BrowserUpdate current updates first isKindOf:
			 RowanAnsweringService).
	self
		assert: BrowserUpdate current updates first answer last
		equals: '123'
]

{ #category : 'tests' }
JadeiteMiscellaneousTestCase >> test_serviceClassBookkeeping [
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

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_versionMatches [
	"See RowanVersionTest for more RowanClientServices version tests"

	self testsIssue: #issue521 withTitle: 'Jadeite version check'.
	self assert: session rowanClientServicesIsSupported	"whatever we're running is actually supported"
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> test_workingDirectoryEqualsImageDirectory [
	"should be set after login window first opens"

	self assert: File workingDirectory equals: SessionManager current imageBase
]

{ #category : 'as yet unclassified' }
JadeiteMiscellaneousTestCase >> writeUnicodeFile [
	"write out a text file with unicode characters"

	| service |
	service := RowanFileService new.
	service
		command: #writeFileWithUnicode;
		commandArgs: Array new.
	service issueCommand: service session: session
]
