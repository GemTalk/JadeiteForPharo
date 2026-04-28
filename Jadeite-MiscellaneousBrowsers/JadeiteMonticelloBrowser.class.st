Class {
	#name : 'JadeiteMonticelloBrowser',
	#superclass : 'JadeiteMiscellaneousBrowser',
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
		displayItalic: [ :item |
				monticelloPackageService notNil and: [
							item descriptionInsideParens
							= monticelloPackageService descriptionInsideParens ] ].
	box add: packagesPresenter.
	packagesPresenter contextMenu: self newPackageMenu.
	self layout add: box
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> loadSelectedPackage [

	| confirmation |
	confirmation := self uiManager confirm:
		                'Load selected package '
		                , packagesPresenter selectedItem name , '?'.
	confirmation ifFalse: [ ^ self ].
	self uiManager alert: 'load package not implemented yet!'
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

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Load Selected Package';
								  action: [ self loadSelectedPackage ]; 
								  enabled: [
									  self repositoriesPresenter selections size = 1 ] ]]
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
