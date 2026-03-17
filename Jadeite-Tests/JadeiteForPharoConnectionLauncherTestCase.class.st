"
Inst var #shouldReopenLauncher - At teardown, let the test decide if we need to reopen the launcher. Some tests may not use the real launcher at all. 
"
Class {
	#name : 'JadeiteForPharoConnectionLauncherTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'launcher',
		'fileRef',
		'backupConnections',
		'backupLastDirectory',
		'clientLibariesPath',
		'shouldReopenLauncher'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoConnectionLauncherTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor"

	^ {
		  JadeiteConnectionLauncher.
		  JadeiteGCIConnectionProfile } asOrderedCollection
]

{ #category : 'testing' }
JadeiteForPharoConnectionLauncherTestCase class >> runAsDataCurator [
	"If the test class is expected to pass while
	logged in with DataCurator, override this 
	method to return true. The test runner will
	run each test as both SystemUser and DataCurator."

	^ true
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> changeAllLauncherFields [

	self changeValueOf: launcher hostText adapter widget text: 'newValue'.
	self
		assert: launcher hostText adapter widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor.
	self
		changeValueOf: launcher stoneText adapter widget
		text: 'newValue'.
	self
		assert: launcher stoneText adapter widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor.
	self changeValueOf: launcher userText adapter widget text: 'newValue'.
	self
		assert: launcher userText adapter widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor.
	self
		changeValueOf: launcher passwordText adapter widget
		text: 'newValue'.
	self
		assert: launcher passwordText adapter widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor.
	self
		changeValueOf: launcher versionText adapter widget
		text: 'newValue'.
	self
		assert: launcher versionText adapter widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor.
	self
		changeValueOf: launcher netldiText adapter widget
		text: 'newValue'.
	self
		assert: launcher netldiText adapter widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> changeValueOf: widget text: aString [

	widget updateTextWith: aString.
	widget textChanged.
	WorldMorph doOneCycle
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> connectionDirName [

	^ 'testImportFromConnectionDir'
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> connectionFileName [

	^ 'testConnectionFile'
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> createMockConnectionProfileDirectory [

	| dir |
	dir := self connectionDirName asFileReference asAbsolute.
	dir createDirectory.
	1 to: self numberOfTestConnections do: [ :idx |
		| profileCopy ref filename |
		filename := self connectionFileName , idx printString.
		profileCopy := JadeiteConnectionProfile connectionProfile copy.
		ref := (dir / filename) asAbsolute.
		launcher basicExportProfile: ref ]
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> deleteTestConnectionFile [

	fileRef ifNil: [ ^ self ].
	fileRef exists ifTrue: [ fileRef delete ]
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> numberOfTestConnections [

	^ 10
]

{ #category : 'accessing' }
JadeiteForPharoConnectionLauncherTestCase >> profile [

	^ JadeiteGCIConnectionProfile connectionProfile
]

{ #category : 'accessing' }
JadeiteForPharoConnectionLauncherTestCase >> rcsSha [
	"make sure the test gets the sha in a way that works for both DataCurator which has no RCS projects visible and SystemUser"

	| sem answeringService waitResult |
	sem := Semaphore new.
	answeringService := RowanAnsweringServiceClient new.
	[
		answeringService
			exec: self rcsShaServerCode
			in: GciSession current
			onCompletion: [ sem signal ] ] fork.
	waitResult := sem waitTimeoutMilliseconds: 500.
	waitResult ifTrue: [ self fail: 'Timeout getting RCS sha exceeded' ].
	^ answeringService answer withoutQuoting
]

{ #category : 'accessing' }
JadeiteForPharoConnectionLauncherTestCase >> rcsShaServerCode [

	^ '| aUserId userId userProfile userPlatformDict registry rcsProj |
	aUserId := ''SystemUser''.
	userProfile := AllUsers userWithId: aUserId.
	(userProfile defaultObjectSecurityPolicy ifNil: [true] ifNotNil: [:x |x currentUserCanRead])
		ifFalse: [
			"do not have permissions to read objects created by <aUserId>"
			^ nil ].
	userPlatformDict := (AllUsers userWithId: aUserId) objectNamed: ''UserGlobals''.
	registry := userPlatformDict
		at: #''RwGsLoadedProjectRegistry''
		ifAbsent: [ 
			(self currentUserId = aUserId)
				ifFalse: [ ^ nil ].
			userPlatformDict at: #''|RwGsLoadedProjectRegistry|'' put: StringKeyValueDictionary new ].
	rcsProj := registry at: ''RowanClientServices'' ifAbsent: [ ].
	rcsProj ifNil: [String new] ifNotNil: [rcsProj loadedCommitId] '
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> removeConnectionProfileDirectory [

	self connectionDirName asFileReference ensureDeleteAll
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> setUp [

	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	JadeiteTestManager replacing: self uiManager.
	self ensureConnectionProfileEstablished.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	launcher clientLibrariesPath:
		JadeiteGCIConnectionProfile clientLibrariesPath.
	backupConnections := launcher class importedConnections copy. "backup"
	backupLastDirectory := launcher class lastImportDirectory.
	shouldReopenLauncher := true
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> tearDown [

	JadeiteConnectionLauncher soleInstance ifNotNil: [ :l |
		l presenter application useBackend: #JadeiteBackend ].
	super tearDown.
	self uiManager restore.
	clientLibariesPath ifNotNil: [
			JadeiteGCIConnectionProfile clientLibrariesPath: clientLibariesPath.
			JadeiteConnectionLauncher soleInstance ifNotNil: [
				JadeiteConnectionLauncher soleInstance window close ].
			JadeiteConnectionApplication singleton start ].
	JadeiteConnectionProfile connectionProfile disconnect.
	fileRef ifNotNil: [ fileRef exists ifTrue: [ fileRef delete ] ].
	self removeConnectionProfileDirectory.
	self destroy: JadeiteConsole currentConsole.
	shouldReopenLauncher
		ifTrue: [ self destroy: launcher ]
		ifFalse: [ launcher pathText text: clientLibariesPath ].
	backupConnections ifNotNil: [
		JadeiteConnectionLauncher importedConnections: backupConnections ].
	backupLastDirectory ifNotNil: [
		JadeiteConnectionLauncher lastImportDirectory: backupLastDirectory ].
	self deleteTestConnectionFile "for those tests that create one"
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> testConnectionFileReference [

	| fileName |
	fileName := self connectionFileName.
	^ (FileSystem disk workingDirectoryPath / fileName) asFileReference
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_autoAcceptState [
	"if autoAccept is not false, we don't get hasUnacceptedEdit changes. 
	We use hasUnacceptedEdit to know what indication to put on the text fields. 
	Expose this simple change as a test so we know where this is done - JadeiteTextInputFieldAdapter >> buildWidget"

	self deny: launcher hostText adapter widget autoAccept
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_basicFileExport [

	| profile fileProfile |
	fileRef := self testConnectionFileReference.
	self deleteTestConnectionFile.
	profile := JadeiteConnectionProfile connectionProfile.
	launcher basicExportProfile: fileRef.
	self assert: fileRef exists.
	fileProfile := STON fromString: fileRef contents.
	self assert: fileProfile version equals: profile version.
	self assert: fileProfile stone equals: profile stone.
	self assert: fileProfile netldi equals: profile netldi.
	self assert: fileProfile user equals: profile user.
	self assert: fileProfile password equals: profile password.
	self assert: fileProfile path equals: profile path
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_basicFileImport [

	| profile |
	"check some fields"
	JadeiteConnectionProfile connectionProfile disconnect.
	fileRef := self testConnectionFileReference.
	self deleteTestConnectionFile.
	profile := JadeiteConnectionProfile connectionProfile.
	launcher basicExportProfile: fileRef.
	self assert: fileRef exists.
	launcher versionText text: String new.
	launcher stoneText text: String new.
	launcher netldiText text: String new.
	launcher userText text: String new.
	launcher passwordText text: String new.

	launcher basicImportProfileFromFileReference: fileRef.

	self assert: launcher versionText text equals: profile version.
	self assert: launcher stoneText text equals: profile stone.
	self assert: launcher netldiText text equals: profile netldi.
	self assert: launcher userText text equals: profile user.
	self assert: launcher passwordText text equals: profile password
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_buttonEnablement [

	JadeiteConnectionProfile connectionProfile disconnect.
	self assert: launcher connectButton isEnabled.
	self deny: launcher disconnectButton isEnabled.
	JadeiteConnectionProfile connectionProfile connect.
	self deny: launcher connectButton isEnabled.
	self assert: launcher disconnectButton isEnabled
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_cancelMenuPresent [

	| menu |
	#( #hostText #stoneText #userText #passwordText #versionText
	   #netldiText #portText ) do: [ :selector |
			menu := (launcher perform: selector) adapter widget textArea
				        getMenu: false.
			self denyIsNil: menu.
			self assert: menu items size equals: 1.
			self assert: menu items first contents equals: 'Cancel' ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_changeFieldsResetOnExport [

	| profile |
	self changeAllLauncherFields.
	profile := JadeiteGCIConnectionProfile new.
	launcher populate: profile.
	fileRef := 'test_changeFieldsResetOnExport.txt' asFileReference.
	launcher basicExportProfile: fileRef.
	self verifyAllLauncherFieldsAreUnchanged
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_changeFieldsResetOnImport [

	| profile |
	fileRef := self testConnectionFileReference.
	self deleteTestConnectionFile.
	profile := JadeiteConnectionProfile connectionProfile.
	launcher basicExportProfile: fileRef.

	self changeAllLauncherFields.
	launcher basicImportProfile: profile.
	self verifyAllLauncherFieldsAreUnchanged
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesMissing [

	self profile isConnected ifTrue: [ self profile disconnect ].
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	launcher pathText adapter widget setText: String new.

	[ launcher connect ]
		on: ProvideAnswerNotification
		do: [ :notification |
				self
					assert: 'Client Libraries Path must be set'
					equals: notification messageText ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesNotChangedByConnectionSelection [

	| nonSensicalPath |
	nonSensicalPath := 'nonSensiscal/path/does/not/change'.
	self profile isConnected ifTrue: [ self profile disconnect ].
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self
		assert: clientLibariesPath
		equals: launcher pathText adapter widget text asString.
	launcher pathText adapter widget setText: nonSensicalPath.

	launcher availableConnectionPresenter list do: [ :conn |
			launcher availableConnectionPresenter selectItem: conn.
			self
				assert: launcher pathText adapter widget text
				equals: nonSensicalPath ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesPathDoesNotExistUseParent [

	self profile isConnected ifTrue: [ self profile disconnect ].
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	launcher pathText text:
		JadeiteGCIConnectionProfile clientLibrariesPath , '/defghi'.
	self
		assert: launcher pathText adapter widget text
		equals: launcher pathText text.
	self
		assert: launcher validLibPathReference pathString
		equals: JadeiteGCIConnectionProfile clientLibrariesPath
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_closeDisconnects [

	JadeiteConnectionProfile connectionProfile connect.
	self assert: JadeiteConnectionProfile connectionProfile isConnected.
	[ launcher window close ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: true ].
	self assert: launcher window isClosed.
	self deny: JadeiteConnectionProfile connectionProfile isConnected
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_connectDoesNotClearChangeFields [

	self changeAllLauncherFields.
	JadeiteConnectionProfile connectionProfile connect.
	self verifyAllLauncherFieldsAreChanged
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_exportConnectionUsesSelectedItemName [

	| dialog |
	self
		testsJadeiteForPharoIssue: #issue385
		title:
		'The filename used to save a connection to disk is not preserved when you'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/385'.
	launcher availableConnectionPresenter selectIndex: 1. "presume it's not empty"
	fileRef := (FileSystem disk workingDirectoryPath
	            / launcher availableConnectionPresenter selectedItem)
		           asFileReference.
	dialog := self
		          waitForNewPresenter: SpDialogWindowMorph
		          while: [ launcher exportProfile ].
	[
		self
			assert: dialog model presenter nameText asString
			equals: fileRef basename ] ensure: [ dialog cancel ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_exportConnectionWontExportDotFiles [
	"connections beginning with a '.' should not be exported"

	fileRef := (FileSystem disk workingDirectoryPath
	            / '.testExportInValidFileName') asFileReference.
	[ launcher basicExportProfile: fileRef ]
		on: ProvideAnswerNotification
		do: [ :ex |
			self
				assert: ex messageText
				equals: 'Cannot export profile to file starting with ''.''' ].
	self deny: fileRef exists
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_fixedPort [
	| profile |
	profile := JadeiteConnectionProfile connectionProfile.
	profile disconnect.
	self deny: profile isConnected.
	profile port: '2000'. "1024 and above should always be valid"
	profile connect.
	self assert: profile isConnected.
	profile disconnect.
	
	profile port: '1023'.
	self should: [ profile connect ] raise: Error. 
	self deny: profile isConnected.
	
	profile port: String new. 
	profile connect.
	self assert: profile isConnected.
	profile disconnect.
	
	profile port: nil.
	profile connect.
	self assert: profile isConnected.
	profile disconnect.
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_gitVersionDisplay [

	| jfpSha gemstoneFFISha rsrSha clientServicesSha browserService desiredWorkspaceText |
	self
		testsIssue: #issue29
		withTitle:
		'Need a report to show what all git repository shas I have loaded'.

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'Rowan not available. Test not run' ].
	JadeiteConnectionProfile connectionProfile isConnected ifFalse: [
		JadeiteConnectionProfile connectionProfile connectWithPostConnect: [
			 ] ].
	workspace := launcher openCommitIdWindow. "will set workspace variable"

	jfpSha := (IceRepository registry detect: [ :ea |
		           ea name = 'JadeiteForPharo' ]) properties commitish
		          shortId.
	gemstoneFFISha := (IceRepository registry detect: [ :ea |
		                   ea name = 'PharoGemStoneFFI' ]) properties
		                  commitish shortId.
	rsrSha := (IceRepository registry detect: [ :ea |
		           ea name = 'RemoteServiceReplication' ]) properties
		          commitish shortId.
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session:
		(GciSession new library: launcher connectionProfile connection)
		onCompletion: [
				| workspaceString |
				clientServicesSha := self rcsSha.
				desiredWorkspaceText := 'Client:*
JadeiteForPharo ' , jfpSha asString , '
PharoGemStoneFFI ' , gemstoneFFISha asString , '
RemoteServiceReplication ' , rsrSha asString , '
---------------------------------------------
Server Required Projects:*
RemoteServiceReplication*
RowanClientServices ' , clientServicesSha asString , '
---------------------------------------------
All loaded projects:*'.
				"In the event of failure, cache the workspace contents otherwise workspace will be destroyed before analysis can be done"
				workspaceString := workspace text asString.
				self assert: (desiredWorkspaceText match: workspaceString).
				self destroy: workspace ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_gitVersionDisplayError [
	"rig up a failure getting shas and make sure we gracefully handle it"

	| contents originalSource senders senderSelectors |
	self
		testsJadeiteForPharoIssue: #issue389
		title:
		'Getting shas when disconnected fails if gci can''t establish a session'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/389'.

	senders := SystemNavigation default allSendersOf:
		           #commitIdServerInfoCode.
	senderSelectors := senders collect: [ :method | method selector ].
	self assert: (senderSelectors includes: #gciCommitIds).
	originalSource := JadeiteGCIConnectionProfile sourceCodeAt:
		                  #commitIdServerInfoCode.
	JadeiteGCIConnectionProfile compile: 'commitIdServerInfoCode

	^  self jfpSendBadMessage  "sent from gciCommitIds - #test_gitVersionDisplayError compiled this code"'.

	workspace := launcher openCommitIdWindow.
	contents := workspace text.
	[
		self assert: ('*<Error getting server information through gci>
Error Message: <Message not understood: JadeiteGCIConnectionProfile >> #jfpSendBadMessage>*'
				 match: contents).
		self destroy: workspace ] ensure: [
			self destroy: workspace.
			JadeiteGCIConnectionProfile compile: originalSource ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_gitVersionDisplayInvalidLogin [

	| contents |
	self
		testsJadeiteForPharoIssue: #issue389
		title:
		'Getting shas when disconnected fails if gci can''t establish a session'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/389'.

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'Rowan not available. Test not run' ].

	launcher stoneText adapter widget setText: 'nonExistantStone'.
	workspace := launcher openCommitIdWindow.
	contents := workspace text.
	[
		self assert:
			('*<Unable to login to gemstone. Cannot get server information>*'
				 match: contents).
		self assert:
			('*GemStone server information:*<not logged in>*' match: contents) ]
		ensure: [ self destroy: workspace ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_gitVersionDisplayNoClientLibs [

	| contents |
	self
		testsJadeiteForPharoIssue: #issue389
		title:
		'Getting shas when disconnected fails if gci can''t establish a session'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/389'.

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'Rowan not available. Test not run' ].

	launcher pathText adapter widget setText: 'notavaliddirectory'.
	workspace := launcher openCommitIdWindow.
	contents := workspace text.
	[
		self assert:
			('*<Unable to login to gemstone. Cannot get server information>
Error Message: <FileDoesNotExistException ''notavaliddirectory*'
				 match: contents).
		self assert:
			('*GemStone server information:*<not logged in>*' match: contents) ]
		ensure: [ self destroy: workspace ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_gitVersionDisplayValidLoginAfterInvalidLogin [

	| contents stone |
	self
		testsJadeiteForPharoIssue: #issue389
		title:
		'Getting shas when disconnected fails if gci can''t establish a session'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/389'.

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'Rowan not available. Test not run' ].
	launcher disconnect.
	stone := launcher stoneText adapter widget text asString copy.
	launcher stoneText adapter widget setText: 'nonExistantStone'.
	workspace := launcher openCommitIdWindow.
	contents := workspace text.
	[
		self assert:
			('*<Unable to login to gemstone. Cannot get server information>*'
				 match: contents).
		self assert:
			('*GemStone server information:*<not logged in>*' match: contents).
		self destroy: workspace.
		launcher stoneText adapter widget setText: stone.
		launcher connect.
		launcher disconnect.
		workspace := launcher openCommitIdWindow.
		contents := workspace text.
		self assert: ('*RowanClientServices*' match: contents).
		self assert: ('*All loaded projects:*' match: contents).
		self assert:
			('*GemStone server information:*nodeName*osName*processId*' match:
				 contents) ] ensure: [ self destroy: workspace ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_importConnectionSkipsDotFiles [
	"connections beginning with a '.' should not be imported"

	| dir filename ref itemPrintStrings |
	self
		testsJadeiteForPharoIssue: #issue307
		title:
		'It should be safe to ignore files with leading . in Connections directory'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/307'.
	self createMockConnectionProfileDirectory.
	dir := self connectionDirName asFileReference asAbsolute.
	filename := '.deleteme'.
	ref := dir / filename.
	ref createFile.
	self assert: ref exists.
	launcher basicImportProfileDirectory:
		self connectionDirName asFileReference asAbsolute.
	self verifyTestConnectionsImported.
	itemPrintStrings := launcher availableConnectionPresenter items.
	self deny: (itemPrintStrings includes: ref asAbsolute pathString)
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_importFromDirectory [

	self createMockConnectionProfileDirectory.
	launcher basicImportProfileDirectory:
		self connectionDirName asFileReference asAbsolute.
	self verifyTestConnectionsImported
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_importedConnectionsJustACollection [
	"was a ListModel before but that got us into trouble
	with connections presenter announcers hanging onto launchers forever.
	Now, we create and throw away ListModel's as they are created."

	launcher class importedConnections isKindOf: SortedCollection
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_loginFailsProjectServiceOutOfSync [
	"create a scenario where the inst vars of RowanProjectService in the client don't match the server.
	If this fails, make sure to restore RowanProjectService's structure otherwise all subsequent logins will fail"

	| sem |
	true ifTrue: [
		^ self skip:
			  'test still not working and restoring inst var correctly' ].
	sem := Semaphore new.
	RowanProjectService removeInstVarNamed: 'canBeWritten'.
	[
		[ JadeiteConnectionLauncher soleInstance presenter connect ] fork.
		self assertAlertDialogProvideAnswerTextMatches: '*RSR Error*' ]
		ensure: [
				RowanProjectService addInstVarNamed: 'canBeWritten'.
				sem signal ].
	sem wait
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_refreshFromImportDirectory [

	self createMockConnectionProfileDirectory.
	launcher basicImportProfileDirectory:
		self connectionDirName asFileReference asAbsolute.
	self verifyTestConnectionsImported.
	launcher basicRemoveAllConnections.
	launcher refreshFromLastImportDirectory.
	self verifyTestConnectionsImported
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_removeAllConnections [
	"connections backed up in setUp and restored in tearDown"

	self
		testsJadeiteForPharoIssue: #issue415
		title: 'Launcher does not remove connections correctly'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/415'.

	launcher basicRemoveAllConnections.
	self assert: launcher availableConnectionPresenter list isEmpty.
	self assert: JadeiteConnectionLauncher importedConnections isEmpty
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_removeConnection [
	"connections backed up in setUp and restored in tearDown"

	| removed |
	self
		testsJadeiteForPharoIssue: #issue415
		title: 'Launcher does not remove connections correctly'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/415'.

	removed := launcher availableConnectionPresenter selectIndex: 1.
	launcher basicRemoveSelectedConnection.
	self assertIsNil: (launcher availableConnectionPresenter list
			 detect: [ :conn | conn == removed ]
			 ifNone: [ ]).
	self assertIsNil: (JadeiteConnectionLauncher importedConnections
			 detect: [ :conn | conn == removed ]
			 ifNone: [ ])
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_soleInstance [

	| launchers launcherSingleton |
	JadeiteConnectionProfile connectionProfile isConnected ifTrue: [
		JadeiteConnectionProfile connectionProfile disconnect ].
	launchers := JadeiteConnectionLauncher allInstances select: [
		             :theLauncher |
		             theLauncher window notNil and: [
			             theLauncher window isOpen ] ].
	self assert: launchers size equals: 1.

	launcherSingleton := launchers first window.
	self
		assert: JadeiteConnectionLauncher soleInstance
		identicalTo: launcherSingleton.

	launcherSingleton window close.

	launchers := JadeiteConnectionLauncher allInstances select: [
		             :theLauncher |
		             theLauncher window notNil and: [
			             theLauncher window isOpen ] ].
	self assert: launchers isEmpty.
	self assertIsNil: JadeiteConnectionLauncher soleInstance
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_suggestedExportName [

	| testLauncher |
	testLauncher := JadeiteConnectionLauncher new open presenter.
	shouldReopenLauncher := false.
	[
	testLauncher stoneText text: 'myStone'.
	testLauncher userText text: 'SystemUser'.
	testLauncher versionText text: '3.7.5'.
	self
		assert: testLauncher suggestedExportName
		equals: 'myStone_3.7.5_SystemUser.txt' ] ensure: [
		testLauncher window close ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_switchConnectionsWhileConnected [

	| selectedConnection |
	launcher connectionProfile isConnected ifFalse: [
		RowanServiceUpdater current critical: [ launcher connect ] ].
	self deny: launcher connectButton isEnabled.
	self assert: launcher disconnectButton isEnabled.
	self denyIsNil: JadeiteConsole currentConsole.

	fileRef := self testConnectionFileReference.
	self deleteTestConnectionFile.
	launcher hostText text: 'aHost'.
	launcher versionText text: '123'.
	launcher stoneText text: 'myStone'.
	launcher userText text: 'aUser'.
	launcher passwordText text: 'password'.
	launcher netldiText text: 'testNetldi'.

	launcher basicExportProfile: fileRef.
	self assert: fileRef exists.
	launcher basicImportProfileFromFileReference: fileRef.
	selectedConnection := launcher availableConnectionPresenter
		                      selectedItem.
	self
		assert: selectedConnection asFileReference basename
		equals: self connectionFileName.

	"Disconnecting should still work even if the connection list has a different selection "
	[
		launcher disconnect.
		self assert: launcher connectButton isEnabled.
		self deny: launcher disconnectButton isEnabled.
		self assertIsNil: JadeiteConsole currentConsole ] ensure: [
			self deleteTestConnectionFile.
			launcher availableConnectionPresenter model remove:
				selectedConnection ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_textFieldsShowChangeIndication [

	self verifyTextChangeMakesColorChange:
		launcher hostText adapter widget.
	self verifyTextChangeMakesColorChange:
		launcher stoneText adapter widget.
	self verifyTextChangeMakesColorChange:
		launcher userText adapter widget.
	self verifyTextChangeMakesColorChange:
		launcher passwordText adapter widget.
	self verifyTextChangeMakesColorChange:
		launcher versionText adapter widget.
	self verifyTextChangeMakesColorChange:
		launcher netldiText adapter widget
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_titleChangesOnConnect [

	| sem connectResult |
	sem := Semaphore new.
	launcher connectionProfile announcer
		when: JadeiteConnectedAnnouncement
		send: #signal
		to: sem.
	launcher connectionProfile isConnected ifTrue: [ launcher disconnect ].
	self
		assert: launcher window title
		equals: 'Jadeite Connection Launcher'.
	launcher connect.
	connectResult := sem waitTimeoutSeconds: 1.
	connectResult ifTrue: [ ^ self fail: 'connection took too long' ].
	self
		assert: launcher window title
		equals: (launcher gciSession titleBarFor: launcher shellName).
	launcher disconnect.
	self
		assert: launcher window title
		equals: 'Jadeite Connection Launcher'
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> updateAndVerifyTextChanged: widget [

	self changeValueOf: widget text: 'some text'.
	self
		assert: widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> validateChangedTextWidgetColor: widget [

	WorldMorph doOneCycle.
	self
		assert: widget color
		equals: Smalltalk ui theme jadeiteChangedTextBackgroundColor
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> validateUnchangedTextWidgetColor: widget [

	WorldMorph doOneCycle.
	self
		assert: widget color
		equals: Smalltalk ui theme jadeiteBackgroundColor
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> verifyAllLauncherFieldsAreChanged [

	self validateChangedTextWidgetColor: launcher hostText adapter widget.
	self validateChangedTextWidgetColor:
		launcher stoneText adapter widget.
	self validateChangedTextWidgetColor: launcher userText adapter widget.
	self validateChangedTextWidgetColor:
		launcher passwordText adapter widget.
	self validateChangedTextWidgetColor:
		launcher versionText adapter widget.
	self validateChangedTextWidgetColor:
		launcher netldiText adapter widget
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> verifyAllLauncherFieldsAreUnchanged [

	self validateUnchangedTextWidgetColor:
		launcher hostText adapter widget.
	self validateUnchangedTextWidgetColor:
		launcher stoneText adapter widget.
	self validateUnchangedTextWidgetColor:
		launcher userText adapter widget.
	self validateUnchangedTextWidgetColor:
		launcher passwordText adapter widget.
	self validateUnchangedTextWidgetColor:
		launcher versionText adapter widget.
	self validateUnchangedTextWidgetColor:
		launcher netldiText adapter widget
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> verifyTestConnectionsImported [
	"unique profiles created by a test are not verified"

	1 to: self numberOfTestConnections do: [ :idx |
		| path itemPrintStrings |
		path := self connectionDirName asFileReference
		        / (self connectionFileName , idx printString).
		itemPrintStrings := launcher availableConnectionPresenter items.
		self assert: (itemPrintStrings includes: path asAbsolute pathString) ]
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> verifyTextChangeMakesColorChange: widget [
	"assume widget is not changed on entry"

	self validateUnchangedTextWidgetColor: widget.
	self updateAndVerifyTextChanged: widget.
	widget cancel.
	WorldMorph doOneCycle.
	self validateUnchangedTextWidgetColor: widget
]
