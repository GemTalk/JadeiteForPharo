Class {
	#name : 'JadeiteForPharoFileTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoFileTestCase >> console [
	"transcript is from the JfD days"

	^ transcript
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> createInaccessibleFileAndDirectory [

	| dirRef fileRef permissions |
	dirRef := (FileSystem workingDirectory
	           / self inaccessibleDirectoryName) asFileReference.
	dirRef createDirectory.
	fileRef := self inaccessibleFileReference.
	fileRef createFile.
	permissions := FileSystemPermission posixPermissions: 8r444.
	fileRef permissions: permissions.
	dirRef permissions: permissions
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> createTempFiles [

	| dirRef |
	dirRef := (FileSystem workingDirectory / self tempDirName)
		          asFileReference.
	dirRef createDirectory.
	(dirRef / self tempFileName1) createFile.
	(dirRef / self tempFileName2) createFile.
	(dirRef / self tempFileName3) createFile
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> deleteInaccessibleFileAndDirectory [

	| dirRef fileRef permissions |
	permissions := FileSystemPermission posixPermissions: 8r777.
	dirRef := (FileSystem workingDirectory
	           / self inaccessibleDirectoryName) asFileReference.
	dirRef exists ifFalse: [ ^ self ].
	dirRef permissions: permissions.

	fileRef := self inaccessibleFileReference.
	fileRef exists ifFalse: [ ^ dirRef delete ].
	fileRef permissions: permissions.
	fileRef delete.
	dirRef delete
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> deleteTempFiles [

	| dirRef fileRef |
	dirRef := (FileSystem workingDirectory / self tempDirName)
		          asFileReference.
	dirRef exists ifFalse: [ ^ self ].
	fileRef := dirRef / self tempFileName1.
	fileRef exists ifTrue: [ fileRef delete ].
	fileRef := dirRef / self tempFileName2.
	fileRef exists ifTrue: [ fileRef delete ].
	fileRef := dirRef / self tempFileName3.
	fileRef exists ifTrue: [ fileRef delete ].
	dirRef delete
]

{ #category : 'constants' }
JadeiteForPharoFileTestCase >> inaccessibleDirectoryName [

	^ 'notAccessibleDirectory'
]

{ #category : 'constants' }
JadeiteForPharoFileTestCase >> inaccessibleFileName [

	^ 'notAccessibleFile'
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> inaccessibleFileReference [

	^ (self inaccessibleDirectoryName , '/' , self inaccessibleFileName)
		  asFileReference
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> setUp [

	super setUp.
	JadeiteTestManager replacing: self uiManager.
	self deleteInaccessibleFileAndDirectory.
	self createInaccessibleFileAndDirectory.
	self registerForFileOperationAnnouncements
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> tearDown [

	self uiManager restore.
	self deleteInaccessibleFileAndDirectory.
	self deleteTempFiles.
	GciSession current announcer unsubscribe: self
]

{ #category : 'constants' }
JadeiteForPharoFileTestCase >> tempDirName [

	^ 'jadeiteTestTempDir'
]

{ #category : 'constants' }
JadeiteForPharoFileTestCase >> tempFileName1 [

	^'jadeiteTestTemp1'
]

{ #category : 'constants' }
JadeiteForPharoFileTestCase >> tempFileName2 [

	^'jadeiteTestTemp2'
]

{ #category : 'constants' }
JadeiteForPharoFileTestCase >> tempFileName3 [

	^ 'jadeiteTestTemp3'
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_cannotOpenInaccessibleServerFile [

	| fileDialog fileSelector inaccessibleDir backupPath sem inaccessibleFile alert |
	backupPath := JadePresenter lastFilePath.
	JadePresenter lastFilePath: FileSystem workingDirectory pathString.
	fileDialog := self
		              waitForNew: JadeiteServerFileSelectorDialog
		              while: [ self console openServerFile ].
	[
		fileSelector := fileDialog fileSelectorPresenter.
		sem := Semaphore new.
		[
			[ fileSelector directoryContentsList list isEmpty ] whileTrue: [
				(Delay forMilliseconds: 5) wait ].
			sem signal ] fork.
		sem waitTimeoutSeconds: 1.
		self assert:
			((fileSelector directoryContentsList list collect: [ :assoc |
				  assoc key ]) includes: self inaccessibleDirectoryName).
		inaccessibleDir := fileSelector directoryContentsList list detect: [
			                   :assoc |
			                   assoc key = self inaccessibleDirectoryName ].
		fileSelector directoryContentsList selectItem: inaccessibleDir.
		fileSelector dive.
		self waitForFileOperationSemaphore.
		self assert:
			((fileSelector directoryContentsList list collect: [ :assoc |
				  assoc key ]) includes: self inaccessibleFileName).

		inaccessibleFile := fileSelector directoryContentsList list detect: [
			                    :assoc | assoc key = self inaccessibleFileName ].
		fileSelector directoryContentsList selectItem: inaccessibleFile.
		alert := self waitForNew: AlertDialogWindow while: [
				         fileDialog window
					         beOk;
					         triggerOkAction ].
		self assert:
			('Error accessing*notAccessibleDirectory/notAccessibleFile*'
				 match: alert textMorph text).
		alert ok ] ensure: [
			JadePresenter lastFilePath: backupPath.
			fileDialog window isOpen ifTrue: [
					fileDialog window
						beCancel;
						triggerCancelAction ] ]
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_createInaccessibleFile [
	"test our support files on disk"

	| fileRef dirRef |
	dirRef := self inaccessibleDirectoryName asFileReference.
	self assert: dirRef exists.
	self assert: dirRef permissions posixPermission equals: 8r444.
	dirRef permissions: (FileSystemPermission posixPermissions: 8r777). "so we can see the file"
	fileRef := self inaccessibleFileReference.
	self assert: fileRef exists.
	self assert: fileRef permissions posixPermission equals: 8r444
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_fileInError [
	"file in errors should not result in a hung image"

	| fileContents fileName fileRef alertDialog |
	self
		testsJadeiteForPharoIssue: #issue295
		title:
		'Hard hang on filein with method class set to unknown class name'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/295'.

	projectsBrowser := JadeiteConsole currentConsole openBrowser.
	RowanServiceUpdater current singleThreaded: true.
	fileContents := 'method BananaSkidoo
testingFileinIssuePleaseIgnore
^6
%' replaceCrWithLf.

	fileName := FileSystem workingDirectory fullName
	            , 'test_fileInError.txt'.
	fileRef := fileName asFileReference.
	fileRef writeStream
		nextPutAll: fileContents;
		flush.
	[
	self assert: fileRef exists.
	alertDialog := self
		               waitForNew: AlertDialogWindow
		               while: [
		               projectsBrowser basicFileInServerFile: fileName ].
	self assert:
		('Error during file in. File in cancelled. Error Text: invalid class name ''BananaSkidoo'', 
at line 1 file*' match:
			 alertDialog textMorph text asString replaceLfWithCr).
	alertDialog close ] ensure: [
		fileRef delete.
		RowanServiceUpdater current singleThreaded: false ]
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_fileSaveInitialPath [
	"should use the saved path if possible"

	| fileDialog backupPath |
	backupPath := JadePresenter lastFilePath.
	JadePresenter lastFilePath: FileSystem workingDirectory pathString.
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - Test Initial Save Path'.
	[
	fileDialog := self
		              waitForNew: JadeiteServerFileSaveDialog
		              while: [ workspace saveServerFileAs ].
	self
		assert: fileDialog fileSelectorPresenter pathText text
		equals: FileSystem workingDirectory pathString.

	fileDialog window isOpen ifTrue: [
		fileDialog window
			beCancel;
			triggerCancelAction ].

	JadePresenter lastFilePath: FileLocator home pathString.
	fileDialog := self
		              waitForNew: JadeiteServerFileSaveDialog
		              while: [ workspace saveServerFileAs ].
	self
		assert: fileDialog fileSelectorPresenter pathText text
		equals: FileLocator home pathString ] ensure: [
		JadePresenter lastFilePath: backupPath.
		workspace window close.

		fileDialog window isOpen ifTrue: [
			fileDialog window beCancel triggerCancelAction ] ]
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_fileSelectInitialPath [
	"should use the saved path if possible"

	| fileDialog backupPath |
	backupPath := JadePresenter lastFilePath.
	JadePresenter lastFilePath: FileSystem workingDirectory pathString.
	[
	fileDialog := self
		              waitForNew: JadeiteServerFileSelectorDialog
		              while: [ self console openServerFile ].
	self
		assert: fileDialog fileSelectorPresenter pathText text
		equals: FileSystem workingDirectory pathString.
	fileDialog window isOpen ifTrue: [
		fileDialog window
			beCancel;
			triggerCancelAction ].

	JadePresenter lastFilePath: FileLocator home pathString.
	fileDialog := self
		              waitForNew: JadeiteServerFileSelectorDialog
		              while: [ self console openServerFile ].
	self
		assert: fileDialog fileSelectorPresenter pathText text
		equals: FileLocator home pathString ] ensure: [
		JadePresenter lastFilePath: backupPath.

		fileDialog window isOpen ifTrue: [
			fileDialog window
				beCancel;
				triggerCancelAction ] ]
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_lastFilePathOnSave [

	| tempDir fileDialog backupPath tempFile dirRef sem |
	self createTempFiles.
	backupPath := JadePresenter lastFilePath.
	[
	| newFileRef |
	JadePresenter lastFilePath: FileSystem workingDirectory pathString.
	self
		assert: JadePresenter lastFilePath
		equals: FileSystem workingDirectory pathString.
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - test_lastFilePathOnSave'.
	fileDialog := self
		              waitForNew: JadeiteServerFileSaveDialog
		              while: [ workspace saveServerFile ].
	tempDir := fileDialog fileSelectorPresenter directoryContentsList
		           list detect: [ :assoc | assoc key = self tempDirName ].
	fileDialog fileSelectorPresenter directoryContentsList selectItem:
		tempDir.
	fileDialog fileSelectorPresenter dive.
	self waitForFileOperationSemaphore.
	dirRef := fileDialog pathText text asFileReference.
	tempFile := fileDialog fileSelectorPresenter directoryContentsList
		            list detect: [ :assoc | assoc key = self tempFileName1 ].
	fileDialog fileSelectorPresenter directoryContentsList selectItem:
		tempFile.
	fileDialog fileNamePresenter text: 'workspace.txt'.
	fileDialog window
		beOk;
		triggerOkAction.
	sem := Semaphore new.
	newFileRef := dirRef / 'workspace.txt'.
	[
	[ newFileRef exists ] whileFalse: [ (Delay forMilliseconds: 5) wait ].
	sem signal ] fork.
	sem waitTimeoutSeconds: 1.
	self assert: newFileRef exists. 
	newFileRef delete.
	self deny: newFileRef exists.
	self assert: JadePresenter lastFilePath equals: dirRef pathString ]
		ensure: [
			JadePresenter lastFilePath: backupPath.
			workspace window close ]
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_lastFilePathOnSelect [

	| tempDir fileDialog backupPath tempFile dirRef sem |
	self createTempFiles.
	backupPath := JadePresenter lastFilePath.
	[
	JadePresenter lastFilePath: FileSystem workingDirectory pathString.
	self
		assert: JadePresenter lastFilePath
		equals: FileSystem workingDirectory pathString.
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - lastFilePathOnSelect'.
	fileDialog := self
		              waitForNew: JadeiteServerFileSelectorDialog
		              while: [ workspace openServerFile ].
	tempDir := fileDialog fileSelectorPresenter directoryContentsList
		           list detect: [ :assoc | assoc key = self tempDirName ].
	fileDialog fileSelectorPresenter directoryContentsList selectItem:
		tempDir.
	fileDialog fileSelectorPresenter dive.
	self waitForFileOperationSemaphore.
	dirRef := fileDialog pathText text asFileReference.
	tempFile := fileDialog fileSelectorPresenter directoryContentsList
		            list detect: [ :assoc | assoc key = self tempFileName1 ].
	fileDialog fileSelectorPresenter directoryContentsList selectItem:
		tempFile.
	fileDialog window
		beOk;
		triggerOkAction.
	sem := Semaphore new.
	[
	[
	JadePresenter lastFilePath = FileSystem workingDirectory pathString ]
		whileTrue: [ (Delay forMilliseconds: 10) wait ].
	sem signal ] fork.
	sem waitTimeoutSeconds: 1.
	self assert: JadePresenter lastFilePath equals: dirRef pathString ]
		ensure: [
			JadePresenter lastFilePath: backupPath.
			workspace window close ]
]

{ #category : 'tests' }
JadeiteForPharoFileTestCase >> test_tempFiles [
	"test our temporary support files on disk"

	| fileRef dirRef |
	self createTempFiles.
	dirRef := self tempDirName asFileReference.
	self assert: dirRef exists.
	fileRef := dirRef / self tempFileName1.
	self assert: fileRef exists.
	fileRef := dirRef / self tempFileName2.
	self assert: fileRef exists.
	fileRef := dirRef / self tempFileName3.
	self assert: fileRef exists.
	self deleteTempFiles. 
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> toolUsedForCommonTests [

	^ nil
]
