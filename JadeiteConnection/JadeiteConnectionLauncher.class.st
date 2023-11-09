Class {
	#name : 'JadeiteConnectionLauncher',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'connectionProfile',
		'versionText',
		'netldiText',
		'stoneText',
		'pathText',
		'userText',
		'passwordText',
		'hostText',
		'connectButton',
		'disconnectButton',
		'setPathButton',
		'connection'
	],
	#classVars : [
		'LastConnectionProfile'
	],
	#category : 'JadeiteConnection'
}

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> lastConnectionProfile [

	^ LastConnectionProfile
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> lastConnectionProfile: aProfile [
 
	LastConnectionProfile := aProfile
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> addStyle: style [

	hostText addStyle: style. 
	stoneText addStyle: style.  
	userText addStyle: style. 
	passwordText addStyle: style. 
	versionText addStyle: style. 
	netldiText addStyle: style. 
	pathText addStyle: style. 
]

{ #category : 'commit id' }
JadeiteConnectionLauncher >> clientCommitIdDescription [

	| ws | 
	ws := WriteStream on: String new. 
	self clientCommitIdDescriptionOn: ws. 
	^ws contents
]

{ #category : 'commit id' }
JadeiteConnectionLauncher >> clientCommitIdDescriptionOn: ws [

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
JadeiteConnectionLauncher >> closeConnectionWindows [

	| connectedPresenters |
	connection := connectionProfile connection.
	connectedPresenters := self jadeiteWindowsFor: connection.
	connectedPresenters do: [ :presenter |
		presenter window ifNotNil: [ :window | window close ] ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> connect [

	| shouldDebug |
	self populateConnectionProfile.
	[
	[
	connection := connectionProfile connect.
	JadeiteConsoleApplication showOnSession: connection ] ensure: [
		self class lastConnectionProfile: connectionProfile.
		self enableButtons ] ]
		on: Error
		do: [ :ex |
			| ws |
			ws := WriteStream on: String new.
			ws
				nextPutAll: ex description;
				cr;
				nextPutAll: 'Debug?'.
			shouldDebug := self uiManager
				               questionWithoutCancel: ws contents
				               title: 'Jadeite Connection Error'.
			shouldDebug
				ifTrue: [ ex pass ]
				ifFalse: [ ^ self ] ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> connectPresenters [

	super connectPresenters.
	connectButton whenActivatedDo: [ self enableButtons ].
	disconnectButton whenActivatedDo: [ self enableButtons ].
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectionProfile [

	^ connectionProfile ifNil: [
		  connectionProfile := JadeiteGCIConnectionProfile new ]
]

{ #category : 'defaults' }
JadeiteConnectionLauncher >> defaultHorizontalSpacing [

	^10
]

{ #category : 'defaults' }
JadeiteConnectionLauncher >> defaultLayout [

	^ SpBoxLayout newVertical spacing: self defaultVerticalSpacing
]

{ #category : 'defaults' }
JadeiteConnectionLauncher >> defaultVerticalSpacing [

	^5
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> disconnect [

	[
	self closeConnectionWindows.
	connectionProfile disconnect.
	self enableButtons ] ensure: [ connection := nil ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> displayClientCommitId: workspace [

	| commitIdDescription |
	commitIdDescription := self clientCommitIdDescription.
	^ workspace text: commitIdDescription
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> displayClientandServerCommitIds: workspace [

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

{ #category : 'actions' }
JadeiteConnectionLauncher >> enableButtons [

	self connectionProfile ifNil: [ ^ self ].
	connectButton enabled: self connectionProfile connection isNil.
	disconnectButton enabled: self connectionProfile connection notNil
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initialize [

	super initialize.
	connectionProfile := self class lastConnectionProfile copy ifNil: [
		                     JadeiteGCIConnectionProfile new ].
	self populateTextFields.
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeAboutMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Git Commit Ids';
				  action: [ self openCommitIdWindow ] ];
		  yourself 
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeButtons [

	connectButton := self newButton
		                 label: 'Connect';
		                 action: [ self connect ].
	disconnectButton := self newButton
		                    label: 'Disconnect';
		                    action: [ self disconnect ].
	self layout add: (SpBoxLayout newHorizontal
			 hAlign: SpLayoutWidgetAlignment center;
			 add: connectButton withConstraints: [ :constraints |
				 constraints
					 height: 30;
					 padding: 10 "put a little extra space around button beyond 'spacing'" ];
			 add: disconnectButton withConstraints: [ :constraints |
			 constraints
				 height: 30;
				 padding: 10 ]).
	self enableButtons
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeHostPresenter [

	self layout
		add: (self newLabel label: 'Host:')
		withConstraints: [ :constraints | constraints height: 20 ].
	hostText := self newTextInput.  
	self layout
		add: hostText
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group | 
			  group addItem: [ :item | 
					  item
						  name: 'About';
						  subMenu: self initializeAboutMenu  ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeNetldiPresenter [

	self layout
		add: (self newLabel label: 'Netldi:')
		withConstraints: [ :constraints | constraints height: 20 ].
	netldiText := self newTextInput.
	self layout
		add: netldiText
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePasswordPresenter [

	self layout
		add: (self newLabel label: 'Password:')
		withConstraints: [ :constraints | constraints height: 20 ].
	passwordText := self newTextInput bePassword.
	self layout
		add: passwordText 
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePathPresenter [

	| pathBox |
	pathBox := SpBoxLayout newHorizontal.
	pathBox
		add: (self newLabel label: 'Client Libraries Path:')
		withConstraints: [ :constraints | constraints height: 20 ].
	setPathButton := self newButton
		                 label: 'Set Path';
		                 icon: (self iconNamed: #smallHome);
		                 action: [ self setPath ].
	pathBox add: setPathButton withConstraints: [ :constraints1 | 
		constraints1
			height: 20;
			width: 150;
			padding: 10 ].
	self layout add: pathBox.
	pathText := self newTextInput beNotEditable.
	self layout
		add: pathText
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePresenters [

	super initializePresenters.
	self initializeHostPresenter.
	self initializeStonePresenter.
	self initializeUserPresenter.
	self initializePasswordPresenter.
	self initializeVersionPresenter.
	self initializeNetldiPresenter.
	self initializePathPresenter.
	self initializeButtons. 
	self setFocusOrder
	
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeStonePresenter [
	self layout
		add: (self newLabel label: 'Stone:')
		withConstraints: [ :constraints | constraints height: 20 ].
	stoneText  := self newTextInput.
	self layout
		add: stoneText
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeUserPresenter [

	self layout
		add: (self newLabel label: 'User:')
		withConstraints: [ :constraints | constraints height: 20 ].
	userText := self newTextInput.
	self layout
		add: userText
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeVersionPresenter [

	self layout
		add: (self newLabel label: 'Version:')
		withConstraints: [ :constraints | constraints height: 20 ].
	versionText := self newTextInput.
	self layout
		add: versionText
		withConstraints: [ :constraints | constraints height: 30 ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 400 @ 550;
		menu: self initializeMenubar.
	self updateCaption

]

{ #category : 'constants' }
JadeiteConnectionLauncher >> jadeiteClientGitRepositories [

	^ #( 'JadeiteForPharo' 'PharoGemStoneFFI' 'RemoteServiceReplication' )
]

{ #category : 'constants' }
JadeiteConnectionLauncher >> jadeiteServerGitRepositories [

	^ #( 'RowanClientServices' )
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> jadeiteWindowsFor: connection [

	| subInstances |
	subInstances := JadeitePresenter allSubInstances.
	subInstances addAll: JadeiteTextDocument allSubInstances.
	^ subInstances select: [ :presenter |
		  presenter gciSession
			  ifNil: [ false ]
			  ifNotNil: [ :sess | sess library == connection ] ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> openCommitIdWindow [

	| workspace windowCaption |
	windowCaption := 'Jadeite Git Commit Ids'.
	connection
		ifNil: [
			workspace := JadeiteNonSessionApplication new start.
			self displayClientCommitId: workspace ]
		ifNotNil: [
			workspace := JadeiteWorkspaceApplication showOnSession: connection.
			self displayClientandServerCommitIds: workspace ].
	workspace setCaption: windowCaption.
	workspace hasUnacceptedEdits: false
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populateConnectionProfile [

	connectionProfile
		host: hostText text;
		stone: stoneText text;
		user: userText text;
		password: passwordText text;
		version: versionText text;
		netldi: netldiText text;
		path: pathText text
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populateTextFields [

	hostText text: connectionProfile host.
	stoneText text: connectionProfile stone.
	userText text: connectionProfile user.
	passwordText text: connectionProfile password.
	versionText text: connectionProfile version.
	netldiText text: connectionProfile netldi.
	pathText text: connectionProfile path
]

{ #category : 'commit id' }
JadeiteConnectionLauncher >> serverCommitIdDescription [

	| ws | 
	ws := WriteStream on: String new. 
	self serverCommitIdDescriptionOn: ws. 
	^ws contents
]

{ #category : 'commit id' }
JadeiteConnectionLauncher >> serverCommitIdDescriptionOn: ws [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session: (GciSession new library: connection).
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
JadeiteConnectionLauncher >> setFocusOrder [

	self focusOrder
		add: hostText;
		add: stoneText;
		add: userText;
		add: passwordText;
		add: versionText;
		add: netldiText;
		add: pathText;
		add: setPathButton;
		add: connectButton;
		add: disconnectButton 
		
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> setPath [

	| path |
	path := UIManager default chooseDirectory.
	path ifNil: [ ^ self ].
	connectionProfile path: path fullName.
	JadeiteGCIConnectionProfile defaultPath: connectionProfile path.
	pathText text: connectionProfile path. 
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> updateCaption [ 
	
	self caption: 'Jadeite Connection Launcher'
]
