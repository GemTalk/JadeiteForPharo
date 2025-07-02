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
	self createInaccessibleFileAndDirectory
]

{ #category : 'support' }
JadeiteForPharoFileTestCase >> tearDown [

	self uiManager restore.
	self deleteInaccessibleFileAndDirectory
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
		('Error accessing*notAccessibleDirectory/notAccessibleFile*' match:
			 alert textMorph text).
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
