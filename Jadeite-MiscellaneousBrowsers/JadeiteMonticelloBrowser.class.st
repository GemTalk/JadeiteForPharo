Class {
	#name : 'JadeiteMonticelloBrowser',
	#superclass : 'JadeiteMiscellaneousBrowser',
	#traits : 'JadeiteMonticelloTrait',
	#classTraits : 'JadeiteMonticelloTrait classTrait',
	#instVars : [
		'repositoriesPresenter',
		'packagesPresenter',
		'monticelloPackageService'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteMonticelloBrowser class >> defaultPreferredExtent [

	^ 90 @ 50
]

{ #category : 'instance creation' }
JadeiteMonticelloBrowser class >> showOn: monticelloPackage application: application [

	| monticelloPackageBrowser windowPresenter |
	monticelloPackageBrowser := self new monticelloPackageService:
		                            monticelloPackage.
	monticelloPackageBrowser gciSession: application gciSession.
	windowPresenter := monticelloPackageBrowser open.
	monticelloPackageBrowser
		updateRepositories;
		selectLoaded.
	monticelloPackageBrowser owner application: application.
	application
		addBorderStyleTo: windowPresenter
		presenter: monticelloPackageBrowser.
	monticelloPackageBrowser
		addStyle: 'jadeiteTextBackgroundColor'
]

{ #category : 'initialization' }
JadeiteMonticelloBrowser >> connectPresenters [

	super connectPresenters.
	repositoriesPresenter whenSelectionChangedDo: [ :selection |
		self updatePackagePresenterFor: selection ].
]

{ #category : 'initialization' }
JadeiteMonticelloBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteMonticelloBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group | self addToolsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteMonticelloBrowser >> initializePresenters [

	| box |
	box := SpBoxLayout newHorizontal.
	repositoriesPresenter := JadeiteListPresenter new display:
		                         #description.
	repositoriesPresenter
		headerTitle: 'Repositories';
		displayItalic: [ :item |
			item == monticelloPackageService sourceRepository ].
	box add: repositoriesPresenter.
	packagesPresenter := JadeiteListPresenter new display: #description.
	packagesPresenter
		headerTitle: 'Available Packages';
		displayItalic: [ :item | self isLoaded: item ].
	box add: packagesPresenter.
	packagesPresenter contextMenu: self newPackageMenu.
	self layout add: box
]

{ #category : 'testing' }
JadeiteMonticelloBrowser >> isLoaded: aPackageService [

	^ monticelloPackageService notNil and: [
			  aPackageService descriptionInsideParens
			  = monticelloPackageService descriptionInsideParens ]
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> monticelloPackageService [

	^ monticelloPackageService
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> monticelloPackageService: anObject [

	monticelloPackageService := anObject
]

{ #category : 'menus' }
JadeiteMonticelloBrowser >> newPackageMenu [

	^ JadeiteMenuPresenter new addGroup: [ :group |
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

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> packagesPresenter [

	^ packagesPresenter
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> packagesPresenter: anObject [

	packagesPresenter := anObject
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> repositoriesPresenter [

	^ repositoriesPresenter
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> repositoriesPresenter: anObject [

	repositoriesPresenter := anObject
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> selectLoaded [

	| sourceRepo index |
	sourceRepo := monticelloPackageService sourceRepository.
	sourceRepo ifNotNil: [
		index := self repositoriesPresenter list indexOf: sourceRepo.
		index > 0 ifTrue: [
			self repositoriesPresenter selectIndex: index scrollToSelection: true ] ].
	self selectLoadedPackage
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> selectLoadedPackage [

	| index package |
	package := self packagesPresenter list
		           detect: [ :availablePackage |
				           availablePackage descriptionInsideParens
				           = monticelloPackageService descriptionInsideParens ]
		           ifNone: [ ^ self ].
	index := self packagesPresenter list indexOf: package.
	self packagesPresenter selectIndex: index scrollToSelection: true
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> shellName [

	^ 'Jadeite Monticello Package Browser for '
	  , monticelloPackageService description
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> sortedPackagesFor: monticelloPackageServices [

	^ monticelloPackageServices asSortedCollection: [ :x :y |
		  x description < y description ]
]

{ #category : 'updates' }
JadeiteMonticelloBrowser >> updatePackagePresenterFor: selection [

	^ packagesPresenter items: (selection selectedItem
			   ifNil: [ Array new ]
			   ifNotNil: [ :repositoryService |
				   self sortedPackagesFor: repositoryService repositoryPackages ])
]

{ #category : 'updates' }
JadeiteMonticelloBrowser >> updateRepositories [

	repositoriesPresenter items: monticelloPackageService repositories. 
]
