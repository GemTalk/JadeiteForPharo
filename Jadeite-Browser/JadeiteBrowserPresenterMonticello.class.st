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

{ #category : 'tab labels' }
JadeiteBrowserPresenterMonticello >> basicProjectTabLabel [
	self monticelloPackageListPresenter selectedItems ifEmpty: [
		^ 'Projects' ].
	self selectedClass ifNotNil: [ ^ self selectedClass name ].
	^ self monticelloPackageListPresenter selectedItem tabLabel
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> classListHierarchyTabsChanged [

	self isHierarchyTabSelected
		ifTrue: [ self updateHierarchy ]
		ifFalse: [
				classHierarchyPresenter selectedItem ifNotNil: [ :sel |
						classListPresenter
							selectIndex: (classListPresenter items indexOf: sel)
							scrollToSelection: true ] ].
	^ self classSelected: self selectedClass
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> connectDictionaryAndClassCategoryPresenters [
	"not relevant for seaside"
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> connectPresenters [

	super connectPresenters.
	monticelloPackageListPresenter
		whenSelectionChangedAndEventsNotSuspendedDo: [ :selection |
		self monticelloPackageChanged: selection selectedItem ]
]

{ #category : 'accessing' }
JadeiteBrowserPresenterMonticello >> dictionaryListPresenter [
	"not sure if this is going to work but so many times
	all we send this method for is to check if we have selections"

	^ self monticelloPackageListPresenter
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
		                                  display: #description;
		                                  displayBold: [ :packageService |
			                                  packageService hasChanges ].
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

{ #category : 'testing' }
JadeiteBrowserPresenterMonticello >> isNoneProjectSelected [

	^ false
]

{ #category : 'events' }
JadeiteBrowserPresenterMonticello >> monticelloPackageChanged: monticelloPackageService [

	monticelloPackageService ifNil: [
			self updateSystemTab.
			^ self classListPresenter items: OrderedCollection new ].
	monticelloPackageService command: #classes.
	self issueCommand: monticelloPackageService onCompletion: [ :svc |
			classListPresenter items: svc classes.
			self updateTabLabel ]
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

{ #category : 'accessing' }
JadeiteBrowserPresenterMonticello >> packageListPresenter [

	^ self monticelloPackageListPresenter
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

{ #category : 'actions' }
JadeiteBrowserPresenterMonticello >> resetClassTemplate [

	| presenter |
	classDefinitionPresenter isModified: false.
	presenter := self monticelloPackageListPresenter.
	presenter selectedItem
		ifNil: [ self updateClassDefPresenter ]
		ifNotNil: [ :selectedItem |
				self uiManager defer: [
						self selectedClassTab
							ifNil: [
							classDefinitionPresenter value: selectedItem defaultTemplate ]
							ifNotNil: [
									classDefinitionPresenter value:
										self selectedClassTab activePresenter selectedItem template ] ] ].
	self markClassDefinitionPaneUnmodified
]

{ #category : 'accessing' }
JadeiteBrowserPresenterMonticello >> templateForMonticelloPackage: monticelloPackageService [

	| answeringService dictionaryService |
	self todo: [
			dictionaryService := self dictionaryListPresenter selectedItem.
			monticelloPackageService ifNil: [
					self uiManager defer: [
							classDefinitionPresenter text:
								dictionaryService defaultTemplate.
							classDefinitionPresenter isModified: false ].
					^ self ].
			JadeitePreferences isRowanAvailable ifTrue: [
					self uiManager defer: [
							classDefinitionPresenter text:
								(self defaultTemplateForClassCategory:
									 monticelloPackageService).
							classDefinitionPresenter isModified: false ].
					^ self ].
			answeringService := RowanAnsweringService new
				                    command:
					                    #templateForClassCategory:dictionaryName:;
				                    commandArgs: (Array
						                     with:
							                     monticelloPackageService
								                     classDefinitionTemplateString
						                     with: dictionaryService name).
			self issueCommand: answeringService onCompletion: [ :service |
					self uiManager defer: [
							classDefinitionPresenter text: service answer.
							classDefinitionPresenter isModified: false ] ] ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterMonticello >> updateClassDefPresenter [

	self selectedClass ifNotNil: [ :classService |
			self uiManager defer: [
					classDefinitionPresenter text:
						(classService template ifNil: [ String new ]).
					classDefinitionPresenter isModified: false ].
			^ self ].
	self monticelloPackageListPresenter selectedItem ifNil: [
		^ self markClassDefinitionPaneUnmodified ].
	self templateForMonticelloPackage:
		self monticelloPackageListPresenter selectedItem
]

{ #category : 'updates' }
JadeiteBrowserPresenterMonticello >> updateHierarchy [

	| service |
	classHierarchyPresenter clear.

	monticelloPackageListPresenter selectionOrNil ifNil: [ ^ self ].
	service := classListPresenter selectionOrNil ifNil: [
		           ^ self updateHierarchyForPacktionaries ].
	service
		updateAfterCommand: false;
		command: #classHierarchy.
	self issueCommand: service onCompletion: [ ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterMonticello >> updateProjectsOnCompletion: completionBlock catchBlock: catchBlock [

	self
		updateMonticelloPackagesOnCompletion: completionBlock
		catchBlock: catchBlock
]
