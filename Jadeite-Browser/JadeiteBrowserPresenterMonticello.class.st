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

{ #category : 'actions' }
JadeiteBrowserPresenterMonticello >> addMonticelloPackage [

	self uiManager alert: 'Not Implemented Yet'
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> connectDictionaryAndClassCategoryPresenters [

	"do nothing in monticello browser "
	
	super connectDictionaryAndClassCategoryPresenters
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> connectPresenters [
	super connectPresenters. 
"	monticelloPackageListPresenter
		whenSelectionChangedAndEventsNotSuspendedDo: [ :selection |  ]"
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> initializeFirstColumns: panedLayout [

	self initializeDictionaryTabIn: panedLayout.
	self initializeClassCategoryTabIn: panedLayout
		"self	initializeMonticelloPackageListIn: panedLayout "
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> initializeMonticelloPackageListIn: panedPresenter [

	| monticelloPackagePage monticelloPackageTab |
	monticelloPackageTab := self instantiate: JadeiteNotebookPresenter.
	monticelloPackageListPresenter := (JadeiteListPresenter
		                                   newNameSortedListFor: self)
		                                  contextMenu:
		                                  self newMonticelloPackageMenu.
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

{ #category : 'registration' }
JadeiteBrowserPresenterMonticello >> registerMonticelloPackagesForUpdates [

	RowanServiceUpdater current
		register: monticelloPackageListPresenter
		selector: #monticelloPackageListUpdate:
]

{ #category : 'registration' }
JadeiteBrowserPresenterMonticello >> registerPackageDictionaryListsForUpdates [

	self registerMonticelloPackagesForUpdates
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
