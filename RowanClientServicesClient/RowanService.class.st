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
	#category : 'RowanClientServicesClient'
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

{ #category : 'comparing' }
RowanService >> = aService [

	^aService isRowanService
]

{ #category : 'public' }
RowanService >> addCachedSymbols: unused [
	
]

{ #category : 'public' }
RowanService >> autoCommitUpdate: browser [
]

{ #category : 'public' }
RowanService >> basicPrepareForReplication [
	"don't call anything potentially recursive here"
]

{ #category : 'public' }
RowanService >> basicReplicateFrom: newService [
	1 to: self class instSize
		do: 
			[:index |
			(self shouldReplicateInstVarAtIndex: index newService: newService)
				ifTrue: [self instVarAt: index put: (newService instVarAt: index)]]
]

{ #category : 'public' }
RowanService >> breakpointSettingChanged: transcript [
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
RowanService >> classCategoryUpdate: presenter [
	
]

{ #category : 'public' }
RowanService >> classCommentUpdate: presenter [  
	
	
]

{ #category : 'public' }
RowanService >> classDefinitionUpdate: presenter [
	
]

{ #category : 'public' }
RowanService >> classHierarchyUpdate: presenter [
	
]

{ #category : 'public' }
RowanService >> classHierarchyUpdate: presenter browser: browser [

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

{ #category : 'public' }
RowanService >> classMethodsUpdate: presenter browser: browser [
	
]

{ #category : 'public' }
RowanService >> classUpdate: presenter [
	
]

{ #category : 'public' }
RowanService >> classesHierarchyUpdate: presenter [

]

{ #category : 'public' }
RowanService >> classesUpdate: presenter browser: anObject [
	
]

{ #category : 'rsr' }
RowanService >> cleanUpService [

	_connection := nil.
	updates := nil.
	1 to: self class instSize do: [ :index |  
	self instVarAt: index put: nil ]
]

{ #category : 'Init / Release' }
RowanService >> clearCommand [

	command := nil. 
	self commandArgs: nil. 
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

{ #category : 'public' }
RowanService >> componentPackagesUpdate: presenter browser: browser [
]

{ #category : 'public' }
RowanService >> componentsUpdate: presenter browser: browser [
]

{ #category : 'accessing' }
RowanService >> data [ 
	"For printString of SpMorphicTreeTableDataSource"
	^self
]

{ #category : 'printing' }
RowanService >> debugPrintOn: aStream [
	self printOn: aStream.
	self class instVarNames do: 
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

{ #category : 'public' }
RowanService >> debuggerMethodSourceUpdate: presenter browser: browser [
]

{ #category : 'public' }
RowanService >> dictionaryListUpdate: presenter [

]

{ #category : 'public' }
RowanService >> dictionaryUpdate: presenter [
	
]

{ #category : 'commands' }
RowanService >> editInSession: aSession window: handle [
	"api for opening an editor window on a service and putting the oop in the export set for the life of the window"

	command := #editInWindow:.
	commandArgs := Array with: handle.
	self issueCommand: self session: aSession
]

{ #category : 'Init / Release' }
RowanService >> emptyFilterListsIn: browser [
	self todo:[browser hasMethods
		ifTrue: 
			[browser categoryListPresenter sortBlock: [:x :y | x < y].
			browser variableListPresenter sortBlock: [:x :y | x < y]]]
]

{ #category : 'public' }
RowanService >> excludedInstVars [

	^#( 'events' )

]

{ #category : 'rsr' }
RowanService >> executeCommand [

	| activeProcess newUIProcess |
	activeProcess := Processor activeProcess.
	[
	| promise |
	promise := remoteSelf executeCommand.
	[ promise wait ]
		on: Error
		do: [ :ex |
			activeProcess terminate.
			RowanServiceUpdater current resetInUpdate.
			^ ex pass ].
	command := nil.
	commandArgs := nil.
	UIManager default resumeUIProcess: activeProcess.
	newUIProcess
		suspend;
		terminate ] fork.
	[
	DefaultExecutionEnvironment beActiveDuring: [
		UIManager default spawnNewProcess.
		newUIProcess := UIManager default uiProcess ] ] ensure: [
		activeProcess suspend ].
	Processor yield. "let the newUIProcess terminate"
	self raiseCompileErrorIfNeeded
]

{ #category : 'rsr' }
RowanService >> executeInSession: session [

	[self registerWith:
		          session library] on: RsrAlreadyRegistered do:[:ex | ].
	^ self executeCommand
]

{ #category : 'public' }
RowanService >> filterUpdate: presenter browser: anObject [
	
]

{ #category : 'Debugger' }
RowanService >> frameListUpdate: aPresenter [
]

{ #category : 'public' }
RowanService >> globalsUpdate: presenter [
]

{ #category : 'Init / Release' }
RowanService >> initialize [
	commandArgs := Array new
]

{ #category : 'Init / Release' }
RowanService >> initializePresenterList: presenter [
	self todo: [presenter sortBlock: [:x :y | x sortAspect < y sortAspect]].
	self todo:[presenter list: ListModel new "needed?"]
]

{ #category : 'public' }
RowanService >> isAnsweringService [

	^false
]

{ #category : 'public' }
RowanService >> isBrowserService [

	^false
]

{ #category : 'public' }
RowanService >> isClassService [

	^false
]

{ #category : 'testing' }
RowanService >> isCompileError [

	^false
]

{ #category : 'public' }
RowanService >> isComponentService [
	^false
]

{ #category : 'public' }
RowanService >> isDefinedProject [

	^true
]

{ #category : 'public' }
RowanService >> isDefinitionService [

	^false
]

{ #category : 'public' }
RowanService >> isDictionaryService [

	^false
]

{ #category : 'testing' }
RowanService >> isFiller [

	^false
]

{ #category : 'public' }
RowanService >> isInspectorService [

	^false
]

{ #category : 'public' }
RowanService >> isLoggingService [

	^false
]

{ #category : 'public' }
RowanService >> isMethodService [

	^false
]

{ #category : 'public' }
RowanService >> isPackageService [

	^false
]

{ #category : 'public' }
RowanService >> isProjectService [

	^false
]

{ #category : 'testing' }
RowanService >> isRowanService [

	^true
]

{ #category : 'public' }
RowanService >> isService [
	^true
]

{ #category : 'public' }
RowanService >> isTestCase [

	^false
]

{ #category : 'public' }
RowanService >> isUpdatableService [
	^true
]

{ #category : 'commands' }
RowanService >> issueCommand: service session: session [
	^self issueCommands: (Array with: service) session: session
]

{ #category : 'commands' }
RowanService >> issueCommands: services session: session [
	^RowanServiceUpdater current issueCommands: services session: session
]

{ #category : 'public' }
RowanService >> jadeiteShouldNotUpdateOnClient [
	"something bad probably happened on the server in the services infrastructure
	as the server told us not to do a client update. "
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

{ #category : 'public' }
RowanService >> methodFilterUpdate: presenter [
	
]

{ #category : 'must not strip' }
RowanService >> methodHistoryUpdated: historyBrowser [
	
]

{ #category : 'public' }
RowanService >> methodListUpdate: presenter browser: browser [
]

{ #category : 'public' }
RowanService >> methodSourceUpdate: presenter browser: anObject [
	
]

{ #category : 'public' }
RowanService >> methodUpdate: presenter browser: anObject [
	
]

{ #category : 'public' }
RowanService >> methodsUpdate: presenter [
	
]

{ #category : 'accessing' }
RowanService >> name [
	^nil
]

{ #category : 'public' }
RowanService >> newProject: presenter [
]

{ #category : 'displaying' }
RowanService >> notRowanizedPackageName [
	^self class notRowanizedPackageName
]

{ #category : 'public' }
RowanService >> packageGroupUpdate: presenter browser: browser [
]

{ #category : 'accessing' }
RowanService >> packageServices [
	"most services do not have packages"

	^Array new
]

{ #category : 'public' }
RowanService >> packageUpdate: presenter [
]

{ #category : 'public' }
RowanService >> packagesUpdate: presenter [
]

{ #category : 'public' }
RowanService >> packagesUpdate: presenter browser: browser parentPresenter: parentPresenter [
	| packageServices selectedComponentPackages |
	(presenter class canUnderstand: #list) ifFalse: [^self].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	parentPresenter selections detect: [:service | service name = self name] ifNone: [^self].
	self todo:[selectedComponentPackages := (browser packageGroupPresenter selectionIfNone: [])
				ifNil: [self packageServices]
				ifNotNil: [:componentService | componentService packageServices]].
	packageServices := selectedComponentPackages
				ifNil: [self packageServices]
				ifNotNil: [self packageServices intersection: selectedComponentPackages].
	self
		updateList: presenter
		whilePreservingSelections: packageServices
		browser: browser.
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]
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

	super printOn: aStream. 
	[aStream nextPut: $:. 
	aStream nextPutAll: (self name ifNil: [nil printString])] on: Error do:[:ex | aStream nextPutAll: 'Error printing service name: '; print: ex]. 
]

{ #category : 'Debugger' }
RowanService >> processListUpdate: aPresenter [
]

{ #category : 'public' }
RowanService >> projectPackagesUpdate: aPresenter browser: anObject [
	
]

{ #category : 'public' }
RowanService >> projectSelectionUpdate: aPresenter [

]

{ #category : 'public' }
RowanService >> projectsUpdate: aPresenter [
]

{ #category : 'public' }
RowanService >> projectsUpdate: presenter browser: browser [
]

{ #category : 'rsr' }
RowanService >> raiseCompileErrorIfNeeded [

	updates ifNotNil: [
		updates isEmpty ifFalse: [
			updates first isCompileError ifTrue: [
				GsCompileError signal: updates first gsArguments ] ] ]
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

{ #category : 'public' }
RowanService >> removedClass: aPresenter [
]

{ #category : 'public' }
RowanService >> removedProject: presenter [
]

{ #category : 'public' }
RowanService >> renamedClass: aClassService browser: anObject [
	
]

{ #category : 'public' }
RowanService >> renamedClassInHierarchy: presenter browser: anObject [
	
]

{ #category : 'public' }
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

{ #category : 'public' }
RowanService >> shouldReplicateInstVarAtIndex: index newService: anObject [

	((1 to: 5) includes: index) ifTrue: [ ^ false ]. "rsr inst vars + command + commandArgs"
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

{ #category : 'double dispatch' }
RowanService >> silentlyExpandHierarchyOneLevel: treeView [
	
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

{ #category : 'public' }
RowanService >> sunitMethodsUpdate: presenter browser: browser [
]

{ #category : 'public' }
RowanService >> superclassListUpdate: presenter [
	
]

{ #category : 'public' }
RowanService >> testClasses: presenter browser: anObject [
	
]

{ #category : 'public' }
RowanService >> testPackages: presenter [
]

{ #category : 'public' }
RowanService >> testResultUpdate: presenter browser: anObject [
	
]

{ #category : 'printing' }
RowanService >> toolTip [
	^self displayString

]

{ #category : 'public' }
RowanService >> updateBreakPoints: presenter browser: browser [
]

{ #category : 'public' }
RowanService >> updateClassCategorySelectionsFor: presenter [
]

{ #category : 'public' }
RowanService >> updateClassHierarchySelectionFor: presenter [
]

{ #category : 'public' }
RowanService >> updateClassSelectionFor: presenter [
]

{ #category : 'public' }
RowanService >> updateDictionarySelectionsFor: presenter [
	
]

{ #category : 'actions' }
RowanService >> updateForSession: session [

	"will not work for some services but does for many"
	
	self
		command: #update;
		commandArgs: Array new. 
	RowanServiceUpdater current issueCommands: (Array with: self) session: session
]

{ #category : 'private' }
RowanService >> updateList: presenter whilePreservingSelections: updates browser: anObject [
	| replicate bag |
	bag := presenter list asBag.
	bag do: 
			[:service |
			replicate := updates detect: [:update | update = service] ifNone: [nil].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	updates
		do: [:update | ((bag includes: update) and: [update wasRenamed not]) ifFalse: [presenter model add: update]].
	bag do: 
			[:service |
			(updates includes: service)
				ifFalse: [service = RowanProjectService noneProject ifFalse: [presenter model remove: service]]]
]

{ #category : 'public' }
RowanService >> updateMethodFilterSelectionFor: presenter [
]

{ #category : 'public' }
RowanService >> updateMethodSelectionFor: presenter [
]

{ #category : 'public' }
RowanService >> updatePackageSelectionsFor: presenter [
	
]

{ #category : 'public' }
RowanService >> updateSelectorFor: presenter [
]

{ #category : 'public' }
RowanService >> updateSuperclassSelectionFor: presenter [
]

{ #category : 'public' }
RowanService >> updateSymbols: unused [
]

{ #category : 'accessing' }
RowanService >> updateType [
	^updateType
]

{ #category : 'accessing' }
RowanService >> updateType: anObject [
	updateType := anObject
]

{ #category : 'public' }
RowanService >> updateVariable: listPresenter debugger: anObject [
	
]

{ #category : 'public' }
RowanService >> updatedClass: aPresenter browser: browser [
	
]

{ #category : 'public' }
RowanService >> updatedClassDefinition: classDefinitionPresenter browser: browser [

	
	
]

{ #category : 'public' }
RowanService >> updatedClassInHierarchy: aPresenter browser: projectBrowser [
]

{ #category : 'public' }
RowanService >> updatedOneLevelInClassHierarchy: classHierarchyPresenter browser: projectBrowser [
]

{ #category : 'accessing' }
RowanService >> updates [

	^ updates
]

{ #category : 'accessing' }
RowanService >> updates: anObject [

	updates := anObject
]

{ #category : 'Debugger' }
RowanService >> variableDataUpdate: aPresenter [
]

{ #category : 'Debugger' }
RowanService >> variableListUpdate: aPresenter [
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
