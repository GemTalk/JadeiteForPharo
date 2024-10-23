"
Rowan is not available in the server. Rowan-specific concepts like projects and packages will not be displayed. 
"
Class {
	#name : 'JadeiteBrowserPresenterWithoutRowan',
	#superclass : 'JadeiteBrowserPresenter',
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectFilterPresenters [

	categoryListPresenter whenSelectionChangedDo: [ :selection |
		self refreshCategoryListWithSelection: selection ].
	variableListPresenter whenSelectionChangedDo: [ :selection |
		selection isEmpty ifFalse: [
			self refreshMethodsOn: methodListPresenter ] ].
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectProjectListPresenter [
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeDefinedClassPackageText: classColumn [

	definedClassPackageText := SpTextPresenter new
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeDefinedMethodPackageText: methodColumn [

	definedMethodPackageText := SpTextPresenter new.
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeFilterTabs: methodPanedLayout [

	| categoryPage variablePage |
	methodFilterTabs := self instantiate: JadeiteNotebookPresenter.
	categoryListPresenter := self initializeCategoryListPresenter.
	self initializeCategoryListMenu.
	variableListPresenter := JadeiteListPresenter new.
	self initializeVariableListMenu.
	categoryPage := JadeiteNotebookPage
		                title: 'Category'
		                icon: nil
		                provider: [ categoryListPresenter ].
	variablePage := JadeiteNotebookPage
		                title: 'Variable'
		                icon: nil
		                provider: [ variableListPresenter ].
	methodFilterTabs addPage: categoryPage.
	methodFilterTabs addPage: variablePage.
	methodPanedLayout add: methodFilterTabs.
	packageMethodListPresenter := JadeiteListPresenter new.
	packageMethodListPage := JadeiteNotebookPage new
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializePackageDictionaryTabsIn: panedPresenter [

	| dictionaryListPage |
	packageDictionaryTabs := self instantiate: JadeiteNotebookPresenter.
	packageListPresenter := JadeiteListPresenter new.
	dictionaryListPresenter := JadeiteListPresenter newNameSortedList
		                           contextMenu: self newDictionaryMenu.
	dictionaryListPage := JadeiteNotebookPage
		                      title: 'Dictionary'
		                      icon: nil
		                      provider: [ dictionaryListPresenter ].
	packageDictionaryTabs addPage: dictionaryListPage.
	panedPresenter add: packageDictionaryTabs
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializePresenters [
	"in order to get scroll bars to (kind of) work, create a paned layout with 
	project & package list. Then create a nother paned layout with the first
	paned layout + the class list, etc.  Then add the final paned layout to the 
	upper box layout. ... Seems unnecessarily complicated. Would be better if 
	I could just add a resizer between two arbitrary widgets."

	| listPresenters classColumn filterLayout panedLayout1 panedLayout2 panedLayout3 methodLayout |
	listPresenters := SpBoxLayout newLeftToRight.
	listPresenters spacing: 10.
	self layout add: listPresenters.
	panedLayout1 := SpPanedLayout newHorizontal.
	self initializeProjectListPresenterIn: panedLayout1.
	self initializePackageDictionaryTabsIn: panedLayout1.
	classColumn := SpBoxLayout newVertical.
	panedLayout1 add: classColumn.
	self initializeClassTabs: classColumn.
	self initializeDefinedClassPackageText: classColumn.
	panedLayout2 := SpPanedLayout newHorizontal positionOfSlider: 0.66.
	panedLayout2 add: panedLayout1.
	filterLayout := SpBoxLayout newHorizontal.
	self initializeFilterTabs: filterLayout.
	panedLayout2 add: filterLayout.
	panedLayout3 := SpPanedLayout newHorizontal positionOfSlider: 0.66.
	panedLayout3 add: panedLayout2.
	methodLayout := SpBoxLayout newHorizontal.
	self initializeMethodList: methodLayout.
	panedLayout3 add: methodLayout.
	listPresenters add: panedLayout3.
	self initializeLowerTabs.
	packageGroupPresenter := JadeiteListPresenter new.
	self whenBuiltDo: [ self addStyle: 'jadeiteTextBackgroundColor' ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeProjectListPresenterIn: panedLayout [

	projectListPresenter := JadeiteListPresenter new. 
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeProjectTab [

	projectInfoList := JadeiteTablePresenter new.
	projectInfoTab := JadeiteNotebookPage new
]

{ #category : 'testing' }
JadeiteBrowserPresenterWithoutRowan >> isDictionaryTabSelected [

	^true

]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> refreshProjectInfoTab [
]

{ #category : 'registration' }
JadeiteBrowserPresenterWithoutRowan >> registerPackageDictionaryListsForUpdates [

	RowanServiceUpdater current
		register: dictionaryListPresenter
		selector: #dictionaryListUpdate:
]

{ #category : 'registration' }
JadeiteBrowserPresenterWithoutRowan >> registerProjectListForUpdates [
]

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> selectClass: classService [

	| index dictionaryService |
	dictionaryService := RowanDictionaryService new name: 
		                     classService dictionaryName.
	index := self dictionaryListPresenter list indexOf: dictionaryService.
	self dictionaryListPresenter selection selectedIndex = index
		ifFalse: [
			self dictionaryListPresenter selection unselectAll.
			self dictionaryListPresenter
				selectIndex: index
				scrollToSelection: true ].
	index := self classListPresenter list indexOf: classService.
	index = 0 ifTrue: [
		classService meta ifNil: [ classService meta: true ].
		index := self classListPresenter list indexOf:
			         (classService copy meta: classService meta not) ].
	self classListPresenter selection selectedIndex = index ifFalse: [
		self classListPresenter selection unselectAll.
		self classListPresenter selectIndex: index scrollToSelection: true.
		self updateClassInfo ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateAfterFindClass: classService onCompletion: completionBlock [

	RowanServiceUpdater current critical: [
		self setAppropriateMeta: classService.
		self selectClassListTab.
		self selectClass: classService.
		completionBlock value ]
]
