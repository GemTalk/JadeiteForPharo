Class {
	#name : 'JadeiteServerFileWorkspace',
	#superclass : 'JadeiteWorkspace',
	#instVars : [
		'path'
	],
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'instance creation' }
JadeiteServerFileWorkspace class >> showOnSession: aGciSession path: path [

	| workspacePresenter workspace service |
	RowanServiceUpdater current critical: [
		service := RowanFileService new
			           session: aGciSession;
			           path: path.
		service isDirectory ifTrue: [
			^ MessageBox notify: 'Cannot open a directory' ].
		service fileContents.
		workspacePresenter := self new
			                      application:
				                      (JadeiteWorkspaceApplication new
					                       gciSession: aGciSession);
			                      addStyle: 'jadeiteTextBackgroundColor';
			                      gciSession: aGciSession;
			                      path: path;
			                      open;
			                      yourself.
		workspace := workspacePresenter workspace.
		workspace filePathString: path.
		workspace codePane documentPresenter value: service answer ]
]

{ #category : 'testing' }
JadeiteServerFileWorkspace >> isOkayToChangeFrame [
	^codePane isOkayToChange
]

{ #category : 'accessing' }
JadeiteServerFileWorkspace >> path [

	^ path
]

{ #category : 'accessing' }
JadeiteServerFileWorkspace >> path: anObject [

	path := anObject
]

{ #category : 'actions' }
JadeiteServerFileWorkspace >> saveDocument [

	| service |
	service := RowanFileService new
		           command: #write:;
		           commandArgs:
			           (Array with:
					            codePane documentPresenter value replaceCrLfWithLf);
		           path: path.
	self issueCommand: service onCompletion: [  ].
	codePane documentPresenter view isModified: false
]

{ #category : 'actions' }
JadeiteServerFileWorkspace >> saveDocumentAs [

	| newPath |
	newPath := JadeiteServerFileSaveDialog
		           showOnSession: gciSession
		           defaultFilePath: path.
	newPath ifNil: [ ^ self ].
	self writeDocumentTo: newPath
]

{ #category : 'actions' }
JadeiteServerFileWorkspace >> updateCaption [
	self caption: (gciSession titleBarFor: 'File contents of: ' , path)
]

{ #category : 'actions' }
JadeiteServerFileWorkspace >> writeDocumentTo: newPath [

	| service |
	service := RowanFileService new
		           command: #write:;
		           commandArgs:
			           (Array with: codePane text replaceCrLfWithLf);
		           path: newPath.
	self issueCommand: service onCompletion: [
		codePane documentPresenter view isModified: false.
		path := newPath.
		self updateCaption ]
]
