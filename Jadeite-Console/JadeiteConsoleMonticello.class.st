Class {
	#name : 'JadeiteConsoleMonticello',
	#superclass : 'JadeiteConsoleWithoutRowan',
	#traits : 'JadeiteMonticelloTrait',
	#classTraits : 'JadeiteMonticelloTrait classTrait',
	#instVars : [
		'monticelloPackageListPresenter'
	],
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'actions' }
JadeiteConsoleMonticello >> browsePackageRepositories [

	| monticelloPackageService |
	self monticelloPackageListPresenter selectedItems size = 1 ifFalse: [
		^ self ].
	monticelloPackageService := self monticelloPackageListPresenter
		                            selectedItem.
	self
		updateServices: monticelloPackageService repositories
		onCompletion: [
				JadeiteMonticelloBrowser
					showOn: monticelloPackageService
					application: self application ]
]

{ #category : 'actions' }
JadeiteConsoleMonticello >> changes [

	| packageService repositoryService |
	packageService := monticelloPackageListPresenter selectedItem.
	repositoryService := packageService sourceRepository.
	self
		changesFor: packageService
		against: repositoryService
		onCompletion: [ :svc |
				| changesBrowser |
				changesBrowser := JadeiteMonticelloChangesBrowser
					                  showOn:
					                  (RowanPatch
						                   fromString: svc changes
						                   session: self gciSession)
					                  name: svc description
					                  application: self application.
				changesBrowser
					packageService: svc;
					repositoryService: repositoryService ]
]

{ #category : 'initialization' }
JadeiteConsoleMonticello >> connectPresenters [
	"initialization"

	super connectPresenters.
	monticelloPackageListPresenter whenActivatedDo: [ :selection |
		self browsePackageRepositories ]
]

{ #category : 'accessing' }
JadeiteConsoleMonticello >> gciSession: aSession [

	super gciSession: aSession.
	aSession ifNotNil: [ :sess |
			sess announcer
				when: JadeiteMethodCompiledAnnouncement
				send: #updateMonticelloPackages:
				to: self ]
]

{ #category : 'menus' }
JadeiteConsoleMonticello >> initializeBrowseMenu [

	^ self newBrowseMethodsConsoleMenu
		  addItem: [ :item |
				  item
					  name: 'Browse Dictionaries';
					  action: [ self browseDictionaries ] ];
		  addItem: [ :item |
				  item
					  name: 'Find Class ...';
					  shortcut: $f shift ctrl;
					  action: [ self findClass ] ];
		  addItem: [ :item |
				  item
					  name: 'Find Class References ...';
					  shortcut: $r shift ctrl;
					  action: [ self findClassReferences ] ];
		  yourself
]

{ #category : 'menus' }
JadeiteConsoleMonticello >> initializeMonticelloPackageListMenu [

	self monticelloPackageListPresenter contextMenu: self newMonticelloMenu
]

{ #category : 'initialization' }
JadeiteConsoleMonticello >> initializePrimaryListPresenter: tabs [

	| box column1 column2 |
	column1 := JadeiteConsoleTableColumn
		           title: 'Package'
		           evaluated: [ :monticelloPackageService |
		           monticelloPackageService description ].
	column1 displayBold: [ :monticelloPackageService |
		monticelloPackageService hasChanges ].
	column2 := JadeiteConsoleTableColumn
		           title: 'Source Repository'
		           evaluated: [ :monticelloPackageService |
			           monticelloPackageService sourceRepository
				           ifNil: [ '' ]
				           ifNotNil: [ :repo | repo description ] ].
	column2 displayBold: [ :monticelloPackageService |
		monticelloPackageService hasChanges ].
	projectColumns := OrderedCollection with: column1 with: column2.
	box := SpBoxLayout newHorizontal.
	monticelloPackageListPresenter := JadeiteTablePresenter new
		                                  addColumn: column1;
		                                  addColumn: column2.
	box add: monticelloPackageListPresenter.
	tabs add: box label: 'Loaded Packages'.
	self initializeMonticelloPackageListMenu
]

{ #category : 'accessing' }
JadeiteConsoleMonticello >> monticelloPackageListPresenter [

	^ monticelloPackageListPresenter
]

{ #category : 'accessing' }
JadeiteConsoleMonticello >> monticelloPackageListPresenter: anObject [

	monticelloPackageListPresenter := anObject
]

{ #category : 'menus' }
JadeiteConsoleMonticello >> newMonticelloMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Browse Package Repositories';
								  action: [ self browsePackageRepositories ];
								  enabled: [
									  self monticelloPackageListPresenter selections size = 1 ] ];
					  addItem: [ :item |
							  item
								  name: 'Changes';
								  action: [ self changes ];
								  enabled: [
									  self monticelloPackageListPresenter selections size = 1 ] ];
					  addItem: [ :item |
							  item
								  name: 'Save ...';
								  action: [ self savePackage ];
								  enabled: [
									  self monticelloPackageListPresenter selectedItem hasChanges ] ] ];
		  addGroup: [ :group |
				  group addItem: [ :item |
						  item
							  name: 'Refresh from Server';
							  action: [ self updateMonticelloPackages ];
							  enabled: [
								  self monticelloPackageListPresenter selections size = 1 ] ] ]
]

{ #category : 'accessing' }
JadeiteConsoleMonticello >> repositoryListFor: monticelloPackageService [

	^ monticelloPackageService
		  ifNil: [ String new ]
		  ifNotNil: [ :svc | svc repositoryDescriptions ]
]

{ #category : 'actions' }
JadeiteConsoleMonticello >> savePackage [

	^ self uiManager alert: 'Save Package not implemented yet'
]

{ #category : 'updates' }
JadeiteConsoleMonticello >> updateProjectsOnCompletion: completionBlock catchBlock: catchBlock [
	"we don't deal with rowan projects in seaside"

	^ self
		  updateMonticelloPackagesOnCompletion: completionBlock
		  catchBlock: catchBlock
]
