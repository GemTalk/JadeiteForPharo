Class {
	#name : 'JadeiteProcessBrowser',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'processListPresenter',
		'toolbar',
		'toolbarPresenter',
		'layoutBox',
		'processColumns'
	],
	#category : 'Jadeite-ProcessBrowser',
	#package : 'Jadeite-ProcessBrowser'
}

{ #category : 'instance creation' }
JadeiteProcessBrowser class >> showOnSession: aGciSession process: processList [

	| inst windowPresenter |
	inst := self new.
	inst
		gciSession: aGciSession;
		initializeProcessList: processList;
		application: JadeiteConsole currentConsole application.
	windowPresenter := inst open.
	inst addStyle: 'jadeiteTextBackgroundColor'.
	^ inst
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> addStyle: aString [

	super addStyle: aString.
	waitIndicator addStyle: aString.
	layoutBox ifNotNil: [ layoutBox adapter addStyle: aString ].
]

{ #category : 'actions' }
JadeiteProcessBrowser >> basicChangePriority: newPriority [

	processListPresenter selectedItem
		changePriority: newPriority
		onCompletion: [
			self updateProcessListOnCompletion: [
				UIManager default inform: 'Process priority was updated' ] ]
]

{ #category : 'actions' }
JadeiteProcessBrowser >> changePriority [

	| newPriority |
	newPriority := UIManager default
		               request: 'Enter new priority (integer)'
		               initialAnswer: '20'
		               title: 'Change Process Priority'.
	newPriority ifNil: [ ^ self ].
	newPriority asInteger ifNotNil: [ :int |
		self basicChangePriority: int ]
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> columnWithAspect: aspect title: title [

	| column |
	column := SpStringTableColumn
		          title: title
		          evaluated: [ :processService |
			          (processService perform: aspect)
				          ifNil: [ String new ]
				          ifNotNil: [ :value | value asString ] ].
	^ column
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> connectPresenters [

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

{ #category : 'actions' }
JadeiteProcessBrowser >> debugProcess [

	| processService |
	processService := processListPresenter selectedItem.
	processService command: #debug.
	RowanServiceUpdater current
		issueCommand: processService
		session: self gciSession
]

{ #category : 'defaults' }
JadeiteProcessBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initialProcessDisplayColumns [

	| columns |
	columns := OrderedCollection new.
	self processDisplayAttributes keysAndValuesDo: [ :aspect :title |
		columns add: (self columnWithAspect: aspect title: title) ].
	^ columns
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Process';
						  subMenu: self newProcessMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initializePresenters [

	| waitBox |
	super initializePresenters.
	layoutBox := SpBoxLayout newVertical.
	self layout add: layoutBox.
	waitBox := self initializeWaitPresenter.
	layoutBox add: waitBox expand: false.
	self initializeProcessListPresenterTo: layoutBox.
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initializeProcessList: aList [

	processListPresenter list: (ListModel withAll: aList)
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initializeProcessListMenu [

	processListPresenter contextMenu: self newProcessMenu
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initializeProcessListPresenterTo: box [

	| initialWidths |
	initialWidths := { 100. 100. 100. 100 }.
	processListPresenter := JadeiteTablePresenter new.
	processColumns := self initialProcessDisplayColumns.
	1 to: processColumns size do: [ :index |
		| column |
		column := processColumns at: index.
		column width: (initialWidths at: index).
		processListPresenter addColumn: column ].
	box add: processListPresenter.
	self initializeProcessListMenu
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 80 @ 30 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self updateCaption
]

{ #category : 'menus' }
JadeiteProcessBrowser >> newProcessMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Debug';
					action: [ self debugProcess ];
					enabled: [ processListPresenter selectionOrNil notNil ] ];
			addItem: [ :item |
				item
					name: 'Terminate';
					action: [ self terminateProcess ];
					enabled: [ processListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Change Priority ...';
					action: [ self changePriority ];
					enabled: [ processListPresenter selectionOrNil notNil ] ];
			addItem: [ :item |
				item
					name: 'Short Stack';
					action: [ self shortStack ];
					enabled: [ processListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Refresh';
				action: [ self refresh ] ] ].
	^ menu
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> processDisplayAttributes [

	| attributes |
	attributes := OrderedDictionary new.
	attributes
		at: #status put: 'Status';
		at: #oop put: 'Oop';
		at: #priority put: 'Priority';
		at: #name put: 'Name'.
	^ attributes
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> refresh [

	self updateProcessListOnCompletion: [  ]
]

{ #category : 'constants' }
JadeiteProcessBrowser >> shellName [
	^'Jadeite Process Browser'
]

{ #category : 'actions' }
JadeiteProcessBrowser >> shortStack [

	| workspace string processService |
	workspace := JadeiteWorkspace showOnSession: self gciSession.
	processService := processListPresenter selectedItem.
	string := self gciSession titleBarFor: processService displayName.
	workspace text: processService serverPrintString.
	workspace caption: string
]

{ #category : 'actions' }
JadeiteProcessBrowser >> terminateProcess [

	processListPresenter selectedItem terminateOnCompletion: [
		self updateProcessListOnCompletion: [
			UIManager default inform: 'Process was terminated' ] ]
]

{ #category : 'events' }
JadeiteProcessBrowser >> themeChanged [
	"do any repair work from lousy pharo theme transitioning"

	self adapter applyStyle
]

{ #category : 'accessing' }
JadeiteProcessBrowser >> toolbarPresenter [
	^toolbarPresenter
]

{ #category : 'initialization' }
JadeiteProcessBrowser >> updateProcessList: aCollection [

	self initializeProcessList: aCollection.
	processListPresenter refresh
]

{ #category : 'actions' }
JadeiteProcessBrowser >> updateProcessListOnCompletion: completionBlock [

	| answeringService |
	answeringService := RowanAnsweringServiceClient new command:
		                    #allProcesses.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			self updateProcessList: answeringService answer.
			completionBlock value ]
]
