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

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> connectionDirName [

	^ 'testImportFromConnectionDir'
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> connectionFileName [

	^ 'testConnectionFile'
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> createConnectionProfileDirectory [

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

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> removeConnectionProfileDirectory [

	self connectionDirName asFileReference ensureDeleteAll
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> setUp [

	JadeiteTestManager replacing: self uiManager.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	backupConnections := launcher class importedConnections copy. "backup"
	backupLastDirectory := launcher class lastImportDirectory.
	shouldReopenLauncher := true.
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> tearDown [

	super tearDown.
	self uiManager previousManager ifNotNil: [ :manager |
		manager beDefault ].
	clientLibariesPath ifNotNil: [
		JadeiteGCIConnectionProfile clientLibrariesPath: clientLibariesPath.
		JadeiteConnectionLauncher soleInstance window close.
		JadeiteConnectionApplication new start ].
	JadeiteConnectionProfile connectionProfile disconnect.
	fileRef ifNotNil: [ fileRef exists ifTrue: [ fileRef delete ] ].
	self removeConnectionProfileDirectory.
	shouldReopenLauncher ifTrue: [ self destroy: launcher ].
	launcher ifNil: [ ^ self ].
	launcher class importedConnections: backupConnections.
	launcher class lastImportDirectory: backupLastDirectory.
	self ensureLauncherOpened
]

{ #category : 'support' }
JadeiteForPharoConnectionLauncherTestCase >> testConnectionFileReference [

	| fileName |
	fileName := self connectionFileName.
	^ (FileSystem disk workingDirectoryPath / fileName) asFileReference
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
	launcher pathText text: String new.
	
	launcher basicImportProfile: fileRef.
	
	self assert: launcher versionText text equals: profile version.
	self assert: launcher stoneText text equals: profile stone.
	self assert: launcher netldiText text equals: profile netldi.
	self assert: launcher userText text equals: profile user.
	self assert: launcher passwordText text equals: profile password.
	self assert: launcher pathText text equals: profile path
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
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesMissing [

	self profile isConnected ifTrue: [ self profile disconnect ].
	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	JadeiteGCIConnectionProfile clientLibrariesPath: String new.

	[ launcher connect ]
		on: ProvideAnswerNotification
		do: [ :notification |
			self assert:
				('Client library could not be found. Error message:*' match:
					 notification messageText) ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesPath [

	| changedPathRef originalPath |
	self profile isConnected ifTrue: [ self profile disconnect ].
	JadeiteConnectionLauncher soleInstance window close.

	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	originalPath := 'testPath'.
	JadeiteGCIConnectionProfile clientLibrariesPath: originalPath.
	JadeiteConnectionApplication new start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: originalPath.
	changedPathRef := 'clientLibrariesChanged.txt' asFileReference.
	[ launcher setPath ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: changedPathRef ].
	launcher window close.
	JadeiteConnectionApplication new start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: changedPathRef fullName
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

	JadeiteConnectionProfile connectionProfile isConnected ifFalse: [
		JadeiteConnectionProfile connectionProfile connect ].
	workspace := launcher openCommitIdWindow.
	[
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
	browserService command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session:
		(GciSession new library: launcher connectionProfile connection)
		onCompletion: [
			| workspaceString |
			clientServicesSha := (browserService projects detect: [
				                      :projectService |
				                      projectService name = 'RowanClientServices' ])
				                     sha.
			desiredWorkspaceText := 'Client:*
JadeiteForPharo ' , jfpSha asString , '
PharoGemStoneFFI ' , gemstoneFFISha asString , '
RemoteServiceReplication ' , rsrSha asString , '
---------------------------------------------
Server Required Projects:*
RemoteServiceReplication ' , rsrSha asString , '
RowanClientServices ' , clientServicesSha asString , '
---------------------------------------------
All loaded projects:*'.
			"In the event of failure, cache the workspace contents otherwise workspace will be destroyed before analysis can be done"
			workspaceString := workspace text asString.
			self assert: (desiredWorkspaceText match: workspaceString) ] ]
		ensure: [ self destroy: workspace ]
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_importFromDirectory [

	self createConnectionProfileDirectory.
	launcher basicImportProfileDirectory:
		self connectionDirName asFileReference asAbsolute.
	self verifyAllTestConnectionsImported
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_refreshFromImportDirectory [

	self createConnectionProfileDirectory.
	launcher basicImportProfileDirectory:
		self connectionDirName asFileReference asAbsolute.
	self verifyAllTestConnectionsImported.
	launcher basicRemoveAllConnections.
	launcher refreshFromLastImportDirectory.
	self verifyAllTestConnectionsImported
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
	self assertIsNil: JadeiteConnectionLauncher soleInstance.

	self ensureLauncherOpened "for the next test"
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_suggestedExportName [

	| testLauncher |
	testLauncher := JadeiteConnectionLauncher new.
	testLauncher stoneText text: nil.
	testLauncher userText text: nil.
	testLauncher versionText text: nil.
	self assertIsNil: testLauncher stoneText text.
	self assertIsNil: testLauncher userText text.
	self assertIsNil: testLauncher versionText text.
	self
		assert: testLauncher suggestedExportName
		equals: 'jadeiteConnection.txt'.
	testLauncher stoneText text: 'myStone'.
	testLauncher userText text: 'SystemUser'.
	testLauncher versionText text: '3.7.5'.
	self
		assert: testLauncher suggestedExportName
		equals: 'myStone_3.7.5_SystemUser.txt'.
	shouldReopenLauncher := false
]

{ #category : 'tests' }
JadeiteForPharoConnectionLauncherTestCase >> test_switchConnectionsWhileConnected [

	| selectedConnection |
	launcher connectionProfile isConnected ifFalse: [
		launcher connect "assume launcher has correct connection" ].
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
	launcher basicImportProfile: fileRef.
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
JadeiteForPharoConnectionLauncherTestCase >> verifyAllTestConnectionsImported [

	1 to: self numberOfTestConnections do: [ :idx |
		| path itemPrintStrings |
		path := self connectionDirName asFileReference
		        / (self connectionFileName , idx printString).
		itemPrintStrings := launcher availableConnectionPresenter items.
		itemPrintStrings includes: path asAbsolute pathString.
		self assert: (itemPrintStrings includes: path asAbsolute pathString) ]
]
