Class {
	#name : 'JadeiteConsole',
	#superclass : 'JadeitePresenterWithAutoCommitButton',
	#traits : 'JadeiteProjectsTrait + JadeiteToolbarTrait + JadeiteMethodsTrait + JadeiteFindClassTrait',
	#classTraits : 'JadeiteProjectsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteMethodsTrait classTrait + JadeiteFindClassTrait classTrait',
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

{ #category : 'events' }
JadeiteConsole >> abortedTransaction [

	self updateProjectsOnCompletion: [
		self projectListPresenter invalidate ]
]

{ #category : 'initialization' }
JadeiteConsole >> addStyle: aString [

	super addStyle: aString.
	waitIndicator addStyle: aString.
	transcriptPresenter addStyle: aString.
	layoutBox ifNotNil: [ layoutBox adapter addStyle: aString ].
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
JadeiteConsole >> basicOpenServerFile: filePath [

	^ JadeiteServerFileWorkspaceApplication
		  showOnSession: gciSession
		  path: filePath
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

{ #category : 'initialization' }
JadeiteConsole >> clearTranscript [

	transcriptPresenter
		clearContent;
		hasUnacceptedEdits: false
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

{ #category : 'initialization' }
JadeiteConsole >> connectPresenters [

	super connectPresenters.
	self application
		when: #committedTransaction
		send: #committedTransaction
		to: self.
	SystemAnnouncer uniqueInstance weak
		when: UIThemeChanged
		send: #themeChanged
		to: self.
	transcriptPresenter announcer
		when: JadeiteCancelAnnouncement
		send: #clearTranscript
		to: self
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
JadeiteConsole >> editLoadSpecFromFile [
	^JadeiteLoadSpecEditor editLoadSpecFromFileInSession: gciSession
]

{ #category : 'actions' }
JadeiteConsole >> findClassNamed: className [

	| browser |
	browser := JadeiteBrowser new owner: self.
	browser postOpenBlock: [ browser findClassNamed: className ].
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

{ #category : 'accessing' }
JadeiteConsole >> gciSession: aGciSession [
	"don't do the force logout. We'll close us ourselves"

	gciSession := aGciSession.
	gciSession
		when: #logoutRequested: send: #logoutRequested: to: self;
		when: #logoutPending send: #exit to: self.
	self gciSession announcer
		when: JadeiteCurrentProjectPackageUpdated
		send: #updateCurrentProjectPackageDisplay:
		to: self;
		when: #abortedTransaction send: #abortedTransaction to: self
]

{ #category : 'actions' }
JadeiteConsole >> gotoJfPGitHubProject [

	WebBrowser openOn: 'https://github.com/GemTalk/JadeiteForPharo'
]

{ #category : 'actions' }
JadeiteConsole >> gotoRowanGitHubProject [

	WebBrowser openOn: 'https://github.com/GemTalk/Rowan'
]

{ #category : 'initialization' }
JadeiteConsole >> initialProjectDisplayColumns [

	| columns |
	columns := OrderedCollection new.
	self projectDisplayAttributes keysAndValuesDo: [ :aspect :title |
		columns add: (self columnWithAspect: aspect title: title) ].
	^ columns
]

{ #category : 'menus' }
JadeiteConsole >> initializeAboutMenu [

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
			  group addItem: [ :item |
				  item
					  name: 'Git Commit Ids';
					  action: [ self openCommitIdWindow ] ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteConsole >> initializeAutoCommit [

	self gciSession initializeAutoCommitRefreshing: self
]

{ #category : 'menus' }
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

{ #category : 'menus' }
JadeiteConsole >> initializeFileMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Open Server File ...';
				  action: [ self openServerFile ] ];
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
						  name: 'About';
						  subMenu: self initializeAboutMenu ].
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
	projectListPresenter := JadeiteTablePresenter new beMultipleSelection.
	projectColumns := self initialProjectDisplayColumns.
	1 to: projectColumns size do: [ :index |
			| column |
			column := projectColumns at: index.
			column width: (initialWidths at: index).
			projectListPresenter addColumn: column ].
	tabs add: projectListPresenter label: 'Projects'.
	self initializeProjectListMenu
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
				action: [ self clearTranscript ];
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

{ #category : 'as yet unclassified' }
JadeiteConsole >> isTranscriptInstalled [
	^isTranscriptInstalled value
]

{ #category : 'as yet unclassified' }
JadeiteConsole >> jadeiteHelpFileCSSExtension [
	"for testing"

	^'.css'
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

{ #category : 'actions' }
JadeiteConsole >> openServerFile [

	| filePath |
	filePath := JadeiteServerFileSelectorDialog
		            showOnSession: gciSession
		            defaultPath: JadePresenter homeEnvVarString.
	filePath ifNotNil: [ self basicOpenServerFile: filePath ]
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

{ #category : 'selecting' }
JadeiteConsole >> selectTranscriptTab [

	consoleTabs adapter widget selectedPageIndex: 2
]

{ #category : 'accessing' }
JadeiteConsole >> selectedPackageServices [

	^Array new
]

{ #category : 'constants' }
JadeiteConsole >> shellName [
	^'Jadeite Console'
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

	self todo: [
			(MessageBox confirm:
				 'Switching transaction modes will cause an abort. Continue?')
				ifTrue: [
						self basicTransactionMode: aSymbol
						"JadePresenter trigger: #abortedTransaction" ]
				ifFalse: [ self resetTransactionModeRadioButtons ] ]
]

{ #category : 'actions' }
JadeiteConsole >> transcriptPresenter [

	^ transcriptPresenter
]

{ #category : 'updates' }
JadeiteConsole >> updateCurrentProjectPackageDisplay: anAnnouncement [

	| projectService |
	anAnnouncement projectService
		ifNil: [
		self projectListPresenter list do: [ :svc | svc isCurrent: false ] ]
		ifNotNil: [
				projectService := self projectListPresenter list
					                  detect: [ :svc |
					                  svc = anAnnouncement projectService ]
					                  ifNone: [ ^ self ].
				projectService replicateFrom: anAnnouncement projectService ].
	self projectListPresenter invalidate
]

{ #category : 'updates' }
JadeiteConsole >> updateProjectPackagesOnCompletion: anObject [
	"no op for project list"
]
