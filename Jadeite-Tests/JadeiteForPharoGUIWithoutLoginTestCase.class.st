"
Tests should not assume that a connection exists. 
(Although a good test would handle a connection if it is present)
"
Class {
	#name : 'JadeiteForPharoGUIWithoutLoginTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'fileRef',
		'launcher'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoGUIWithoutLoginTestCase >> getLauncher [
	self closeConnectionLaunchers. 
	launcher := JadeiteConnectionApplication new start
]

{ #category : 'support' }
JadeiteForPharoGUIWithoutLoginTestCase >> setUp [ 
	
	"don't call super setUp - we ignore all the assumptions other
	Jadeite tests make about connections being available."
]

{ #category : 'support' }
JadeiteForPharoGUIWithoutLoginTestCase >> tearDown [
	
	"don't call super tearDown - we ignore all the assumptions other
	Jadeite tests make about connections being available."
]

{ #category : 'tests' }
JadeiteForPharoGUIWithoutLoginTestCase >> test_exportConnection [

	|  profile isConnected exportedProfile |
	"https://github.com/GemTalk/JadeiteForPharo/issues/67"
	self
		testsJadeiteForPharoIssue: #issue67
		title: 'Need to be able to save connections'.
	profile := JadeiteConnectionProfile connectionProfile.
	profile isConnected ifTrue: [ profile disconnect ].
	isConnected := profile isConnected.
	self getLauncher.
	fileRef := FileSystem workingDirectory resolveString:
		           'test_exportConnection.txt'.
	fileRef exists ifTrue: [ fileRef delete ].
	self deny: fileRef exists.
	launcher basicExportProfile: fileRef.

	self assert: fileRef exists.
	self
		assert: profile
		identicalTo: JadeiteConnectionProfile connectionProfile.
	self assert: isConnected equals: profile isConnected.
	exportedProfile := STON fromString: fileRef contents.
	(JadeiteGCIConnectionProfile instVarNames copyWithout: #session) do: [ :instVarName |
		self
			assert: (exportedProfile instVarNamed: instVarName)
			equals:
			(JadeiteConnectionProfile connectionProfile instVarNamed:
				 instVarName) ]
]

{ #category : 'tests' }
JadeiteForPharoGUIWithoutLoginTestCase >> test_importConnection [

	| profile |
	"https://github.com/GemTalk/JadeiteForPharo/issues/67"
	self
		testsJadeiteForPharoIssue: #issue67
		title: 'Need to be able to save connections'.
	profile := JadeiteConnectionProfile connectionProfile.
	profile isConnected ifTrue: [ profile disconnect ].
	self getLauncher.
	fileRef := FileSystem workingDirectory resolveString:
		           'test_importConnection.txt'.
	fileRef exists ifTrue: [ fileRef delete ].
	self deny: fileRef exists.

	launcher basicExportProfile: fileRef.

	launcher hostText text: String new.
	launcher stoneText text: String new.
	launcher userText text: String new.
	launcher passwordText text: String new.
	launcher versionText text: String new.
	launcher netldiText text: String new.
	launcher pathText text: String new.
	launcher portText text: String new.

	launcher
		basicImportProfile: fileRef readStream
		path: fileRef pathString.
	profile := JadeiteConnectionProfile connectionProfile.

	self assert: launcher hostText text equals: profile host.
	self assert: launcher stoneText text equals: profile stone.
	self assert: launcher userText text equals: profile user.
	self assert: launcher passwordText text equals: profile password.
	self assert: launcher versionText text equals: profile version.
	self assert: launcher netldiText text equals: profile netldi.
	self assert: launcher pathText text equals: profile path.
	self assert: launcher portText text equals: profile port.
	launcher connect.
	self assert: launcher connectionProfile isConnected
]
