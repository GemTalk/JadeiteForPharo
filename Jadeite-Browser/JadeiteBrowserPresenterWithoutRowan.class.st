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
		self selectClass: self selectedClass completionBlock: [  ] ]
]

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> addClassCategory: classCategory [

	| sorted |
	sorted := self dictionaryListPresenter selectedItem classCategories
		          asSortedCollection.
	sorted add: classCategory.
	self dictionaryListPresenter selectedItem classCategories:
		sorted asArray.
	self updateClassCategoriesFor:
		self dictionaryListPresenter selectedItem
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
			self refreshMethodsOn: methodListPresenter extensions: Array new ] ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectPackageDictionaryPresenters [

"	dictionaryListPresenter whenSelectionChangedDo: [ :selection |
		self updateDictionary ]"
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectPresenters [

	super connectPresenters.
	dictionaryListPresenter whenSelectionChangedAndEventsNotSuspendedDo: [
		:selection | self updateClassCategoriesFor: selection selectedItem ].
	classCategoryPresenter whenSelectionChangedDo: [ :selection |
		selectionEventsSuspended ifFalse: [
			self updateClassesForClassCategory: selection selectedItem.
			self updateClassDefPresenter ] ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> connectProjectListPresenter [
]

{ #category : 'acccessing' }
JadeiteBrowserPresenterWithoutRowan >> defaultTemplateForClassCategory: classCategory [

	^ self dictionaryListPresenter selectedItem defaultTemplate
		  copyReplaceAll: 'category: nil'
		  with: 'category: ''' , classCategory firstSubstringsToIndex , ''''
]

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> filterClassesBySelectedClassCategory: theClasses [

	classCategoryPresenter selectedItem ifNil: [ ^ theClasses ].
	^ theClasses select: [ :classService |
		  classService classCategory
		  = classCategoryPresenter selectedItem name ]
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
JadeiteBrowserPresenterWithoutRowan >> initializeClassExtraText: classColumn [

	classExtraText := SpTextPresenter new
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeDefinedMethodPackageText: methodColumn [

	definedMethodPackageText := SpTextPresenter new.
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> initializeDictionaryTabIn: panedPresenter [

	| dictionaryListPage |
	packageDictionaryTabs := self instantiate: JadeiteNotebookPresenter.
	packageListPresenter := JadeiteListPresenter newFor: self.
	dictionaryListPresenter := (JadeiteListPresenter
		                            newNameSortedListFor: self)
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
	variableListPresenter := (JadeiteListPresenter newFor: self)
		                         beMultipleSelection.
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
	self initializeClassExtraText: classColumn.
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

{ #category : 'events' }
JadeiteBrowserPresenterWithoutRowan >> newClass: classService addedTo: presenter [

	dictionaryListPresenter selectedItem ifNotNil: [ :dictionaryService |
		dictionaryService addClass: classService ].
	self classCategoryPresenter ifNil: [ ^ self ].
	self classCategoryPresenter selectedItem ifNotNil: [ :item |
		classService classCategory = item name ifFalse: [
			self selectClassCategoryFor: classService.
			self classCategoryPresenter selectedItem ifNil: [ "still not found"
				self addClassCategory: classService classCategory.
				self selectClassCategoryFor: classService ] ] ].
	(presenter items includes: classService) ifFalse: [
		presenter items add: classService ]
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
JadeiteBrowserPresenterWithoutRowan >> selectClass: classService completionBlock: completionBlock [

	classService ifNil: [ ^ self ].
	self selectDictionaryNamed: classService dictionaryName.
	super selectClass: classService completionBlock: completionBlock
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> selectClassCategory: classCategoryService keepSelectedClass: selectedClass [

	| classes toBeSelected |
	classes := self dictionaryListPresenter selectedItem classes select: [
		           :classService |
		           classService classCategory
			           ifNil: [ false ]
			           ifNotNil: [ :cat |
			           classCategoryService firstSubstringsToIndex , '*'
				           match: cat ] ].
	self classListPresenter list:
		(classes asSortedCollection: [ :x :y | x name < y name ]).
	toBeSelected := self classListPresenter items
		                detect: [ :classService |
		                classService = selectedClass ]
		                ifNone: [ nil ].
	^ selectedClass ifNotNil: [
		  self isClassListTabSelected ifTrue: [
			  self classListPresenter selectItem: toBeSelected ] ]
]

{ #category : 'actions' }
JadeiteBrowserPresenterWithoutRowan >> selectClassCategoryFor: classService [
	"I'm not sure this is the right thing to do. In some ways it makes sense -
	show the exact category the selected class is in. But in other ways you want
	to not change the category selection the user chose. Disabling for now."

	| classCategoryService index |
	index := classService classCategory
		         ifNil: [ 1 ]
		         ifNotNil: [ :cat | (cat substrings: #( $- )) size ].
	classCategoryService := classService classCategory = String new
		                        ifTrue: [
		                        RowanClassCategoryService nilClassCategory ]
		                        ifFalse: [
			                        RowanClassCategoryService new
				                        name: classService classCategory;
				                        substringIndex: index;
				                        yourself ].
	self classCategoryPresenter selectedItem = classCategoryService
		ifFalse: [
		self classCategoryPresenter selectItem: classCategoryService ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateAfterFindClass: classService methodService: methodService onCompletion: completionBlock [

	self suspendSelectionEvents.
	self updateService: classService onCompletion: [
		[
		RowanServiceUpdater current applyUpdateWhile: [
			self selectDictionaryNamed: classService dictionaryName.
			self updateService: self dictionaryListPresenter selectedItem.
			self updateClassCategoriesFor:
				self dictionaryListPresenter selectedItem.
			self setAppropriateMeta: classService.
			self isHierarchyTabSelected ifTrue: [
				self selectedClass = classService ifFalse: [
					self selectClassListTab ] ].
			self selectClassCategoryFor: classService.
			self updateClassesForClassCategory:
				self classCategoryPresenter selectedItem.
			self selectClass: classService completionBlock: completionBlock.
			methodListPresenter items: classService methods.
			methodListPresenter beSorted.
			classService updateSortedJadeiteCategories: categoryListPresenter.
			methodService ifNotNil: [
				| index |
				self methodListPresenter selection unselectAll.
				index := self methodListPresenter items indexOf: methodService.
				self methodListPresenter
					selectIndex: index
					scrollToSelection: true ] ] ] ensure: [
			self resumeSelectionEvents ] ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClass: classService [
	" a class service was updated, refresh our display"

	| selection |
	selection := self selectedClass.
	self isClassHierarchyTabSelected
		ifTrue: [
		self updateClassInClassHierarchy: classService selection: selection ]
		ifFalse: [ self updateClassInClassList: classService selection: selection ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClassCategoriesFor: dictionaryService [

	| newServices |
	dictionaryService ifNil: [
		^ classCategoryPresenter roots: OrderedCollection new ].
	dictionaryService
		command: #updateClassCategories;
		commandArgs: Array new;
		shouldUpdate: false.
	classListPresenter items: Array new.
	classHierarchyPresenter roots: Array new.
	self issueCommand: dictionaryService onCompletion: [
		dictionaryService classCategories
			ifNil: [ classCategoryPresenter roots: OrderedCollection new ]
			ifNotNil: [
				newServices := dictionaryService classCategories collect: [
					               :category |
					               RowanClassCategoryService new name: category ].
				classCategoryServices := newServices.
				classCategoryPresenter roots:
					(self classCategoriesAt: 1 matching: '*') ] ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenterWithoutRowan >> updateClassDefPresenter [

	| defaultTemplate |
	self selectedClass ifNotNil: [ :classService |
		classDefinitionPresenter text: classService template.
		classDefinitionPresenter isModified: false.
		^ self ].
	self dictionaryListPresenter selectedItem ifNil: [
		^ self resetClassDefinitionPane ].
	defaultTemplate := self classCategoryPresenter selectedItem
		                   ifNil: [
		                   self dictionaryListPresenter selectedItem
			                   defaultTemplate ]
		                   ifNotNil: [ :classCategory |
			                   self defaultTemplateForClassCategory:
				                   classCategory ].
	classDefinitionPresenter text: defaultTemplate.
	classDefinitionPresenter isModified: false
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
	classHierarchyPresenter refresh
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
	selection ifNil: [ ^ self ].
	self
		selectClass: selection
		completionBlock: [ classListPresenter view invalidate ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateClassInfo [

	self selectedClass ifNil: [
		self resetClassExtras.
		^ self ].
	self basicUpdateClassInfo.
	self sundryCleanup
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateClassThenFind: classService onCompletion: completionBlock [

	self isClassHierarchyTabSelected
		ifTrue: [
			classHierarchyPresenter items: Array new.
			classService
				updateAfterCommand: true;
				command: #classHierarchy.
			self
				issueCommand: classService
				onCompletion: [ self updateClassInfo ] ]
		ifFalse: [
			self
				updateAfterFindClass: classService
				methodService: nil
				onCompletion: completionBlock ]
]

{ #category : 'updates' }
JadeiteBrowserPresenterWithoutRowan >> updateClassesForClassCategory: classCategoryService [

	| dictionaryService selectedClass |
	classCategoryService ifNil: [ ^ self ].
	self classCategoryPresenter selectedItem = classCategoryService
		ifTrue: [ selectedClass := self selectedClass ]
		ifFalse: [
			classListPresenter unselectAll.
			selectedClass := nil ].
	dictionaryService := self dictionaryListPresenter selectedItem.
	self dictionaryListPresenter selectedItem ifNil: [ ^ self ].
	dictionaryService
		command: #updateForClassCategory:;
		commandArgs:
			(Array with: classCategoryService firstSubstringsToIndex);
		shouldUpdate: false.
	RowanServiceUpdater current
		issueCommand: dictionaryService
		session: self gciSession
		onCompletion: [
			self
				selectClassCategory: classCategoryService
				keepSelectedClass: selectedClass ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenterWithoutRowan >> updateClassesOnCompletion: completionBlock [

	self
		updateServices: dictionaryListPresenter selections
		onCompletion: completionBlock
]
