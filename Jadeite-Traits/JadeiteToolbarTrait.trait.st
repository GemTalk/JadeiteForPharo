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
JadeiteToolbarTrait >> addToolsToMenuGroup: group [
	group addItem: [ :item |
					  item
						  name: 'Tools';
						  subMenu: self newToolsMenu ]. 
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

{ #category : 'menus' }
JadeiteToolbarTrait >> browserAction [

	^ [ self openBrowser ]
]

{ #category : 'menus' }
JadeiteToolbarTrait >> browserIcon [

	^ self iconNamed: #smallSystemBrowser
]

{ #category : 'menus' }
JadeiteToolbarTrait >> browserLabel [

	^ 'Browser'
]

{ #category : 'trait protocol conflict' }
JadeiteToolbarTrait >> existingBrowser [

	| existing newBrowser |
	existing := JadeiteBrowser browserClass allInstances
		            detect: [ :browser | browser window isOpen ]
		            ifNone: [  ].
	^ existing ifNil: [
		  newBrowser := self openBrowser.
		  newBrowser tabs removeAll. "sending method should open the tab"
		  newBrowser ]
]

{ #category : 'actions' }
JadeiteToolbarTrait >> gitShaWorkspaceClientAndServer [

	^ JadeiteConnectionProfile connectionProfile gitShaWorkspace
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

{ #category : 'menus' }
JadeiteToolbarTrait >> newJadeiteToolbar [

	toolbar := self instantiate: JadeiteToolbarPresenter.
	toolbar
		addStyle: 'stToolbar';
		fillWith: self toolbarActions.
	toolbar
		addItem: (SpToolbarButtonPresenter new
				 label: self workspaceLabel;
				 icon: self workspaceIcon;
				 help: 'opens GemStone workspace';
				 action: self workspaceAction;
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: self browserLabel;
				 icon: self browserIcon;
				 help: 'open Browser';
				 action: self browserAction;
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: self sunitBrowserLabel;
				 icon: self sunitBrowserIcon;
				 help: 'open SUnit Browser and Test Runner';
				 action: self sunitBrowserAction;
				 yourself).

	^ toolbar
]

{ #category : 'menus' }
JadeiteToolbarTrait >> newToolsMenu [

	^ self newMenu
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: self workspaceLabel;
						  icon: self workspaceIcon;
						  action: self workspaceAction ];
				  addItem: [ :item |
					  item
						  name: self browserLabel;
						  icon: self browserIcon;
						  action: self browserAction ];
				  addItem: [ :item |
					  item
						  name: self sunitBrowserLabel;
						  icon: self sunitBrowserIcon;
						  action: self sunitBrowserAction ];
				  addItem: [ :item |
					  item
						  name: 'Process Browser';
						  icon: (self iconNamed: #processBrowser);
						  action: [ self openProcessBrowser ] ];
				  addItem: [ :item |
					  item
						  name: 'Windows Browser';
						  icon: (self iconNamed: #window);
						  action: [ self openWindowsBrowser ] ] ];
		  yourself
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
JadeiteToolbarTrait >> openProcessBrowser [

	| inst |
	self isConnected
		ifTrue: [
		inst := JadeiteProcessBrowser showOnSession: self gciSession ]
		ifFalse: [ UIManager default alert: 'Jadeite Not Connected ' ]
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
JadeiteToolbarTrait >> openWindowsBrowser [

	JadeiteWindowsBrowser showOnSession: self gciSession
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

{ #category : 'menus' }
JadeiteToolbarTrait >> sunitBrowserAction [

	^ [ self openSUnitBrowser ]
]

{ #category : 'menus' }
JadeiteToolbarTrait >> sunitBrowserIcon [

	^ self iconNamed: #smallPaint
]

{ #category : 'menus' }
JadeiteToolbarTrait >> sunitBrowserLabel [

	^ 'SUnit Browser'
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

{ #category : 'menus' }
JadeiteToolbarTrait >> workspaceAction [

	^ [ self openWorkspace ]
]

{ #category : 'menus' }
JadeiteToolbarTrait >> workspaceIcon [

	^ self iconNamed: #workspace
]

{ #category : 'menus' }
JadeiteToolbarTrait >> workspaceLabel [

	^ 'Workspace'
]
