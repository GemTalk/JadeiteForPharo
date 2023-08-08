Class {
	#name : 'JadeiteServerFileWorkspace',
	#superclass : 'JadeiteWorkspace',
	#instVars : [
		'path'
	],
	#category : 'JadeiteTextPanes'
}

{ #category : 'instance creation' }
JadeiteServerFileWorkspace class >> showOnSession: aGciSession path: path [

	| inst service |
	service := RowanFileService new
		           session: aGciSession;
		           path: path.
	service isDirectory ifTrue: [ 
		^ MessageBox notify: 'Cannot open a directory' ].
	service fileContents.
	inst := self new
		        application:
			        (JadeiteWorkspaceApplication new gciSession: aGciSession);
		        addStyle: 'jadedTextBackgroundColor';
		        gciSession: aGciSession;
		        path: path;
		        open;
		        yourself.
	inst codePane documentPresenter value: service answer.
	^ inst
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
				commandArgs: (Array with: codePane documentPresenter value replaceCrLfWithLf);
				path: path.
	self issueCommand: service.
	codePane documentPresenter view isModified: false. 
]

{ #category : 'actions' }
JadeiteServerFileWorkspace >> saveDocumentAs [
	| newPath |
	newPath := JadeiteServerFileSaveDialog showOnSession: gciSession defaultFilePath: path.
	newPath ifNil: [^self].
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
				commandArgs: (Array with: codePane documentPresenter value replaceCrLfWithLf);
				path: newPath.
	self issueCommand: service.
	codePane documentPresenter view isModified: false.
	path := newPath.
	self updateCaption
]
