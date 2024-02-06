"
Coordinate client presenters with updates from the server.

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
		'primaryQueueProcess',
		'primaryServiceQueue',
		'secondaryQueueProcess',
		'secondaryServiceQueue'
	],
	#classVars : [
		'Current'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanServiceUpdater class >> clearCurrent [
	"
	RowanServiceUpdater clearCurrent.
"

	Current ifNotNil: [ :updater | updater stopCommandProcessors ].
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

{ #category : 'accessing' }
RowanServiceUpdater >> applyUpdatesFromReturnedServices: aCollection [
	"don't just reinitialize the updates instance variable because
	presenters are registered to that object"

	self applyUpdateWhile: [ "updates removeAll: updates."
		updates addAll: aCollection.
		self updatesReadyToApply ]
]

{ #category : 'service queue' }
RowanServiceUpdater >> basicProcessQueueElement: nextQueueElement [

	| sem updateResult updateAndCompleteBlock |
	RowanServiceUpdater current logger newLoggingService logComment:
		'RowanServiceUpdater>>#basicProcessQueueElement: '
		, nextQueueElement service command printString , ' '
		, nextQueueElement service commandArgs printString.
	nextQueueElement service
		command: nextQueueElement command;
		commandArgs: nextQueueElement commandArgs.
	nextQueueElement service prepareForReplication.
	sem := Semaphore new.
	updateAndCompleteBlock := [ :aService |
	                          [
	                          updateResult := self
		                                          applyUpdatesFromReturnedServices:
		                                          nextQueueElement service
			                                          returnedServices.
	                          nextQueueElement completionBlock ifNotNil: [
		                          :block | block value: aService ] ]
		                          ensure: [ sem signal ] ].

	nextQueueElement service
		executeInSession: GciSession current
		onCompletion: updateAndCompleteBlock
		semaphore: sem.
	sem wait
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

{ #category : 'public' }
RowanServiceUpdater >> deferUntilUpdatesComplete: aZeroArgBlock [
	self inUpdate critical: [ aZeroArgBlock value ]
]

{ #category : 'as yet unclassified' }
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
	primaryServiceQueue := AtomicSharedQueue new.
	secondaryServiceQueue := AtomicSharedQueue new.
	self startCommandProcessors
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
	"priority 0 - top priority (debugger) 
	priority 1 - services sent from other service's commands: 
	priority 2 - ui services initiated from the user"

	| queueElement |
	queueElement := RowanServiceQueueElement new
		                service: service;
		                completionBlock: completionBlock;
		                command: service command;
		                commandArgs: service commandArgs.
	Processor activeProcess == UIManager default uiProcess ifTrue: [
		queueElement priority: 2 ].
	queueElement priority: (service command == #update
			 ifTrue: [ 0 ]
			 ifFalse: [ 1 ]).
	RowanServiceUpdater current logger newLoggingService logComment:
		'RowanServiceUpdater>>#issueCommand:session:onCompletion: '
		, service printString , ' ' , service command printString , ' '
		, service commandArgs printString , ' priority - '
		, queueElement priority printString.
	primaryServiceQueue nextPut: queueElement
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

{ #category : 'service queue' }
RowanServiceUpdater >> nextPrimaryQueueElement [

	#( 0 1 2 ) do: [ :priority |
		(self nextPrimaryQueueElementWithPriority: priority) ifNotNil: [ :e | ^ e ] ].
	^ nil
]

{ #category : 'service queue' }
RowanServiceUpdater >> nextPrimaryQueueElementWithPriority: priority [

	^ primaryServiceQueue nextOrNilSuchThat: [ :queueElement |
		  queueElement priority = priority ]
]

{ #category : 'service queue' }
RowanServiceUpdater >> nextSecondaryQueueElement [

	#( 0 1 ) do: [ :priority |
		(self nextSecondaryQueueElementWithPriority: priority) ifNotNil: [ :e | ^ e ] ].
	^ nil
]

{ #category : 'service queue' }
RowanServiceUpdater >> nextSecondaryQueueElementWithPriority: priority [
	| result |
	
	result :=  secondaryServiceQueue nextOrNilSuchThat: [ :queueElement |
		  queueElement priority = priority ].
	result ifNil: [ ^nil ].
	RowanServiceUpdater current logger newLoggingService logComment:
		'RowanServiceUpdater>>#nextSecondaryQueueElementWithPriority: '
		, result service printString , ' ' , result command printString , ' '
		, result commandArgs printString , ' priority - '
		, result priority printString.
	^result
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

{ #category : 'service queue' }
RowanServiceUpdater >> processQueueElement: nextQueueElement [
	"don't issue multiple commands from the same service simultaneously"
	nextQueueElement service inCommand critical: [
		self basicProcessQueueElement: nextQueueElement ]
]

{ #category : 'accessing' }
RowanServiceUpdater >> queueProcess [

	^ primaryQueueProcess
]

{ #category : 'accessing' }
RowanServiceUpdater >> queueProcess: anObject [

	^ primaryQueueProcess := anObject
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

{ #category : 'service queue' }
RowanServiceUpdater >> startCommandProcessors [

	self startPrimaryCommandProcessor. 
	self startSecondaryCommandProcessor. 
]

{ #category : 'logging' }
RowanServiceUpdater >> startLogging [
	logger startLogging
]

{ #category : 'service queue' }
RowanServiceUpdater >> startPrimaryCommandProcessor [

	primaryQueueProcess := [
	                [
	                | nextQueueElement |
	                nextQueueElement := self nextPrimaryQueueElement.
	                nextQueueElement ifNotNil: [ :e |
		                e priority = 2
			                ifTrue: [ self processQueueElement: e ]
			                ifFalse: [ secondaryServiceQueue nextPut: nextQueueElement ] ].
	                primaryServiceQueue waitForNewItems ] repeat ] forkNamed:
		                'Jadeite Primary Service Queue'
]

{ #category : 'service queue' }
RowanServiceUpdater >> startSecondaryCommandProcessor [

	secondaryQueueProcess := [
	                         [
	                         | nextQueueElement |
	                         nextQueueElement := self
		                                             nextSecondaryQueueElement.
	                         nextQueueElement ifNotNil: [ :e |
		                         e priority = 1
			                         ifTrue: [ self processQueueElement: e ]
			                         ifFalse: [
				                         [ "priority 0"
				                         self processQueueElement: e ] forkAt:
					                         Processor activePriority + 1.
				                         Processor yield ] ].
	                         secondaryServiceQueue waitForNewItems ]
		                         repeat ] forkNamed:
		                         'Jadeite Secondary Service Queue'
]

{ #category : 'service queue' }
RowanServiceUpdater >> stopCommandProcessors [

	self stopPrimaryCommandProcessor. 
	self stopSecondaryCommandProcessor. 
]

{ #category : 'logging' }
RowanServiceUpdater >> stopLogging [
	logger stopLogging
]

{ #category : 'service queue' }
RowanServiceUpdater >> stopPrimaryCommandProcessor [

	primaryQueueProcess ifNotNil: [
		primaryQueueProcess terminate.
		primaryQueueProcess := nil ]
]

{ #category : 'service queue' }
RowanServiceUpdater >> stopSecondaryCommandProcessor [

	secondaryQueueProcess ifNotNil: [
		secondaryQueueProcess terminate.
		secondaryQueueProcess := nil ]
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
			RowanServiceUpdater current logComment: 'Released inUpdate semaphore'.
			^commandResult]
]

{ #category : 'accessing' }
RowanServiceUpdater >> updates [
	^updates
]

{ #category : 'public' }
RowanServiceUpdater >> updatesPerform: selector presenter: presenter [
	"the update may know which client updates 
	it wants us to care about. Respect that."

	[
	updates do: [ :updateService |
		(self shouldApply: selector forService: updateService) ifTrue: [
			updateService perform: selector with: presenter ] ] ]
		on: Error
		do: [ :ex |
			RowanServiceUpdater current logger newLoggingService logComment:
				'RowanServiceUpdater>>#updatesPerform:presenter: - error! '
				, ex printString.
			self halt ]
]

{ #category : 'public' }
RowanServiceUpdater >> updatesPerform: selector presenter: presenter browser: browser [
	"the update may know which client updates 
	it wants us to care about if updateType is set. 
	Respect the server's wishes."

	
	[updates do: 
			[:update |
			(self shouldApply: selector forService: update)
				ifTrue: 
					[update
						perform: selector
						with: presenter
						with: browser]]]
			on: Error
			do: [:ex | self halt]
]

{ #category : 'public' }
RowanServiceUpdater >> updatesReadyToApply [

	RowanServiceUpdater current logger newLoggingService logComment:
		'RowanServiceUpdater>>#updatesReadyToApply'.
	updates isEmpty ifFalse: [ self trigger: #updatesReadyToApply ]
]
