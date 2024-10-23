Class {
	#name : 'RowanBrowserService',
	#superclass : 'RowanService',
	#traits : 'JadeiteUtilityTrait',
	#classTraits : 'JadeiteUtilityTrait classTrait',
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
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
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

{ #category : 'commands' }
RowanBrowserService >> checkForAddedProjects: projectServices onCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #checkForAddedProjects:;
		commandArgs: (Array with: projectServices).
	RowanServiceUpdater current 
		issueCommand: browserService
		session: GciSession current
		onCompletion: completionBlock
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

	| removals |
	presenter list isEmpty ifTrue: [ presenter list: ListModel new ].
	dictionaries ifNil: [ ^ self ].
	removals := presenter list reject: [ :dictionaryService |
		            dictionaries includes: dictionaryService ].
	presenter list: dictionaries. 
	presenter invalidate
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

{ #category : 'commands' }
RowanBrowserService >> newProjectNamed: projectName session: session windowHandle: handle [

	self
		command: #newProjectNamed:windowHandle:;
		commandArgs: (Array with: projectName with: handle).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: [ ]
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
	^projects
]

{ #category : 'updates' }
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
		whilePreservingSelections: (self sortedProjectsFrom: projects)
		browser: nil
]

{ #category : 'updates' }
RowanBrowserService >> projectsUpdate: presenter browser: browser [

	| removals selectedProjectService |
	projects ifNil: [ ^ self ].
	presenter list isEmpty ifTrue: [
		self initializePresenterList: presenter ].
	removals := presenter list reject: [ :projectService |
		            (projects includes: projectService) ].
	selectedProjectService := presenter selectedItem. 
	(removals includes: selectedProjectService) ifTrue:[presenter unselectAll]. 
	presenter removeAll: removals.
	presenter selections isEmpty ifTrue: [
		browser updateProjectPackagesOnCompletion: nil ].
	self
		updateList: presenter
		whilePreservingSelections: (self sortedProjectsFrom: projects)
		browser: browser.
	browser refreshProjectInfoTab
]

{ #category : 'commands' }
RowanBrowserService >> registerWindow: handle rootObject: oop session: session [

	RowanServiceUpdater current logComment:
		'Register window handle: ' , handle printString , ' {'
		, self identityHash printString , '}'.
	self
		command: #saveRootObject:windowHandle:;
		commandArgs: (Array with: oop with: handle).
	RowanServiceUpdater current issueCommand: self session: session onCompletion: nil
]

{ #category : 'commands' }
RowanBrowserService >> releaseWindow: handle session: session [
	"during test runs, the session may have been logged out making the release moot"

	session isValidSession ifFalse: [ ^ self ].
	session isLoggingOut ifTrue: [ ^ self ].
	self
		command: #releaseWindowHandle:;
		commandArgs: (Array with: handle).
	RowanServiceUpdater current issueCommand: self session: session onCompletion: nil
]

{ #category : 'commands' }
RowanBrowserService >> reloadProjects: selectedProjectServices presenter: presenter onCompletion: completionBlock [

	| selectedServices |
	selectedServices := RowanServiceUpdater current selectedServices
		                    asSet asOrderedCollection.
	self
		command: #reloadProjects:andUpdateServices:;
		commandArgs: (Array
				 with: selectedProjectServices asSet asArray
				 with: selectedServices).
	RowanServiceUpdater current
		issueCommand: self
		session: presenter gciSession
		onCompletion: completionBlock
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
RowanBrowserService >> testDictionaries: presenter [
	dictionaries ifNil: [ ^self ].
	presenter list: dictionaries
]

{ #category : 'public' }
RowanBrowserService >> testPackages [

	^testPackages ifNil: [ testPackages := OrderedCollection new ]
]

{ #category : 'public' }
RowanBrowserService >> testPackages: presenter [
	| additions |
	testPackages ifNil: [ ^self ].
	additions := OrderedCollection new.
	testPackages do: 
			[:newPackageService |
			| updatedPackage |
			updatedPackage := presenter list detect: [:packageService | packageService = newPackageService]
						ifNone: 
							[additions add: newPackageService.
							nil].
			updatedPackage ifNotNil: [updatedPackage replicateFrom: newPackageService]].
	presenter list addAll: additions.
	presenter list copy do:[:oldPackageService |
		(testPackages includes: oldPackageService) ifFalse:[oldPackageService ifNotNil: [presenter list remove: oldPackageService]]]. 
]
