Trait {
	#name : 'JadeiteToolbarTrait',
	#instVars : [
		'toolbar'
	],
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
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
JadeiteToolbarTrait >> addToolbarItemsToMenuGroup: group [

	^ self newJadeiteToolbar items do: [ :toolbarItem |
		  group addItem: [ :item |
			  item
				  name: toolbarItem label;
				  description: toolbarItem label;
				  icon: toolbarItem icon;
				  action: toolbarItem action ] ]
]

{ #category : 'actions' }
JadeiteToolbarTrait >> basicOpenBrowser: browser [

	| windowPresenter |
	browser
		application: self application;
		gciSession: self gciSession.
	windowPresenter := browser open.
	browser addStyle: 'jadeWorkspace'.
	self application addBorderStyleTo: windowPresenter presenter: browser.
	^ browser
]

{ #category : 'actions' }
JadeiteToolbarTrait >> displayClientCommitId: workspace [

	| commitIdDescription |
	commitIdDescription := self clientCommitIdDescription.
	^ workspace text: commitIdDescription
]

{ #category : 'actions' }
JadeiteToolbarTrait >> gitShaWorkspaceClientAndServer [

	^ JadeiteConnectionProfile connectionProfile gitShaWorkspace
]

{ #category : 'actions' }
JadeiteToolbarTrait >> gitShaWorkspaceClientOnly [

	| workspace windowCaption |
	windowCaption := 'Jadeite Git Commit Ids'.
	workspace := JadeiteNonSessionApplication new start.
	self displayClientCommitId: workspace.
	workspace setCaption: windowCaption.
	workspace hasUnacceptedEdits: false.
	^ workspace
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

{ #category : 'testing' }
JadeiteToolbarTrait >> isConnected [

	^ JadeiteGCIConnectionProfile connectionProfile
		  ifNil: [ false ]
		  ifNotNil: [ :profile | profile isConnected ]
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
				 yourself).
	^ toolbar
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openBrowser [

	| inst |
	self isConnected
		ifTrue: [
			inst := JadeiteBrowser new owner: self.
			^self basicOpenBrowser: inst ]
		ifFalse: [ UIManager default alert: 'Jadeite Not Connected ' ]
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openCommitIdWindow [

	| windowCaption |
	windowCaption := 'Jadeite Git Commit Ids'.
	^ self gitShaWorkspaceClientAndServer
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openSUnitBrowser [

	| inst |
	self isConnected
		ifTrue: [
			RowanServiceUpdater current critical: [
				| windowPresenter |
				inst := self sunitBrowserPresenterClass basicNew.
				inst
					application: self application;
					gciSession: self gciSession;
					initialize.
				windowPresenter := inst open.
				inst addStyle: 'jadeWorkspace'.
				self application addBorderStyleTo: windowPresenter presenter: inst.
				^ inst ] ]
		ifFalse: [ UIManager default alert: 'Jadeite Not Connected ' ]
]

{ #category : 'actions' }
JadeiteToolbarTrait >> openWorkspace [

	self isConnected
		ifTrue: [
		JadeiteWorkspaceApplication showOnSession: self gciSession library ]
		ifFalse: [ UIManager default alert: 'Jadeite Not Connected ' ]
]

{ #category : 'actions' }
JadeiteToolbarTrait >> serverCommitIdDescription: ws onCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session: (GciSession new library: self connection)
		onCompletion: [
			self jadeiteServerGitRepositories do: [ :projectName |
				| project |
				project := browserService projects detect: [ :projectService |
					           projectService name = projectName ].
				ws
					nextPutAll: projectName;
					space;
					nextPutAll: project sha;
					cr ].
			completionBlock value ]
]

{ #category : 'accessing' }
JadeiteToolbarTrait >> sunitBrowserPresenterClass [

	^ JadeitePreferences isRowanLoaded
		  ifTrue: [ JadeiteSUnitPresenter ]
		  ifFalse: [ JadeiteSUnitPresenterWithoutRowan ]
]

{ #category : 'initialization' }
JadeiteToolbarTrait >> toolbarActions [

	^ CmCommandGroup forSpec
		in: [ :this | self addToolbarCommandsTo: this ];
		yourself
]
