Class {
	#name : 'JadeiteConnectionLauncher',
	#superclass : 'JadeitePresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
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
		'lastConnection',
		'lastImportedFileName',
		'availableConnectionPresenter',
		'displayFullPath',
		'portText'
	],
	#classVars : [
		'ConnectionProfile',
		'ImportedConnections'
	],
	#category : 'Jadeite-Connection',
	#package : 'Jadeite-Connection'
}

{ #category : 'as yet unclassified' }
JadeiteConnectionLauncher class >> addImportedConnection: filePath [

	(ImportedConnections collection includes: filePath) ifFalse: [
		ImportedConnections add: filePath ]
]

{ #category : 'as yet unclassified' }
JadeiteConnectionLauncher class >> importedConnections [

	^ ImportedConnections 
]

{ #category : 'as yet unclassified' }
JadeiteConnectionLauncher class >> importedConnections: aSpCollectionListModel [

	ImportedConnections ifNotNil: [ :conn |
		aSpCollectionListModel addAll: conn items ].
	ImportedConnections := aSpCollectionListModel
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
	portText addStyle: style.
	availableConnectionPresenter addStyle: style
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> basicExportProfile: fileRef [

	| profileCopy ws |
	ws := fileRef writeStream.
	[
	profileCopy := JadeiteGCIConnectionProfile new.
	self populate: profileCopy. "don't want to export the connection"
	ws nextPutAll: (STON toString: profileCopy).
	ws flush ] ensure: [ ws close ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> basicImportProfile: fileStream [

	| connectionProfile |
	connectionProfile := [ STON fromString: fileStream contents ]
		                     ensure: [ fileStream close ].
	self clearConnectionSubscriptions.
	JadeiteConnectionProfile connectionProfile: connectionProfile.
	self populateTextFields.
	self connectConnection
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> basicNewConnection [

	hostText text: String new.
	stoneText text: String new.
	userText text: String new.
	passwordText text: String new.
	versionText text: String new.
	netldiText text: String new
]

{ #category : 'testing' }
JadeiteConnectionLauncher >> canDiscardEdits [

	^true
]

{ #category : 'testing' }
JadeiteConnectionLauncher >> canDiscardSelectionEdits [

	^ true
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> clearConnectionSubscriptions [

	^ (self connectionProfile observablePropertyNamed: #connection)
		  subscriptions: OrderedCollection new
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> closeWindowsForConnection: theConnection [

	| jadeiteWindows |
	jadeiteWindows := JadeiteConnectionProfile connectionProfile
		                  jadeiteWindows.
	[ jadeiteWindows do: [ :window | window close ] ] ensure: [
		JadeiteConnectionProfile connectionProfile jadeiteWindows:
			OrderedCollection new ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> connect [

	| shouldDebug |
	self populateConnectionProfile.
	[ self connectionProfile connect ]
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

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectButton [

	^ connectButton
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> connectConnection [

	self connectionProfile whenConnectionChangedDo: [ :theConnection |
		theConnection
			ifNil: [ self closeWindowsForConnection: lastConnection ]
			ifNotNil: [
				theConnection isOpen ifTrue: [
					JadeiteConsoleApplication showOnSession: theConnection ] ].
		self enableButtons.
		lastConnection := theConnection ]
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> connectPresenters [

	super connectPresenters.
	self connectConnection.
	availableConnectionPresenter whenSelectionChangedDo: [ :selection |
		self installImportedConnection: selection selectedItem.
		self populateTextFields ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> connection [

	^self connectionProfile connection
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectionProfile [

	^JadeiteConnectionProfile connectionProfile
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> copyConnection [
	"a copy is essentially a do nothing operation"

	Clipboard clipboardText:
		(STON toString: JadeiteConnectionProfile connectionProfile).
	UIManager default inform: 'Jadeite connection copied'
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

{ #category : 'defaults' }
JadeiteConnectionLauncher >> defaultWindowPresenterClass [
		
	^ JadeiteGlobalWindowPresenter
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> disconnect [

	self connectionProfile disconnect
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> disconnectButton [

	^ disconnectButton
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> displayClientCommitId: workspace [

	| commitIdDescription |
	commitIdDescription := self clientCommitIdDescription.
	^ workspace text: commitIdDescription
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> enableButtons [

	self connectionProfile ifNil: [ ^ self ].
	connectButton enabled: self connectionProfile connection isNil.
	disconnectButton enabled: self connectionProfile connection notNil
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> exportProfile [

	| fileRef |
	fileRef := UIManager default theme
		           chooseForSaveFileReferenceIn: Smalltalk ui
		           title: 'Export Connection File'
		           extensions: nil
		           path: '*'
		           preview: nil.
	fileRef ifNil: [ ^ self ].
	fileRef exists ifTrue: [
		(UIManager default confirm: 'Overwrite existing file?') ifFalse: [
			^ self ] ].
	self basicExportProfile: fileRef
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> hostText [

	^ hostText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> hostText: anObject [

	hostText := anObject
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> importProfile [

	| fileStream fileWindow |
	JadeiteConnectionProfile connectionProfile isConnected ifTrue: [
		(UIManager default confirm:
			 'Importing a connection will disconnect current connection. Continue?')
			ifTrue: [ JadeiteConnectionProfile connectionProfile disconnect ]
			ifFalse: [ ^ self ] ].
	fileWindow := FileDialogWindow basicNew.
	fileStream := fileWindow
		              previewType: nil;
		              initialize;
		              title: 'Select connection profile to import';
		              answerOpenFile;
		              openModal;
		              answer.
	fileStream ifNil: [ ^ self ].
	lastImportedFileName := fileWindow selectedFileName. 
	self class addImportedConnection: fileWindow selectedPathName. 
	self basicImportProfile: fileStream
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initialize [ 
	super initialize. 
	displayFullPath := false
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
JadeiteConnectionLauncher >> initializeAvailableConnectionPresenter [

	self layout add: (self newLabel label: 'Imported Connections:').
	availableConnectionPresenter := JadeiteListPresenter new
		                                display: [ :filePath |
			                                displayFullPath
				                                ifTrue: [ filePath ]
				                                ifFalse: [
					                                self shortPathFor: filePath ] ];
		                                contextMenu:
			                                self initializeConnectionsMenu.
	self layout add: availableConnectionPresenter height: 60.
	self class importedConnections: availableConnectionPresenter model
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
				 constraints padding: 10 "put a little extra space around button beyond 'spacing'" ];
			 add: disconnectButton
			 withConstraints: [ :constraints | constraints padding: 10 ]).
	self enableButtons
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeClientLibPathPresenter [

	| pathBox |
	pathBox := SpBoxLayout newHorizontal.
	pathBox add: (self newLabel label: 'Client Libraries Path:').
	setPathButton := self newButton
		                 label: 'Set Path';
		                 icon: (self iconNamed: #smallHome);
		                 action: [ self setPath ].
	pathBox
		add: setPathButton
		withConstraints: [ :constraints1 | constraints1 padding: 5 ].
	self layout add: pathBox.

	pathText := self newTextInput beNotEditable.
	self layout add: pathText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeConnectionsMenu [

	| menu |
	menu := self newMenu.
	menu
		addItem: [ :item |
			item
				name: 'Toggle Full Path Display';
				action: [ self toggleFullPathDisplay ] ];
		addItem: [ :item |
			item
				name: 'Remove Item';
				action: [ self removeSelectedConnection ] ].
	^ menu
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeFileMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'New Connection';
				  action: [ self newConnection ] ];
		  addItem: [ :item |
			  item
				  name: 'Copy Connection';
				  action: [ self copyConnection ] ];
		  addItem: [ :item |
			  item
				  name: 'Export Connection ...';
				  action: [ self exportProfile ] ];
		  addItem: [ :item |
			  item
				  name: 'Import Connection ...';
				  action: [ self importProfile ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeHostPresenter [

	self layout add: (self newLabel label: 'Host:').
	hostText := self newTextInput.
	self layout add: hostText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'File';
						  subMenu: self initializeFileMenu ];
				  addItem: [ :item |
					  item
						  name: 'About';
						  subMenu: self initializeAboutMenu ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeNetldiPresenter [

	self layout add: (self newLabel label: 'Netldi:').
	netldiText := self newTextInput.
	self layout add: netldiText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePasswordPresenter [

	self layout add: (self newLabel label: 'Password:').
	passwordText := self newTextInput bePassword.
	self layout add: passwordText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePortNumber [

	self layout add: (self newLabel label: 'Fixed Port (leave blank for wildcard port)').
	portText := self newTextInput.
	portText enabled: false.
	self layout add: portText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePresenter [
	super initializePresenter. 
	self populateTextFields.
	self enableButtons
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
	self initializeClientLibPathPresenter.
	self initializePortNumber. 
	self initializeAvailableConnectionPresenter. 
	self initializeButtons. 
	self setFocusOrder
	
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeStonePresenter [

	self layout add: (self newLabel label: 'Stone:').
	stoneText := self newTextInput.
	self layout add: stoneText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeUserPresenter [

	self layout add: (self newLabel label: 'User:').
	userText := self newTextInput.
	self layout add: userText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeVersionPresenter [

	self layout add: (self newLabel label: 'Version:').
	versionText := self newTextInput.
	self layout add: versionText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: (40 @ 65) * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self updateCaption.
	aWindowPresenter whenClosedDo: [ self clearConnectionSubscriptions ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> installImportedConnection: filePath [

	| fileStream |
	fileStream := ZnCharacterReadStream
		              on: filePath asFileReference binaryReadStream
		              encoding: 'utf8'.
	self basicImportProfile: fileStream
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> netldiText [

	^ netldiText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> netldiText: anObject [

	netldiText := anObject
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> newConnection [
	"blank the fields so the user can enter entirely new connction information"

	| shouldClear |
	shouldClear := UIManager default confirm:
		               'Clear all fields to enter new connection information?'.
	shouldClear ifTrue: [ self basicNewConnection ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> passwordText [

	^ passwordText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> passwordText: anObject [

	passwordText := anObject
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> pathText [

	^ pathText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> pathText: anObject [

	pathText := anObject
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populate: profile [

	profile
		host: hostText text;
		stone: stoneText text;
		user: userText text;
		password: passwordText text;
		version: versionText text;
		netldi: netldiText text;
		path: pathText text ;
		port: portText text
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populateConnectionProfile [

	self populate: self connectionProfile
		
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populateTextFields [

	hostText text: self connectionProfile host.
	stoneText text: self connectionProfile stone.
	userText text: self connectionProfile user.
	passwordText text: self connectionProfile password.
	versionText text: self connectionProfile version.
	netldiText text: self connectionProfile netldi.
	pathText text: self connectionProfile path.
	portText text: self connectionProfile port. 
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> removeSelectedConnection [

	availableConnectionPresenter model remove: availableConnectionPresenter selectedItem 
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
	self connectionProfile path: path fullName.
	JadeiteGCIConnectionProfile defaultPath: self connectionProfile path.
	pathText text: self connectionProfile path. 
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> shortPathFor: filePath [

	^ filePath asFileReference basename
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> stoneText [

	^ stoneText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> stoneText: anObject [

	stoneText := anObject
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> toggleFullPathDisplay [

	displayFullPath := displayFullPath not.
	availableConnectionPresenter invalidate. 
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> updateCaption [ 
	
	self caption: 'Jadeite Connection Launcher'
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> userText [

	^ userText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> userText: anObject [

	userText := anObject
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> versionText [

	^ versionText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> versionText: anObject [

	versionText := anObject
]
