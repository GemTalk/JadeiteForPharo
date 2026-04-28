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
	repositoriesPresenter
		headerTitle: 'Repositories';
		displayItalic: [ :item | item isKindOf: JadeiteRepositoryGroupSeparator ];
		displayColor: [ :item |
			(item isKindOf: JadeiteRepositoryGroupSeparator)
				ifTrue: [ Color gray ]
				ifFalse: [ nil ] ].
	box add: repositoriesPresenter.
	packagesPresenter := JadeiteListPresenter new display: #description.
	packagesPresenter
		headerTitle: 'Packages';
		displayItalic: [ :item |
			packages anySatisfy: [ :loaded |
				loaded descriptionInsideParens = item descriptionInsideParens ] ].
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
							  enabled: [
								  self repositoriesPresenter hasSelection and: [
									  (self repositoriesPresenter selectedItem
										   isKindOf: JadeiteRepositoryGroupSeparator) not ] ] ] ]
]

{ #category : 'actions' }
JadeiteAllRepositoriesBrowser >> removeRepository [

	| repositoryService packageService |
	self repositoriesPresenter hasSelection ifFalse: [ ^ self ].
	repositoryService := self repositoriesPresenter selectedItem.
	(repositoryService isKindOf: JadeiteRepositoryGroupSeparator) ifTrue: [ ^ self ].
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

	^ (repositoryService repositoryPackages ifNil: [ #() ])
		  asSortedCollection: [ :x :y | x description < y description ]
]

{ #category : 'updates' }
JadeiteAllRepositoriesBrowser >> updatePackagePresenterFor: selection [

	| item |
	item := selection selectedItem.
	(item isNil or: [ item isKindOf: JadeiteRepositoryGroupSeparator ])
		ifTrue: [
			packagesPresenter items: Array new.
			^ self ].
	packagesPresenter items: (self sortedPackagesForRepository: item)
]

{ #category : 'updates' }
JadeiteAllRepositoriesBrowser >> updateRepositories [

	| allRepos seen sorted result previousKey |
	allRepos := OrderedCollection new.
	seen := Set new.
	packages do: [ :pkg |
		pkg repositoryGroups repositories do: [ :repo |
			| key |
			key := repo repositoryOop ifNil: [ repo description ].
			(seen includes: key) ifFalse: [
				seen add: key.
				allRepos add: repo ] ] ].
	sorted := allRepos asSortedCollection: [ :x :y |
		          | kx ky |
		          kx := self repositoryTypeKeyFor: x.
		          ky := self repositoryTypeKeyFor: y.
		          kx = ky
			          ifTrue: [ x description < y description ]
			          ifFalse: [ kx < ky ] ].
	result := OrderedCollection new.
	previousKey := nil.
	sorted do: [ :repo |
		| key |
		key := self repositoryTypeKeyFor: repo.
		key ~= previousKey ifTrue: [
			result add: (JadeiteRepositoryGroupSeparator label:
					 (self repositoryTypeLabelFor: key)) ].
		previousKey := key.
		result add: repo ].
	repositoriesPresenter items: result
]

{ #category : 'private' }
JadeiteAllRepositoriesBrowser >> repositoryTypeKeyFor: aRepositoryService [

	| desc |
	desc := aRepositoryService description asLowercase.
	(desc includesSubstring: 'cache') ifTrue: [ ^ 0 ].
	(desc includesSubstring: 'github') ifTrue: [ ^ 1 ].
	(desc beginsWith: 'http') ifTrue: [ ^ 2 ].
	(desc endsWith: '.mcz') ifTrue: [ ^ 3 ].
	^ 4
]

{ #category : 'private' }
JadeiteAllRepositoriesBrowser >> repositoryTypeLabelFor: aKey [

	aKey = 0 ifTrue: [ ^ 'Cache' ].
	aKey = 1 ifTrue: [ ^ 'GitHub' ].
	aKey = 2 ifTrue: [ ^ 'HTTP' ].
	aKey = 3 ifTrue: [ ^ 'MCZ' ].
	^ 'FileTree'
]
