Trait {
	#name : 'JadeiteToolbarTrait',
	#instVars : [
		'toolbar'
	],
	#category : 'Jadeite-Traits'
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

{ #category : 'actions' }
JadeiteToolbarTrait >> clientCommitIdDescription [

	| ws | 
	ws := WriteStream on: String new. 
	self clientCommitIdDescriptionOn: ws. 
	^ws contents
]

{ #category : 'actions' }
JadeiteToolbarTrait >> clientCommitIdDescriptionOn: ws [

	self jadeiteClientGitRepositories doWithIndex: [ :repoName :index |
		| repo |
		repo := IceRepository registry detect: [ :ea | ea name = repoName ].
		index = 1 ifFalse:[ws cr]. 
		ws
			nextPutAll: repoName;
			space;
			nextPutAll: repo properties commitish shortId ]
]

{ #category : 'actions' }
JadeiteToolbarTrait >> displayClientCommitId: workspace [

	| commitIdDescription |
	commitIdDescription := self clientCommitIdDescription.
	^ workspace text: commitIdDescription
]

{ #category : 'actions' }
JadeiteToolbarTrait >> displayClientandServerCommitIds: workspace [

	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: self clientCommitIdDescription;
		cr;
		nextPutAll: '---------------------------------------------';
		cr;
		nextPutAll: self serverCommitIdDescription.
	^ workspace text: ws contents
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

{ #category : 'actions' }
JadeiteToolbarTrait >> jadeiteClientGitRepositories [

	^ #( 'JadeiteForPharo' 'PharoGemStoneFFI' 'RemoteServiceReplication' )
]

{ #category : 'actions' }
JadeiteToolbarTrait >> jadeiteServerGitRepositories [

	^ #( 'RowanClientServices' )
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> newJadeiteToolbar [

	toolbar := self instantiate: JadeiteToolbarPresenter.
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
	^ toolbar
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
JadeiteToolbarTrait >> openCommitIdWindow [

	| workspace windowCaption |
	windowCaption := 'Jadeite Git Commit Ids'.
	self connection
		ifNil: [
			workspace := JadeiteNonSessionApplication new start.
			self displayClientCommitId: workspace ]
		ifNotNil: [
			workspace := JadeiteWorkspaceApplication showOnSession: self connection.
			self displayClientandServerCommitIds: workspace ].
	workspace setCaption: windowCaption.
	workspace hasUnacceptedEdits: false.
	^workspace
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

	[ JadeiteWorkspaceApplication showOnSession: self gciSession library ]
		schedule
]

{ #category : 'actions' }
JadeiteToolbarTrait >> serverCommitIdDescription [

	| ws | 
	ws := WriteStream on: String new. 
	self serverCommitIdDescriptionOn: ws. 
	^ws contents
]

{ #category : 'actions' }
JadeiteToolbarTrait >> serverCommitIdDescriptionOn: ws [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session: (GciSession new library: self connection)
		onCompletion: nil.
	self jadeiteServerGitRepositories do: [ :projectName |
		| project |
		project := browserService projects detect: [ :projectService |
			           projectService name = projectName ].
		ws
			nextPutAll: projectName;
			space;
			nextPutAll: project sha;
			cr ]
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> toolbarActions [

	^ CmCommandGroup forSpec
		in: [ :this | self addToolbarCommandsTo: this ];
		yourself
]
