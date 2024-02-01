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
		'postCompletionBlock'
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

	RowanServiceUpdater current logger newLoggingService logComment:
		'RowanServiceUpdater>>#applyUpdatesFromReturnedServices:'.
	self applyUpdateWhile: [ "updates removeAll: updates."
		updates addAll: aCollection.
		self updatesReadyToApply ]
]

{ #category : 'commands' }
RowanServiceUpdater >> basicIssueCommand: services session: session onCompletion: completionBlock [

	| updateResult loggedServices newLoggingService |
	self todo: [
		newLoggingService := logger newServiceLoggingService addServices:
			                     services.
		self logSentServices: services.
		loggedServices := services asOrderedCollection
			                  addFirst: newLoggingService;
			                  yourself ].
	services do: [ :service |
		| updateAndCompleteBlock sem inCompletionBlock |
		service prepareForReplication.
		sem := Semaphore new.
		inCompletionBlock := false. 
		updateAndCompleteBlock := [ :aService |
		                          [
										inCompletionBlock := true. 
		                          updateResult := self
			                                          applyUpdatesFromReturnedServices:
			                                          service returnedServices.
		                          completionBlock ifNotNil: [
			                          completionBlock value: aService ] ]
			                          ensure: [ sem signal ] ].
		service
			executeInSession: session
			onCompletion: updateAndCompleteBlock
			semaphore: sem.
		sem wait ].
	self todo: [ session releaseAllOops ].
	^ updateResult
]

{ #category : 'private' }
RowanServiceUpdater >> basicUpdateServices: services session: session [

	services do: [ :service | service command: #update ].
	^ self basicIssueCommand: services session: session onCompletion: nil
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

	^ self
		  issueCommands: (Array with: service)
		  session: session
		  onCompletion: nil
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommand: service session: session onCompletion: completionBlock [

	^ self
		  issueCommands: (Array with: service)
		  session: session
		  onCompletion: completionBlock
]

{ #category : 'commands' }
RowanServiceUpdater >> issueCommands: services session: session onCompletion: completionBlock [

	Processor activeProcess == UIManager default uiProcess
		ifTrue: [
			[
			self
				issueDirectCommands: services
				session: session
				completionBlock: completionBlock ] fork ]
		ifFalse: [
			self
				issueDirectCommands: services
				session: session
				completionBlock: completionBlock ]
]

{ #category : 'commands' }
RowanServiceUpdater >> issueDirectCommands: services session: session completionBlock: completionBlock [

	^ self inUpdateWhile: [
		  | commandResult |
		  session ifNotNil: [
			  commandResult := self
				                   basicIssueCommand: services
				                   session: session
				                   onCompletion: completionBlock.
			  RowanServiceUpdater current logComment:
				  'Released inUpdate semaphore' ] ]
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

{ #category : 'logging' }
RowanServiceUpdater >> startLogging [
	logger startLogging
]

{ #category : 'logging' }
RowanServiceUpdater >> stopLogging [
	logger stopLogging
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
