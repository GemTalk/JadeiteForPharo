Class {
	#name : 'JadeiteForPharoFileDialogTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'fileDialog',
		'fileDialogPresenter'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteForPharoFileDialogTestCase class >> runAsDataCurator [
	"If the test class is expected to pass while
	logged in with DataCurator, override this 
	method to return true. The test runner will
	run each test as both SystemUser and DataCurator."

	^ true
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> fileAndDirectoryNames [

	^ fileDialogPresenter directoryContentsList list collect: [ :assoc |
		  assoc key ]
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> fileName [

	^ 'workspace.txt'
]

{ #category : 'accessing' }
JadeiteForPharoFileDialogTestCase >> fileOperationSemaphore [

	^ fileOperationSemaphore
]

{ #category : 'accessing' }
JadeiteForPharoFileDialogTestCase >> fileOperationSemaphore: anObject [

	fileOperationSemaphore := anObject
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> fullPath: path [

	| fileService | 
	fileService := RowanFileServiceClient new path: path. 
	fileService session: session. 
	fileService expandPath. 
	^fileService answer

	
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> setUp [

	super setUp.
	fileDialog := JadeiteServerFileSelectorDialog
		              _showOnSession: GciSession current
		              defaultPath:
		              JadePresenter rowanProjectsHomeEnvVarString
		              shellName: nil.
	self registerForFileOperationAnnouncements
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> tearDown [

	super tearDown.
	self destroy: fileDialog.
	GciSession current announcer unsubscribe: self
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_dive [
	"the test sets $ROWAN_PROJECTS_HOME as the initial directory"

	| item keys dirContentsList |
	fileDialogPresenter := fileDialog fileSelectorPresenter.
	dirContentsList := fileDialogPresenter directoryContentsList.
	item := dirContentsList list detect: [ :assoc |
		        assoc key = 'JadeiteForPharo' ].
	fileDialogPresenter directoryContentsList selectItem: item.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME'.
	keys := self fileAndDirectoryNames.
	self deny: (keys includes: 'Jadeite-Browser').
	fileDialogPresenter dive.
	self waitForFileOperationSemaphore.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME/JadeiteForPharo'.
	keys := self fileAndDirectoryNames.
	self assert: (keys includes: 'Jadeite-Browser').
	fileDialogPresenter pop.
	self waitForFileOperationSemaphore.
	keys := self fileAndDirectoryNames.
	self deny: (keys includes: 'Jadeite-Browser').
	item := dirContentsList list detect: [ :assoc |
		        assoc key = 'JadeiteForPharo' ].
	fileDialogPresenter directoryContentsList selectItem: item.
	fileDialogPresenter directoryContentsList doActivateAtIndex:
		fileDialogPresenter directoryContentsList selection selectedIndex.
	self waitForFileOperationSemaphore.
	keys := self fileAndDirectoryNames.
	self assert: (keys includes: 'Jadeite-Browser')
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_pathTextEntry [

	| item dirContentsList names |
	self
		testsJadeiteForPharoIssue: #issue326
		title:
		'Would be convenient to be able to paste a directory/file path into the File Browser ... it seems you have to manually navigate using GUI'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/326'.
	fileDialogPresenter := fileDialog fileSelectorPresenter.
	dirContentsList := fileDialogPresenter directoryContentsList.
	names := dirContentsList items collect: [ :ea | ea key ].
	self deny: (names includes: '1.0.0').
	self deny: (names includes: '3.7.4').
	item := dirContentsList list detect: [ :assoc |
		        assoc key = 'JadeiteForPharo' ].
	fileDialogPresenter directoryContentsList selectItem: item.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME'.
	fileDialogPresenter pathText text:
		'/export/gcm/where/gemstone64/releases'.
	(fileDialogPresenter pathText adapter widget kmDispatcher
		 directKeymaps keymaps detect: [ :ea |
		 ea shortcut platformCharacter name = #RETURN ]) action value. "this heinous piece of code simulates pressing enter in the pathText field. Wish Pharo made it easy to simulate key presses in tests"
	names := dirContentsList items collect: [ :ea | ea key ].
	self assert: (names includes: '1.0.0').
	self assert: (names includes: '3.7.4')
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_pop1 [

	| item keys directoryContentsList parentPath |
	fileDialogPresenter := fileDialog fileSelectorPresenter.
	directoryContentsList := fileDialogPresenter directoryContentsList.
	item := directoryContentsList list detect: [ :assoc |
		        assoc key = '..' ].
	directoryContentsList selectItem: item.
	parentPath := fileDialogPresenter fileService parentDirectoryPath.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME'. "no change"
	keys := directoryContentsList list collect: [ :assoc | assoc key ].
	self assert: (keys includes: 'JadeiteForPharo').

	directoryContentsList doActivateAtIndex:
		directoryContentsList selection selectedIndex. "pop by clicking .."
	self waitForFileOperationSemaphore.
	self assert: parentPath equals: fileDialogPresenter pathText text.
	keys := directoryContentsList list collect: [ :assoc | assoc key ].
	self deny: (keys includes: 'JadeiteForPharo')
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_pop2 [

	| keys directoryContentsList parentPath |
	fileDialogPresenter := fileDialog fileSelectorPresenter.
	directoryContentsList := fileDialogPresenter directoryContentsList.
	parentPath := fileDialogPresenter fileService parentDirectoryPath.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME'. "no change"
	keys := directoryContentsList list collect: [ :assoc | assoc key ].
	self assert: (keys includes: 'JadeiteForPharo').
	fileDialogPresenter pop.
	self waitForFileOperationSemaphore.
	self assert: parentPath equals: fileDialogPresenter pathText text.
	keys := directoryContentsList list collect: [ :assoc | assoc key ].
	self deny: (keys includes: 'JadeiteForPharo')
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_saveFileDialogDoesNotOverwriteOrClose [
	"not sure this is a great test as it's unclear if the dialog actually would have closed during the test"

	| filename ref path dirRef |
	self todo:
		'need better test that confirmation doesn''t close dialog if No is chosen'.
	fileDialog window close. "not using the dialog from setUp"
	filename := 'test_saveFileDialogReturnValue_deleteme'.
	path := FileSystem workingDirectory fullPath pathString.
	dirRef := path asFileReference.
	ref := dirRef / filename.
	ref exists ifTrue: [ ref delete ].
	[
		JadeiteServerFileSaveDialog
			showOnSession: session
			defaultPath: path
			defaultFileName: self fileName ] fork.
	fileDialog := self waitForSaveDialog.
	fileDialog window beTopWindow.
	self assert: fileDialog window isActive. "not sure why but #isActive requires the window to be the top window. Haven't found an isOpen or ilk that doesn't require the window be on top yet"
	fileDialogPresenter := fileDialog presenter fileSelectorPresenter.

	ref writeStreamDo: [ :stream | stream nextPutAll: 'some content' ].
	self assert: ref exists.
	[ fileDialogPresenter window triggerOkAction ]
		on: ProvideAnswerNotification
		do: [ :notification |
				notification resume: false.
				WorldMorph doOneCycle ].

	self assert: fileDialog window isActive.
	self assert: ref exists.
	self assert: ref contents equals: 'some content'.

	ref delete
]
