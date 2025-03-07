"
Service commands issued here. Coordinates single threading to compensate for RSR's asynchronous nature. 

returnedServices are the last services returned from the server. Handy for testing. 
"
Class {
	#name : 'RowanServiceUpdater',
	#superclass : 'Model',
	#instVars : [
		'updates',
		'debug',
		'logger',
		'applyingUpdates',
		'breakpointsEnabled',
		'returnedServices',
		'postCompletionBlock',
		'serviceQueueSemaphore',
		'singleThreaded',
		'commandsStarted'
	],
	#classVars : [
		'Current'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanServiceUpdater class >> clearCurrent [
	"
	RowanServiceUpdater clearCurrent.
"

	Current := nil
]

{ #category : 'accessing' }
RowanServiceUpdater class >> current [
	^Current ifNil: [Current := self new]
]

{ #category : 'accessing' }
RowanServiceUpdater class >> current: anUpdater [

	Current := anUpdater
]

{ #category : 'logging' }
RowanServiceUpdater class >> startLogging [
	Current startLogging
]

{ #category : 'logging' }
RowanServiceUpdater class >> stopLogging [
	Current stopLogging
]

{ #category : 'instance creation' }
RowanServiceUpdater class >> uninstallTestUpdater [ 

	self adoptInstance: self current
]

{ #category : 'commands' }
RowanServiceUpdater >> _basicIssueCommand: service [

	| postExecutionBlock |
	self startCommandProgressBar: service.
	service commandArgs ifNil: [ service commandArgs: Array new ].
	service prepareForReplication.
	postExecutionBlock := [ :aService |
	                      [
	                      [
	                      service replicateFrom: aService.
	                      self possibleSignalCompileError: service.
	                      self applyUpdates: service.
	                      service handleServiceCompletion ] ifCurtailed: [
		                      aService inCommand signal ].
	                      aService inCommand signal ]
		                      on: GsCompileError
		                      do: [ :ex |
			                      service handleCompileError: ex.
			                      service inCommand signal.
			                      self stopCommandProgressBar: service ].
	                      self stopCommandProgressBar: service ].
	GciSession current isValidSession ifFalse: [
		^ self "can happen in tests mostly" ].
	service
		executeInSession: GciSession current
		onCompletion: postExecutionBlock.
	service inCommand wait
]

{ #category : 'accessing' }
RowanServiceUpdater >> activeClassServices [
	^self registeredListServices select: [:service | service isService and: [ service isClassService]]
]

{ #category : 'accessing' }
RowanServiceUpdater >> activeMethodServices [
	^self registeredListServices select: [:service | service isService and: [service isMethodService]]
]

{ #category : 'accessing' }
RowanServiceUpdater >> activePackageServices [
	^self registeredListServices select: [:service | service isService and:[service isPackageService]]
]

{ #category : 'accessing' }
RowanServiceUpdater >> activeServices [
	"services which are open in windows in list browsers"

	| services |
	services := OrderedCollection new.
	services addAll: self activeMethodServices.
	services addAll: self activeClassServices.
	services addAll: self activePackageServices.
	^services
]

{ #category : 'public' }
RowanServiceUpdater >> applyUpdateWhile: block [
	applyingUpdates := true.
	block ensure: 
			[applyingUpdates := false.
			self rowanPostUpdate]
]

{ #category : 'commands' }
RowanServiceUpdater >> applyUpdates: service [
	"Note - do not apply updates in the gui thread - We need to finish
	updates in this process before proceeding from the command. 
	Let each update that needs to update the gui do it's own forking."

	self applyUpdatesFromReturnedServices: service returnedServices
]

{ #category : 'accessing' }
RowanServiceUpdater >> applyUpdatesFromReturnedServices: aCollection [
	"don't just reinitialize the updates instance variable because
	presenters are registered to that object"

	self applyUpdateWhile: [
		updates removeAll: updates. "get rid of compile error service"
		updates addAll: aCollection.
		self updatesReadyToApply ]
]

{ #category : 'commands' }
RowanServiceUpdater >> basicIssueCommand: service [
	"Don't block the morphic process.
	Any sending process has use completion blocks"
	service isInCommand ifTrue: [ ^ self ].
	(singleThreaded and: [ service notAlwaysForked ])
		ifTrue: [
			serviceQueueSemaphore critical: [
				self _basicIssueCommand: service.
				WorldMorph doOneCycle ] ]
		ifFalse: [
			[ self _basicIssueCommand: service ] fork.
			Processor yield ]
]

{ #category : 'private' }
RowanServiceUpdater >> basicUpdateServices: services session: session onCompletion: completionBlock [

	services do: [ :service |
		service
			command: #update;
			commandArgs: Array new.
		self
			issueCommand: service
			session: session
			onCompletion: completionBlock ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> breakpointsEnabled [
	^breakpointsEnabled
]

{ #category : 'accessing' }
RowanServiceUpdater >> breakpointsEnabled: anObject [
	breakpointsEnabled := anObject
]

{ #category : 'progress indication' }
RowanServiceUpdater >> commandCompleted: service [

	self commandsStarted remove: service ifAbsent: [  ].
	self commandsStarted ifEmpty: [
		JadeiteConnectionProfile connectionProfile jadeiteWindows do: [
			:window | window presenter showNotWait ].
		WorldMorph doOneCycle ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> commandsStarted [

	^ commandsStarted ifNil: [
		  commandsStarted := OrderedCollection new ]
]

{ #category : 'conversion' }
RowanServiceUpdater >> convertEventSymbolToClass: aSymbol [

	"conversion from Dolphin-style symbol events to Pharo-style class events"

	| classSymbolStream |
	classSymbolStream := WriteStream on: String new.
	classSymbolStream
		nextPut: aSymbol first uppercase;
		nextPutAll: (aSymbol copyFrom: 2 to: aSymbol size).
	^ Smalltalk classNamed: classSymbolStream contents
]

{ #category : 'commands' }
RowanServiceUpdater >> critical: aBlock [
	"single thread services - only for limited use"

	singleThreaded := true.
	aBlock ensure: [ singleThreaded := false ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> debug [
	^debug
]

{ #category : 'accessing' }
RowanServiceUpdater >> debug: aBoolean [
	aBoolean
		ifTrue: 
			[Smalltalk at: #roundTrips put: 0].
	debug := aBoolean
]

{ #category : 'events' }
RowanServiceUpdater >> getEvents [

	^ nil
]

{ #category : 'commands' }
RowanServiceUpdater >> inUpdateWhile: block [

	| result |
	result := "self inUpdate critical: [ "
		          self todo: [RowanServiceUpdater current logComment:
			          'Process: {'
			          , Processor activeProcess identityHash printString
			          , '} gets inUpdate semaphore.  [' , block printString
			          , ']'].
		          block ensure: [ 
			          GciSession current ifNotNil: [ :session | 
				          session autoCommit == true ifTrue: [ 
					          JadePresenter trigger: #committedTransaction "autoCommit could be a symbol #failed" ] ] ] "]".
	^ result
]

{ #category : 'initialization' }
RowanServiceUpdater >> initialize [

	super initialize.
	self initializeUpdates.
	debug := false.
	logger := JadeiteLogger new.
	breakpointsEnabled := false.
	announcer := RowanServiceUpdaterAnnouncer new serviceUpdater: self.
	serviceQueueSemaphore := Semaphore forMutualExclusion.
	singleThreaded := false. 
]

{ #category : 'initialization' }
RowanServiceUpdater >> initializeUpdates [
	updates := OrderedCollection new.
	
]

{ #category : 'public' }
RowanServiceUpdater >> isApplyingUpdates [
	"we've come back from the server and
	are in the middle of updating browsers. 
	Send this to avoid untimely updates to
	services until updates are fully applied"

	^applyingUpdates == true
]

{ #category : 'logging' }
RowanServiceUpdater >> isLogging [

	^logger isLogging
]

{ #category : 'logging' }
RowanServiceUpdater >> isLogging: boolean [
	boolean ifTrue: [self startLogging] ifFalse: [self stopLogging]
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommand: service session: session [

	^ self issueCommand: service session: session onCompletion: [  ]
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommand: service session: session onCompletion: completionBlock [

	| theCompletionBlock |
	theCompletionBlock := completionBlock ifNil: [ [  ] ].
	session ifNil: [ ^ nil ].
	service serviceCompletionBlock: theCompletionBlock.
	self basicIssueCommand: service
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommands: services session: session onCompletion: completionBlock [

	services do: [ :service |
		self
			issueCommand: service
			session: session
			onCompletion: completionBlock ]
]

{ #category : 'logging' }
RowanServiceUpdater >> logComment: string [
	logger logComment: string
]

{ #category : 'accessing' }
RowanServiceUpdater >> logFileName [

	^logger logFileName
]

{ #category : 'accessing' }
RowanServiceUpdater >> logFileName: string [

	^logger logFileName: string
]

{ #category : 'logging' }
RowanServiceUpdater >> logReceivedServices: services [
	logger logReceivedServices: services.
	logger shouldGetNewLoggerGroup: true
]

{ #category : 'logging' }
RowanServiceUpdater >> logSentServices: services [
	logger logSentServices: services
]

{ #category : 'accessing' }
RowanServiceUpdater >> logger [
	"Private - for testing"

	^logger
]

{ #category : 'accessing' }
RowanServiceUpdater >> logger: anObject [
	logger := anObject
]

{ #category : 'accessing' }
RowanServiceUpdater >> loggingService [
	"for testing"

	^logger loggingService
]

{ #category : 'private' }
RowanServiceUpdater >> performUpdate: updateBlock with: selector [
	updates do: 
			[:update | 
			update updateType
				ifNil: [updateBlock value: update]
				ifNotNil: 
					[:type |
					(type == selector or: [type isEmpty or: [type includes: selector]])
						ifTrue: [updateBlock value: update]]]
]

{ #category : 'commands' }
RowanServiceUpdater >> possibleSignalCompileError: service [

	service returnedServices do: [ :svc | svc signalCompileError ]
]

{ #category : 'public' }
RowanServiceUpdater >> register: presenter selector: selector [
	"send the update to the presenter so that when the presenter gets
	removed, it's events go with it."

	self
		when: #updatesReadyToApply
		send: #update:withSelector:
		to: presenter
		withArguments: (Array with: self with: selector)
]

{ #category : 'public' }
RowanServiceUpdater >> register: presenter selector: selector browser: browser [
	"send the update to the presenter so that when the presenter gets
	removed, it's events go with it."

	self
		when: #updatesReadyToApply
		send: #update:withSelector:browser:
		to: presenter
		withArguments: (Array
				with: self
				with: selector
				with: browser)
]

{ #category : 'private' }
RowanServiceUpdater >> registeredListPresenters [
	^self registeredPresenters select: [:presenter | presenter class canUnderstand: #list]
]

{ #category : 'private' }
RowanServiceUpdater >> registeredListServices [
	| listServices |
	listServices := OrderedCollection new.
	self registeredListPresenters do: [:listPresenter | listServices addAll: listPresenter list].
	self registeredTreePresenters do:[:treePresenter | listServices addAll: treePresenter model]. 
	^listServices
]

{ #category : 'public' }
RowanServiceUpdater >> registeredPresenters [
	"The #asActionSequence message send ensures we get a collection back.
	If the size is one, we'll get a WeakMessageSend"

	| presenters |
	(self hasActionForEvent: #updatesReadyToApply) ifFalse: [
		^ Array new ].
	presenters := (self actionForEvent: #updatesReadyToApply)
		              asActionSequence collect: [ :weakMessageSend |
		              weakMessageSend receiver ].
	^ presenters asSet
]

{ #category : 'private' }
RowanServiceUpdater >> registeredTreePresenters [
	^self registeredPresenters select: [:presenter | presenter isKindOf: JadeiteTreePresenter]
]

{ #category : 'public' }
RowanServiceUpdater >> removeEventsTriggeredFor: anObject [
	self removeActionsWithReceiver: anObject
]

{ #category : 'commands' }
RowanServiceUpdater >> returnedCompileError: service [

	^ service returnedServices
		  detect: [ :svc | svc isCompileError ]
		  ifNone: [  ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> returnedServices [

	^returnedServices
]

{ #category : 'public' }
RowanServiceUpdater >> rowanPostUpdate [
	updates do: [:service | service postUpdateBlock ifNotNil: [:block | block value]]
]

{ #category : 'accessing' }
RowanServiceUpdater >> selectedServices [
	| services potentialSelections |
	services := OrderedCollection new.
	self registeredPresenters do: 
			[:presenter |
			(presenter class canUnderstand: #selections)
				ifTrue: 
					[potentialSelections := presenter selections.
					services addAll: (potentialSelections select: [:selection | selection isUpdatableService])]].
	services do:[:service | service command: #update]. 
	^services asSet asArray
]

{ #category : 'accessing' }
RowanServiceUpdater >> selectedServicesForConnection: theConnection [

	| services potentialSelections |
	services := OrderedCollection new.
	self registeredPresenters do: [ :presenter | 
		(presenter class canUnderstand: #selections) ifTrue: [ 
			presenter selections isEmpty ifFalse:[
			potentialSelections := presenter selectedItems.
			services addAll: (potentialSelections select: [ :selection | 
					 selection isUpdatableService and: [ 
						 selection connection == theConnection ] ]) ] ]].
	services do: [ :service | service command: #update ].
	^ services asSet asArray
]

{ #category : 'private' }
RowanServiceUpdater >> shouldApply: selector forService: service [
	service isNil ifTrue:[^false]. "if a service is gc'd we could possibly end up with a nil here"
	(service class canUnderstand: selector) ifFalse:[^false]. 
	^service updateType isNil or: 
			[service updateType == selector
				or: [service updateType isEmpty or: [service updateType includes: selector]]]
]

{ #category : 'accessing' }
RowanServiceUpdater >> shouldGetNewLoggerGroup: boolean [

	logger shouldGetNewLoggerGroup: boolean
]

{ #category : 'accessing' }
RowanServiceUpdater >> singleThreaded [

	^ singleThreaded
]

{ #category : 'accessing' }
RowanServiceUpdater >> singleThreaded: anObject [

	^ singleThreaded := anObject
]

{ #category : 'progress indication' }
RowanServiceUpdater >> startCommandProgressBar: service [

	self commandsStarted add: service.
	JadeiteConnectionProfile connectionProfile jadeiteWindows do: [
		:window | window presenter showWait ].
	WorldMorph doOneCycle
]

{ #category : 'logging' }
RowanServiceUpdater >> startLogging [
	logger startLogging
]

{ #category : 'progress indication' }
RowanServiceUpdater >> stopCommandProgressBar: service [
	"an application can tell the updater when it starts an operation"

	self commandCompleted: service
]

{ #category : 'logging' }
RowanServiceUpdater >> stopLogging [
	logger stopLogging
]

{ #category : 'progress indication' }
RowanServiceUpdater >> stopProgressBar [
	"a debugger was opened, stop all progress indication"

	commandsStarted := OrderedCollection new.
	JadeiteConnectionProfile connectionProfile jadeiteWindows do: [
		:window | window presenter showNotWait ]
]

{ #category : 'updating' }
RowanServiceUpdater >> trigger: aSymbol [

	self triggerEvent: aSymbol "(self convertEventSymbolToClass: aSymbol)"
]

{ #category : 'public' }
RowanServiceUpdater >> update: services afterStonReplication: stonResults [
	"assume we get back the 'same' services as we sent"

	self initializeUpdates.
	returnedServices := JadeiteSTON fromString: stonResults.
	logger loggingService replicateFrom: returnedServices last.
	returnedServices := returnedServices copyWithout: returnedServices last.
	self logReceivedServices: returnedServices.
	returnedServices do: [:newService | services do: [:service | service replicateFrom: newService]].
	self applyUpdatesFromReturnedServices: returnedServices.
	returnedServices do: [:service | service rowanPostUpdate].
	^returnedServices
]

{ #category : 'updating' }
RowanServiceUpdater >> update: browserUpdate withSelector: selector [
	browserUpdate updatesPerform: selector presenter: self. 
]

{ #category : 'updating' }
RowanServiceUpdater >> update: updater withSelector: selector browser: browser [
	updater
		updatesPerform: selector
		presenter: self
		browser: browser.
	(browser class canUnderstand: #redrawAllViews) ifTrue: [browser redrawAllViews]
]

{ #category : 'public' }
RowanServiceUpdater >> updateService: service session: session onCompletion: completionBlock [

	^ self
		  updateServices: (Array with: service)
		  session: session
		  onCompletion: completionBlock
]

{ #category : 'public' }
RowanServiceUpdater >> updateServices: services session: session onCompletion: completionBlock [

	| commandResult |
	services isEmpty ifTrue: [ ^ self ].
	self inUpdateWhile: [
		commandResult := self
			                 basicUpdateServices: services
			                 session: session
			                 onCompletion: completionBlock.
		^ commandResult ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> updates [
	^updates
]

{ #category : 'public' }
RowanServiceUpdater >> updatesPerform: selector presenter: presenter [

	self updatesPerform: selector presenter: presenter browser: nil
]

{ #category : 'public' }
RowanServiceUpdater >> updatesPerform: selector presenter: presenter browser: browser [
	"the update may know which client updates 
	it wants us to care about if updateType is set. 
	Respect the server's wishes."

	updates do: [ :update |
		(self shouldApply: selector forService: update) ifTrue: [
			update
				perform: selector
				withEnoughArguments: (Array with: presenter with: browser) ] ]
]

{ #category : 'public' }
RowanServiceUpdater >> updatesReadyToApply [

	updates isEmpty ifFalse: [ self trigger: #updatesReadyToApply ]
]
