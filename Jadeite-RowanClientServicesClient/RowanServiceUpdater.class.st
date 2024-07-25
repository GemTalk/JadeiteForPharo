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
		'inUpdate',
		'logger',
		'applyingUpdates',
		'breakpointsEnabled',
		'returnedServices',
		'postCompletionBlock',
		'serviceQueue',
		'serviceQueueProcess',
		'morphicProcesses',
		'serviceQueueSemaphore'
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

	Current ifNotNil: [ :updater | updater stopServiceQueue ].
	Current := nil
]

{ #category : 'accessing' }
RowanServiceUpdater class >> current [
	^Current ifNil: [Current := self new]
]

{ #category : 'logging' }
RowanServiceUpdater class >> startLogging [
	Current startLogging
]

{ #category : 'logging' }
RowanServiceUpdater class >> stopLogging [
	Current stopLogging
]

{ #category : 'commands' }
RowanServiceUpdater >> _basicIssueCommand: service [

	| postExecutionBlock |
	Processor activeProcess jadeiteTranscriptWrite:
		'service isInCommand - ' , service isInCommand printString.
	service isInCommand ifTrue: [ ^ self ].
	(service command = #update and: [ self isApplyingUpdates ]) ifTrue:[^self]. 
	service prepareForReplication.
	postExecutionBlock := [ :aService |
	                      [
	                      Processor activeProcess
		                      jadeiteTranscriptWrite:
		                      'postExecutionBlock started '
		                      , service printString.
	                      self possibleSignalCompileError: service. 
	                      self applyUpdates: service.
	                      service inCommand signal. "signal before continuing to let gui do further updates as needed."
	                      service handleServiceCompletion.
	                      Processor activeProcess
		                      jadeiteTranscriptWrite:
		                      'postExecutionBlock complete' ]
		                      on: GsCompileError
		                      do: [ :ex |
			                      service handleCompileError: ex.
			                      service inCommand signal ] ].
	Processor activeProcess jadeiteTranscriptWrite:
		'about to executeInSession:*'.
	service
		executeInSession: GciSession current
		onCompletion: postExecutionBlock
		semaphore: service inCommand.
	Processor activeProcess jadeiteTranscriptWrite:
		'about to wait on service inCommand'.
	service inCommand wait.
	Processor activeProcess jadeiteTranscriptWrite:
		'service inCommand signaled'
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

{ #category : 'testing' }
RowanServiceUpdater >> activeProcessIsMorphicProcess [

	^ UIManager default uiProcess == Processor activeProcess or: [
		  Processor activeProcess name = 'Morphic UI Process_Jadeite' ]
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
		Processor activeProcess jadeiteTranscriptWrite:
			'RowanServiceUpdater>>#applyUpdatesFromReturnedServices: updates - '
			, updates printString.
		Processor activeProcess jadeiteTranscriptWrite:
			'RowanServiceUpdater>>#applyUpdatesFromReturnedServices: aCollection - '
			, aCollection printString.
		updates removeAll: updates. "get rid of compile error service"
		updates addAll: aCollection.
		self updatesReadyToApply ]
]

{ #category : 'commands' }
RowanServiceUpdater >> basicIssueCommand: service [
	Processor activeProcess jadeiteTranscriptWrite: 'RowanServiceUpdater>>#basicIssueCommand: - ', service printString. 
	true ifTrue:[^[self _basicIssueCommand: service] fork]. 
	self activeProcessIsMorphicProcess
		ifTrue: [
			| sem processingCommand proc |
			Processor activeProcess jadeiteTranscriptWrite:
				'-------------------------'.
			sem := Semaphore new.
			processingCommand := true.
			proc := [
			        MorphicRenderLoop new doOneCycleWhile: [ processingCommand ] ]
				        newProcess priority: Processor userSchedulingPriority.
			proc name: 'Morphic UI Process_Jadeite'.
			proc jadeiteTranscriptWrite: 'named'.
			[
			[
			Processor activeProcess jadeiteTranscriptWrite:
				'about to _basicIssueCommand: ', service printString.
			self _basicIssueCommand: service ] ensure: [
				Processor activeProcess jadeiteTranscriptWrite:
					'_basicIssueCommand: complete - in ensure block'.
				processingCommand := false.
				sem signal.
				Processor activeProcess jadeiteTranscriptWrite:
					'_basicIssueCommand: complete - ensure block complete' ] ] fork.
			[
			proc resume.
			proc jadeiteTranscriptWrite: 'resumed'.
			Processor activeProcess jadeiteTranscriptWrite:
				'about to wait on sem'.
			sem wait.
			Processor activeProcess jadeiteTranscriptWrite: 'sem signaled' ]
				ifCurtailed: [ "just in case forked ensure block doesn't run and we're terminated. 
			Any observable slot that sends a service call can get into a stuck lock state if terminated"
					processingCommand := false.
					sem signal ] ]
		ifFalse: [ self _basicIssueCommand: service ]
]

{ #category : 'private' }
RowanServiceUpdater >> basicUpdateServices: services session: session [

	services do: [ :service |
		service command: #update.
		self issueCommand: service session: session onCompletion: nil ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> breakpointsEnabled [
	^breakpointsEnabled
]

{ #category : 'accessing' }
RowanServiceUpdater >> breakpointsEnabled: anObject [
	breakpointsEnabled := anObject
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

{ #category : 'private' }
RowanServiceUpdater >> inUpdate [
	^inUpdate
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
	inUpdate := Semaphore forMutualExclusion.
	logger := JadeiteLogger new.
	breakpointsEnabled := false.
	announcer := RowanServiceUpdaterAnnouncer new serviceUpdater: self.
	"Keep this code around - might need it again if we reimplement service queue.
	serviceQueue := OrderedCollection new.
	serviceQueueSemaphore := Semaphore new.
	self startServiceQueueProcess" 
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

	^ self issueCommand: service session: session onCompletion: nil
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommand: service session: session onCompletion: completionBlock [

	session ifNil: [ ^ nil ].
	service serviceCompletionBlock: completionBlock. 
	self basicIssueCommand: service
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommand: command to: service session: session [
	"not used yet"
	service
		command: command;
		commandArgs: Array new.
	^ self issueCommand: service session: session
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

{ #category : 'accessing' }
RowanServiceUpdater >> morphicProcesses [

	^ morphicProcesses ifNil: [
		  morphicProcesses := OrderedCollection new ]
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

{ #category : 'accessing' }
RowanServiceUpdater >> queueProcess [

	^ serviceQueueProcess
]

{ #category : 'accessing' }
RowanServiceUpdater >> queueProcess: anObject [

	^ serviceQueueProcess := anObject
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

{ #category : 'initialization' }
RowanServiceUpdater >> resetLoggingService [
	logger loggingService: nil. 
	logger newLoggingService
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

{ #category : 'service queue' }
RowanServiceUpdater >> serviceQueuePut: aBlock [

	serviceQueue add: aBlock
]

{ #category : 'service queue' }
RowanServiceUpdater >> serviceQueuePutFirst: aBlock [

	serviceQueue addFirst: aBlock
]

{ #category : 'service queue' }
RowanServiceUpdater >> serviceQueueUIPut: aBlock [
	"push a block onto the queue but run it in the ui process.
	No commands should be sent to the server in aBlock"

	serviceQueue add: [
		| sem |
		sem := Semaphore new.
		UIManager default defer: [ aBlock ensure: [ sem signal ] ].
		sem wait ]
]

{ #category : 'service queue' }
RowanServiceUpdater >> serviceQueueUIPutFirst: aBlock [

	serviceQueue addFirst: [
		| sem |
		sem := Semaphore new.
		UIManager default defer: [ aBlock ensure: [ sem signal ] ].
		sem wait ]
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

{ #category : 'logging' }
RowanServiceUpdater >> startLogging [
	logger startLogging
]

{ #category : 'service queue' }
RowanServiceUpdater >> startServiceQueueProcess [

	serviceQueueProcess := [
	                       [
	                       | block |
	                       serviceQueue isEmpty
		                       ifTrue: [ (Delay forMilliseconds: 1) wait ]
		                       ifFalse: [
			                       block := serviceQueue remove:
				                                serviceQueue first.
			                       block fork ] ] repeat ] forkNamed:
		                       'Jadeite Service Queue'
]

{ #category : 'logging' }
RowanServiceUpdater >> stopLogging [
	logger stopLogging
]

{ #category : 'service queue' }
RowanServiceUpdater >> stopServiceQueue [

	serviceQueueProcess ifNotNil: [
		serviceQueueProcess terminate.
		serviceQueueProcess := nil.
		serviceQueueSemaphore := nil ]
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
RowanServiceUpdater >> updateService: service session: session [
	^self updateServices: (Array with: service) session: session
]

{ #category : 'public' }
RowanServiceUpdater >> updateServices: services session: session [
	| commandResult |
	services isEmpty ifTrue: [^self].
	self inUpdateWhile: 
			[commandResult := self basicUpdateServices: services session: session.
			^commandResult]
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
