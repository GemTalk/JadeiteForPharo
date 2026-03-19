Class {
	#name : 'JadeiteAddPackageDialog',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'packageNamePresenter',
		'symbolDictionaryNamePresenter',
		'componentNamePresenter',
		'projectService'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'constants' }
JadeiteAddPackageDialog class >> defaultPreferredExtent [

	^ 40 @ 30
]

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
		  add: 'Package Name:' atPoint: 1 @ 1;
		  add: packageNamePresenter atPoint: 2 @ 1 span: 2 @ 1;
		  add: 'Component Name:' atPoint: 1 @ 2;
		  add: componentNamePresenter atPoint: 2 @ 2 span: 2 @ 1;
		  add: 'Symbol Dictionary:' atPoint: 1 @ 3;
		  add: symbolDictionaryNamePresenter atPoint: 2 @ 3 span: 2 @ 1;
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

	projectService = RowanProjectService noneProject ifTrue: [ ^ self ].
	RowanAnsweringService new
		symbolDictionaryNames: self gciSession
		onCompletion: [ :service |
				| dictionaryNames |
				dictionaryNames := service answer.
				dictionaryNames remove: 'UserGlobals' ifAbsent: [  ].
				dictionaryNames addFirst: 'UserGlobals'.
				symbolDictionaryNamePresenter items: dictionaryNames ]
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
