Class {
	#name : 'JadeiteAddPackageDialog',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'packageNamePresenter',
		'symbolDictionaryNamePresenter',
		'componentNamePresenter',
		'projectService'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'instance creation' }
JadeiteAddPackageDialog class >> newModalWindowOn: aGciSession projectService: theProjectService [

	| inst modalWindow |
	inst := self new.
	modalWindow := inst
		               gciSession: aGciSession;
		               projectService: theProjectService;
		               initializeLists;
		               asModalWindow.
	modalWindow closeOnBackdropClick: true.
	^ modalWindow
]

{ #category : 'instance creation' }
JadeiteAddPackageDialog class >> showOnSession: aGciSession [

	^self new 
		gciSession: aGciSession;
		initializeLists;
		openModal

]

{ #category : 'instance creation' }
JadeiteAddPackageDialog class >> showOnSession: aGciSession projectService: theProjectService [

	| modalWindow |
	modalWindow := self
		               newModalWindowOn: aGciSession
		               projectService: theProjectService.
	^ modalWindow open
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> allPackages [

	| browserService packageServices |
	browserService := RowanBrowserService new.
	browserService command: #allPackages.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession. "get the projects and extract the packages"
	packageServices := SortedCollection new.
	browserService projects do: [ :projectService |
		packageServices addAll: projectService packageServices ].
	^ packageServices
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> componentName [

	^componentNamePresenter selectedItem
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> defaultLayout [

	^ SpGridLayout new
		  add: 'Package Name:' at: 1 @ 1;
		  add: packageNamePresenter at: 2 @ 1 span: 2 @ 1;
		  add: 'Component Name:' at: 1 @ 2;
		  add: componentNamePresenter at: 2 @ 2 span: 2 @ 1;
		  add: 'Symbol Dictionary:' at: 1 @ 3;
		  add: symbolDictionaryNamePresenter at: 2 @ 3 span: 2 @ 1;
		  beColumnNotHomogeneous
]

{ #category : 'initialization' }
JadeiteAddPackageDialog >> initializeComponents [
	| componentNames |
	projectService ifNil: [ ^self ].
	projectService componentServices ifNil:[^self]. "none project selected" 
	componentNames := projectService componentServices keys
				select: [:componentService | (componentService == #nil) not]
				thenCollect: [:componentService | componentService name].
	componentNamePresenter items: componentNames asSortedCollection asOrderedCollection
]

{ #category : 'initialization' }
JadeiteAddPackageDialog >> initializeLists [ 
	
		self initializeSymbolDictionaries.
		self initializeComponents.
]

{ #category : 'initialization' }
JadeiteAddPackageDialog >> initializePresenters [

	super initializePresenters. 
	packageNamePresenter := self newTextInput.
	componentNamePresenter := self newDropList. 
	symbolDictionaryNamePresenter := self newDropList.
]

{ #category : 'initialization' }
JadeiteAddPackageDialog >> initializeSymbolDictionaries [

	| dictionaryNames |
	projectService = RowanProjectService noneProject ifTrue: [ ^ self ].
	dictionaryNames := RowanAnsweringService new symbolDictionaryNames:
		                   self gciSession.
	symbolDictionaryNamePresenter items: dictionaryNames
]

{ #category : 'initialization' }
JadeiteAddPackageDialog >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent: 400 @ 300.
	self updateCaption
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> packageName [

	^packageNamePresenter text
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> projectService [

	^ projectService
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> projectService: anObject [

	projectService := anObject
]

{ #category : 'accessing' }
JadeiteAddPackageDialog >> symbolDictionaryName [

	^symbolDictionaryNamePresenter selectedItem
]

{ #category : 'initialization' }
JadeiteAddPackageDialog >> updateCaption [
	self caption: 'Add Package'
]
