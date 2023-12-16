Class {
	#name : 'JadeiteConnectionLauncher',
	#superclass : 'JadeitePresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
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
		'lastConnection'
	],
	#classVars : [
		'LastConnectionProfile'
	],
	#category : 'Jadeite-Connection'
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

{ #category : 'actions' }
JadeiteConnectionLauncher >> closeWindowsForConnection: theConnection [

	| connectedPresenters |
	connectedPresenters := self jadeiteWindowsFor: theConnection.
	connectedPresenters do: [ :presenter |
		presenter window ifNotNil: [ :window | window close ] ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> connect [

	| shouldDebug |
	self populateConnectionProfile.
	[ connectionProfile connect ]
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
	connectionProfile whenConnectionChangedDo: [ :theConnection |
		theConnection
			ifNil: [ self closeWindowsForConnection: lastConnection ]
			ifNotNil: [
				self class lastConnectionProfile: connectionProfile.
				JadeiteConsoleApplication showOnSession: theConnection ].
		self enableButtonsWithConnection: nil.
		lastConnection := theConnection ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectionProfile [

	^ connectionProfile
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectionProfile: anObject [ 

	connectionProfile := anObject 
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

	connectionProfile disconnect
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
JadeiteConnectionLauncher >> enableButtonsWithConnection: anObject [

	self connectionProfile ifNil: [ ^ self ].
	connectButton enabled: self connectionProfile connection isNil.
	disconnectButton enabled: self connectionProfile connection notNil
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
	self enableButtonsWithConnection: nil
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
JadeiteConnectionLauncher >> initializePresenter [
	super initializePresenter. 
	connectionProfile := self class lastConnectionProfile copy ifNil: [
		                     JadeiteGCIConnectionProfile new ].
	self populateTextFields.
	self enableButtonsWithConnection: nil. 
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
