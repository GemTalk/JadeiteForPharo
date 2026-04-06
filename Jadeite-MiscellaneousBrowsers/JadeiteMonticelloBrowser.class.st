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
		selectLastRepository.
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
	repositoriesPresenter headerTitle: 'Repositories'.
	box add: repositoriesPresenter.
	packagesPresenter := JadeiteListPresenter new display: #description.
	packagesPresenter headerTitle: 'Available Packages'.
	box add: packagesPresenter.
	self layout add: box
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> monticelloPackageService [

	^ monticelloPackageService
]

{ #category : 'accessing' }
JadeiteMonticelloBrowser >> monticelloPackageService: anObject [

	monticelloPackageService := anObject
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
JadeiteMonticelloBrowser >> selectLastRepository [

	self repositoriesPresenter selectIndex:
		self repositoriesPresenter list size
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
