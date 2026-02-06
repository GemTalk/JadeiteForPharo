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
	launcher pathText text:
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
	launcher pathText text: String new.
	
	launcher basicImportProfileFromFileReference: fileRef.
	
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
		          waitForNew: SpDialogWindowMorph
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
		JadeiteConnectionProfile connectionProfile connect ].
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

	launcher connectionProfile isConnected ifTrue: [ launcher disconnect ].
	self
		assert: launcher window title
		equals: 'Jadeite Connection Launcher'.
	launcher connect.
	self
		assert: launcher window title
		equals: (launcher gciSession titleBarFor: launcher shellName).
	launcher disconnect. 
	self
		assert: launcher window title
		equals: 'Jadeite Connection Launcher'.
	
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
