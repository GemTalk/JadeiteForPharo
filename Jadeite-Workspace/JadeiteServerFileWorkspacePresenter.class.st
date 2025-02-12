Class {
	#name : 'JadeiteServerFileWorkspacePresenter',
	#superclass : 'JadeiteWorkspacePresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#category : 'Jadeite-Workspace',
	#package : 'Jadeite-Workspace'
}

{ #category : 'accessing' }
JadeiteServerFileWorkspacePresenter >> path: aString [

	workspace path: aString
]

{ #category : 'actions' }
JadeiteServerFileWorkspacePresenter >> updateCaption [

	self caption:
		(gciSession titleBarFor: 'File contents of: ' , workspace path)
]

{ #category : 'accessing' }
JadeiteServerFileWorkspacePresenter >> workspaceClass [

	^ JadeiteServerFileWorkspace
]
