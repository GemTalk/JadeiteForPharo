Class {
	#name : 'JadeiteBrowserPresenterMonticello',
	#superclass : 'JadeiteBrowserPresenterWithoutRowan',
	#traits : 'JadeiteMonticelloTrait',
	#classTraits : 'JadeiteMonticelloTrait classTrait',
	#instVars : [
		'monticelloPackageListPresenter'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'events' }
JadeiteBrowserPresenterMonticello >> abortedTransaction [
	self todo: 'should update monticello package list'.
	self updateDictionariesOnCompletion: [
			self resetClassTemplate.
			self resetClassComment.
			self updateMethodSource.
			self resetStatusBarColor.
			self statusBarText pushMessage: String new.
			self updateSUnitTab ]
]

{ #category : 'actions' }
JadeiteBrowserPresenterMonticello >> addMonticelloPackage [

	self uiManager alert: 'Not Implemented Yet'
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> connectPresenters [

	monticelloPackageListPresenter
		whenSelectionChangedAndEventsNotSuspendedDo: [ :selection |  ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> initializeFirstColumns: panedLayout [

	self initializeMonticelloPackageListIn: panedLayout.
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> initializeMonticelloPackageListIn: panedPresenter [

	| monticelloPackagePage monticelloPackageTab |
	monticelloPackageTab := self instantiate: JadeiteNotebookPresenter.
	monticelloPackageListPresenter := (JadeiteListPresenter
		                                   newNameSortedListFor: self)
		                                  contextMenu:
			                                  self newMonticelloPackageMenu;
		                                  display: #description.
	self todo: [
			self monticelloPackageListPresenter
				wantsDrop: [ :transfer |
					self jadeiteDictionaryWantsDrop: transfer ];
				acceptDrop: [ :transfer | self prepareToDropClass: transfer ] ].
	monticelloPackagePage := JadeiteNotebookPage
		                         title: 'Monticello Package'
		                         icon: nil
		                         provider: [ monticelloPackageListPresenter ].
	monticelloPackageTab addPage: monticelloPackagePage.
	panedPresenter add: monticelloPackageTab
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> initializePresenters [

	| listPresenters classColumn filterLayout panedLayout1 panedLayout2 panedLayout3 panedLayout4 methodLayout |
	listPresenters := SpBoxLayout newLeftToRight.
	listPresenters spacing: 10.
	self layout add: listPresenters.
	panedLayout1 := SpPanedLayout newHorizontal positionOfSlider: 0.99.
	self initializeMonticelloPackageListIn: panedLayout1.
	classColumn := SpBoxLayout newVertical.
	self initializeClassTabs: classColumn.
	self initializeClassExtraText: classColumn.
	panedLayout2 := SpPanedLayout newHorizontal positionOfSlider: 0.66.
	panedLayout2 add: panedLayout1.
	panedLayout2 add: classColumn.
	filterLayout := SpBoxLayout newHorizontal.
	self initializeFilterTabs: filterLayout.
	panedLayout3 := SpPanedLayout newHorizontal positionOfSlider: 0.7.
	panedLayout3 add: panedLayout2.
	panedLayout3 add: filterLayout.
	panedLayout4 := SpPanedLayout newHorizontal positionOfSlider: 0.75.
	methodLayout := SpBoxLayout newHorizontal.
	self initializeMethodList: methodLayout.
	panedLayout4 add: panedLayout3.
	panedLayout4 add: methodLayout.
	listPresenters add: panedLayout4.
	self initializeLowerTabs.
	self whenBuiltDo: [ self addStyle: 'jadeiteTextBackgroundColor' ].
	projectListPresenter := JadeiteListPresenter new
]

{ #category : 'accessing' }
JadeiteBrowserPresenterMonticello >> monticelloPackageListPresenter [

	^ monticelloPackageListPresenter
]

{ #category : 'accessing' }
JadeiteBrowserPresenterMonticello >> monticelloPackageListPresenter: anObject [

	monticelloPackageListPresenter := anObject
]

{ #category : 'menus' }
JadeiteBrowserPresenterMonticello >> newMonticelloPackageMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
				  group
					  addItem: [ :item |
							  item
								  name: 'Add Package ...';
								  action: [ self addMonticelloPackage ] ];
					  addItem: [ :item |
							  item
								  name: 'Remove Package ...';
								  action: [ self removeMonticelloPackage ];
								  enabled: [
									  self monticelloPackageListPresenter selectedItem notNil ] ] ];
		  addGroup: [ :group |
				  group addItem: [ :item |
						  item
							  name: 'Refresh from Server';
							  action: [
								  self
									  updateMonticelloPackagesOnCompletion: [ ]
									  catchBlock: [ ] ] ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> postOpen [

	self
		updateMonticelloPackagesOnCompletion: [ :svc | self basicPostOpen ]
		catchBlock: [ ]
]

{ #category : 'actions' }
JadeiteBrowserPresenterMonticello >> removeMonticelloPackage [

	self uiManager alert: 'Not Implemented Yet'
]

{ #category : 'updates' }
JadeiteBrowserPresenterMonticello >> updateProjectsOnCompletion: completionBlock catchBlock: catchBlock [

	self
		updateMonticelloPackagesOnCompletion: completionBlock
		catchBlock: catchBlock
]
