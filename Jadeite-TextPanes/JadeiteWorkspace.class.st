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

	| workspacePresenter |
	workspacePresenter := JadeiteWorkspaceApplication showOnSession:
		                      aSession library.
	^ workspacePresenter workspace
]

{ #category : 'private' }
JadeiteWorkspace >> caption: string [

	self owner caption: string 
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
JadeiteWorkspace >> filePathString [
	"for testing"

	^ filePathString
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
JadeiteWorkspace >> initializeWindow: aWindowPresenter [
	"let JadeiteWorkspacePresenter do this"
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
		service := RowanFileServiceClient new
			           session: gciSession;
			           path: filePathString.
		service isDirectory ifTrue: [
			^ MessageBox notify: 'Cannot open a directory' ].
		codePane text: service fileContents.
		self updateCaption.
		self hasUnacceptedEdits: false ]
]

{ #category : 'accessing' }
JadeiteWorkspace >> parseText: fullSource [

	^ RBParser parseFaultyExpression: fullSource
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
		service := RowanFileServiceClient new
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

	| selectionInterval theText |
	selectionInterval := self selectionInterval.
	selectionInterval ifEmpty: [ ^ '' ].
	theText := adapter
		           ifNil: [ self text ]
		           ifNotNil: [ adapter widget text asString ].
	^ theText
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
	service := RowanFileServiceClient new
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
