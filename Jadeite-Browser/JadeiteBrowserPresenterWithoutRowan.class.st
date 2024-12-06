"
Rowan is not available in the server. Rowan-specific concepts like projects and packages will not be displayed. 
"
Class {
	#name : 'JadeiteBrowserPresenterWithoutRowan',
	#superclass : 'JadeiteBrowserPresenter',
	#instVars : [
		'classCategoryTabs',
		'classCategoryServices'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'events' }
JadeiteBrowserPresenterWithoutRowan >> abortedTransaction [

	| selectedDictionaryService selectedClassService index |
	selectedDictionaryService := self dictionaryListPresenter
		                             selectedItem ifNil: [ ^ self ].
	selectedClassService := self selectedClass.
	self updateDictionaries.
	index := self dictionaryListPresenter list indexOf:
		         selectedDictionaryService.
	self dictionaryListPresenter
		selectIndex: index
		scrollToSelection: true.
	selectedClassService ifNotNil: [
		self selectClassCategoryFor: selectedClassService.
		self selectClass: self selectedClass ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> classCategoriesAt: index matching: matchString [

	| matches |
	matches := classCategoryServices
		           select: [ :classCategoryService |
			           classCategoryService data notNil and: [
				           matchString match: classCategoryService data ] ]
		           thenCollect: [ :classCategoryService |
			           classCategoryService copy substringIndex: index ].
	matches := matches reject: [ :svc | svc data isNil ].
	^ matches asSet asSortedCollection: [ :x :y | x data < y data ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectFilterPresenters [

	categoryListPresenter whenSelectionChangedDo: [ :selection |
		self refreshCategoryListWithSelection: selection ].
	variableListPresenter whenSelectionChangedDo: [ :selection |
		selection isEmpty ifFalse: [
			self refreshMethodsOn: methodListPresenter ] ].
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectPresenters [

	super connectPresenters.
	dictionaryListPresenter whenSelectionChangedDo: [ :selection |
		self updateClassCategoriesFor: selection ].
	classCategoryPresenter whenSelectionChangedDo: [ :selection | 
		self updateClassesForClassCategory: selection ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectProjectListPresenter [
]

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> filterClassesBySelectedClassCategory: theClasses [

	classCategoryPresenter selectedItem ifNil: [ ^ theClasses ].
	^ theClasses select: [ :classService |
		  classService classCategory
		  = classCategoryPresenter selectedItem data ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeClassCategoryTabIn: panedPresenter [

	| classCategoryPage |
	classCategoryTabs := self instantiate: JadeiteNotebookPresenter.
	classCategoryPresenter := (SpTreePresenter new children: [ :service |
		                           self
			                           classCategoriesAt: service substringIndex + 1
			                           matching: service firstSubstringsToIndex , '*' ])
		                          display: [ :m | m displayString ].
	classCategoryPage := JadeiteNotebookPage
		                     title: 'Class Category'
		                     icon: nil
		                     provider: [ classCategoryPresenter ].
	classCategoryTabs addPage: classCategoryPage.
	panedPresenter add: classCategoryTabs
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
JadeiteBrowserPresenterWithoutRowan >> initializeDictionaryTabIn: panedPresenter [

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
JadeiteBrowserPresenterWithoutRowan >> initializePresenters [
	"in order to get scroll bars to (kind of) work, create a paned layout with 
	project & package list. Then create a nother paned layout with the first
	paned layout + the class list, etc.  Then add the final paned layout to the 
	upper box layout. ... Seems unnecessarily complicated. Would be better if 
	I could just add a resizer between two arbitrary widgets."

	| listPresenters classColumn filterLayout panedLayout1 panedLayout2 panedLayout3 panedLayout4 methodLayout |
	listPresenters := SpBoxLayout newLeftToRight.
	listPresenters spacing: 10.
	self layout add: listPresenters.
	panedLayout1 := SpPanedLayout newHorizontal.
	self initializeDictionaryTabIn: panedLayout1.
	self initializeClassCategoryTabIn: panedLayout1.

	classColumn := SpBoxLayout newVertical.
	self initializeClassTabs: classColumn.
	self initializeDefinedClassPackageText: classColumn.
	panedLayout2 := SpPanedLayout newHorizontal positionOfSlider: 0.66.
	panedLayout2 add: panedLayout1. 
	panedLayout2 add: classColumn.
	
	filterLayout := SpBoxLayout newHorizontal.
	self initializeFilterTabs: filterLayout.
	panedLayout3 := SpPanedLayout newHorizontal positionOfSlider: 0.75.
	panedLayout3 add: panedLayout2.
	panedLayout3 add: filterLayout.

	panedLayout4 := SpPanedLayout newHorizontal positionOfSlider: 0.75.
	methodLayout := SpBoxLayout newHorizontal.
	self initializeMethodList: methodLayout.
	panedLayout4 add: panedLayout3. 
	panedLayout4 add: methodLayout.

	listPresenters add: panedLayout4.
	self initializeLowerTabs.
	packageGroupPresenter := JadeiteListPresenter new.
	self whenBuiltDo: [ self addStyle: 'jadeiteTextBackgroundColor' ].
	projectListPresenter := JadeiteListPresenter new. "may be able to remove"
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeProjectListPresenterIn: panedLayout [
	"doesn't really do anything without rowan present.
	Might be able to remove"
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

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> postOpen [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateDictionaries.
	self
		issueCommand: browserService
		onCompletion: [ self basicPostOpen ]
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

{ #category : 'private' }
JadeiteBrowserPresenterWithoutRowan >> renameCommandFor: classService to: newName [

	classService
		command: #renameClass:to:;
		commandArgs: (Array with: classService name with: newName);
		selectedPackageServices: Array new
]

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> selectClass: classService [

	| index dictionaryService |
	classService ifNil: [ ^self ]. 
	dictionaryService := self dictionaryListPresenter list
		                     detect: [ :d |
		                     d name = classService dictionaryName ]
		                     ifNone: [ ^ self ].
	index := self dictionaryListPresenter list indexOf: dictionaryService.
	self dictionaryListPresenter selection selectedIndex = index
		ifFalse: [
			self dictionaryListPresenter selection unselectAll.
			self dictionaryListPresenter
				selectIndex: index
				scrollToSelection: true ].
	self selectClassCategoryFor: classService.
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

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> selectClassCategoryFor: classService [

	| classCategoryService index |
	index := classService classCategory
		         ifNil: [ 1 ]
		         ifNotNil: [ :cat | (cat substrings: #($-)) size ].
	classCategoryService := RowanClassCategoryService new
		                        name: classService classCategory;
		                        substringIndex: index;
		                        yourself.
	self classCategoryPresenter selectedItem = classCategoryService
		ifFalse: [
		self classCategoryPresenter selectItem: classCategoryService ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateAfterFindClass: classService onCompletion: completionBlock [

	RowanServiceUpdater current critical: [
		self setAppropriateMeta: classService.
		self selectClassListTab.
		self selectClass: classService.
		completionBlock value ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClass: classService [
	" a class service was updated, refresh our display"

	| selection |
	selection := self selectedClass.
	self selectClassCategoryFor: classService.
	self isClassHierarchyTabSelected
		ifTrue: [
		self updateClassInClassHierarchy: classService selection: selection ]
		ifFalse: [ self updateClassInClassList: classService selection: nil ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClassCategoriesFor: selection [

	| dictionaryService newServices |
	dictionaryService := selection selectedItem.
	dictionaryService ifNil: [
		^ classCategoryPresenter roots: OrderedCollection new ].
	dictionaryService classCategories ifNil: [
		^ classCategoryPresenter roots: OrderedCollection new ].
	newServices := dictionaryService classCategories collect: [ :category |
		               RowanClassCategoryService new name: category ].
	newServices = classCategoryServices ifTrue: [ ^ self ].
	classCategoryServices := newServices.
	classCategoryPresenter roots:
		(self classCategoriesAt: 1 matching: '*')
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClassInClassHierarchy: classService selection: selection [
	" a class service was updated, refresh our display"

	| update |
	update := classHierarchyPresenter model asBag
		          detect: [ :listClassService |
		          listClassService name = classService name ]
		          ifNone: [ ^ self ].
	update replicateFrom: classService.
	selection ifNil: [ ^ self ].
	self selectClassInClassHierarchyNamed: selection name.
	classHierarchyPresenter view invalidate
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClassInClassList: classService selection: selection [
	" a class service was updated, refresh our display"

	| update |
	update := classListPresenter model asBag
		          detect: [ :listClassService |
		          listClassService name = classService name ]
		          ifNone: [ ^ self ].
	update replicateFrom: classService.
	classService ifNil: [ ^ self ].
	self selectClass: selection.
	classListPresenter view invalidate
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateClassInfo [

	self selectedClass ifNil: [
		self resetDefinedClassPackage.
		^ self ].
	self basicUpdateClassInfo.
	self sundryCleanup
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClassesForClassCategory: selection [

	| classCategoryService classes |
	classCategoryService := selection selectedItem.
	classCategoryService ifNil: [ ^ self ].
	classes := self dictionaryListPresenter selectedItem classes select: [
		           :classService |
		           classService classCategory
			           ifNil: [ false ]
			           ifNotNil: [ :cat |
			           classCategoryService firstSubstringsToIndex , '*'
				           match: cat ] ].
	self classListPresenter list:
		(classes asSortedCollection: [ :x :y | x name < y name ])
]
