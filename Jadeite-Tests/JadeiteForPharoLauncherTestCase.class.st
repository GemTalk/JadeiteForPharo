Class {
	#name : 'JadeiteForPharoLauncherTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'launcher',
		'fileRef',
		'backupConnections',
		'backupLastDirectory'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoLauncherTestCase >> createConnectionProfileDirectory [

	| dir |
	dir := self testConnectionDirName asFileReference asAbsolute.
	dir createDirectory.
	1 to: self numberOfTestConnections do: [ :idx |
		| profileCopy ref filename |
		filename := self testConnectionFileName , idx printString.
		profileCopy := JadeiteConnectionProfile connectionProfile copy.
		ref := (dir / filename) asAbsolute.
		launcher basicExportProfile: ref ]
]

{ #category : 'support' }
JadeiteForPharoLauncherTestCase >> numberOfTestConnections [

	^ 10
]

{ #category : 'support' }
JadeiteForPharoLauncherTestCase >> removeConnectionProfileDirectory [

	self testConnectionDirName asFileReference ensureDeleteAll
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> setUp [

	launcher := JadeiteConnectionLauncher allInstances
		            detect: [ :aLauncher | aLauncher window isOpen ]
		            ifNone: [ self ensureLauncherOpened ].
	backupConnections := launcher class importedConnections copy. "backup"
	backupLastDirectory := launcher class lastImportDirectory
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> tearDown [

	super tearDown.
	JadeiteConnectionProfile connectionProfile disconnect.
	fileRef ifNotNil: [ fileRef exists ifTrue: [ fileRef delete ] ].
	self removeConnectionProfileDirectory.
	self destroy: launcher.
	launcher class importedConnections: backupConnections.
	launcher class lastImportDirectory: backupLastDirectory.
	self ensureLauncherOpened
]

{ #category : 'support' }
JadeiteForPharoLauncherTestCase >> testConnectionDirName [

	^ 'testImportFromConnectionDir'
]

{ #category : 'support' }
JadeiteForPharoLauncherTestCase >> testConnectionFileName [

	^ 'testConnectionFile'
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_basicFileExport [

	| profile fileName fileProfile |
	fileName := 'jfp_testConnectionFile.txt'.
	fileRef := (FileSystem disk workingDirectoryPath / fileName)
		           asFileReference.
	fileRef exists ifTrue: [ fileRef delete ].
	profile := JadeiteConnectionProfile connectionProfile.
	launcher basicExportProfile: fileRef.
	self assert: fileRef exists.
	fileProfile := STON fromString: fileRef contents.
	"check some fields"
	self assert: fileProfile version equals: profile version. 
	self assert: fileProfile stone equals: profile stone. 
	self assert: fileProfile netldi equals: profile netldi. 
	self assert: fileProfile user equals: profile user. 
	self assert: fileProfile password equals: profile password. 
	self assert: fileProfile path equals: profile path. 

]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_basicFileImport [

	| profile fileName |
	JadeiteConnectionProfile connectionProfile disconnect.
	fileName := 'jfp_testConnectionFile.txt'.
	fileRef := (FileSystem disk workingDirectoryPath / fileName)
		           asFileReference.
	fileRef exists ifTrue: [ fileRef delete ].
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
	"check some fields"
	self assert: launcher versionText text equals: profile version.
	self assert: launcher stoneText text equals: profile stone.
	self assert: launcher netldiText text equals: profile netldi.
	self assert: launcher userText text equals: profile user.
	self assert: launcher passwordText text equals: profile password.
	self assert: launcher pathText text equals: profile path
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_buttonEnablement [

	JadeiteConnectionProfile connectionProfile disconnect.
	self assert: launcher connectButton isEnabled.
	self deny: launcher disconnectButton isEnabled.
	JadeiteConnectionProfile connectionProfile connect.
	self deny: launcher connectButton isEnabled.
	self assert: launcher disconnectButton isEnabled
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_closeDisconnects [

	JadeiteConnectionProfile connectionProfile connect.
	self assert: JadeiteConnectionProfile connectionProfile isConnected.
	[ launcher window close ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: true ].
	self assert: launcher window isClosed.
	self deny: JadeiteConnectionProfile connectionProfile isConnected
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_fixedPort [
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
JadeiteForPharoLauncherTestCase >> test_importFromDirectory [

	self createConnectionProfileDirectory.
	launcher basicImportProfileDirectory:
		self testConnectionDirName asFileReference asAbsolute.
	self verifyAllTestConnectionsImported
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> test_refreshFromImportDirectory [

	self createConnectionProfileDirectory.
	launcher basicImportProfileDirectory:
		self testConnectionDirName asFileReference asAbsolute.
	self verifyAllTestConnectionsImported.
	launcher basicRemoveAllConnections.
	launcher refreshFromLastImportDirectory.
	self verifyAllTestConnectionsImported
]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> verifyAllTestConnectionsImported [

	1 to: self numberOfTestConnections do: [ :idx |
		| path itemPrintStrings |
		path := self testConnectionDirName asFileReference
		        / (self testConnectionFileName , idx printString).
		itemPrintStrings := launcher availableConnectionPresenter items
			                    collect: [ :item | item printString ].
		self assert: (itemPrintStrings includes: path asAbsolute asString) ]
]
