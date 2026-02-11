Extension { #name : 'JadeiteForPharoConnectionLauncherTestCase' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_clientLibrariesPath [

	| changedPathRef originalPath |
	self profile isConnected ifTrue: [ self profile disconnect ].
	JadeiteConnectionLauncher soleInstance window close.
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
	"test that the launcher reads the client libraries path from the share var"

	| originalPath |
	self
		testsJadeiteForPharoIssue:
		'WOR: Really annoying that I can''t just type in the clientlibs path '
		title: 'https://github.com/GemTalk/JadeiteForPharo/issues/344'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/344'.
	self profile isConnected ifTrue: [ self profile disconnect ].
	JadeiteConnectionLauncher soleInstance window close.

	originalPath := 'testPath'.
	JadeiteGCIConnectionProfile clientLibrariesPath: originalPath.
	JadeiteConnectionApplication singleton start.
	launcher := JadeiteConnectionLauncher soleInstance presenter.
	self assert: launcher pathText text equals: originalPath.
	self destroy: launcher
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

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_nilShareVarExportConnection [

	self
		testsJadeiteForPharoIssue: #issue362
		title: 'exporting a connection with a nil share var gives walkback'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/362'.
	JadeiteGCIConnectionProfile clientLibrariesPath: nil. "will be restored in teardown."
	fileRef := (FileSystem disk workingDirectoryPath
	            / 'testExportFileName') asFileReference.
	fileRef exists ifTrue: [ fileRef delete ].
	[ launcher basicExportProfile: fileRef ] ensure: [
		self assert: fileRef exists ]
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_nilShareVarOpenClientLibButton [
	" make sure the dialog will open if our share var is nil "

	| dialog |
	self
		testsJadeiteForPharoIssue: #issue362
		title: 'exporting a connection with a nil share var gives walkback'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/362'.
	JadeiteGCIConnectionProfile clientLibrariesPath: nil. "will be restored in teardown."
	dialog := self
		          waitForNewPresenter: SpDialogWindowMorph
		          while: [
		          launcher setClientLibrariesPathButton performAction ].
	[ self assert: (dialog isKindOf: SpDialogWindowMorph) ] ensure: [
		dialog close ]
]
