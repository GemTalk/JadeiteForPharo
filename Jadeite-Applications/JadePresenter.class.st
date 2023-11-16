"
Abstract class for Jadeite's presenters. 

We're storing TransactionMode here for global access.
However, it might be better to move it to session state on the server and access via a service. 
"
Class {
	#name : 'JadePresenter',
	#superclass : 'JadeiteApplication',
	#classVars : [
		'ExpandedRowanProjectsHome',
		'PackageGroupsVisible',
		'PackageListVisible',
		'SigAbortProcessInterval',
		'SigAbortsProcess',
		'SigAbortsProcessEnabled',
		'TransactionMode'
	],
	#category : 'Jadeite-Applications'
}

{ #category : 'public' }
JadePresenter class >> areAbortCommitEnabled [
	^self transactionMode == #autoBegin
		or: [self transactionMode == #manualBegin and: [self inTransaction]]
]

{ #category : 'constants' }
JadePresenter class >> defaultAdditionalAccelerators [
	^#(#(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'public' }
JadePresenter class >> defaultMethodTemplate [

	^'methodSelector
	"method comment"

	| temps |
	^ self yourself' replaceCrLfWithLf
]

{ #category : 'public' }
JadePresenter class >> defaultSigAbortProcessInterval [
	"in seconds"

	^10
]

{ #category : 'constants' }
JadePresenter class >> homeEnvVarString [
	^'$HOME'
]

{ #category : 'public' }
JadePresenter class >> isBeginTransactionEnabled [
	^self transactionMode = #manualBegin and: [self inTransaction not]
]

{ #category : 'public' }
JadePresenter class >> isCommitEnabled [
	^self transactionMode == #autoBegin
		or: [self transactionMode == #manualBegin and: [self inTransaction]]
]

{ #category : 'operations' }
JadePresenter class >> loadViewResource2: aString inContext: contextView [
	| resourceIdentifier |
	ShellView
		defaultExtentBlock: [:shellView | shellView extent];
		createHookBlock: 
				[:shellView :createBlock | (Smalltalk at: #stopOnce)
		ifTrue: 
			["Smalltalk at: #stopOnce put: true"
			Smalltalk at: #stopOnce put: false.
			self halt]. 
				shellView beCentered.
				createBlock value.
				].
	
	[resourceIdentifier := ResourceIdentifier class: self name: aString.
	^resourceIdentifier loadWithContext: contextView]
			ensure: 
				[ShellView
					defaultExtentBlock: nil;
					createHookBlock: nil]
]

{ #category : 'constants' }
JadePresenter class >> maxPrintStringSize [
	^100000
]

{ #category : 'browsing' }
JadePresenter class >> openCommit: sha inGitHub: projectService [
	^ShellLibrary default shellOpen: projectService projectUrl , '/commit/' , sha directory: ''
]

{ #category : 'preferences' }
JadePresenter class >> packageGroupsVisible [
	^PackageGroupsVisible ifNil: [PackageGroupsVisible := true]
]

{ #category : 'preferences' }
JadePresenter class >> packageGroupsVisible: aBoolean [
	PackageGroupsVisible := aBoolean
]

{ #category : 'preferences' }
JadePresenter class >> packageListVisible [
	^PackageListVisible ifNil: [PackageListVisible := true]
]

{ #category : 'preferences' }
JadePresenter class >> packageListVisible: aBoolean [
	PackageListVisible := aBoolean
]

{ #category : 'public' }
JadePresenter class >> resetSigAbortProcessEnablement [
	"Sent during logout process. 
	Enablement control is done in the Jadeite.prefs file"

	self sigAbortsProcessEnabled: true
]

{ #category : 'public' }
JadePresenter class >> resetSigAbortProcessInterval [
	"Sent during logout process. 
	Interval control is done in the Jadeite.prefs file"

	self sigAbortProcessInterval: self defaultSigAbortProcessInterval
]

{ #category : 'constants' }
JadePresenter class >> rowanProjectsHomeEnvVarString [
	^'$ROWAN_PROJECTS_HOME'
]

{ #category : 'constants' }
JadePresenter class >> rowanSample1Path [
	^'file:$ROWAN_PROJECTS_HOME/Rowan/samples/RowanSample1_resolved_v2.ston'
]

{ #category : 'constants' }
JadePresenter class >> rowanSample9Path [
	^'file:$ROWAN_PROJECTS_HOME/RowanSample9/rowan/specs/spec_0061.ston'
]

{ #category : 'preferences' }
JadePresenter class >> sigAbortProcessInterval [
	^SigAbortProcessInterval ifNil: [SigAbortProcessInterval := self defaultSigAbortProcessInterval]
]

{ #category : 'preferences' }
JadePresenter class >> sigAbortProcessInterval: anInteger [
	"can be set from preferences file to be applied on startup"

	SigAbortProcessInterval := anInteger
]

{ #category : 'public' }
JadePresenter class >> sigAbortsProcess [

	^SigAbortsProcess
]

{ #category : 'public' }
JadePresenter class >> sigAbortsProcess: aProcess [

	SigAbortsProcess := aProcess
]

{ #category : 'public' }
JadePresenter class >> sigAbortsProcessEnabled [
	^SigAbortsProcessEnabled ifNil: [SigAbortsProcessEnabled := true]
]

{ #category : 'public' }
JadePresenter class >> sigAbortsProcessEnabled: aBoolean [
	SigAbortsProcessEnabled := aBoolean
]

{ #category : 'public' }
JadePresenter class >> stopListeningForSigAborts [
	self sigAbortsProcess ifNotNil: [:proc | proc terminate].
	self sigAbortsProcess: nil
]

{ #category : 'preferences' }
JadePresenter class >> transactionMode [
	TransactionMode ifNil: [self initializeTransactionMode].
	^TransactionMode value
]

{ #category : 'public' }
JadePresenter class >> transactionModeValueHolder [
	^TransactionMode ifNil:[self initializeTransactionMode]
]

{ #category : 'events' }
JadePresenter class >> trigger: aSymbol [

	RowanServiceUpdater current trigger: aSymbol
]

{ #category : 'public' }
JadePresenter >> addSystemBrowser [

	self subclassResponsibility
]

{ #category : 'constants' }
JadePresenter >> additionalAccelerators [
	^#(#(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'public' }
JadePresenter >> gciSession [

	^gciSession

]

{ #category : 'public' }
JadePresenter >> gciSession: aGciSession [

	gciSession := aGciSession.

]

{ #category : 'displaying' }
JadePresenter >> insertIfFalse: methodSourcePresenter [
	"Accelerator key - Ctrl-Shift-D"

	| selectionRange |
	selectionRange := methodSourcePresenter selectionRange.
	methodSourcePresenter view replaceSelection: 'ifFalse:[]'.
	methodSourcePresenter selectionRange: selectionRange + 9
]

{ #category : 'displaying' }
JadePresenter >> insertIfTrue: methodSourcePresenter [
	"Accelerator key - Ctrl-Shift-T"

	| selectionRange |
	selectionRange := methodSourcePresenter selectionRange.
	methodSourcePresenter view replaceSelection: 'ifTrue:[]'.
	methodSourcePresenter selectionRange: selectionRange + 8
]

{ #category : 'public' }
JadePresenter >> isBeginTransactionEnabled [
	^self class isBeginTransactionEnabled
]

{ #category : 'public' }
JadePresenter >> isCommitEnabled [
	^self class isCommitEnabled
]

{ #category : 'public' }
JadePresenter >> isValidClassService: classService [
	^true
]

{ #category : 'event handlers' }
JadePresenter >> onViewOpened [
	super onViewOpened.
	self positionToDefaultLocation
]

{ #category : 'event handlers' }
JadePresenter >> positionToDefaultLocation [
	self topShell position: JadePresenter defaultWindowPosition
]

{ #category : 'menu handlers support' }
JadePresenter >> postEditSaveMethod [
]

{ #category : 'public' }
JadePresenter >> queryCommand: query [
	"this seems dumb but if JadePresenter can perform a symbol it will enable 
	the command regardless of what it's subclasses do."

	super queryCommand: query.
	query commandSymbol = #beginTransaction
		ifTrue: 
			[query isEnabled: self isBeginTransactionEnabled.
			^true].
	query commandSymbol = #commitTransaction
		ifTrue: 
			[query isEnabled: self isCommitEnabled.
			^true]
]

{ #category : 'menu handlers' }
JadePresenter >> refresh [

	self subclassResponsibility
]

{ #category : 'public' }
JadePresenter >> refreshFromServer [
	parentPresenter refreshFromServer
]

{ #category : 'public' }
JadePresenter >> resetCursor [

	(Delay forMilliseconds: 20) wait.
	[Cursor current: nil] forkAt: Processor userBackgroundPriority.

]

{ #category : 'public' }
JadePresenter >> resetListeningForSigAborts: session [
	self stopListeningForSigAborts.
	(self transactionMode == #manualBegin or: [self transactionMode == #transactionless])
		ifTrue: [self listenForSigAborts: session]
]

{ #category : 'displaying' }
JadePresenter >> setStatusBarDefault [
	| statusBarView |
	statusBarView := self topShell view viewNamed: 'statusBarField'.
	statusBarView backcolor: statusBarView defaultBackcolor
]

{ #category : 'public' }
JadePresenter >> sigAbortsProcessEnabled [
	^self class sigAbortsProcessEnabled
]

{ #category : 'public' }
JadePresenter >> sigAbortsProcessEnabled: aBoolean [
	self class sigAbortsProcessEnabled: aBoolean
]

{ #category : 'public' }
JadePresenter >> statusBarText: aString [
	self topShell statusBarText: aString.
	(self view topShell view viewNamed: 'statusBarField') invalidate

]

{ #category : 'menus' }
JadePresenter >> subMenuName [

	^nil.

]

{ #category : 'menus' }
JadePresenter >> subMenuPresenter [

	^nil.

]

{ #category : 'public' }
JadePresenter >> transactionMode [

	^self class transactionMode
]

{ #category : 'public' }
JadePresenter >> transactionMode: aSymbol [
	self class transactionMode: aSymbol
]

{ #category : 'public' }
JadePresenter >> transactionMode: aSymbol session: session [
	self class transactionMode: aSymbol session: session.
	self resetListeningForSigAborts: session
]

{ #category : 'menus' }
JadePresenter >> updateMenuBar: aMenuBar [

	self
		updateMenuBar: aMenuBar 
		withName: self subMenuName 
		itemsFrom: self subMenuPresenter.

]

{ #category : 'menus' }
JadePresenter >> updateMenuBar: aMenuBar withName: aString itemsFrom: aPresenter [

	| contextMenu commandsToRemove items newMenu |
	aString isNil ifTrue: [^self].
	(contextMenu := aPresenter view contextMenu) isNil ifTrue: [^self].
	commandsToRemove := #(#'rename').
	items := contextMenu items reject: [:each | commandsToRemove includes: each command].
	items isEmpty ifTrue: [^self].
	newMenu := aMenuBar addSubmenu: aString.
	1 to: items size do: [:i | 
		| item description |
		item := (items at: i) copy.
		(item isKindOf: CommandMenuItem) ifTrue: [
			description := item commandDescription.
			description := ClosedCommandDescription new
				command: 		description command;
				description: 		description description;
				acceleratorKey: 	description acceleratorKey;
				isModalCommand: 	description isModalCommand;
				image: 			description image;
				receiver:			self;
				queryBlock: 		[:aCommandQuery | self queryCommand: aCommandQuery];
				yourself.
			item commandDescription: description.
		].
		newMenu 
			insertItem: item
			at: i.
	].

]

{ #category : 'public' }
JadePresenter >> updateService: service [
	^self updateServices: (Array with: service) 
]
