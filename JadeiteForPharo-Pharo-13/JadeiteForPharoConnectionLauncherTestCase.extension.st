Extension { #name : 'JadeiteForPharoConnectionLauncherTestCase' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesPath [

	| changedPathRef originalPath |
	self profile isConnected ifTrue: [ self profile disconnect ].
	JadeiteConnectionLauncher soleInstance window close.

	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	originalPath := 'testPath'.
	JadeiteGCIConnectionProfile clientLibrariesPath: originalPath.
	JadeiteConnectionApplication singleton start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: originalPath.
	changedPathRef := 'clientLibrariesChanged.txt' asFileReference.
	launcher application useBackend: #JadeiteTest.
	[ launcher setClientLibrariesPath ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: changedPathRef ].
	launcher window close.
	JadeiteConnectionApplication singleton start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: changedPathRef fullName
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesTextField [

	| originalPath command |
	self
		testsJadeiteForPharoIssue:
		'WOR: Really annoying that I can''t just type in the clientlibs path '
		title: 'https://github.com/GemTalk/JadeiteForPharo/issues/344'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/344'.
	self profile isConnected ifTrue: [ self profile disconnect ].
	JadeiteConnectionLauncher soleInstance window close.

	clientLibariesPath := JadeiteGCIConnectionProfile clientLibrariesPath.
	originalPath := 'testPath'.
	JadeiteGCIConnectionProfile clientLibrariesPath: originalPath.
	JadeiteConnectionApplication singleton start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: originalPath.

	launcher pathText text: 'new/Client/Lib/Path'.
	command := launcher pathText ensureInternalActions allCommands
		           detect: [ :ea | ea id = 'shortcutCtrl+S' ].
	command execute.
	self
		assert: JadeiteGCIConnectionProfile clientLibrariesPath
		equals: 'new/Client/Lib/Path'
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_exportConnectionProfile [

	fileRef := self testConnectionFileReference.
	self deny: fileRef exists.
	[
		[ launcher exportProfile ]
			on: ProvideAnswerNotification
			do: [ :ex | ex resume: fileRef ].
		self assert: fileRef exists ] ensure: [
			fileRef delete.
			self deny: fileRef exists ]
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_importConnectionProfile [
	"not much of a test but at least confirm that #importProfileFile
	is exercised by a test to catch basic failures"

	| answer |
	[ answer := launcher importProfileFile ]
		on: ProvideAnswerNotification
		do: [ :ex | ex resume: 'fakePath' ].
	self assert: answer equals: 'fakePath'
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_importConnectionProfileNoLastImportDirectory [

	| answer lastImportDirectory |
	lastImportDirectory := (JadeiteConnectionLauncher bindingOf:
		                        #LastImportDirectory) value.
	JadeiteConnectionLauncher lastImportDirectory: nil.
	[
		[ answer := launcher importProfileFile ]
			on: ProvideAnswerNotification
			do: [ :ex | ex resume: 'fakePath' ].
		self assert: answer equals: 'fakePath' ] ensure: [
		JadeiteConnectionLauncher lastImportDirectory: lastImportDirectory ]
]
