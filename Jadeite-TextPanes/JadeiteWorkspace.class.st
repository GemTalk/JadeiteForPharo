"
model is an instance of GciSession
"
Class {
	#name : 'JadeiteWorkspace',
	#superclass : 'JadeiteTextDocument',
	#instVars : [
		'filePathString'
	],
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'instance creation' }
JadeiteWorkspace class >> showOnSession: aSession [
	^JadeiteWorkspaceApplication showOnSession: aSession library
	
	
]

{ #category : 'private' }
JadeiteWorkspace >> codePane [
	"Private -  for testing"

	^codePane
]

{ #category : 'initialization' }
JadeiteWorkspace >> connectPresenters [

	super connectPresenters.
	self whenResetDo: [
		self isModified: false.
		filePathString ifNotNil: [ self resetFileText ] ]
]

{ #category : 'accessing' }
JadeiteWorkspace >> defaultSaveAsFileName [
	| tail | 
	filePathString ifNil: [ ^'workspace.txt' ].
	tail := (filePathString subStrings: {$/}) last. 
	^tail
]

{ #category : 'accessing' }
JadeiteWorkspace >> defaultSaveFileAsDirectory [

	| substrings |
	filePathString ifNil: [
		^ JadePresenter rowanProjectsHomeEnvVarString ].
	substrings := filePathString subStrings: { $/ }.
	^ (substrings first: substrings size - 1)
		  inject: String new
		  into: [ :path :x |
			  x first = $$
				  ifTrue: [ x ]
				  ifFalse: [ path , '/' , x ] ]
]

{ #category : 'menu handlers' }
JadeiteWorkspace >> editRevert [
	codePane documentPresenter value: lastSave
]

{ #category : 'accessing' }
JadeiteWorkspace >> filePathString: anObject [

	filePathString := anObject
]

{ #category : 'accessing' }
JadeiteWorkspace >> filename [ 
	^filePathString
]

{ #category : 'initialization' }
JadeiteWorkspace >> initializeFileMenu [

	self
		bindKeyCombination: $s meta asKeyCombination
		toAction: [ self saveServerFile ].
	self
		bindKeyCombination: $o shift meta asKeyCombination
		toAction: [ self openServerFile ].
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
	RowanServiceUpdater current critical: [
		filePath := JadeiteServerFileSelectorDialog
			            showOnSession: gciSession
			            defaultPath: self defaultSaveFileAsDirectory.
		filePath ifNil: [ ^ self ].
		filePathString := filePath.
		service := RowanFileService new
			           session: gciSession;
			           path: filePathString.
		service isDirectory ifTrue: [
			^ MessageBox notify: 'Cannot open a directory' ].
		codePane text: service fileContents.
		self updateCaption.
		self hasUnacceptedEdits: false ]
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
JadeiteWorkspace >> resetFileText [

	| service |
	RowanServiceUpdater current critical: [
		service := RowanFileService new
			           session: gciSession;
			           path: filePathString.
		codePane text: service fileContents.
		self updateCaption.
		codePane hasUnacceptedEdits: false ]
]

{ #category : 'actions' }
JadeiteWorkspace >> saveServerFile [

	filePathString ifNil: [ ^ self saveServerFileAs ].
	self writeDocumentTo: filePathString
]

{ #category : 'actions' }
JadeiteWorkspace >> saveServerFileAs [

	| filePath |
	RowanServiceUpdater current critical: [
		filePath := JadeiteServerFileSaveDialog
			            showOnSession: GciSession current
			            defaultPath: self defaultSaveFileAsDirectory
			            defaultFileName: self defaultSaveAsFileName.
		filePath ifNotNil: [
			filePathString := filePath.
			self writeDocumentTo: filePathString ] ]
]

{ #category : 'command support' }
JadeiteWorkspace >> selectedSelector [

	^super selectedSelector ifNotNil: [:obj | obj asString]
]

{ #category : 'api - selection' }
JadeiteWorkspace >> selectedText [ 

	| selectionInterval |
	
	selectionInterval := self selectionInterval.
	selectionInterval ifEmpty: [ ^ '' ].
	
	^adapter widget text asString  "<<<<< Jadeite change here, sending `self text` may update the sp inst var and unselect text"
		copyFrom: selectionInterval first 
		to: selectionInterval last
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
		           commandArgs:
			           (Array with:
					            codePane documentPresenter text asString
						            replaceCrWithLf);
		           path: newPath. 
	self issueCommand: service onCompletion: [
		filePathString := newPath.
		self updateCaption.
		self hasUnacceptedEdits: false ]
]
