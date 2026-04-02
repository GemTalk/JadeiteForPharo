Class {
	#name : 'JadeiteConsoleSeaside',
	#superclass : 'JadeiteConsoleWithoutRowan',
	#instVars : [
		'monticelloPackageListPresenter'
	],
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'actions' }
JadeiteConsoleSeaside >> browsePackageRepositories [

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

{ #category : 'initialization' }
JadeiteConsoleSeaside >> connectPresenters [
	"initialization"

	super connectPresenters.
	monticelloPackageListPresenter whenActivatedDo: [ :selection |
		self browsePackageRepositories ]
]

{ #category : 'accessing' }
JadeiteConsoleSeaside >> gciSession: aSession [

	super gciSession: aSession.
	aSession ifNotNil: [ :sess |
			sess announcer
				when: JadeiteMethodCompiledAnnouncement
				send: #updateMonticelloPackages:
				to: self ]
]

{ #category : 'menus' }
JadeiteConsoleSeaside >> initializeMonticelloPackageListMenu [

	self monticelloPackageListPresenter contextMenu: self newMonticelloMenu
]

{ #category : 'initialization' }
JadeiteConsoleSeaside >> initializePrimaryListPresenter: tabs [

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
			           monticelloPackageService repositoryGroups
				           repositoryDescriptions last ].
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
JadeiteConsoleSeaside >> monticelloPackageListPresenter [

	^ monticelloPackageListPresenter
]

{ #category : 'accessing' }
JadeiteConsoleSeaside >> monticelloPackageListPresenter: anObject [

	monticelloPackageListPresenter := anObject
]

{ #category : 'menus' }
JadeiteConsoleSeaside >> newMonticelloMenu [

	^ JadeiteMenuPresenter new addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Browse Package Repositories';
						  action: [ self browsePackageRepositories ];
						  enabled: [
							  self monticelloPackageListPresenter selections size = 1 ] ] ]
]

{ #category : 'accessing' }
JadeiteConsoleSeaside >> repositoryListFor: monticelloPackageService [

	^ monticelloPackageService
		  ifNil: [ String new ]
		  ifNotNil: [ :svc | svc repositoryDescriptions ]
]

{ #category : 'updates' }
JadeiteConsoleSeaside >> updateMonticelloPackages: anAnnouncement [

	self updateMonticelloPackagesOnCompletion: [ ] catchBlock: [ ]
]

{ #category : 'updates' }
JadeiteConsoleSeaside >> updateMonticelloPackagesOnCompletion: completionBlock catchBlock: catchBlock [

	| monticelloService |
	monticelloService := RowanMonticelloService new.
	monticelloService command: #update.
	monticelloService catchBlock: catchBlock.
	RowanServiceUpdater current
		issueCommand: monticelloService
		session: self gciSession
		onCompletion: [
				monticelloPackageListPresenter items: monticelloService packages.
				completionBlock value ]
]

{ #category : 'updates' }
JadeiteConsoleSeaside >> updateProjectsOnCompletion: completionBlock catchBlock: catchBlock [
	"we don't deal with rowan projects in seaside"

	^ self
		  updateMonticelloPackagesOnCompletion: completionBlock
		  catchBlock: catchBlock
]
