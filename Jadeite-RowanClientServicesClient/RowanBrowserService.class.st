Class {
	#name : 'RowanBrowserService',
	#superclass : 'RowanService',
	#instVars : [
		'projects',
		'removedMethods',
		'allClasses',
		'hierarchyServices',
		'testPackages',
		'testCount',
		'dictionaries',
		'selectedClass',
		'newCachedSelectors',
		'newCachedClasses'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanBrowserService class >> templateClassName [

	^#RowanBrowserService
]

{ #category : 'comparing' }
RowanBrowserService >> = browserService [
	^browserService isService and:[browserService isBrowserService]
]

{ #category : 'accessing' }
RowanBrowserService >> allClasses [
	^allClasses
]

{ #category : 'accessing' }
RowanBrowserService >> allClasses: theClasses [
	allClasses := theClasses
]

{ #category : 'public' }
RowanBrowserService >> basicPrepareForReplication [
	"don't call anything potentially recursive here.
	method services don't iterate over subcollections"

	removedMethods
		ifNotNil: [removedMethods do: [:methodService | methodService basicPrepareForReplication]].
	dictionaries := nil .
	
]

{ #category : 'public' }
RowanBrowserService >> classHierarchyUpdate: presenter browser: browser [
	browser isHierarchyTabSelected ifFalse: [^false].
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices
]

{ #category : 'public' }
RowanBrowserService >> dictionaryListUpdate: presenter [
	"no sort. dictionaries maintain their server order"
	| removals replicate |	
	presenter list isEmpty ifTrue: [presenter list: ListModel new].
	dictionaries ifNil: [ ^self ].
	removals := presenter list reject: [:dictionaryService | dictionaries includes: dictionaryService].
	presenter model removeAll: removals.
	presenter list copy do: 
			[:service |
			replicate := dictionaries detect: [:update | update = service] ifNone: [nil].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	1 to: dictionaries size
		do: 
			[:index |
			(dictionaries at: index) = (presenter model at: index ifAbsent: [RowanDictionaryService new])
				ifFalse: [presenter model add: (dictionaries at: index). self todo:[ self afterIndex: index - 1 "not working yet"]]]
]

{ #category : 'displaying' }
RowanBrowserService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'public' }
RowanBrowserService >> excludedInstVars [
	^super excludedInstVars , #('hierarchyServices')
]

{ #category : 'initialization' }
RowanBrowserService >> initialize [
	super initialize.
	allClasses := OrderedCollection new
]

{ #category : 'public' }
RowanBrowserService >> isBrowserService [

	^true
]

{ #category : 'accessing' }
RowanBrowserService >> name [
	"browser services aren't named, but (for convenience) can respond"

	^nil
]

{ #category : 'accessing' }
RowanBrowserService >> name: aString [
	name := aString asString
]

{ #category : 'commands' }
RowanBrowserService >> newProjectNamed: projectName session: session windowHandle: handle [
	self
		command: #newProjectNamed:windowHandle:;
		commandArgs: (Array with: projectName with: handle).
	RowanServiceUpdater current issueCommands: (Array with: self) session: session
]

{ #category : 'public' }
RowanBrowserService >> prepareForReplication [
	super prepareForReplication.
	self basicPrepareForReplication
]

{ #category : 'printing' }
RowanBrowserService >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	command
		ifNotNil: 
			[aStream
				nextPutAll: 'command: ';
				print: command;
				space;
				nextPutAll: 'commandArgs: ';
				print: commandArgs].
	aStream nextPut: $)
]

{ #category : 'accessing' }
RowanBrowserService >> projects [
	^projects sorted
]

{ #category : 'public' }
RowanBrowserService >> projectsUpdate: presenter [

	| removals |
	projects isNil ifTrue: [ ^ self ].
	presenter list isEmpty ifTrue: [
		self initializePresenterList: presenter ].
	removals := presenter list select: [ :projectService |
		            (projects includes: projectService) not ].
	presenter model removeAll: removals.
	self
		updateList: presenter
		whilePreservingSelections: projects
		browser: nil
]

{ #category : 'public' }
RowanBrowserService >> projectsUpdate: presenter browser: browser [
	| removals |
	projects isNil ifTrue:[^self].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	removals := presenter list select: 
					[:projectService |
					(projects includes: projectService) not].
	presenter model removeAll: removals.
	presenter selections isEmpty ifTrue: [browser updateProjectPackages].
	self
		updateList: presenter
		whilePreservingSelections: projects
		browser: browser.
	browser refreshProjectInfoTab
]

{ #category : 'commands' }
RowanBrowserService >> registerWindow: handle rootObject: oop session: session [
	RowanServiceUpdater current
		logComment: 'Register window handle: ' , handle printString , ' {' , self identityHash printString
				, '}'.
	self
		command: #saveRootObject:windowHandle:;
		commandArgs: (Array with: oop with: handle).
	JadePresenter issueCommands: (Array with: self) session: session
]

{ #category : 'commands' }
RowanBrowserService >> releaseWindow: handle session: session [
	"during test runs, the session may have been logged out making the release moot"

	session isValidSession ifFalse: [^self].
	session isLoggingOut ifTrue: [^self].
	self
		command: #releaseWindowHandle:;
		commandArgs: (Array with: handle).
	JadePresenter issueCommands: (Array with: self) session: session
]

{ #category : 'commands' }
RowanBrowserService >> reloadProjects: selectedProjectServices presenter: presenter [

	| selectedServices |
	selectedServices := RowanServiceUpdater current selectedServices asSet
		                    asOrderedCollection.
	self
		command: #reloadProjects:andUpdateServices:;
		commandArgs: (Array
				 with: selectedProjectServices asSet asArray
				 with: selectedServices).
	RowanServiceUpdater current
		issueCommands: (Array with: self)
		session: presenter gciSession
]

{ #category : 'accessing' }
RowanBrowserService >> removedMethods [
	^removedMethods
]

{ #category : 'accessing' }
RowanBrowserService >> removedMethods: anObject [
	removedMethods := anObject
]

{ #category : 'public' }
RowanBrowserService >> replicateFrom: newService [
	self isBrowserService ifTrue: [super replicateFrom: newService]
]

{ #category : 'accessing' }
RowanBrowserService >> selectedClass [

	^selectedClass
]

{ #category : 'accessing' }
RowanBrowserService >> selectedClass: anObject [
	selectedClass := anObject
]

{ #category : 'accessing' }
RowanBrowserService >> sortAspect [

	^name
]

{ #category : 'accessing' }
RowanBrowserService >> testCount [
	^testCount
]

{ #category : 'accessing' }
RowanBrowserService >> testCount: anObject [
	testCount := anObject
]

{ #category : 'public' }
RowanBrowserService >> testPackages [

	^testPackages ifNil: [ testPackages := OrderedCollection new ]
]

{ #category : 'public' }
RowanBrowserService >> testPackages: presenter [
	| additions |
	additions := OrderedCollection new.
	self testPackages do: 
			[:newPackageService |
			| updatedPackage |
			updatedPackage := presenter model detect: [:packageService | packageService = newPackageService]
						ifNone: 
							[additions add: newPackageService.
							nil].
			updatedPackage ifNotNil: [updatedPackage replicateFrom: newPackageService]].
	presenter model addAll: additions.
	presenter model copy do:[:oldPackageService |
		(testPackages includes: oldPackageService) ifFalse:[oldPackageService ifNotNil: [presenter model remove: oldPackageService]]]. 
]
