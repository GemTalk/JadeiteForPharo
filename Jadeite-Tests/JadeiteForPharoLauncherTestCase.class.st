Class {
	#name : 'JadeiteForPharoLauncherTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'launcher',
		'fileRef'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> setUp [

	super setUp.
	launcher := JadeiteConnectionLauncher allInstances detect: [
		            :aLauncher | aLauncher window isOpen ].

]

{ #category : 'tests' }
JadeiteForPharoLauncherTestCase >> tearDown [

	super tearDown.
	fileRef ifNotNil: [ fileRef exists ifTrue: [ fileRef delete ] ]
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
