Class {
	#name : 'JadeiteAllRepositoriesBrowser',
	#superclass : 'JadeiteMiscellaneousBrowser',
	#instVars : [
		'repositoriesPresenter',
		'packagesPresenter',
		'packages'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser class >> defaultPreferredExtent [

	^ 90 @ 50
]

{ #category : 'instance creation' }
JadeiteAllRepositoriesBrowser class >> showOnPackages: aCollection application: application [

	| browser windowPresenter |
	browser := self new packages: aCollection.
	browser gciSession: application gciSession.
	windowPresenter := browser open.
	browser updateRepositories.
	browser owner application: application.
	application
		addBorderStyleTo: windowPresenter
		presenter: browser.
	browser addStyle: 'jadeiteTextBackgroundColor'
]

{ #category : 'actions' }
JadeiteAllRepositoriesBrowser >> addRepository [

	packages isEmpty ifTrue: [ ^ self ].
	JadeiteMonticelloAddRepositoryDialog
		showOnSession: self gciSession
		packageService: packages first
		onCompletion: [ self updateRepositories ]
]

{ #category : 'actions' }
JadeiteAllRepositoriesBrowser >> browsePackageRepositories [

	| packageService |
	self packagesPresenter hasSelection ifFalse: [ ^ self ].
	packageService := self packagesPresenter selectedItem.
	JadeiteMonticelloBrowser
		showOn: packageService
		application: self owner application
]

{ #category : 'initialization' }
JadeiteAllRepositoriesBrowser >> connectPresenters [

	super connectPresenters.
	repositoriesPresenter whenSelectionChangedDo: [ :selection |
		self updatePackagePresenterFor: selection ]
]

{ #category : 'initialization' }
JadeiteAllRepositoriesBrowser >> defaultLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteAllRepositoriesBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group | self addToolsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteAllRepositoriesBrowser >> initializePresenters [

	| box |
	box := SpBoxLayout newHorizontal.
	repositoriesPresenter := JadeiteListPresenter new display: #description.
	repositoriesPresenter headerTitle: 'Repositories'.
	box add: repositoriesPresenter.
	packagesPresenter := JadeiteListPresenter new display: #description.
	packagesPresenter headerTitle: 'Packages'.
	box add: packagesPresenter.
	packagesPresenter contextMenu: self newPackageMenu.
	repositoriesPresenter contextMenu: self newRepositoryMenu.
	self layout add: box
]

{ #category : 'actions' }
JadeiteAllRepositoriesBrowser >> loadSelectedPackage [

	| confirmation |
	self packagesPresenter hasSelection ifFalse: [ ^ self ].
	confirmation := self uiManager confirm:
		                'Load selected package '
		                , packagesPresenter selectedItem description , '?'.
	confirmation ifFalse: [ ^ self ].
	self uiManager alert: 'load package not implemented yet!'
]

{ #category : 'menus' }
JadeiteAllRepositoriesBrowser >> newRepositoryMenu [

	^ JadeiteMenuPresenter new addGroup: [ :group |
			  group
				  addItem: [ :item |
						  item
							  name: 'Add Repository...';
							  action: [ self addRepository ] ];
				  addItem: [ :item |
						  item
							  name: 'Remove Repository...';
							  action: [ self removeRepository ];
							  enabled: [ self repositoriesPresenter hasSelection ] ] ]
]

{ #category : 'actions' }
JadeiteAllRepositoriesBrowser >> removeRepository [

	| repositoryService packageService |
	self repositoriesPresenter hasSelection ifFalse: [ ^ self ].
	repositoryService := self repositoriesPresenter selectedItem.
	(self uiManager confirm:
		 'Really remove repository ' , repositoryService description)
		ifFalse: [ ^ self ].
	packageService := packages
		                  detect: [ :pkg |
			                  pkg repositoryGroups repositories anySatisfy: [
				                  :repo |
				                  repo repositoryOop = repositoryService repositoryOop ] ]
		                  ifNone: [ ^ self ].
	packageService
		command: #removeRepository:;
		commandArgs: (Array with: repositoryService name).
	self gciSession
		issueCommand: packageService
		onCompletion: [ self updateRepositories ]
]

{ #category : 'menus' }
JadeiteAllRepositoriesBrowser >> newPackageMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Browse Package Repositories';
								  action: [ self browsePackageRepositories ];
								  enabled: [ self packagesPresenter hasSelection ] ];
					  addItem: [ :item |
							  item
								  name: 'Load Package';
								  action: [ self loadSelectedPackage ];
								  enabled: [ self packagesPresenter hasSelection ] ] ]
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> packages [

	^ packages
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> packages: aCollection [

	packages := aCollection
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> packagesPresenter [

	^ packagesPresenter
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> packagesPresenter: anObject [

	packagesPresenter := anObject
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> repositoriesPresenter [

	^ repositoriesPresenter
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> repositoriesPresenter: anObject [

	repositoriesPresenter := anObject
]

{ #category : 'accessing' }
JadeiteAllRepositoriesBrowser >> shellName [

	^ 'Jadeite Monticello Repository Browser'
]

{ #category : 'private' }
JadeiteAllRepositoriesBrowser >> sortedPackagesForRepository: repositoryService [

	| repoOop |
	repoOop := repositoryService repositoryOop.
	^ (packages select: [ :pkg |
		   pkg repositoryGroups repositories anySatisfy: [ :repo |
			   repo repositoryOop = repoOop ] ])
		  asSortedCollection: [ :x :y | x description < y description ]
]

{ #category : 'updates' }
JadeiteAllRepositoriesBrowser >> updatePackagePresenterFor: selection [

	packagesPresenter items: (selection selectedItem
			 ifNil: [ Array new ]
			 ifNotNil: [ :repositoryService |
				 self sortedPackagesForRepository: repositoryService ])
]

{ #category : 'updates' }
JadeiteAllRepositoriesBrowser >> updateRepositories [

	| allRepos seen |
	allRepos := OrderedCollection new.
	seen := Set new.
	packages do: [ :pkg |
		pkg repositoryGroups repositories do: [ :repo |
			(seen includes: repo repositoryOop) ifFalse: [
				seen add: repo repositoryOop.
				allRepos add: repo ] ] ].
	repositoriesPresenter items:
		(allRepos asSortedCollection: [ :x :y | x description < y description ])
]
