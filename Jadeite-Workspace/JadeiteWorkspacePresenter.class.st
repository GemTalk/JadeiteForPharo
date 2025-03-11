Class {
	#name : 'JadeiteWorkspacePresenter',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'workspace'
	],
	#category : 'Jadeite-Workspace',
	#package : 'Jadeite-Workspace'
}

{ #category : 'api' }
JadeiteWorkspacePresenter >> addStyle: aStyle [

	workspace addStyle: aStyle
]

{ #category : 'layout' }
JadeiteWorkspacePresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'api' }
JadeiteWorkspacePresenter >> gciSession: aGciSession [

	gciSession := aGciSession.
	workspace gciSession: aGciSession
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> initializeFileMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Open Server File';
				  shortcut: $o shift meta;
				  action: [ workspace openServerFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Save On Server';
				  shortcut: $s meta;
				  action: [ workspace saveServerFile ] ];
		  addItem: [ :item2 |
			  item2
				  name: 'Save On Server As ...';
				  action: [ workspace saveServerFileAs ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> initializeKeyBindings [

	self workspace
		bindKeyCombination: $s meta asKeyCombination
		toAction: [ workspace saveServerFile ].
	self workspace
		bindKeyCombination: $o shift meta asKeyCombination
		toAction: [ workspace openServerFile ]
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'File';
						  subMenu: self initializeFileMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> initializePresenters [

	| waitBox |
	super initializePresenters.
	waitBox := self initializeWaitPresenter.
	self layout add: waitBox expand: false.
	self showNotWait.
	workspace := self workspaceClass new.
	self layout add: workspace
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	self updateCaption. 
	self initializeKeyBindings.
	aWindowPresenter
		initialExtent: 80 @ 50 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar
]

{ #category : 'actions' }
JadeiteWorkspacePresenter >> setCaption: string [

	| theString |
	theString := gciSession titleBarFor: string.
	self caption: theString
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> updateCaption [

	| string title |
	title := 'Jadeite Workspace'.
	string := gciSession
		          ifNil: [ title ]
		          ifNotNil: [ gciSession titleBarFor: title ].
	self caption: string
]

{ #category : 'accessing' }
JadeiteWorkspacePresenter >> workspace [

	^ workspace
]

{ #category : 'accessing' }
JadeiteWorkspacePresenter >> workspace: anObject [

	workspace := anObject
]

{ #category : 'initialization' }
JadeiteWorkspacePresenter >> workspaceClass [

	^ JadeiteWorkspace
]
