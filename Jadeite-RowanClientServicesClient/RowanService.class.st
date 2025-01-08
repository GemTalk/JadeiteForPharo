Class {
	#name : 'RowanService',
	#superclass : 'RsrService',
	#instVars : [
		'command',
		'commandArgs',
		'updateType',
		'organizer',
		'updates',
		'wasUpdated',
		'shouldUpdate'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
RowanService class >> command: symbol withArgs: array [
	| inst |
	inst := self new.
	inst
		command: symbol;
		commandArgs: array.
	^inst
]

{ #category : 'private' }
RowanService class >> defaultIcon [
	"Answer a suitable default icon to use for this class. Not all classes use their 
	default icon; one must define an appropriate #icon method in each class where the 
	icon required differs from that of the superclass."

	^(self environment at: #Icon) fromId: self defaultIconName.

]

{ #category : 'private' }
RowanService class >> defaultIconName [
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Model' extension: 'ico'.
]

{ #category : 'private' }
RowanService class >> icon [
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon
]

{ #category : 'ast' }
RowanService class >> lookupVar: aName [
	"Used for styling code in ast's (abstract syntax trees) 
	For now just assume this is a class service.
	Eventually, return a global service if it's not a class"

	| classService |
	true ifTrue:[^super lookupVar: aName]. 
	classService := (RowanClassService named: aName). "command: #update; commandArgs: #().
	BrowserUpdate current issueCommand: classService session: GciSession current. "
	^ GlobalVariable key: aName asSymbol value: classService
]

{ #category : 'initialization' }
RowanService class >> new [
	| rsrInstance |
	(self name last: 6) = 'Client' ifTrue:[^super new initialize]. 
	rsrInstance := (Smalltalk at: (self name, 'Client')) basicNew.	
	^rsrInstance initialize
]

{ #category : 'constants' }
RowanService class >> notRowanizedPackageName [
	^'(NONE)'
]

{ #category : 'public' }
RowanService class >> rowanClientServicesVersionLowerLimit [
	^'3.0.7'
]

{ #category : 'accessing' }
RowanService class >> templateClassName [

	^#RowanService
]

{ #category : 'service completion' }
RowanService >> _handleServiceCompletionBlock [

	self serviceCompletionBlock ifNil: [
		^ self "sometimes bad timing can happen during automated tests" ].
	[ self serviceCompletionBlock cull: self ] ensure: [
		self serviceCompletionBlock: nil ]
]

{ #category : 'replication' }
RowanService >> basicPrepareForReplication [
	"don't call anything potentially recursive here"
]

{ #category : 'replication' }
RowanService >> basicReplicateFrom: newService [
	1 to: self class instSize
		do: 
			[:index |
			(self shouldReplicateInstVarAtIndex: index newService: newService)
				ifTrue: [self instVarAt: index put: (newService instVarAt: index)]].
]

{ #category : 'accessing' }
RowanService >> catchBlock [
	"some services need special processing in case of error or terminated remote process"

	^ [  ]
]

{ #category : 'private' }
RowanService >> chooseModel: presenter using: browser [
	| treeModel |
	treeModel := browser projectListPresenter selectionOrNil isNil
				ifTrue: 
					[JadeiteTreeModel new
						searchPolicy: SearchPolicy equality;
						reset]
				ifFalse: [presenter model].
	^treeModel
]

{ #category : 'public' }
RowanService >> classHierarchyUpdate: presenter browser: browser hierarchyServices: hierarchyServices [
	| treeModel subclasses parent |
	browser isHierarchyTabSelected ifFalse: [^self].
	hierarchyServices ifNil: [^self].
	hierarchyServices isEmpty ifTrue: [^self].
	presenter selectedItem isNil ifFalse: [(presenter selectedItem = self) ifFalse: [^self]].
	treeModel := presenter.
	parent := nil.
	subclasses := hierarchyServices at: #nil ifAbsent: [].
	presenter roots: subclasses. 
	subclasses do: 
			[:classService |
			self
				possiblyAddHierarchyService: classService
				to: treeModel
				withParent: parent
				hierarchyServices: hierarchyServices].
	presenter expandAll. 
]

{ #category : 'rsr' }
RowanService >> cleanUpService [

	_connection := nil.
	updates := nil.
	1 to: self class instSize do: [ :index |  
	self instVarAt: index put: nil ]
]

{ #category : 'public' }
RowanService >> clientDefinitionClass [

	^self subclassResponsibility
]

{ #category : 'accessing' }
RowanService >> codePoint [
	"trapping difficult to find error" 
	self halt. 
]

{ #category : 'accessing' }
RowanService >> command [
	^command
]

{ #category : 'accessing' }
RowanService >> command: symbol [
	command := symbol.
	commandArgs ifNil: [ commandArgs := Array new ]
	
]

{ #category : 'accessing' }
RowanService >> commandArgs [
	^commandArgs
]

{ #category : 'accessing' }
RowanService >> commandArgs: anObject [
	commandArgs := anObject
]

{ #category : 'accessing' }
RowanService >> data [ 
	"For printString of SpMorphicTreeTableDataSource"
	^self
]

{ #category : 'printing' }
RowanService >> debugPrintOn: aStream [
	self printOn: aStream.
	self class allInstVarNames do: 
			[:instVarName |
			aStream
				tab;
				nextPutAll: instVarName;
				nextPut: $:;
				space;
				nextPutAll: (self instVarNamed: instVarName) printString;
				cr]
]

{ #category : 'printing' }
RowanService >> debugPrintString [
	| ws |
	ws := WriteStream on: String new.
	self debugPrintOn: ws.
	^ws contents
]

{ #category : 'commands' }
RowanService >> editInSession: aSession window: handle [
	"api for opening an editor window on a service and putting the oop in the export set for the life of the window"

	command := #editInWindow:.
	commandArgs := Array with: handle.
	self issueCommand: self session: aSession
]

{ #category : 'public' }
RowanService >> excludedInstVars [

	^#( 'events' )

]

{ #category : 'rsr' }
RowanService >> executeCommandOnCompletion: completionBlock [

	| promise theCompletionBlock process |
	process := Processor activeProcess.
	theCompletionBlock := completionBlock ifNil: [ [ :unused |  ] ].
	promise := remoteSelf executeCommand.
	promise
		when: [ :arg | theCompletionBlock value: arg ]
		catch: [ :value |
			[
			RowanServiceUpdater current isLogging ifTrue: [ value traceCr ].
			value tag = 'rsrProcessTerminated' ifTrue: [
				RowanServiceUpdater current logComment: 'rsrProcessTerminated' ].
			self terminate: process error: value.
			self raiseCompileErrorIfNeeded.
			self catchBlock cull: value ] ensure: [ self inCommand signal ] ]
]

{ #category : 'rsr' }
RowanService >> executeInSession: session onCompletion: completionBlock [
	[ self registerWith: session library ]
		on: RsrAlreadyRegisteredWithAnotherConnection
		do: [ :ex |  ].
	^ self executeCommandOnCompletion: completionBlock
]

{ #category : 'public' }
RowanService >> filterUpdate: presenter browser: anObject [
	
]

{ #category : 'actions' }
RowanService >> handleCompileError: compileError [

	compileError pass
]

{ #category : 'service completion' }
RowanService >> handleServiceCompletion [

	self serviceCompletionBlock ifNotNil: [
		self _handleServiceCompletionBlock ]
]

{ #category : 'inCommand' }
RowanService >> inCommand [
	"return self for subclasses that don't implement inCommand"

	"inCommand is only defined on the client and not replicated to the server as it's a Semaphore. 
	Therefore, only define the inst var inCommand in client-only subclasses. RSR's quirky design 
	requires this - can't define a 'client only' inst var in a super class, unfortunately.
	
	The purpose of the inCommand semaphore is to prevent issuing more than one command 
	to a service at a time. RSR will override values on the server!"

	^false
]

{ #category : 'inCommand' }
RowanService >> inCommand: semaphore [

	"do nothing - only some subclasses implement"
]

{ #category : 'accessing' }
RowanService >> indexOfInCommandInstVar [
	"some services don't have inCommand"

	^-1 
]

{ #category : 'accessing' }
RowanService >> indexOfServiceCompletionBlock [
	"some services don't have serviceCompletionBlock"

	^-1 
]

{ #category : 'Init / Release' }
RowanService >> initialize [

	commandArgs := Array new.
	self inCommand: RowanSemaphore new
]

{ #category : 'Init / Release' }
RowanService >> initializePresenterList: presenter [
	self todo: [presenter sortBlock: [:x :y | x sortAspect < y sortAspect]].
	self todo:[presenter list: ListModel new "needed?"]
]

{ #category : 'testing' }
RowanService >> isAnsweringService [

	^false
]

{ #category : 'testing' }
RowanService >> isBrowserService [

	^false
]

{ #category : 'testing' }
RowanService >> isClassService [

	^false
]

{ #category : 'testing' }
RowanService >> isCompileError [

	^false
]

{ #category : 'testing' }
RowanService >> isComponentService [
	^false
]

{ #category : 'testing' }
RowanService >> isDefinedProject [

	^true
]

{ #category : 'testing' }
RowanService >> isDefinitionService [

	^false
]

{ #category : 'testing' }
RowanService >> isDictionaryService [

	^false
]

{ #category : 'testing' }
RowanService >> isFiller [

	^false
]

{ #category : 'inCommand' }
RowanService >> isInCommand [
	"only client subclasses have the instVar inCommand"

	(self class instVarNames includes: #inCommand) ifTrue: [
		^ self inCommand lockingProcess isNil not ].
	^ false
]

{ #category : 'testing' }
RowanService >> isInspectorService [

	^false
]

{ #category : 'testing' }
RowanService >> isLoggingService [

	^false
]

{ #category : 'testing' }
RowanService >> isMethodService [

	^false
]

{ #category : 'testing' }
RowanService >> isPackageService [

	^false
]

{ #category : 'testing' }
RowanService >> isProjectService [

	^false
]

{ #category : 'testing' }
RowanService >> isService [
	^true
]

{ #category : 'testing' }
RowanService >> isTestCase [

	^false
]

{ #category : 'testing' }
RowanService >> isUpdatableService [
	^true
]

{ #category : 'commands' }
RowanService >> issueCommand: service session: session [

	^ RowanServiceUpdater current issueCommand: service session: session onCompletion: [  ]
]

{ #category : 'commands' }
RowanService >> issueCommands: services session: session onCompletion: completionBlock [

	^ RowanServiceUpdater current
		  issueCommands: services
		  session: session
		  onCompletion: completionBlock
]

{ #category : 'rsr' }
RowanService >> jadeiteConfirm: aString [

	^UIManager default confirm: aString
]

{ #category : 'rsr' }
RowanService >> jadeiteInspect: anOop [

	JadeiteInspectorApplication
		show: anOop
		onSession: GciSession current library
]

{ #category : 'rsr' }
RowanService >> jadeiteNotify: aString [

	^UIManager default alert:  aString 
]

{ #category : 'public' }
RowanService >> jadeiteShouldNotUpdateOnClient [
	"something bad probably happened on the server in the services infrastructure
	as the server told us not to do a client update. "
]

{ #category : 'printing' }
RowanService >> lineDelimiter [

	^ OSPlatform current isWindows
		  ifTrue: [ String crlf ]
		  ifFalse: [ String lf ]
]

{ #category : 'logging' }
RowanService >> logCommand: contextPrintString [
	self logCommand: contextPrintString with: String new
]

{ #category : 'logging' }
RowanService >> logCommand: contextPrintString with: additionalLogging [
	RowanServiceUpdater current logger newLoggingService logComment:
		contextPrintString , ' ' , self printString, ' ', additionalLogging
]

{ #category : 'printing' }
RowanService >> logOn: aStream [
	aStream nextPutAll: self class name
]

{ #category : 'printing' }
RowanService >> logReceivedOn: aStream [
	aStream
		nextPutAll: self class name;
		space;
		nextPut: ${;
		print: self identityHash;
		nextPut: $}
]

{ #category : 'printing' }
RowanService >> logReceivedString [
	| ws |
	ws := WriteStream on: String new.
	self logReceivedOn: ws.
	^ws contents
]

{ #category : 'printing' }
RowanService >> logSentOn: aStream [
	aStream
		nextPutAll: self class name;
		space;
		nextPutAll: 'command: ';
		nextPutAll: command.
	commandArgs
		ifNotNil: 
			[commandArgs isEmpty
				ifFalse: 
					[aStream
						tab;
						nextPutAll: commandArgs printString]]
]

{ #category : 'printing' }
RowanService >> logSentString [
	| ws |
	ws := WriteStream on: String new.
	self logSentOn: ws.
	^ws contents
]

{ #category : 'printing' }
RowanService >> logString [
	| ws |
	ws := WriteStream on: String new.
	self logOn: ws.
	^ws contents
]

{ #category : 'accessing' }
RowanService >> name [
	^nil
]

{ #category : 'public' }
RowanService >> newClass: presenter [
]

{ #category : 'public' }
RowanService >> newProject: presenter [
]

{ #category : 'testing' }
RowanService >> notAlwaysForked [

	^true 
]

{ #category : 'displaying' }
RowanService >> notRowanizedPackageName [
	^self class notRowanizedPackageName
]

{ #category : 'accessing' }
RowanService >> packageServices [
	"most services do not have packages"

	^Array new
]

{ #category : 'public' }
RowanService >> packagesUpdate: presenter browser: browser parentPresenter: parentPresenter [

	| packageServices selectedComponentPackages |
	(presenter class canUnderstand: #list) ifFalse: [ ^ self ].
	presenter list isEmpty ifTrue: [
		self initializePresenterList: presenter ].
	parentPresenter selectedItems
		detect: [ :service | service name = self name ]
		ifNone: [ ^ self ].
	self todo: [
		selectedComponentPackages := (browser packageGroupPresenter
			                              selectionIfNone: [  ])
			                             ifNil: [ self packageServices ]
			                             ifNotNil: [ :componentService |
			                             componentService packageServices ] ].
	packageServices := selectedComponentPackages
		                   ifNil: [ self packageServices ]
		                   ifNotNil: [
		                   self packageServices intersection:
			                   selectedComponentPackages ].
	self
		updateList: presenter
		whilePreservingSelections: packageServices
		browser: browser
]

{ #category : 'private' }
RowanService >> possiblyAddComponent: service to: treeModel withParent: parentService hierarchyServices: hierarchyServices [
	| node |
	node := treeModel getNodeFor: service
				ifAbsent: 
					[treeModel add: service asChildOf: parentService.
					treeModel getNodeFor: service].
	node visited: true.
	(hierarchyServices at: service ifAbsent: [^self]) do: 
			[:aService |
			self
				possiblyAddHierarchyService: aService
				to: treeModel
				withParent: service
				hierarchyServices: hierarchyServices]
]

{ #category : 'private' }
RowanService >> possiblyAddHierarchyService: classService to: treeModel withParent: parentService hierarchyServices: hierarchyServices [

	| theSubclassServices |
	theSubclassServices := hierarchyServices
		                       at: classService
		                       ifAbsent: [ ^ nil ].
	classService subclassServices: theSubclassServices.
	theSubclassServices do: [ :subclassService | 
		self
			possiblyAddHierarchyService: subclassService 
			to: treeModel
			withParent: classService
			hierarchyServices: hierarchyServices ]
]

{ #category : 'rsr' }
RowanService >> postRegistration [

	super postRegistration.
	_connection announcer
		when: RsrConnectionClosed
		send: #cleanUpService
		to: self
]

{ #category : 'public' }
RowanService >> postReload [
	"most services will do nothing"

	
]

{ #category : 'accessing' }
RowanService >> postUpdateBlock [
	"RowanAutoCommitService is the only use now. 
	Pushed the inst var to that class to conform with RSR
	replication protocols."

	^nil
]

{ #category : 'rsr' }
RowanService >> preUpdate [

	^ self copy
]

{ #category : 'replication' }
RowanService >> preUpdate: browser [

	
]

{ #category : 'replication' }
RowanService >> prepareForReplication [

	"only replicate what is absolutely necessary. Each service knows how to do that. 
	This method prepares each command arg as well"

	self basicPrepareForReplication.
	commandArgs
		ifNil: [ commandArgs := Array new ]
		ifNotNil: [ :args | args prepareForReplication ].
	updates := Array new
]

{ #category : 'printing' }
RowanService >> printOn: aStream [

	[
	aStream
		nextPutAll: self class name;
		nextPut: $:;
		nextPutAll: (self name ifNil: [ nil printString ]);
		space;
		nextPut: ${;
		nextPutAll: self identityHash printString;
		nextPut: $};
		space;
		nextPut: $(;
		nextPutAll: command printString;
		nextPutAll: '->';
		nextPutAll: commandArgs printString;
		nextPut: $) ]
		on: Error
		do: [ :ex |
			aStream
				nextPutAll: 'Error printing service name: ';
				print: ex ]
]

{ #category : 'rsr' }
RowanService >> raiseCompileErrorIfNeeded [
 
	self isCompileError ifTrue: [ self signalCompileError ]
]

{ #category : 'must not strip' }
RowanService >> remoteServiceName [
	self subclassResponsibility
]

{ #category : 'private' }
RowanService >> removeDeletedClassesIn: presenter browser: browser classes: theClasses [
	| updatedClasses removedClasses renamedClassNames |
	theClasses ifNil: [ ^self ].
	updatedClasses := theClasses select: [:classService | classService packageName = self name]
				thenCollect: [:classService | classService name asString].
	removedClasses := presenter list
				select: [:classService | classService packageName = self name and: [(updatedClasses includes: classService name) not]].
	renamedClassNames := theClasses collect: [:classService | classService renamedName].
	removedClasses := removedClasses
				reject: [:classService | renamedClassNames includes: classService name].
	removedClasses do: 
			[:removedClassService |
			(presenter selections includes: removedClassService)
				ifTrue: [self todo:[presenter view noEventsDo: [presenter view resetSelection]]]].
	removedClasses isEmpty ifTrue: [^self].
	self todo:[presenter model
		setList: (ListModel withAll: (presenter list asArray copyWithoutAll: removedClasses))
		searchPolicy: SearchPolicy equality]
]

{ #category : 'public' }
RowanService >> removed: presenter [
	| service |
	(updateType = #removed:) ifFalse: [^self	"server must tell us to remove service"].
	service := presenter model asBag detect: [:svc | svc = self] ifNone: [^self].
	presenter model remove: service.
	presenter resetSelection
]

{ #category : 'replication' }
RowanService >> replicateFrom: newService [
	(newService class = self class and: [newService name = self name])
		ifTrue: [self basicReplicateFrom: newService]
]

{ #category : 'accessing' }
RowanService >> returnedServices [

	"we return ourselves in RSR + updates"
	^(Array with: self), updates
]

{ #category : 'Init / Release' }
RowanService >> rowanPostUpdate [
	"Give the service a chance to clean up unnecessary objects after replication"

	
]

{ #category : 'service completion' }
RowanService >> serviceCompletionBlock [
	"only some subclasses have serviceCompletionBlock"
	^nil
]

{ #category : 'service completion' }
RowanService >> serviceCompletionBlock: anObject [
	"only some subclasses have serviceCompletionBlock"

	
]

{ #category : 'replication' }
RowanService >> shouldReplicateInstVarAtIndex: index newService: anObject [

	((1 to: 5) includes: index) ifTrue: [ ^ false ]. "rsr inst vars + command + commandArgs"
	self indexOfInCommandInstVar = index ifTrue: [ ^ false ].
	self indexOfServiceCompletionBlock = index ifTrue: [ ^ false ].
	^ true
]

{ #category : 'accessing' }
RowanService >> shouldUpdate [

	^ shouldUpdate
]

{ #category : 'accessing' }
RowanService >> shouldUpdate: anObject [

	shouldUpdate := anObject
]

{ #category : 'inCommand' }
RowanService >> signal [ 

	" do nothing "
]

{ #category : 'actions' }
RowanService >> signalCompileError [

	"only a compile error service takes action"
]

{ #category : 'must not strip' }
RowanService >> stonOn: stonWriter [
	| instanceVariableNames |
	(instanceVariableNames := self class allInstVarNames
				reject: [:iv | self excludedInstVars includes: iv]) isEmpty
		ifTrue: [stonWriter writeObject: self do: [stonWriter encodeMap: #()]]
		ifFalse: 
			[stonWriter writeObject: self
				streamMap: 
					[:dictionary |
					instanceVariableNames do: 
							[:each |
							(self instVarNamed: each)
								ifNotNil: [:value | dictionary at: each asSymbol put: value]
								ifNil: [self stonShouldWriteNilInstVars ifTrue: [dictionary at: each asSymbol put: nil]]]]]
]

{ #category : 'rsr' }
RowanService >> terminate: process error: value [

	process
		suspend;
		terminate.
]

{ #category : 'printing' }
RowanService >> toolTip [
	^self displayString

]

{ #category : 'actions' }
RowanService >> updateForSession: session [
	"will not work for some services but does for many"

	self
		command: #update;
		commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'private' }
RowanService >> updateList: presenter whilePreservingSelections: theUpdates browser: anObject [

	| replicate bag |
	bag := presenter list asBag.
	bag do: [ :service |
		replicate := theUpdates
			             detect: [ :update | update = service ]
			             ifNone: [ nil ].
		replicate notNil ifTrue: [ service replicateFrom: replicate ] ].
	theUpdates do: [ :update |
		((bag includes: update) and: [ update wasRenamed not ]) ifFalse: [
			presenter model add: update ] ].
	bag do: [ :service |
		(theUpdates includes: service) ifFalse: [
			service = RowanProjectService noneProject ifFalse: [
				presenter model remove: service ifAbsent: [  ] ] ] ].
	presenter model beSorted
]

{ #category : 'accessing' }
RowanService >> updateType [
	^updateType
]

{ #category : 'accessing' }
RowanService >> updateType: anObject [
	updateType := anObject
]

{ #category : 'accessing' }
RowanService >> updates [

	^ updates
]

{ #category : 'accessing' }
RowanService >> updates: anObject [

	updates := anObject
]

{ #category : 'inCommand' }
RowanService >> wait [ 

	"do nothing"
]

{ #category : 'public' }
RowanService >> wasRenamed [
	"not all services can be renamed"

	^false
]

{ #category : 'accessing' }
RowanService >> wasUpdated [
	^wasUpdated
]

{ #category : 'accessing' }
RowanService >> wasUpdated: anObject [
	wasUpdated := anObject
]
