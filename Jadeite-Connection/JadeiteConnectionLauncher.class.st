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
		'ImportedConnections',
		'LastImportDirectory',
		'SoleInstance'
	],
	#category : 'Jadeite-Connection',
	#package : 'Jadeite-Connection'
}

{ #category : 'connections' }
JadeiteConnectionLauncher class >> addImportedConnection: filePath [

	(self importedConnections includes: filePath) ifTrue: [ ^ self ].
	self importedConnections add: filePath.
	self importedConnections collection reSort
]

{ #category : 'connections' }
JadeiteConnectionLauncher class >> addImportedConnections: directoryRef [

	| fileRefs |
	fileRefs := directoryRef files asSortedCollection.
	fileRefs do: [ :fileRef | self addImportedConnection: fileRef ].
	^ fileRefs
]

{ #category : 'defaults' }
JadeiteConnectionLauncher class >> defaultConnectionSortBlock [

	^ [ :x :y | (self shortPathFor: x) < (self shortPathFor: y) ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> importedConnections [

	ImportedConnections
		ifNil: [ ImportedConnections := self newImportedConnections ]
		ifNotNil: [
			(ImportedConnections collection isKindOf: SortedCollection)
				ifFalse: [
					| new |
					ImportedConnections ifNotNil: [
						new := self newImportedConnections.
						new addAll: ImportedConnections.
						ImportedConnections := new ] ] ].
	^ ImportedConnections
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> importedConnections: connections [
	"for testing only"

	ImportedConnections := connections
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> lastImportDirectory [

	^LastImportDirectory
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> lastImportDirectory: pathString [

	LastImportDirectory := pathString
]

{ #category : 'connections' }
JadeiteConnectionLauncher class >> newImportedConnections [

	^ ListModel newSorted: self defaultConnectionSortBlock
]

{ #category : 'connections' }
JadeiteConnectionLauncher class >> shortPathFor: filePath [

	^ filePath asFileReference basename
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> soleInstance [

	^SoleInstance 
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> soleInstance: aConnectionLauncher [

	SoleInstance := aConnectionLauncher
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

{ #category : 'accessing' }
JadeiteConnectionLauncher >> availableConnectionPresenter [

	^ availableConnectionPresenter
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicExportProfile: fileRef [

	| profileCopy ws |
	ws := fileRef writeStream.
	[
	profileCopy := JadeiteGCIConnectionProfile new.
	self populate: profileCopy. "don't want to export the connection"
	ws nextPutAll: (STON toString: profileCopy).
	ws flush ] ensure: [ ws close ]
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicImportProfile: fileRef [

	| connectionProfile |
	connectionProfile := STON fromString: fileRef contents.
	self clearConnectionSubscriptions.
	JadeiteConnectionProfile connectionProfile: connectionProfile.
	self populateTextFields.
	self connectConnection.
	availableConnectionPresenter model collection reSort
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicImportProfileDirectory: directoryRef [

	| fileRefs |
	self class lastImportDirectory: directoryRef asAbsolute asText.
	fileRefs := self class addImportedConnections: directoryRef.
	fileRefs do: [ :fileRef |
		[ self basicImportProfile: fileRef ]
			on: Error
			do: [ :ex |
				| ws |
				ws := WriteStream on: String new.
				ws
					nextPutAll: 'Error importing file:';
					space;
					nextPutAll: fileRef fullName;
					cr;
					nextPutAll: 'Directory import cancelled';
					cr;
					nextPutAll: 'Error message:';
					space;
					nextPutAll: ex messageText.
				^ UIManager default alert: ws contents ] ].
	availableConnectionPresenter model collection reSort
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicImportProfileFile: fileWindow [

	self class addImportedConnection:
		fileWindow selectedPathName asFileReference.
	[
	self basicImportProfile: FileReference / fileWindow selectedPathName ]
		on: Error
		do: [ :ex |
			| ws |
			ws := WriteStream on: String new.
			ws
				nextPutAll: 'Error importing file:';
				space;
				nextPutAll: fileWindow selectedPathName;
				cr;
				nextPutAll: 'Error message:';
				space;
				nextPutAll: ex messageText.
			UIManager default alert: ws contents ]
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

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicRemoveAllConnections [

	availableConnectionPresenter model removeAll
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
		                  jadeiteWindows copy.
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
		selection selectedIndex = 0 ifFalse: [
			self installImportedConnection: selection selectedItem ] ]
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

{ #category : 'connections' }
JadeiteConnectionLauncher >> exportProfile [

	| fileRef |
	fileRef := UIManager default theme
		           jadeiteChooseForSaveFileReferenceIn: Smalltalk ui
		           title: 'Export Connection File'
		           extensions: nil
		           path: 'jadeiteConnection.txt'
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

{ #category : 'connections' }
JadeiteConnectionLauncher >> importProfileDirectory [

	| directoryRef fileWindow |
	"confusing not to see files"
	self possiblyDisconnect ifFalse: [ ^ self ].
	fileWindow := FileDialogWindow basicNew.
	fileWindow
		previewType: nil;
		initialize;
		title: 'Select directory containing only connection profiles';
		answerDirectory.
	fileWindow fileSelectionBlock: fileWindow defaultFileSelectionBlock.
	self class lastImportDirectory ifNotNil: [ :dir |
		fileWindow selectDirectory: dir asFileReference ].
	directoryRef := fileWindow
		                openModal;
		                answer.
	directoryRef ifNil: [ ^ self ].
	self basicImportProfileDirectory: directoryRef
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> importProfileFile [

	| fileStream fileWindow |
	self possiblyDisconnect ifFalse: [ ^ self ].
	fileWindow := FileDialogWindow basicNew.
	fileWindow
		previewType: nil;
		initialize;
		title: 'Select connection profile file to import';
		answerOpenFile.
	self class lastImportDirectory ifNotNil: [ :dir |
		fileWindow selectDirectory: dir asFileReference ].
	fileStream := fileWindow
		              openModal;
		              answer.
	fileStream ifNil: [ ^ self ].
	self basicImportProfileFile: fileWindow
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

	self layout add: (self newLabel label: 'Imported Connections List:').
	availableConnectionPresenter := JadeiteListPresenter new
		                                display: [ :filePath |
			                                displayFullPath
				                                ifTrue: [ filePath ]
				                                ifFalse: [
					                                self shortPathFor: filePath ] ];
		                                contextMenu:
			                                self initializeConnectionsMenu.
	self layout add: availableConnectionPresenter height: 100.
	availableConnectionPresenter model: self class importedConnections
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
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Toggle Full Path Display';
					action: [ self toggleFullPathDisplay ] ];
			addItem: [ :item |
				item
					name: 'Refresh from last Import Directory';
					action: [ self refreshFromLastImportDirectory ] ] ].
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Remove Connection';
					action: [ self removeSelectedConnection ] ];
			addItem: [ :item |
				item
					name: 'Remove All Connections';
					action: [ self removeAllConnections ] ] ].
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
				  action: [ self importProfileFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Import Connection Directory...';
				  action: [ self importProfileDirectory ] ];
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
		initialExtent: 40 @ 70 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar;
		centered.
	self updateCaption.
	aWindowPresenter whenClosedDo: [
		self clearConnectionSubscriptions.
		self class soleInstance: nil ].
	self class soleInstance: aWindowPresenter
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> installImportedConnection: filePath [

	| fileStream fileRef |
	fileRef := filePath asFileReference.
	fileRef exists ifFalse: [ ^ self ].
	fileStream := ZnCharacterReadStream
		              on: filePath asFileReference binaryReadStream
		              encoding: 'utf8'.
	self basicImportProfile: fileStream.
	self populateTextFields 
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
	self connectionProfile port
		ifNil: [ portText text: String new ]
		ifNotNil: [ portText text: self connectionProfile port ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> portText [

	^ portText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> portText: anObject [

	portText := anObject
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> possiblyDisconnect [

	JadeiteConnectionProfile connectionProfile isConnected ifTrue: [
		(UIManager default confirm:
			 'Importing a connection will disconnect current connection. Continue?')
			ifTrue: [ JadeiteConnectionProfile connectionProfile disconnect ]
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> refreshFromLastImportDirectory [

	self class lastImportDirectory ifNil: [
		^UIManager default alert: 'Need to import from a directory first' ].
	self basicImportProfileDirectory: self class lastImportDirectory asFileReference
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> removeAllConnections [

	(UIManager default confirm: 'Really remove all imported connections?')
		ifFalse: [ ^ self ].
	self basicRemoveAllConnections
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> removeSelectedConnection [

	(UIManager default confirm: 'Really remove imported connection?')
		ifFalse: [ ^ self ].
	availableConnectionPresenter model remove:
		availableConnectionPresenter selectedItem
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

	^ self class shortPathFor: filePath
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
