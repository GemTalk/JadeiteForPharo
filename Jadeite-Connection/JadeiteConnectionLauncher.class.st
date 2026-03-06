Class {
	#name : 'JadeiteConnectionLauncher',
	#superclass : 'JadeiteSessionPresenter',
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
		'lastConnection',
		'lastImportedFileName',
		'availableConnectionPresenter',
		'displayFullPath',
		'portText',
		'selectedProfile',
		'connectionBox',
		'nonConnectionBox',
		'setClientLibrariesPathButton'
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
	self importedConnections
		add: filePath;
		reSort
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

	^ ImportedConnections ifNil: [
			  ImportedConnections := SortedCollection sortBlock:
				                         self defaultConnectionSortBlock ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> importedConnections: connections [
	"for testing only"

	ImportedConnections := connections
]

{ #category : 'class initialization' }
JadeiteConnectionLauncher class >> initialize [

	LastImportDirectory := FileSystem workingDirectory pathString
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> lastImportDirectory [

	^ LastImportDirectory ifNil: [
		  LastImportDirectory := FileSystem workingDirectory pathString ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher class >> lastImportDirectory: pathString [

	LastImportDirectory := pathString
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

{ #category : 'connections' }
JadeiteConnectionLauncher >> addFileToAvailableConnections: fileRef [

	availableConnectionPresenter addIfAbsent: fileRef pathString.
	availableConnectionPresenter model collection reSort.
	availableConnectionPresenter selection: fileRef pathString
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
	availableConnectionPresenter whenBuiltDo: [ "not yet sure why just adding the style was no longer good enough"
			availableConnectionPresenter adapter widget color:
				JadeiteApplication defaultBackgroundColor ]
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> availableConnectionPresenter [

	^ availableConnectionPresenter
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicExportProfile: fileRef [

	| profileCopy ws |
	fileRef basename first = $. ifTrue: [
			UIManager default alert:
				'Cannot export profile to file starting with ''.'''.
			^ self ].
	ws := fileRef writeStream.
	[
		profileCopy := JadeiteGCIConnectionProfile new.
		self populate: profileCopy. "don't want to export the connection"
		ws nextPutAll: (STON toString: profileCopy).
		ws flush ] ensure: [ ws close ].
	self resetChangedTextFields.
	self basicImportProfileFromFileReference: fileRef
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicImportProfile: connectionProfile [

	self clearConnectionSubscriptions.
	selectedProfile := connectionProfile.
	self populateTextFields.
	self resetChangedTextFields.
	self connectConnection
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicImportProfileDirectory: directoryRef [

	| fileRefs |
	self class lastImportDirectory: directoryRef asAbsolute asText.
	fileRefs := directoryRef files asSortedCollection.
	fileRefs do: [ :fileRef |
		[ self basicImportProfileFromFileReference: fileRef ]
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
JadeiteConnectionLauncher >> basicImportProfileFromFileReference: fileRef [

	| connectionProfile |
	fileRef basename first = $. ifTrue: [ ^ self ].
	self class addImportedConnection: fileRef pathString.
	connectionProfile := STON fromString: fileRef contents.
	self basicImportProfile: connectionProfile.
	self addFileToAvailableConnections: fileRef.
	^ connectionProfile
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> basicImportProfileFromPath: path [

	[ self basicImportProfileFromFileReference: FileReference / path ]
		on: Error
		do: [ :ex |
			| ws |
			ws := WriteStream on: String new.
			ws
				nextPutAll: 'Error importing file:';
				space;
				nextPutAll: path;
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

	| observable |
	observable := self connectionProfile observablePropertyNamed:
		              #connection.
	observable subscriptions do: [ :subscription |
		observable unsubscribe: subscription ].
	^ observable subscriptions: OrderedCollection new
]

{ #category : 'constants' }
JadeiteConnectionLauncher >> clientLibraryHelpMessage [

	^ 'The Client Libraries Path must point to a directory on the client in which the GemStone server shared libraries are located. Jadeite expects a directory structure with the shared libraries under clientLibsDir/version/64bit/. 
Clientlibs can be downloaded from the GemTalk website; the zip contains a folder with the version number, which can be copied into your clientlibs directory.
The path text may be manually entered or set using a file dialog by pressing ''Set Client Libraries Path''.'
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
	pathText adapter widget text isEmpty ifTrue: [
			self uiManager alert: 'Client Libraries Path must be set'.
			self setClientLibrariesPath ifNil: [ ^ self ] ].
	JadeiteGCIConnectionProfile clientLibrariesPath:
		pathText adapter widget text asString. "spec doesn't respect typed changes sometimes so go to morphic"

	self populateConnectionProfile.
	[
		self connectionProfile connectWithPostConnect: [
				self gciSession: GciSession current.
				self updateCaption ] ]
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
					ifFalse: [ ex return ] ]
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
				self installImportedConnection: selection selectedItem ] ].
	pathText whenSubmitDo: [ :newPath |
		pathText adapter widget hasUnacceptedEdits: false ].
	SystemAnnouncer uniqueInstance weak
		when: UIThemeChanged
		send: #themeChanged
		to: self
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> connection [

	^self connectionProfile connection
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectionProfile [

	^JadeiteConnectionProfile connectionProfile
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> connectionProfile: aProfile [

	JadeiteConnectionProfile connectionProfile: aProfile
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> copyConnection [
	"a copy is essentially a do nothing operation"

	Clipboard clipboardText:
		(STON toString: JadeiteConnectionProfile connectionProfile).
	UIManager default inform: 'Jadeite connection copied'
]

{ #category : 'connections' }
JadeiteConnectionLauncher >> defaultExportName [
	"note that we use the underlying morphic widget
	as the spec presenter won't have unsaved changes"

	| userString stoneString versionString |
	stoneString := stoneText adapter widget text asString.
	versionString := versionText adapter widget text asString.
	userString := userText adapter widget text asString.
	^ stoneString , '_' , versionString , '_' , userString , '.txt'
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

	self connectionProfile disconnect.
	self gciSession: nil.
	self updateCaption
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

{ #category : 'accessing' }
JadeiteConnectionLauncher >> hostText [

	^ hostText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> hostText: anObject [

	hostText := anObject
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

	nonConnectionBox
		add: (self newLabel
				 displayBold: [ true ];
				 label: 'Imported Connections List:')
		height: 30.
	availableConnectionPresenter := JadeiteListPresenter new
		                                display: [ :filePath |
				                                displayFullPath value
					                                ifTrue: [ filePath ]
					                                ifFalse: [
						                                self shortPathFor: filePath ] ];
		                                contextMenu:
			                                self initializeConnectionsMenu.
	nonConnectionBox add: availableConnectionPresenter.
	availableConnectionPresenter model:
		((ListModel newSorted: self class defaultConnectionSortBlock)
			 addAll: self class importedConnections;
			 yourself)
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

	| clientLibsBox pathBox |
	clientLibsBox := SpBoxLayout newVertical.
	clientLibsBox add: (self newLabel label: 'Client Libraries Path:').

	pathBox := SpBoxLayout newHorizontal.
	pathText := JadeiteTextInputFieldPresenter new.
	pathBox add: pathText.
	pathBox
		add: (self newButton
				 icon: (self iconNamed: #smallQuestion);
				 action: [
						 self uiManager
							 alert: self clientLibraryHelpMessage
							 title: 'Jadeite Client Library Help' ])
		withConstraints: [ :constraints | constraints width: 25 ].
	clientLibsBox add: pathBox.

	setClientLibrariesPathButton := self newButton
		                                label: 'Set Client Libraries Path';
		                                icon: (self iconNamed: #smallHome);
		                                action: [
			                                self setClientLibrariesPath ].
	clientLibsBox
		add: setClientLibrariesPathButton
		withConstraints: [ :constraints1 | constraints1 padding: 5 ].
	nonConnectionBox
		add: clientLibsBox
		withConstraints: [ :constraints | constraints height: 90 ]
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

	connectionBox add: (self newLabel label: 'Host:').
	hostText := JadeiteTextInputFieldPresenter new.
	connectionBox add: hostText
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
						  subMenu: self initializeAboutMenu ];
				  addItem: [ :item |
					  item
						  name: 'Tools';
						  subMenu: self initializeToolsMenu ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeNetldiPresenter [

	connectionBox add: (self newLabel label: 'Netldi:').
	netldiText := JadeiteTextInputFieldPresenter new.
	connectionBox add: netldiText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePasswordPresenter [

	connectionBox add: (self newLabel label: 'Password:').
	passwordText := JadeiteTextInputFieldPresenter new bePassword.
	connectionBox add: passwordText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePortNumber [

	connectionBox add:
		(self newLabel label: 'RSR Listening Port (leave blank for wildcard port)').
	portText := JadeiteTextInputFieldPresenter new.
	connectionBox add: portText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePresenter [

	super initializePresenter.
	selectedProfile := JadeiteConnectionProfile connectionProfile copy.
	self populateTextFields.
	self enableButtons
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializePresenters [

	| box label connectionLabelBox nonConnectionLabelBox |
	super initializePresenters.
	box := SpBoxLayout newHorizontal.
	connectionBox := SpBoxLayout newVertical.
	connectionLabelBox := SpBoxLayout newHorizontal hAlignCenter.
	label := self newLabel
		         displayBold: [ true ];
		         label: 'Client Connection';
		         help:
			         'The values in the left column can be exported to disk'.
	connectionLabelBox add: label.
	connectionBox add: connectionLabelBox.
	self initializeHostPresenter.
	self initializeStonePresenter.
	self initializeUserPresenter.
	self initializePasswordPresenter.
	self initializeVersionPresenter.
	self initializeNetldiPresenter.
	self initializePortNumber.
	box
		add: connectionBox
		withConstraints: [ :constraints | constraints padding: 5 ].
	nonConnectionBox := SpBoxLayout newVertical.
	connectionBox := SpBoxLayout newVertical.
	nonConnectionLabelBox := SpBoxLayout newHorizontal hAlignCenter.
	label := self newLabel
		         displayBold: [ true ];
		         label: 'Server Connection';
		         help: 'The values in the right column are not exported'.
	nonConnectionLabelBox add: label.
	nonConnectionBox add: nonConnectionLabelBox height: 30.
	self initializeClientLibPathPresenter.
	self initializeAvailableConnectionPresenter.
	box
		add: nonConnectionBox
		withConstraints: [ :constraints | constraints padding: 5 ].
	self layout add: box.
	self initializeButtons.
	self setFocusOrder
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeStonePresenter [

	connectionBox add: (self newLabel label: 'Stone:').
	stoneText := JadeiteTextInputFieldPresenter new.
	connectionBox add: stoneText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeToolsMenu [

	^ self newMenu
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Windows Browser';
						  action: [ self openWindowsBrowser ] ] ];
		  addGroup: [ :group |
			  group addItem: [ :item |
				  item
					  name: 'Jadeite Help';
					  action: [ self openJadeiteHelpWebPage ] ] ] yourself
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeUserPresenter [

	connectionBox add: (self newLabel label: 'User:').
	userText := JadeiteTextInputFieldPresenter new.
	connectionBox add: userText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeVersionPresenter [

	connectionBox add: (self newLabel label: 'Version:').
	versionText := JadeiteTextInputFieldPresenter new.
	connectionBox add: versionText
]

{ #category : 'initialization' }
JadeiteConnectionLauncher >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 70 @ 40 * StandardFonts defaultFont pointSize;
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

	| fileRef |
	fileRef := filePath asFileReference.
	fileRef exists ifFalse: [ ^ self ].
	self basicImportProfileFromFileReference: fileRef.
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

{ #category : 'showing' }
JadeiteConnectionLauncher >> open [

	| jadeiteWindow |
	jadeiteWindow := self asWindow open.
	self showNotWait.
	^ jadeiteWindow
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> openWindowsBrowser [

	JadeiteWindowsBrowser show
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
		host: hostText adapter widget text asString;
		stone: stoneText adapter widget text asString;
		user: userText adapter widget text asString;
		password: passwordText adapter widget text asString;
		version: versionText adapter widget text asString;
		netldi: netldiText adapter widget text asString;
		port: portText adapter widget text asString
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populateConnectionProfile [

	self populate: self connectionProfile
		
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> populateTextFields [

	hostText text: selectedProfile host.
	stoneText text: selectedProfile stone.
	userText text: selectedProfile user.
	passwordText text: selectedProfile password.
	versionText text: selectedProfile version.
	netldiText text: selectedProfile netldi.
	pathText text: JadeiteGCIConnectionProfile clientLibrariesPath.
	selectedProfile port
		ifNil: [ portText text: String new ]
		ifNotNil: [ portText text: selectedProfile port ]
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
	availableConnectionPresenter remove:
		availableConnectionPresenter selectedItem
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> resetChangedTextFields [

	self hostText adapter widget accept.
	self hostText adapter widget hasUnacceptedEdits: false.
	self versionText adapter widget accept.
	self versionText adapter widget hasUnacceptedEdits: false.
	self stoneText adapter widget accept.
	self stoneText adapter widget hasUnacceptedEdits: false.
	self userText adapter widget accept.
	self userText adapter widget hasUnacceptedEdits: false.
	self passwordText adapter widget accept.
	self passwordText adapter widget hasUnacceptedEdits: false.
	self netldiText adapter widget accept.
	self netldiText adapter widget hasUnacceptedEdits: false.
	self portText adapter widget accept.
	self portText adapter widget hasUnacceptedEdits: false
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> setClientLibrariesPathButton [

	^ setClientLibrariesPathButton
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> setClientLibrariesPathButton: anObject [

	setClientLibrariesPathButton := anObject
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
		add: setClientLibrariesPathButton;
		add: connectButton;
		add: disconnectButton 
		
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> shellName [

	^ 'Jadeite Connection Launcher'
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

{ #category : 'connections' }
JadeiteConnectionLauncher >> suggestedExportName [

	availableConnectionPresenter selectedItem ifNotNil: [ :sel |
		^ sel asFileReference basename ].
	^ self defaultExportName
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> textFieldPresenters [

	| oc |
	oc := OrderedCollection new.
	oc
		add: hostText;
		add: stoneText;
		add: userText;
		add: passwordText;
		add: versionText;
		add: netldiText;
		add: portText;
		add: pathText.
	^ oc
]

{ #category : 'events' }
JadeiteConnectionLauncher >> themeChanged [

	PharoLightTheme isCurrent
		ifTrue: [ self updateWidgetLightThemeColors ]
		ifFalse: [ self updateWidgetDarkThemeColors ]
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> toggleFullPathDisplay [

	displayFullPath := displayFullPath not.
	availableConnectionPresenter invalidate. 
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedHost [

	^ hostText adapter widget text asString
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedNetldi [

	^ netldiText adapter widget text asString
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedPassword [

	^ passwordText adapter widget text asString
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedPath [

	^ pathText adapter widget text asString
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedStone [

	^ stoneText adapter widget text asString
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedUser [

	^ userText adapter widget text asString
]

{ #category : 'morphic widget texts' }
JadeiteConnectionLauncher >> unsavedVersion [

	^ versionText adapter widget text asString
]

{ #category : 'actions' }
JadeiteConnectionLauncher >> updateCaption [

	self caption: (self gciSession
			 ifNil: [ self shellName ]
			 ifNotNil: [ self gciSession titleBarFor: self shellName ])
]

{ #category : 'updates' }
JadeiteConnectionLauncher >> updateWidgetDarkThemeColors [
	"yuck - why is this necessary?"

	self textFieldPresenters do: [ :text |
			text adapter widget color: self theme backgroundColor.
			text adapter widget scrollPane color: self theme backgroundColor.
			text adapter widget scrollPane textArea color:
				self theme backgroundColor.
			text adapter widget changed ].
	setClientLibrariesPathButton adapter widget labelMorph morph
		textColor: Color white.
	setClientLibrariesPathButton adapter widget changed.
	self window adapter widget borderColor: self theme jadeiteBorderColor.
	self window adapter widget borderWidth: self theme jadeiteBorderWidth
]

{ #category : 'updates' }
JadeiteConnectionLauncher >> updateWidgetLightThemeColors [
	"yuck - why is this necessary?"

	self textFieldPresenters do: [ :text |
			text adapter widget color:
				JadeiteApplication defaultBackgroundColor.
			text adapter widget scrollPane color:
				JadeiteApplication defaultBackgroundColor.
			text adapter widget scrollPane textArea color:
				JadeiteApplication defaultBackgroundColor.
			text adapter widget changed ].
	availableConnectionPresenter adapter widget color:
		JadeiteApplication defaultBackgroundColor.
	availableConnectionPresenter adapter widget changed.
	setClientLibrariesPathButton adapter widget labelMorph morph textColor: Color black.
	setClientLibrariesPathButton adapter widget changed
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
JadeiteConnectionLauncher >> validLibPathReference [

	| libPathRef |
	libPathRef := JadeiteGCIConnectionProfile clientLibrariesPath
		              asFileReference.
	[ libPathRef exists ] whileFalse: [ libPathRef := libPathRef parent ].
	^ libPathRef
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> versionText [

	^ versionText
]

{ #category : 'accessing' }
JadeiteConnectionLauncher >> versionText: anObject [

	versionText := anObject
]
