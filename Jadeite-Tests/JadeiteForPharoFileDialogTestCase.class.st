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

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> fileName [

	^ 'workspace.txt'
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
		              shellName: nil
]

{ #category : 'support' }
JadeiteForPharoFileDialogTestCase >> tearDown [

	super tearDown.
	self destroy: fileDialog
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_dive [
	"the default directory is $ROWAN_PROJECTS_HOME
	so we know that JadeiteForPharo directory will be there."

	| item keys list |
	fileDialogPresenter := fileDialog fileSelectorPresenter.
	list := fileDialogPresenter directoryContentsList.
	item := list list detect: [ :assoc | assoc key = 'JadeiteForPharo' ].
	fileDialogPresenter directoryContentsList selectItem: item.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME'.
	keys := fileDialogPresenter directoryContentsList list collect: [
		        :assoc | assoc key ].
	self deny: (keys includes: 'Jadeite-Browser').
	fileDialogPresenter dive.
	self
		assert: fileDialogPresenter pathText text
		equals: '$ROWAN_PROJECTS_HOME/JadeiteForPharo'.
	keys := fileDialogPresenter directoryContentsList list collect: [
		        :assoc | assoc key ].
	self assert: (keys includes: 'Jadeite-Browser').
	fileDialogPresenter pop.
	fileDialogPresenter directoryContentsList selectItem: item.
	fileDialogPresenter directoryContentsList doActivateAtIndex:
		fileDialogPresenter directoryContentsList selection selectedIndex.
	keys := fileDialogPresenter directoryContentsList list collect: [
		        :assoc | assoc key ].
	self deny: (keys includes: 'Jadeite-Browser')
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
	self assert: parentPath equals: fileDialogPresenter pathText text.
	keys := directoryContentsList list collect: [ :assoc | assoc key ].
	self deny: (keys includes: 'JadeiteForPharo')
]

{ #category : 'tests' }
JadeiteForPharoFileDialogTestCase >> test_saveFileDialogReturnValue [
	"selectedFileOrDirectory is what is returned from the save file dialog"

	| item list |
	self destroy: fileDialog.
	fileDialog := JadeiteServerFileSaveTestDialog
		              showOnSession: session
		              defaultPath: '$ROWAN_PROJECTS_HOME'
		              defaultFileName: self fileName.

	fileDialogPresenter := fileDialog fileSelectorPresenter.
	self
		assert: fileDialogPresenter pathText text
		equals: (self fullPath: '$ROWAN_PROJECTS_HOME').
	self assert: fileDialog fileNamePresenter text equals: self fileName.
	"no directory selected"
	self
		assert: fileDialog selectedFileOrDirectory
		equals: ((self fullPath: '$ROWAN_PROJECTS_HOME') asFileReference
			 / self fileName) pathString.

	"select a directory, file will be saved to that directory"
	list := fileDialogPresenter directoryContentsList.
	item := list list detect: [ :assoc | assoc key = 'JadeiteForPharo' ].
	fileDialogPresenter directoryContentsList selectItem: item.
	self
		assert: fileDialog selectedFileOrDirectory
		equals: ((self fullPath: '$ROWAN_PROJECTS_HOME') asFileReference
			 / 'JadeiteForPharo' / self fileName) pathString.

	"change file name"
	fileDialog fileNamePresenter text: 'newName.txt'.
	self
		assert: fileDialog selectedFileOrDirectory
		equals: ((self fullPath: '$ROWAN_PROJECTS_HOME') asFileReference
			 / 'JadeiteForPharo' / 'newName.txt') pathString
]
