Class {
	#name : 'JadeiteMonticelloAllRepositoriesBrowser',
	#superclass : 'JadeiteMiscellaneousBrowser',
	#traits : 'JadeiteMonticelloTrait',
	#classTraits : 'JadeiteMonticelloTrait classTrait',
	#instVars : [
		'repositoriesPresenter',
		'packagesPresenter',
		'packages'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser class >> defaultPreferredExtent [

	^ 90 @ 50
]

{ #category : 'instance creation' }
JadeiteMonticelloAllRepositoriesBrowser class >> showOnPackages: aCollection application: application [

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
JadeiteMonticelloAllRepositoriesBrowser >> addRepository [

	packages isEmpty ifTrue: [ ^ self ].
	JadeiteMonticelloAddRepositoryDialog
		showOnSession: self gciSession
		packageService: packages first
		onCompletion: [ :url | self updateRepositoriesSelectingUrl: url ]
]

{ #category : 'actions' }
JadeiteMonticelloAllRepositoriesBrowser >> browsePackageRepositories [

	| loadedPackage answeringService |
	self packagesPresenter hasSelection ifFalse: [ ^ self ].
	loadedPackage := self loadedPackageFor: self packagesPresenter selectedItem.
	loadedPackage ifNil: [ ^ self ].
	answeringService := RowanAnsweringService new
		                    command: #updateServices:;
		                    commandArgs: (Array with: loadedPackage repositories).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			JadeiteMonticelloBrowser
				showOn: loadedPackage
				application: self owner application ]
]

{ #category : 'initialization' }
JadeiteMonticelloAllRepositoriesBrowser >> connectPresenters [

	super connectPresenters.
	repositoriesPresenter whenSelectionChangedDo: [ :selection |
		self updatePackagePresenterFor: selection ]
]

{ #category : 'initialization' }
JadeiteMonticelloAllRepositoriesBrowser >> defaultLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteMonticelloAllRepositoriesBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group | self addToolsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteMonticelloAllRepositoriesBrowser >> initializePresenters [

	| box |
	self layout add: self initializeWaitPresenter expand: false.
	box := SpBoxLayout newHorizontal.
	repositoriesPresenter := JadeiteListPresenter new display: #description.
	repositoriesPresenter
		headerTitle: 'Repositories';
		displayItalic: [ :item | item isSeparator ];
		displayColor: [ :item |
			(item isSeparator)
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

{ #category : 'testing' }
JadeiteMonticelloAllRepositoriesBrowser >> isLoaded: aPackageService [

	^ (self packages
		   detect: [ :pkg |
			   pkg descriptionInsideParens
			   = aPackageService descriptionInsideParens ]
		   ifNone: [ ]) isNil
]

{ #category : 'private' }
JadeiteMonticelloAllRepositoriesBrowser >> loadedPackageFor: aPackageService [

	^ packages
		  detect: [ :pkg |
			  pkg descriptionInsideParens = aPackageService descriptionInsideParens ]
		  ifNone: [ nil ]
]

{ #category : 'menus' }
JadeiteMonticelloAllRepositoriesBrowser >> newPackageMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
				  group addItem: [ :item |
							  item
								  name: 'Browse Package Repositories';
								  action: [ self browsePackageRepositories ];
								  enabled: [
										  self packagesPresenter hasSelection and: [
												  (self loadedPackageFor:
														   self packagesPresenter selectedItem) notNil ] ] ] ];
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Load Package';
								  action: [ self loadSelectedPackage ];
								  enabled: [ self selectedPackageIsLoaded ] ];
					  addItem: [ :item |
							  item
								  name: 'Unload Package';
								  action: [ self unloadSelectedPackage ];
								  enabled: [ self selectedPackageIsLoaded ] ] ]
]

{ #category : 'menus' }
JadeiteMonticelloAllRepositoriesBrowser >> newRepositoryMenu [

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
										   isSeparator) not ] ] ] ]
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> packages [

	^ packages
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> packages: aCollection [

	packages := aCollection
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> packagesPresenter [

	^ packagesPresenter
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> packagesPresenter: anObject [

	packagesPresenter := anObject
]

{ #category : 'actions' }
JadeiteMonticelloAllRepositoriesBrowser >> removeRepository [

	| repositoryService service |
	self repositoriesPresenter hasSelection ifFalse: [ ^ self ].
	repositoryService := self repositoriesPresenter selectedItem.
	repositoryService isSeparator ifTrue: [ ^ self ].
	(self uiManager confirm:
		 'Really remove repository ' , repositoryService description)
		ifFalse: [ ^ self ].
	service := RowanMonticelloService new
		           command: #removeRepository:;
		           commandArgs: (Array with: repositoryService).
	self gciSession
		issueCommand: service
		onCompletion: [ self updateRepositories ]
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> repositoriesPresenter [

	^ repositoriesPresenter
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> repositoriesPresenter: anObject [

	repositoriesPresenter := anObject
]

{ #category : 'private' }
JadeiteMonticelloAllRepositoriesBrowser >> repositoryTypeKeyFor: aRepositoryService [

	| desc |
	desc := aRepositoryService description asLowercase.
	(desc includesSubstring: 'cache') ifTrue: [ ^ 0 ].
	(desc includesSubstring: 'github') ifTrue: [ ^ 1 ].
	(desc beginsWith: 'http') ifTrue: [ ^ 2 ].
	(desc endsWith: '.mcz') ifTrue: [ ^ 3 ].
	(desc beginsWith: 'filetree:') ifTrue: [ ^ 4 ].
	^ 5
]

{ #category : 'private' }
JadeiteMonticelloAllRepositoriesBrowser >> repositoryTypeLabelFor: aKey [

	aKey = 0 ifTrue: [ ^ 'Cache' ].
	aKey = 1 ifTrue: [ ^ 'GitHub' ].
	aKey = 2 ifTrue: [ ^ 'HTTP' ].
	aKey = 3 ifTrue: [ ^ 'MCZ' ].
	aKey = 4 ifTrue: [ ^ 'FileTree' ].
	^ 'Other'
]

{ #category : 'accessing' }
JadeiteMonticelloAllRepositoriesBrowser >> shellName [

	^ 'Jadeite Monticello Repository Browser'
]

{ #category : 'private' }
JadeiteMonticelloAllRepositoriesBrowser >> sortedPackagesForRepository: repositoryService [

	^ (repositoryService repositoryPackages ifNil: [ #() ])
		  asSortedCollection: [ :x :y | x description < y description ]
]

{ #category : 'updates' }
JadeiteMonticelloAllRepositoriesBrowser >> updatePackagePresenterFor: selection [

	| repositoryService answeringService |
	repositoryService := selection selectedItem.
	(repositoryService isNil or: [ repositoryService isSeparator ]) ifTrue: [
		packagesPresenter items: Array new.
		^ self ].
	answeringService := RowanAnsweringService new
		                    command: #updateServices:;
		                    commandArgs: (Array with: (Array with: repositoryService)).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			packagesPresenter items:
				(self sortedPackagesForRepository: repositoryService) ]
]

{ #category : 'updates' }
JadeiteMonticelloAllRepositoriesBrowser >> updateRepositories [

	| sorted result previousKey service allRepos |
	service := RowanMonticelloService new command: #updateRepositories.
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [ :svc |
				allRepos := svc repositories asSet.
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
				repositoriesPresenter items: result ]
]

{ #category : 'updates' }
JadeiteMonticelloAllRepositoriesBrowser >> updateRepositoriesSelectingUrl: url [

	| repo |
	self updateRepositories.
	repo := repositoriesPresenter items
		        detect: [ :item |
			        item isSeparator not and: [ item description = url ] ]
		        ifNone: [ nil ].
	repo ifNotNil: [ repositoriesPresenter selectItem: repo ]
]
