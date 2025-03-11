Class {
	#name : 'JadeiteForPharoWorkspaceTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoWorkspaceTestCase >> fileContents: thePath [

	| service |
	service := RowanFileServiceClient new
		           command: #fileContents;
		           path: thePath.
	RowanServiceUpdater current issueCommand: service session: session.
	^service answer
]

{ #category : 'support' }
JadeiteForPharoWorkspaceTestCase >> removeTestFile: thePath [

	| service |
	service := RowanFileServiceClient new
		           command: #remove;
		           commandArgs: Array new;
		           path: thePath.
	RowanServiceUpdater current issueCommand: service session: session
]

{ #category : 'support' }
JadeiteForPharoWorkspaceTestCase >> saveTestFileTo: thePath [

	| service |
	service := RowanFileServiceClient new
		           command: #write:;
		           commandArgs:
			           (Array with:
					            'testFile'
						            replaceCrWithLf);
		           path: thePath. 
	RowanServiceUpdater current issueCommand: service session: session. 
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_ctrlSKeybindings [

	| keymap fileRef filePath |
	self
		testsJadeiteForPharoIssue: #issue240
		title: 'CTL-S does not do a save in a JfP workspace window'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/240'.
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - Test Display'.
	keymap := workspace contextKeyBindings keymaps detect: [ :ea |
		          (ea shortcut class canUnderstand: #character) and: [
			          ea shortcut character name = #S ] ].
	self
		assert: keymap action printString
		equals: '[ workspace saveServerFile ]'.
	fileRef := FileSystem workingDirectory
	           / 'test_ctrlSKeybindings_deleteme.txt'.
	self deny: fileRef exists.
	filePath := fileRef pathString.
	[ keymap action value ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: filePath ].
	[ self assert: fileRef exists ] ensure: [
		self removeTestFile: filePath ]
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_reset [

	| filePath fileContents |
	filePath := '$HOME/test_reset.txt'.

	self saveTestFileTo: filePath.
	[
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - test_reset'.
	[ workspace openServerFile ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: filePath ].
	self assert: workspace codePane text equals: 'testFile'.
	fileContents := self fileContents: filePath.
	self assert: fileContents equals: 'testFile'.
	workspace codePane text: 'some new content'.
	self assert: workspace codePane text equals: 'some new content'.
	workspace resetFileText.
	self assert: workspace codePane text equals: 'testFile' ] ensure: [
		self removeTestFile: filePath ]
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_serverFileDialogSave [

	| filePath fileContents |
	filePath := '$HOME/test_serverFileDialogSaveTestFile.txt'.

	self saveTestFileTo: filePath.
	[
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - test_serverFileDialogSave'.
	[ workspace openServerFile ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: filePath ].
	self assert: workspace codePane text equals: 'testFile'.
	fileContents := self fileContents: filePath.
	self assert: fileContents equals: 'testFile'.
	workspace codePane text: 'some new content'.
	self assert: workspace codePane text equals: 'some new content'.
	workspace saveServerFile. "should not open a dialog"
	self assert: workspace codePane text equals: 'some new content'.
	fileContents := self fileContents: filePath.
	self assert: fileContents equals: 'some new content' ] ensure: [
		self removeTestFile: filePath ]
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_serverFileDialogSaveAs [

	| filePath fileContents newPath |
	filePath := '$HOME/test_serverFileDialogSaveAsTestFile.txt'.

	self saveTestFileTo: filePath.
	[
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - test_serverFileDialogSave'.
	[ workspace openServerFile ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: filePath ].
	self assert: workspace codePane text equals: 'testFile'.
	fileContents := self fileContents: filePath.
	self assert: fileContents equals: 'testFile'.
	workspace codePane text: 'some new content'.
	self assert: workspace codePane text equals: 'some new content'.
	newPath := '$HOME/test_serverFileDialogSaveTestFile_newPath.txt'.
	[ workspace saveServerFileAs ]
		on: ProvideAnswerNotification
		do: [ :notification | notification resume: newPath ].
	self assert: workspace codePane text equals: 'some new content'.
	fileContents := self fileContents: newPath.
	self assert: fileContents equals: 'some new content' ] ensure: [
		self removeTestFile: filePath.
		self removeTestFile: newPath ]
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_workspaceAdHocDisplayUnicodeCharacters [
	self testsIssue: #issue678
		withTitle: 'Print-it for out of range characters is... peculiar (3.0.92.3)'.
	workspace := (JadeiteWorkspace showOnSession: session)
				caption: 'Jade Workspace - Test Unicode Characters'.
	workspace codePane documentPresenter
		value: '''aa'', (String with: (Character withValue: 353)), ''bb''  '.
	workspace codePane selectAll.
	self displayAndPrint.
	self assert: workspace codePane documentPresenter selection equals: ' "''aašbb''"'.
	self assert: workspace codePane text
		equals: '''aa'', (String with: (Character withValue: 353)), ''bb''   "''aašbb''"'
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_workspaceDeselectionOnContextMenuOpen [
	"simulate the problem without actually opening the menu.
	Opening the menu is (at the moment) not possible in a test because the menu isn't returned
	and even if I changed the code to return the menu, the gui won't return until the menu is closed.
	By then the menu is gone and nil is returned "

	| code |
	self
		testsJadeiteForPharoIssue: #issue201
		title: 'Running selected code in Workspace fails for the first time'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/201'.
	self
		testsJadeiteForPharoIssue: #issue219
		title: 'Funky behavior of workspace select on right mouse click'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/219'.
	code := '| abc | 
	abc := Array new.
	abc size'.
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - Test Selection Disappearing'.

	workspace instVarNamed: #text put: '123'.
	workspace adapter widget setText: code.
	self
		deny: workspace basicText
		equals: workspace adapter widget getText asString. "ensure condition before send #text so problem code is executed"
	workspace selectAll.
	self assert: workspace selectedText equals: code.
	workspace text. "caused the deselection problem"
	self assert: workspace selectedText equals: code
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_workspaceDisplay [

	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - Test Display'.
	workspace codePane documentPresenter value: '''aa'''.
	workspace codePane selectAll.
	self displayAndPrint.
	self
		assert: workspace codePane documentPresenter selection
		equals: ' "''aa''"'.
	self assert: workspace codePane text equals: '''aa''' , ' "''aa''"'
]

{ #category : 'tests' }
JadeiteForPharoWorkspaceTestCase >> test_workspaceDoIt [

	session executeString: 'UserGlobals at: #test_workspaceDoIt put: nil'.
	self assertIsNil: (session executeString:
			 'UserGlobals at: #test_workspaceDoIt ifAbsent: []').
	workspace := (JadeiteWorkspace showOnSession: session) caption:
		             'Jade Workspace - Test DoIt'.
	workspace codePane text:
		'UserGlobals at: #test_workspaceDoIt put: 123'.
	workspace codePane selectAll.
	workspace codePane jadeDisplay.
	self
		assert:
		(session executeString: 'UserGlobals at: #test_workspaceDoIt')
		equals: 123
]
