Class {
	#name : 'JadeiteConsole',
	#superclass : 'JadeitePresenterWithAutoCommitButton',
	#traits : 'JadeiteProjectsTrait + JadeiteToolbarTrait + JadeiteMethodsTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteProjectsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteMethodsTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'projectListPresenter',
		'isTranscriptInstalled',
		'areBreakpointsEnabled',
		'autoCompleteEnabled',
		'transactionModePresenter',
		'lastKnownTransaction',
		'cardContainer',
		'toolbar',
		'transcriptService',
		'consoleTabs',
		'toolbarPresenter',
		'transcriptPresenter',
		'layoutBox',
		'projectColumns'
	],
	#classVars : [
		'ColumnWidths',
		'CurrentConsole'
	],
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'accessing' }
JadeiteConsole class >> columnWidths [
	"make the column widths sticky for convenience"

	^ ColumnWidths ifNil: [ ColumnWidths := self defaultColumnWidths ]
]

{ #category : 'accessing' }
JadeiteConsole class >> columnWidths: anArray [

	ColumnWidths := anArray
]

{ #category : 'accessing' }
JadeiteConsole class >> currentConsole [

	^ CurrentConsole
]

{ #category : 'accessing' }
JadeiteConsole class >> currentConsole: anObject [

	CurrentConsole := anObject
]

{ #category : 'defaults' }
JadeiteConsole class >> defaultColumnWidths [

	^ { 200. 100. 100. nil }
]

{ #category : 'actions' }
JadeiteConsole class >> setColumnWidths [

	self currentConsole ifNotNil: [ :console |
		self columnWidths:
			(console projectColumns collect: [ :column | column width ]) ]
]

{ #category : 'as yet unclassified' }
JadeiteConsole class >> showOnSession: aGciSession [
	| theConsole |
	theConsole := super showOnSession: aGciSession.
	theConsole setTransactionModeFromServer.
	^theConsole
]

{ #category : 'events' }
JadeiteConsole >> abortedTransaction [

	self updateProjectsOnCompletion: [  ].
	self todo: [ self displayLastKnownCommitOrAbort ].
	self projectListPresenter invalidate
]

{ #category : 'updates' }
JadeiteConsole >> addNoneProject [
	"project list does not add a none project"

	
]

{ #category : 'initialization' }
JadeiteConsole >> addStyle: aString [

	super addStyle: aString.
	waitIndicator addStyle: aString.
	transcriptPresenter addStyle: aString.
	layoutBox ifNotNil: [ layoutBox adapter addStyle: aString ].
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> additionalAccelerators [
	^super additionalAccelerators , #(#(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> areBreakpointsEnabled [
	^areBreakpointsEnabled
]

{ #category : 'accessing' }
JadeiteConsole >> autoCommit: aBoolean [

	gciSession autoCommit contents: aBoolean
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> autoCompleteEnabled [
	"for testing"

	^autoCompleteEnabled value
]

{ #category : 'accessing' }
JadeiteConsole >> autoCompleteEnabled: boolean [
	"for testing"

	JadeiteSearch autoCompleteEnabled: boolean.
	autoCompleteEnabled value: boolean
]

{ #category : 'actions' }
JadeiteConsole >> basicFileInServerFile: filePath [

	| service |
	service := RowanFileServiceClient new
		           path: filePath;
		           session: self gciSession.
	service fileInOnCompletion: [
		UIManager default inform: 'FileIn complete - ' , filePath ]
]

{ #category : 'actions' }
JadeiteConsole >> basicOpenServerFile: filePath [

	^ JadeiteServerFileWorkspaceApplication
		  showOnSession: gciSession
		  path: filePath
]

{ #category : 'actions' }
JadeiteConsole >> basicSetFont: newFont [
	JadeitePreferences displayFontFrom: newFont.
	JadeitePreferences current currentFont: newFont
]

{ #category : 'actions' }
JadeiteConsole >> basicSetTextFont: newFont [
	JadeiteScintillaView allInstances do: [:scintillaView | scintillaView font: newFont].
	JadeitePreferences current currentTextFont: newFont
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> basicTransactionMode: aSymbol [
	self parentPresenter transactionMode: aSymbol session: gciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> beginTransaction [
	self parentPresenter beginTransaction
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> browseBreakpointList [
	^JadePresenter browseBreakpointsIn: self gciSession
]

{ #category : 'queries' }
JadeiteConsole >> browseClass [
	^JadePresenter browseClassIn: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> browseJadeiteLogs [
	^JadeiteLoggerShell showOnSession: self gciSession
]

{ #category : 'actions' }
JadeiteConsole >> browseJadeitePrefs [
	^JadeitePreferencesWorkspace browseJadeitePrefs: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> browseUsers [
	^AllUsersShell showOnSession: gciSession.

]

{ #category : 'accessing' }
JadeiteConsole >> browserOpener [
	"dumb name but tool that opens the browser"

	^ self
]

{ #category : 'testing' }
JadeiteConsole >> canDiscardEdits [

	^true
]

{ #category : 'testing' }
JadeiteConsole >> canDiscardSelectionEdits [

	^ true
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> cardContainer [
	^cardContainer
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> cardContainer: anObject [
	cardContainer := anObject
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> colorForCompileError [
	| newColor |
	newColor := ColorDialog showModalOn: JadeiteTextStyles default colorForNoEdits.
	newColor ifNotNil: [JadeiteTextStyles default colorForCompileError: newColor]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> colorForNoEdits [
	| newColor |
	newColor := ColorDialog showModalOn: JadeiteTextStyles default colorForNoEdits.
	newColor ifNotNil: [JadeiteTextStyles default colorForNoEdits: newColor]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> colorForUnsavedEdits [
	| newColor |
	newColor := ColorDialog showModalOn: JadeiteTextStyles default colorForUnsavedEdits.
	newColor ifNotNil: [JadeiteTextStyles default colorForUnsavedEdits: newColor]
]

{ #category : 'accessing' }
JadeiteConsole >> columnWithAspect: aspect title: title [

	| column |
	column := JadeiteConsoleTableColumn
		          title: title
		          evaluated: [ :projectService |
			          (projectService perform: aspect)
				          ifNil: [ String new ]
				          ifNotNil: [ :value | value asString ] ].
	column
		displayBold: [ :projectService | projectService isDirty ];
		displayItalic: [ :projectService | projectService isDiskDirty == true ];
		displayColor: [ :projectService |
			projectService isSkew
				ifTrue: [ Color red ]
				ifFalse: [ Smalltalk ui theme textColor ] ].
	^ column
]

{ #category : 'transactions' }
JadeiteConsole >> committedTransaction [
	self displayLastKnownCommitOrAbort
]

{ #category : 'initialization' }
JadeiteConsole >> connectPresenters [ 

	super connectPresenters. 
	self application
		when: #abortedTransaction
		send: #abortedTransaction
		to: self.
	self application
		when: #committedTransaction
		send: #committedTransaction
		to: self.
	SystemAnnouncer uniqueInstance weak 
		when: UIThemeChanged 
		send: #themeChanged
		to: self
]

{ #category : 'accessing' }
JadeiteConsole >> connection [

	^self gciSession library
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> createNewProject [
	^projectListPresenter createNewProject
]

{ #category : 'accessing' }
JadeiteConsole >> currentPackage [

	^ self currentProject ifNotNil: [ :projectService |
		  projectService packageServices
			  detect: [ :packageService | packageService isCurrent ]
			  ifNone: [  ] ]
]

{ #category : 'accessing' }
JadeiteConsole >> currentProject [

	^ self projectListPresenter list
		  detect: [ :projectService | projectService isCurrent ]
		  ifNone: [  ]
]

{ #category : 'defaults' }
JadeiteConsole >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'defaults' }
JadeiteConsole >> defaultWindowPresenterClass [
		
	^ JadeiteGlobalWindowPresenter
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> displayLastKnownCommitOrAbort [
	| writeStream |
	writeStream := WriteStream on: String new.
	TimeStamp current printOn: writeStream format: 'M/d/yyyy h:mm:ss tt'.
	lastKnownTransaction value: 'Last Known Commit or Abort: ' , writeStream contents
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> editLoadSpecFromFile [
	^JadeiteLoadSpecEditor editLoadSpecFromFileInSession: gciSession
]

{ #category : 'actions' }
JadeiteConsole >> fileInServerFile [

	| filePath |
	RowanServiceUpdater current critical: [
		filePath := JadeiteServerFileSelectorDialog
			            showOnSession: gciSession
			            defaultPath:
			            JadePresenter rowanProjectsHomeEnvVarString.
		filePath ifNotNil: [ self basicFileInServerFile: filePath ] ]
]

{ #category : 'actions' }
JadeiteConsole >> findClassNamed: selection [

	| classService browser |
	browser := JadeiteBrowser new owner: self.
	browser postOpenBlock: [
		classService := RowanClassService new name: selection.
		self updateService: classService onCompletion: [
			browser activePresenter
				updateAfterFindClass: classService
				methodService: nil
				onCompletion: [  ] ] ].
	self basicOpenBrowser: browser
]

{ #category : 'actions' }
JadeiteConsole >> findClassService: classService [

	| browser browserPresenter |
	classService ifNil: [ ^ self ].
	browser := JadeiteBrowser new owner: self.
	browser postOpenBlock: [
		browser ifNotNil: [
			browser activePresenter
				updateAfterFindClass: classService
				methodService: nil
				onCompletion: [  ] ] ].
	browserPresenter := self basicOpenBrowser: browser
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> flipAutocomplete [
	| newValue confirmedValue |
	newValue := JadeiteSearch autoCompleteEnabled not.
	confirmedValue := JadeiteSearch confirmAutoCompleteEnabled: newValue in: self gciSession.
	"confirmedValue results in no change if user declines to continue"
	autoCompleteEnabled value: confirmedValue
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> flipBreakpointsEnabled [
	| answeringService | 
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: areBreakpointsEnabled value not session: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> flipDebugger [
	JadeiteDebugger debuggerClass == JadeiteDebugger
		ifTrue: [JadeiteDebugger debuggerClass: JadeDebugger]
		ifFalse: [JadeiteDebugger debuggerClass: JadeiteDebugger]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> flipLogging [
	RowanServiceUpdater current isLogging: RowanServiceUpdater current isLogging not
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> flipTranscript [
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService flipTranscriptIn: self gciSession.
	isTranscriptInstalled := isTranscriptInstalled value: isTranscriptInstalled value not
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> gciSession [

	^gciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> gciSession: aGciSession [
	"don't do the force logout. We'll close us ourselves"

	gciSession := aGciSession.
	gciSession
		when: #logoutRequested:
			send: #logoutRequested:
			to: self;
		when: #logoutPending
			send: #exit
			to: self;
		yourself.
]

{ #category : 'actions' }
JadeiteConsole >> gotoJfPGitHubProject [

	WebBrowser openOn: 'https://github.com/GemTalk/JadeiteForPharo'
]

{ #category : 'actions' }
JadeiteConsole >> gotoRowanGitHubProject [

	WebBrowser openOn: 'https://github.com/GemTalk/Rowan'
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> hidePackageGroups [
	^JadePresenter hidePackageGroups
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> hidePackageList [
	^JadePresenter hidePackageList
]

{ #category : 'initialization' }
JadeiteConsole >> initialProjectDisplayColumns [

	| columns |
	columns := OrderedCollection new.
	self projectDisplayAttributes keysAndValuesDo: [ :aspect :title |
		columns add: (self columnWithAspect: aspect title: title) ].
	^ columns
]

{ #category : 'initialization' }
JadeiteConsole >> initializeAutoCommit [

	self gciSession initializeAutoCommitRefreshing: self
]

{ #category : 'initialization' }
JadeiteConsole >> initializeBrowseMenu [

	^ self newBrowseMethodsConsoleMenu
		  addItem: [ :item |
			  item
				  name: 'Find Class ...';
				  shortcut: $f shift ctrl;
				  action: [ self findClass ] ];
		  addItem: [ :item |
			  item
				  name: 'Find Class References ...';
				  shortcut: $r shift ctrl;
				  action: [ self findClassReferences ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConsole >> initializeFileMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Open Server File ...';
				  action: [ self openServerFile ] ];
		  addItem: [ :item |
			  item
				  name: 'File In Server File ...';
				  action: [ self fileInServerFile ];
				  enabled: [ self isCurrentProjectAndPackageSet ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConsole >> initializeHelpMenu [

	^ self newMenu
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Jadeite for Pharo GitHub Project';
						  action: [ self gotoJfPGitHubProject ] ];
				  addItem: [ :item |
					  item
						  name: 'Rowan GitHub Project';
						  action: [ self gotoRowanGitHubProject ] ] ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Git Commit Ids';
						  action: [ self openCommitIdWindow ] ];
				  addItem: [ :item |
					  item
						  name: 'Jadeite Help';
						  action: [ self openJadeiteHelpFile ] ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConsole >> initializeKeyBindings: aWindowPresenter [

	aWindowPresenter
		bindKeyCombination: $f shift ctrl toAction: [ self findClass ];
		bindKeyCombination: $r shift ctrl
		toAction: [ self findClassReferences ]
]

{ #category : 'initialization' }
JadeiteConsole >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'File';
						  subMenu: self initializeFileMenu ];
				  addItem: [ :item |
					  item
						  name: 'Browse';
						  subMenu: self initializeBrowseMenu ];
				  addItem: [ :item |
					  item
						  name: 'Help';
						  subMenu: self initializeHelpMenu ].
			  self addToolsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConsole >> initializePresenters [

	| waitBox |
	super initializePresenters.
	layoutBox := SpBoxLayout newVertical.
	self layout add: layoutBox.
	waitBox := self initializeWaitPresenter.
	layoutBox add: waitBox expand: false.
	consoleTabs := SpTabLayout new.
	self initializeProjectListPresenter: consoleTabs.
	self initializeTranscriptPresenter: consoleTabs.
	layoutBox add: consoleTabs.
	self initializeAutoCommitPresenter.
	lastKnownTransaction := self newStatusBar.
	self layout addLast: lastKnownTransaction expand: false
]

{ #category : 'initialization' }
JadeiteConsole >> initializeProjectListPresenter: tabs [

	| initialWidths |
	initialWidths := self class columnWidths.
	projectListPresenter := JadeiteTablePresenter new.
	projectColumns := self initialProjectDisplayColumns.
	1 to: projectColumns size do: [ :index |
		| column |
		column := projectColumns at: index.
		column width: (initialWidths at: index).
		projectListPresenter addColumn: column ].
	tabs add: projectListPresenter label: 'Projects'.
	self initializeProjectListMenu
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> initializeTransactionModeSettings [
	self transactionMode
		ifNil: 
			[self setTransactionModeFromServer	"should have already been set when window was created ... but just in case"]
]

{ #category : 'initialization' }
JadeiteConsole >> initializeTranscriptPresenter: tabs [

	tabs
		add: (transcriptPresenter := JadeiteTextDocument new _gciSession:
				                        self application gciSession)
		label: 'Transcript'.
	transcriptPresenter contextMenu: [
		SpMenuPresenter new addItem: [ :item |
			item
				name: 'Clear';
				action: [
					transcriptPresenter
						clearContent;
						hasUnacceptedEdits: false ];
				enabled: true ] ]
]

{ #category : 'initialization' }
JadeiteConsole >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 120 @ 50 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self initializeKeyBindings: aWindowPresenter.
	self updateCaption.
	aWindowPresenter whenClosedDo: [ self class currentConsole: nil ]
]

{ #category : 'actions' }
JadeiteConsole >> installTranscript [

	transcriptService := RowanTranscriptServiceClient new registerWith:
		                     gciSession library.
	transcriptService transcriptPresenter: transcriptPresenter. 
	transcriptService installTranscript.

]

{ #category : 'as yet unclassified' }
JadeiteConsole >> isBeginTransactionEnabled [
	^self parentPresenter isBeginTransactionEnabled
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> isCommitEnabled [
	^self parentPresenter isCommitEnabled
]

{ #category : 'testing' }
JadeiteConsole >> isCurrentProjectAndPackageSet [

	^ self currentProject notNil and: [ self currentPackage notNil ]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> isTranscriptInstalled [
	^isTranscriptInstalled value
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> isTranscriptInstalledValueHolder [
	^isTranscriptInstalled
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> jadeiteHelpFileCSSExtension [
	"for testing"

	^'.css'
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> jadeiteHelpFileExtension [
	^'.html'
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> jadeiteHelpFileName [
	^self jadeiteHelpFileNameRoot , self jadeiteHelpFileExtension
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> jadeiteHelpFileNameRoot [
	^'JadeiteHelp'
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> lastKnownTransaction [
	^lastKnownTransaction
]

{ #category : 'testing' }
JadeiteConsole >> okToChangeSelections [

	^true
]

{ #category : 'testing' }
JadeiteConsole >> okToClose [

	^true
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> onCloseRequested: boolValueHolder [
	| answer |
	self onPromptToSaveChanges: boolValueHolder.
	boolValueHolder value ifFalse: [^self].
	gciSession isNil ifTrue: [^self].
	gciSession isValidSession
		ifFalse: 
			[gciSession trigger: #forceJadeiteWindowClose.
			^self].
	gciSession logoutRequested
		ifFalse: 
			[boolValueHolder value: false.
			^self].
	(RowanAnsweringService new needsCommit: self gciSession)
		ifTrue: 
			[self shouldAskToCommitOnLogout
				ifTrue: 
					[answer := MessageBox new
								caption: 'Close Requested';
								confirmOrCancel: 'Commit current transaction?'.
					boolValueHolder value: (#(#yes #no) includes: answer).
					answer = #yes ifTrue: [gciSession commit]]].
	boolValueHolder value ifFalse: [^self].
	allSessionsPresenter aboutToClose.
	gciSession notNil
		ifTrue: 
			[| temp |
			JadePresenter
				stopListeningForSigAborts;
				resetSigAbortProcessEnablement;
				resetSigAbortProcessInterval.
			temp := gciSession.	"I'm getting closed so make sure session gets logged out"
			gciSession := nil.
			temp forceLogout]
]

{ #category : 'actions' }
JadeiteConsole >> openGitHubJadeiteProject [
	^JadePresenter openGitHubJadeiteProject
]

{ #category : 'actions' }
JadeiteConsole >> openGitHubRowanProject [
	^JadePresenter openGitHubRowanProject
]

{ #category : 'actions' }
JadeiteConsole >> openServerFile [

	| filePath |
	RowanServiceUpdater current critical: [
		filePath := JadeiteServerFileSelectorDialog 
			            showOnSession: gciSession
			            defaultPath:
			            JadePresenter rowanProjectsHomeEnvVarString.
		filePath ifNotNil: [ self basicOpenServerFile: filePath ] ]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> openSourceStyler [
	JadeiteScintillaView openSourceStyler
]

{ #category : 'accessing' }
JadeiteConsole >> postOpenBlock [

	"no postOpenBlock yet"
	^nil
]

{ #category : 'accessing' }
JadeiteConsole >> projectColumns [

	^ projectColumns
]

{ #category : 'accessing' }
JadeiteConsole >> projectDisplayAttributes [

	| attributes |
	attributes := OrderedDictionary new.
	attributes at: #displayName put: 'Project Name'.
	attributes at: #sha put: 'Loaded Sha'.
	attributes at: #branch put: 'Branch'.
	attributes at: #projectUrl put: 'Project URL'.
	^ attributes
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> projectListPresenter [
	^projectListPresenter
]

{ #category : 'actions' }
JadeiteConsole >> projectListUpdated [
	"no other lists to clear"
]

{ #category : 'updates' }
JadeiteConsole >> refreshProjectInfoTab [
]

{ #category : 'registration' }
JadeiteConsole >> registerPresentersForUpdates [
	RowanServiceUpdater current
		register: self selector: #autoCommitUpdate:;
		register: self selector: #breakpointSettingChanged:;
		register: self selector: #updateSymbols:;
		register: self selector: #addCachedSymbols:;
		register: projectListPresenter
		selector: #projectsUpdate:browser:
		browser: self;
		register: projectListPresenter selector: #removedProject:;
		register: projectListPresenter selector: #newProject:;
		register: projectListPresenter selector: #removed:;
		register: projectListPresenter selector: #projectsUpdate:;
		register: projectListPresenter selector: #resetCurrentProjectPackage

]

{ #category : 'as yet unclassified' }
JadeiteConsole >> remoteAutoCommit [

	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #autoCommit;
		commandArgs: Array new.
	self issueCommand: answeringService onCompletion: [].
	^ answeringService answer
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> resetColors [
	JadeiteTextStyles default resetColors
]

{ #category : 'actions' }
JadeiteConsole >> resetCurrentProjectFor: aService [

	projectListPresenter items do: [ :projectService |
		projectService = aService
			ifTrue: [ projectService isCurrent: aService isCurrent ]
			ifFalse: [ projectService isCurrent: false ] ].
	projectListPresenter adapter widget simulateClick "not sure why, but console won't redraw correctly. this seems to work sometimes. "
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> resetFonts [
	JadeitePreferences current resetFont.
	JadeitePreferences current resetTextFont
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> resetTransactionModeRadioButtons [
	#(#autoBegin #manualBegin #transactionless)
		do: [:aSymbol | (transactionModePresenter view viewNamed: aSymbol asString) displayValue: false].
	(transactionModePresenter view viewNamed: self transactionMode asString) displayValue: true
]

{ #category : 'accessing' }
JadeiteConsole >> selectedPackageServices [

	^Array new
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> setFont [
	| newFont currentFont |
	currentFont := JadeitePreferences current currentFont ifNil: [JadeitePreferences defaultFont].
	newFont := FontDialog showModalOn: currentFont.
	newFont ifNil: [^self].
	self basicSetFont: newFont
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> setRowanProjectsHome [
	self setRowanProjectsHome: gciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> setRowanProjectsHome: aGciSession [
	| varString |
	varString := JadeiteServerFileSelectorDialog showOnSession: aGciSession
				defaultPath: JadePresenter homeEnvVarString.
	varString isNil ifTrue: [^MessageBox notify: '$ROWAN_PROJECTS_HOME was not set.'].
	aGciSession
		executeString: '(System gemEnvironmentVariable: ''ROWAN_PROJECTS_HOME'' put: ''' , varString , ''')'
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> setRowanProjectsHomeIfNecessary: aGciSession [
	| varSet shouldSet |
	varSet := aGciSession
				executeString: '(System gemEnvironmentVariable: ''ROWAN_PROJECTS_HOME'') notNil'.
	varSet ifTrue: [^self].
	shouldSet := MessageBox
				confirm: '$ROWAN_PROJECTS_HOME is not set. Would you like to set it? (Failure to do so will result in Jadeite errors)'.
	shouldSet ifFalse: [^self].
	self setRowanProjectsHome: aGciSession
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> setTextFont [
	| newFont currentFont |
	currentFont := JadeitePreferences current currentTextFont
				ifNil: [JadeitePreferences defaultTextFont].
	newFont := FontDialog showModalOn: currentFont.
	newFont ifNil: [^self].
	self basicSetTextFont: newFont
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> setTransactionModeFromServer [
	"Only run this when opening the transcript.  We don't use the service mutex so it's mildly dangerous."
	self parentPresenter transactionMode: (gciSession executeString: 'System transactionMode').
	self resetTransactionModeRadioButtons.
	self parentPresenter inTransaction: (gciSession executeString: 'System inTransaction').
	self parentPresenter resetListeningForSigAborts: gciSession
]

{ #category : 'constants' }
JadeiteConsole >> shellName [
	^'Jadeite Console'
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> shouldAskToCommitOnLogout [
	^self transactionMode = #autoBegin
		or: [self transactionMode = #manualBegin and: [self parentPresenter inTransaction]]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> showPackageList [
	^JadePresenter showPackageList
]

{ #category : 'events' }
JadeiteConsole >> themeChanged [
	"do any repair work from lousy pharo theme transitioning"

	self adapter applyStyle
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> togglePackageList [
	JadePresenter packageListVisible
		ifTrue: 
			[JadePresenter packageListVisible: false.
			JadePresenter hidePackageList]
		ifFalse: 
			[JadePresenter packageListVisible: true.
			JadePresenter showPackageList]
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> toolbarPresenter [
	^toolbarPresenter
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> transactionMode [
	^self parentPresenter transactionMode
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> transactionMode: aSymbol [
	"It seems Dolphin should have an event like 'aboutToChangeRadioButton' to avoid having to muck with the low level view"

	(MessageBox confirm: 'Switching transaction modes will cause an abort. Continue?')
		ifTrue: 
			[self basicTransactionMode: aSymbol.
			JadePresenter trigger: #abortedTransaction]
		ifFalse: [self resetTransactionModeRadioButtons]
]

{ #category : 'updates' }
JadeiteConsole >> updateProjectPackagesOnCompletion: anObject [
	"no op for project list"
]
