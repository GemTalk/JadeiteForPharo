"
model is an instance of GciSession
"
Class {
	#name : 'JadeiteWorkspace',
	#superclass : 'JadeiteTextDocument',
	#instVars : [
		'filename'
	],
	#category : 'JadeiteTextPanes'
}

{ #category : 'instance creation' }
JadeiteWorkspace class >> showOnSession: aSession [
	"for legacy imported tests"
	^JadeiteWorkspaceApplication showOnSession: aSession library
	
	
]

{ #category : 'private' }
JadeiteWorkspace >> codePane [
	"Private -  for testing"

	^codePane
]

{ #category : 'menu handlers' }
JadeiteWorkspace >> editRevert [
	codePane documentPresenter value: lastSave
]

{ #category : 'accessing' }
JadeiteWorkspace >> filename [ 
	^filename
]

{ #category : 'initialization' }
JadeiteWorkspace >> initializeFileMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Open Server File';
				  shortcut: $o shift meta;
				  action: [ self openServerFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Save On Server';
				  shortcut: $s meta;
				  action: [ self saveServerFile ] ];
		  addItem: [ :item2 |
			  item2
				  name: 'Save On Server As ...';
				  action: [ self saveServerFileAs ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteWorkspace >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'File';
						  subMenu: self initializeFileMenu ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteWorkspace >> initializePresenters [

	super initializePresenters.
	self
		bindKeyCombination: $s meta asKeyCombination
		toAction: [ self saveServerFile ].
	self
		bindKeyCombination: $o shift meta asKeyCombination
		toAction: [ self openServerFile ]
]

{ #category : 'initialization' }
JadeiteWorkspace >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter. 
	aWindowPresenter menu: self initializeMenubar. 
]

{ #category : 'actions' }
JadeiteWorkspace >> inspectOop: anOop [

	^ JadeiteInspectorApplication
		  show: anOop
		  onSession:
		  gciSession library
]

{ #category : 'actions' }
JadeiteWorkspace >> openServerFile [

	| filePath service |
	filePath := JadeiteServerFileSelectorDialog
		            showOnSession: gciSession
		            defaultPath: JadePresenter rowanProjectsHomeEnvVarString.
	filePath ifNil: [ ^ self ].
	filename := filePath.
	service := RowanFileService new
		           session: gciSession;
		           path: filename.
	service isDirectory ifTrue: [
		^ MessageBox notify: 'Cannot open a directory' ].
	codePane text: service fileContents.
	self updateCaption. 
]

{ #category : 'public' }
JadeiteWorkspace >> queryCommand: aCommandQuery [

	| cmd |
	
	cmd := aCommandQuery commandSymbol.
	(cmd == #'setEnvironment0' and: [environment == 0]) ifTrue: [aCommandQuery isChecked: true; isEnabled: false. ^true].
	(cmd == #'setEnvironment1' and: [environment == 1]) ifTrue: [aCommandQuery isChecked: true; isEnabled: false. ^true].
	(cmd == #'setEnvironment2' and: [environment == 2]) ifTrue: [aCommandQuery isChecked: true; isEnabled: false. ^true].
	^super queryCommand: aCommandQuery
]

{ #category : 'actions' }
JadeiteWorkspace >> saveServerFile [

	filename ifNil: [ ^ self saveServerFileAs ].
	self writeDocumentTo: filename
]

{ #category : 'actions' }
JadeiteWorkspace >> saveServerFileAs [

	| filePath |
	filePath := JadeiteServerFileSaveDialog
		            showOnSession: GciSession current
		            defaultPath: JadePresenter rowanProjectsHomeEnvVarString
		            defaultFileName: 'workspace.txt'.
	filePath ifNil: [ ^ self ].
	self writeDocumentTo: filePath
]

{ #category : 'private' }
JadeiteWorkspace >> setCaption: string [

	| theString |
	theString := gciSession titleBarFor: string.
	self caption: theString
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment0 [

	self setEnvironment: 0.
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment1 [

	self setEnvironment: 1.
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment2 [

	self setEnvironment: 2.
]

{ #category : 'public' }
JadeiteWorkspace >> setEnvironment: anInteger [

	environment := anInteger.
	codePane documentPresenter parentPresenter environment: anInteger.
	self updateCaption.

]

{ #category : 'private' }
JadeiteWorkspace >> updateCaption [

	| string |
	string := self filename isNil
		ifTrue: ['Jadeite Workspace']
		ifFalse: [self filename].
	string := gciSession titleBarFor: string.
	environment ~~ 0 ifTrue: [string := string , ' @env' , environment printString].
	self caption: string.

]

{ #category : 'accessing' }
JadeiteWorkspace >> value [ 
	^self
]

{ #category : 'actions' }
JadeiteWorkspace >> writeDocumentTo: newPath [
	| service |
	service := RowanFileService new
				command: #write:;
				commandArgs: (Array with: codePane documentPresenter text replaceCrWithLf);
				path: newPath.
	self issueCommand: service.
	filename := newPath. 
	self updateCaption
]
