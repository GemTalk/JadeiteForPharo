"
Coordinate client presenters with updates from the server.

returnedServices are the last services returned from the server. Handy for testing. 
"
Class {
	#name : 'BrowserUpdate',
	#superclass : 'Model',
	#instVars : [
		'updates',
		'debug',
		'inUpdate',
		'logger',
		'applyingUpdates',
		'breakpointsEnabled',
		'returnedServices'
	],
	#classVars : [
		'Current'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
BrowserUpdate class >> clearCurrent [
"
	BrowserUpdate clearCurrent.
"
	Current := nil
]

{ #category : 'accessing' }
BrowserUpdate class >> current [
	^Current ifNil: [Current := self new]
]

{ #category : 'logging' }
BrowserUpdate class >> startLogging [
	Current startLogging
]

{ #category : 'logging' }
BrowserUpdate class >> stopLogging [
	Current stopLogging
]

{ #category : 'accessing' }
BrowserUpdate >> activeClassServices [
	^self registeredListServices select: [:service | service isClassService]
]

{ #category : 'accessing' }
BrowserUpdate >> activeMethodServices [
	^self registeredListServices select: [:service | service isMethodService]
]

{ #category : 'accessing' }
BrowserUpdate >> activePackageServices [
	^self registeredListServices select: [:service | service isPackageService]
]

{ #category : 'accessing' }
BrowserUpdate >> activeServices [
	"services which are open in windows in list browsers"

	| services |
	services := OrderedCollection new.
	services addAll: self activeMethodServices.
	services addAll: self activeClassServices.
	services addAll: self activePackageServices.
	^services
]

{ #category : 'public' }
BrowserUpdate >> applyUpdateWhile: block [
	applyingUpdates := true.
	block ensure: 
			[applyingUpdates := false.
			self rowanPostUpdate]
]

{ #category : 'accessing' }
BrowserUpdate >> applyUpdatesFromReturnedServices: aCollection [
	"don't just reinitialize the updates instance variable because
	presenters are registered to that object"
	self applyUpdateWhile: 
			[updates removeAll: updates.
			updates addAll: aCollection.
			self updatesReadyToApply]
]

{ #category : 'commands' }
BrowserUpdate >> basicIssueCommand: services session: session [

	| updateResult loggedServices newLoggingService |
	self todo: [ 
		newLoggingService := logger newServiceLoggingService addServices:
			                     services.
		self logSentServices: services.
		loggedServices := services asOrderedCollection
			                  addFirst: newLoggingService;
			                  yourself ].
	services do: [ :service |  
		service prepareForReplication.
		service executeInSession: session.
		updateResult := self applyUpdatesFromReturnedServices:
			                service returnedServices ].
	self todo: [ session releaseAllOops ].
	^ updateResult
]

{ #category : 'private' }
BrowserUpdate >> basicUpdateServices: services session: session [
	services do: [:service | service command: #update].
	^self basicIssueCommand: services session: session
]

{ #category : 'accessing' }
BrowserUpdate >> breakpointsEnabled [
	^breakpointsEnabled
]

{ #category : 'accessing' }
BrowserUpdate >> breakpointsEnabled: anObject [
	breakpointsEnabled := anObject
]

{ #category : 'conversion' }
BrowserUpdate >> convertEventSymbolToClass: aSymbol [

	"conversion from Dolphin-style symbol events to Pharo-style class events"

	| classSymbolStream |
	classSymbolStream := WriteStream on: String new.
	classSymbolStream
		nextPut: aSymbol first uppercase;
		nextPutAll: (aSymbol copyFrom: 2 to: aSymbol size).
	^ Smalltalk classNamed: classSymbolStream contents
]

{ #category : 'accessing' }
BrowserUpdate >> debug [
	^debug
]

{ #category : 'accessing' }
BrowserUpdate >> debug: aBoolean [
	aBoolean
		ifTrue: 
			[Smalltalk at: #roundTrips put: 0].
	debug := aBoolean
]

{ #category : 'as yet unclassified' }
BrowserUpdate >> getEvents [

	^ nil
]

{ #category : 'private' }
BrowserUpdate >> inUpdate [
	^inUpdate ifNil: [inUpdate := RowanSemaphore forMutualExclusion]
]

{ #category : 'commands' }
BrowserUpdate >> inUpdateWhile: block [

	| result |
	result := "self inUpdate critical: [ "
		          self todo: [BrowserUpdate current logComment:
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
BrowserUpdate >> initialize [ 
	super initialize. 
	self initializeUpdates.
	debug := false.
	inUpdate := Mutex new.
	logger := JadeiteLogger new.
	breakpointsEnabled := false.
	announcer := BrowserUpdateAnnouncer new browserUpdate: self. 
]

{ #category : 'initialization' }
BrowserUpdate >> initializeUpdates [
	updates := OrderedCollection new.
	
]

{ #category : 'public' }
BrowserUpdate >> isApplyingUpdates [
	"we've come back from the server and
	are in the middle of updating browsers. 
	Send this to avoid untimely updates to
	services until updates are fully applied"

	^applyingUpdates == true
]

{ #category : 'logging' }
BrowserUpdate >> isLogging [

	^logger isLogging
]

{ #category : 'logging' }
BrowserUpdate >> isLogging: boolean [
	boolean ifTrue: [self startLogging] ifFalse: [self stopLogging]
]

{ #category : 'commands' }
BrowserUpdate >> issueCommand: service session: session [
	^self issueCommands: (Array with: service) session: session
]

{ #category : 'commands' }
BrowserUpdate >> issueCommands: services session: session [
	self inUpdateWhile: 
			[| commandResult |
			session
				ifNotNil: 
					[commandResult := self basicIssueCommand: services session: session.
					BrowserUpdate current logComment: 'Released inUpdate semaphore'.
					^commandResult]]
]

{ #category : 'logging' }
BrowserUpdate >> logComment: string [
	logger logComment: string
]

{ #category : 'accessing' }
BrowserUpdate >> logFileName [

	^logger logFileName
]

{ #category : 'accessing' }
BrowserUpdate >> logFileName: string [

	^logger logFileName: string
]

{ #category : 'logging' }
BrowserUpdate >> logReceivedServices: services [
	logger logReceivedServices: services.
	logger shouldGetNewLoggerGroup: true
]

{ #category : 'logging' }
BrowserUpdate >> logSentServices: services [
	logger logSentServices: services
]

{ #category : 'accessing' }
BrowserUpdate >> logger [
	"Private - for testing"

	^logger
]

{ #category : 'accessing' }
BrowserUpdate >> logger: anObject [
	logger := anObject
]

{ #category : 'accessing' }
BrowserUpdate >> loggingService [
	"for testing"

	^logger loggingService
]

{ #category : 'private' }
BrowserUpdate >> performUpdate: updateBlock with: selector [
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
BrowserUpdate >> register: presenter selector: selector [
	"send the update to the presenter so that when the presenter gets
	removed, it's events go with it."

	self
		when: #updatesReadyToApply
		send: #update:withSelector:
		to: presenter
		withArguments: (Array with: self with: selector)
]

{ #category : 'public' }
BrowserUpdate >> register: presenter selector: selector browser: browser [
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
BrowserUpdate >> registeredListPresenters [
	^self registeredPresenters select: [:presenter | presenter class canUnderstand: #list]
]

{ #category : 'private' }
BrowserUpdate >> registeredListServices [
	| listServices |
	listServices := OrderedCollection new.
	self registeredListPresenters do: [:listPresenter | listServices addAll: listPresenter list].
	self registeredTreePresenters do:[:treePresenter | listServices addAll: treePresenter model]. 
	^listServices
]

{ #category : 'public' }
BrowserUpdate >> registeredPresenters [

	| presenters |
	presenters := Set new.
	presenters addAll:
		((self actionMap at: #updatesReadyToApply ifAbsent:[^Array new]) collect: [ 
			 :weakMessageSend | weakMessageSend receiver ]).
	^ presenters
]

{ #category : 'private' }
BrowserUpdate >> registeredTreePresenters [
	^self registeredPresenters select: [:presenter | presenter isKindOf: TreePresenter]
]

{ #category : 'public' }
BrowserUpdate >> removeEventsTriggeredFor: anObject [
	super removeEventsTriggeredFor: anObject.
	"self
		logComment: 'Remove events triggered for ' , anObject printString , ' {'
				, anObject identityHash printString , '}'"
]

{ #category : 'private' }
BrowserUpdate >> resetInUpdate [
	inUpdate := RowanSemaphore forMutualExclusion
]

{ #category : 'initialization' }
BrowserUpdate >> resetLoggingService [
	logger loggingService: nil. 
	logger newLoggingService
]

{ #category : 'accessing' }
BrowserUpdate >> returnedServices [

	^returnedServices
]

{ #category : 'public' }
BrowserUpdate >> rowanPostUpdate [
	updates do: [:service | service postUpdateBlock ifNotNil: [:block | block value]]
]

{ #category : 'accessing' }
BrowserUpdate >> selectedServices [
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
BrowserUpdate >> selectedServicesForConnection: theConnection [

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
BrowserUpdate >> shouldApply: selector forSelector: service [
	^service updateType isNil or: 
			[service updateType == selector
				or: [service updateType isEmpty or: [service updateType includes: selector]]]
]

{ #category : 'accessing' }
BrowserUpdate >> shouldGetNewLoggerGroup: boolean [

	logger shouldGetNewLoggerGroup: boolean
]

{ #category : 'logging' }
BrowserUpdate >> startLogging [
	logger startLogging
]

{ #category : 'logging' }
BrowserUpdate >> stopLogging [
	logger stopLogging
]

{ #category : 'updating' }
BrowserUpdate >> trigger: aSymbol [

	self triggerEvent: aSymbol "(self convertEventSymbolToClass: aSymbol)"
]

{ #category : 'public' }
BrowserUpdate >> update: services afterStonReplication: stonResults [
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
BrowserUpdate >> update: browserUpdate withSelector: selector [
	browserUpdate updatesPerform: selector presenter: self. 
]

{ #category : 'updating' }
BrowserUpdate >> update: browserUpdate withSelector: selector browser: browser [
	browserUpdate
		updatesPerform: selector
		presenter: self
		browser: browser.
	(browser class canUnderstand: #redrawAllViews) ifTrue: [browser redrawAllViews]
]

{ #category : 'public' }
BrowserUpdate >> updateService: service session: session [
	^self updateServices: (Array with: service) session: session
]

{ #category : 'public' }
BrowserUpdate >> updateServices: services session: session [
	| commandResult |
	services isEmpty ifTrue: [^self].
	self inUpdateWhile: 
			[commandResult := self basicUpdateServices: services session: session.
			BrowserUpdate current logComment: 'Released inUpdate semaphore'.
			^commandResult]
]

{ #category : 'accessing' }
BrowserUpdate >> updates [
	^updates
]

{ #category : 'public' }
BrowserUpdate >> updatesPerform: selector presenter: presenter [
	"the update may know which client updates 
	it wants us to care about. Respect that."

	
	[updates do: 
			[:update |
			(self shouldApply: selector forSelector: update) ifTrue: [update perform: selector with: presenter]]]
			on: Error
			do: [:ex | self halt]
]

{ #category : 'public' }
BrowserUpdate >> updatesPerform: selector presenter: presenter browser: browser [
	"the update may know which client updates 
	it wants us to care about if updateType is set. 
	Respect the server's wishes."

	
	[updates do: 
			[:update |
			(self shouldApply: selector forSelector: update)
				ifTrue: 
					[update
						perform: selector
						with: presenter
						with: browser]]]
			on: Error
			do: [:ex | self halt]
]

{ #category : 'public' }
BrowserUpdate >> updatesReadyToApply [
	updates isEmpty ifFalse: [self trigger: #updatesReadyToApply]
]
