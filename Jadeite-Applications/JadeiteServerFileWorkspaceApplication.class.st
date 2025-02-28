Class {
	#name : 'JadeiteServerFileWorkspaceApplication',
	#superclass : 'JadeiteWorkspaceApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'instance creation' }
JadeiteServerFileWorkspaceApplication class >> showOnSession: aGciSession path: path [

	| workspacePresenter workspace service |
	RowanServiceUpdater current critical: [
		service := RowanFileServiceClient new
			           session: aGciSession;
			           path: path.
		service isDirectory ifTrue: [
			^ MessageBox notify: 'Cannot open a directory' ].
		service fileContents.
		workspacePresenter := (JadeiteServerFileWorkspacePresenter new
			                       gciSession: aGciSession)
			                      addStyle: 'jadeiteTextBackgroundColor';
			                      gciSession: aGciSession;
			                      application: self new;
			                      path: path;
			                      open;
			                      yourself.
		workspace := workspacePresenter workspace.
		workspace filePathString: path.
		workspace codePane documentPresenter value: service answer ]
]

{ #category : 'accessing' }
JadeiteServerFileWorkspaceApplication >> presenterClass [

	^ JadeiteServerFileWorkspace
]
