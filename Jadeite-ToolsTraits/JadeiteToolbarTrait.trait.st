Trait {
	#name : 'JadeiteToolbarTrait',
	#instVars : [
		'toolbar'
	],
	#category : 'Jadeite-ToolsTraits'
}

{ #category : 'toolbar support' }
JadeiteToolbarTrait classSide >> toolbarCommands [

	^ { 
		  JadeiteAbortCommand.
		  JadeiteCommitCommand }
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> addToolbarCommandsTo: aGroup [

	self class toolbarCommands do: [ :each | 
		aGroup register: (each forSpecContext: self) ]
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> initializeToolbar [

	self newJadeiteToolbar.
	self layout
		add: #toolbar
		expand: false
		fill: false
		padding: 0
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> newJadeiteToolbar [

	toolbar := self newToolbar.
	toolbar
		addStyle: 'stToolbar';
		fillWith: self toolbarActions.
	toolbar
		addItem: (SpToolbarButtonPresenter new
				 label: 'Workspace';
				 icon: (self iconNamed: #workspace);
				 help: 'opens GemStone workspace';
				 action: [ self openWorkspace ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Browser';
				 icon: (self iconNamed: #smallSystemBrowser);
				 help: 'open Browser';
				 action: [ self openBrowser ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'SUnit Browser';
				 icon: (self iconNamed: #smallPaint);
				 help: 'open SUnit Browser and Test Runner';
				 action: [ self openSUnitBrowser ];
				 yourself);
		yourself.
	^toolbar
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openBrowser [

	| inst | 
	inst := JadeiteBrowser new owner: self. 
	inst
		application: self application;
		gciSession: self gciSession.
	inst open.
	inst addStyle: 'jadeWorkspace'.
	^inst
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openSUnitBrowser [

	| inst |
	inst := JadeiteSUnitPresenter basicNew.
	inst
		application: self application;
		gciSession: self gciSession;
		initialize.
	inst open.
	inst addStyle: 'jadeWorkspace'
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openWorkspace [

	JadeiteWorkspaceApplication showOnSession: self gciSession library
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> toolbarActions [

	^ CmCommandGroup forSpec
		in: [ :this | self addToolbarCommandsTo: this ];
		yourself
]
