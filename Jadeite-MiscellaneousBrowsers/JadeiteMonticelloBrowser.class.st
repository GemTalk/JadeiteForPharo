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

{ #category : 'actions' }
JadeiteMonticelloBrowser >> addFiletreeRepository [

	| directoryString |
	directoryString := JadeiteServerFileSelectorDialog
		                   showOnSession: gciSession
		                   defaultPath: JadePresenter homeEnvVarString.
	directoryString ifNil: [ ^ self ].
	self monticelloPackageService
		command: #addFiletreeRepository:;
		commandArgs: (Array with: directoryString).
	self gciSession
		issueCommand: self monticelloPackageService
		onCompletion: [ self updateRepositories ]
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> addGithubRepository [

	| urlString |
	urlString := self application newRequest
		             title: 'Github url request';
		             label: 'Enter complete Github url string';
		             openModalWithParent: self window.
	urlString ifNil: [ ^ self ].
	self monticelloPackageService
		command: #addGithubRepository:;
		commandArgs: (Array with: urlString).
	self gciSession
		issueCommand: self monticelloPackageService
		onCompletion: [ self updateRepositories ]
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> addHttpRepository [

	| urlString |
	urlString := self application newRequest
		             title: 'HTTP url request';
		             label: 'Enter complete HTTP url string';
		             openModalWithParent: self window.
	urlString ifNil: [ ^ self ].
	self monticelloPackageService
		command: #addHttpRepository:;
		commandArgs: (Array with: urlString).
	self gciSession
		issueCommand: self monticelloPackageService
		onCompletion: [ self updateRepositories ]
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> addMCZRepository [

	| directoryString |
	directoryString := JadeiteServerFileSelectorDialog
		                   showOnSession: gciSession
		                   defaultPath: JadePresenter homeEnvVarString.
	directoryString ifNil: [ ^ self ].
	self monticelloPackageService
		command: #addMCZRepository:;
		commandArgs: (Array with: directoryString).
	self gciSession
		issueCommand: self monticelloPackageService
		onCompletion: [ self updateRepositories ]
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
	packagesPresenter contextMenu: self newPackageMenu.
	repositoriesPresenter contextMenu: self newRepositoryMenu.
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

{ #category : 'menus' }
JadeiteMonticelloBrowser >> newRepositoryMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Attach Http Repository';
								  action: [ self addHttpRepository ] ];
					  addItem: [ :item |
							  item
								  name: 'Attach Github Repository';
								  action: [ self addGithubRepository ] ] ];
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Attach MCZ Repository';
								  action: [ self addMCZRepository ] ];
					  addItem: [ :item |
							  item
								  name: 'Attach Filetree Repository';
								  action: [ self addFiletreeRepository ] ] ]
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

	self repositoriesPresenter selectIndex:
		self repositoriesPresenter list size.
	self selectLoadedPackage
]

{ #category : 'actions' }
JadeiteMonticelloBrowser >> selectLoadedPackage [

	| index package |
	package := self packagesPresenter list
		           detect: [ :availablePackage |
				           '*' , availablePackage description , '*' match:
					           monticelloPackageService description ]
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
