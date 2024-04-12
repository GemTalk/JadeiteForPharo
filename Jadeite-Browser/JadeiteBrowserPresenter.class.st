Class {
	#name : 'JadeiteBrowserPresenter',
	#superclass : 'JadeiteProjectsBrowserPresenter',
	#traits : 'JadeiteMethodsTrait + JadeiteProjectsTrait + JadeiteFilterTrait + JadeiteClassTrait + JadeitePackageTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteProjectsTrait classTrait + JadeiteFilterTrait classTrait + JadeiteClassTrait classTrait + JadeitePackageTrait classTrait',
	#instVars : [
		'packageDictionaryCards',
		'globalsTab',
		'search',
		'previousTabViewArrangement',
		'previousTopViewArrangement',
		'packageGroupPresenter',
		'componentPackageContainer',
		'packageDictionaryContainer',
		'packageMethodListPresenter',
		'projectListContainer',
		'packageGroupsContainer',
		'classContainer',
		'projectInfoList',
		'addPackagePresenter',
		'projectReadMeTab',
		'toolbar',
		'methodSourcePage',
		'classDefinitionPage',
		'instanceRadioButton',
		'classRadioButton',
		'classCommentTab',
		'packageMethodListPage',
		'backButton',
		'forwardButton'
	],
	#pools : [
		'ScintillaConstants'
	],
	#category : 'Jadeite-Browser'
}

{ #category : 'utility' }
JadeiteBrowserPresenter class >> browseSendersOf: string session: session [

	| service shell |
	service := RowanQueryService
		           command: #sendersOf:
		           withArgs: (Array with: string asSymbol).
	self issueCommand: service session: session onCompletion: nil.
	shell := self
		         openMethodListOn: service
		         selecting: string
		         session: session.
	shell updateCaptionFromSearchString:
		'Senders of ' , string asString printString.
	^ shell
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter class >> defaultAdditionalAccelerators [
	^super defaultAdditionalAccelerators, #(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T'))
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter class >> downArrowIcon [
	^Icon fromFile: 'icons\DownArrow.ico'

]

{ #category : 'utility' }
JadeiteBrowserPresenter class >> issueCommand: service session: gciSession [

	^RowanServiceUpdater current issueCommand: service session: gciSession
]

{ #category : 'utility' }
JadeiteBrowserPresenter class >> issueCommands: service session: gciSession onCompletion: anObject [

	^ RowanServiceUpdater current
		  issueCommands: service
		  session: gciSession
		  onCompletion: nil
]

{ #category : 'utility' }
JadeiteBrowserPresenter class >> openMethodListOn: service selecting: string session: session [
	| selectionString |
	selectionString := (ReadStream on: string) upTo: $:.
	^JadeiteMethodListBrowser
		openOn: service
		selecting: selectionString
		session: session
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter class >> overriddenIcon [
	^Icon fromId: 'icons\OVERRIDDEN.ICO'
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter class >> projectMenu [
	^Menu fromStrings: self projectMenuStrings
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> abortTransaction [

	super abortTransaction.
	self gciSession autoCommit:
		(self gciSession autoCommit value == #failed
			 ifTrue: [ true ]
			 ifFalse: [ self gciSession autoCommit value ])
]

{ #category : 'events' }
JadeiteBrowserPresenter >> abortedTransaction [

	self updateProjects.
	self selectedClass ifNotNil: [ :classService |
		self updateAfterFindClass: classService onCompletion: nil ].
	self resetClassTemplate.
	self resetClassComment.
	self projectListPresenter invalidate
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> aboutToChange: aSelectionChangingEvent [
	aSelectionChangingEvent value
		ifTrue: 
			[aSelectionChangingEvent value: self isOkayToChange.
			aSelectionChangingEvent value ifTrue: [self resetCategoryText]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> addComputedCategories [

	categoryListPresenter list first
	= RowanClassService computedExtensionCategory ifFalse: [
		categoryListPresenter list addFirst:
			RowanClassService computedExtensionCategory ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> addDictionary [
	| newDictionaryName |
	(newDictionaryName := Prompter prompt: 'Enter new dictionary name:') isNil ifTrue: [^self].
	newDictionaryName isEmpty ifTrue: [^MessageBox notify: 'Blank dictionary names not allowed'].
	(dictionaryListPresenter list detect: [:service | service name = newDictionaryName] ifNone: [])
		ifNotNil: [^MessageBox notify: 'Dictionary ' , newDictionaryName , ' already exists'].
	(MessageBox
		confirm: 'Really add dictionary ' , newDictionaryName , '? This will commit the transaction')
			ifTrue: [^self basicAddDictionaryNamed: newDictionaryName]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> addNoneProject [
	(projectListPresenter list includes: RowanProjectService noneProject)
		ifFalse: [projectListPresenter model add: RowanProjectService noneProject]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> addPackagePresenter [
	^addPackagePresenter
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> addStyle: aString [

	methodSourcePresenter whenBuiltDo: [
		methodSourcePresenter addStyle: 'jadeiteTextBackgroundColor'. ].
	classDefinitionPresenter whenBuiltDo: [
		classDefinitionPresenter addStyle: 'jadeiteTextBackgroundColor' ].
	classCommentPresenter whenBuiltDo: [
		classCommentPresenter addStyle: 'jadeiteTextBackgroundColor' ].
	projectInfoList whenBuiltDo: [
		projectInfoList addStyle: 'jadeiteTextBackgroundColor' ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> addSystemBrowser [
	| browser position |
	position := self topShell view position.	"don't let default position takeover when adding tab"
	browser := self topShell addSystemBrowser.
	self makeSameSelectionsIn: browser currentCard as: self.
	self topShell view position: position.
	^browser
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> addVariableAccessors [
	self confirmOverwriteAccessor ifFalse: [^self].
	self basicAddVariableAccessors
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> additionalAccelerators [
	^super additionalAccelerators , #(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T'))
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> arrangement: anObject [

	self parentPresenter updateLabel: anObject
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicAddDictionaryNamed: newDictionaryName [

	| insertionIndex dictionaryService |
	insertionIndex := dictionaryListPresenter selectionByIndex = 0
		                  ifTrue: [ dictionaryListPresenter list size + 1 ]
		                  ifFalse: [
		                  dictionaryListPresenter selectionByIndex + 1 ].
	dictionaryService := RowanDictionaryService new name:
		                     newDictionaryName.
	dictionaryService
		command: #insertAt:;
		commandArgs: (Array with: insertionIndex).
	self issueCommand: dictionaryService onCompletion: nil.
	dictionaryListPresenter selection:
		(dictionaryListPresenter list detect: [ :newService |
			 newService name = newDictionaryName ])
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicAddMethodCategory: string [

	| service jadeiteCategory listCategory |
	jadeiteCategory := JadeiteCategory named: string.
	listCategory := self categoryListPresenter list detect:[:jc | jc = jadeiteCategory] ifNone:[].
	listCategory notNil ifTrue: [
		listCategory isComputed ifFalse: [ ^ self ] ].
	service := self selectedClass
		           command: #addCategory:;
		           commandArgs: (Array with: string).
	service meta: self isClassSideSelected.
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: nil.
	self selectCategoriesNamed: (Array with: jadeiteCategory)
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicAddVariableAccessors [
	| cachedSelections |
	(cachedSelections := self methodFilterListPresenter selections) do: 
			[:variable |
			| sourceStream classService |
			classService := self selectedClass.
			sourceStream := self getterMethodSourceFor: variable.
			classService
				saveMethod: sourceStream contents
				category: 'accessing'
				session: self gciSession.
			sourceStream := self setterMethodSourceFor: variable.
			classService
				saveMethod: sourceStream contents
				category: 'accessing'
				session: self gciSession].
	self methodFilterListPresenter selections: cachedSelections
]

{ #category : 'actions' }
JadeiteBrowserPresenter >> basicBrowseClassReferences: className session: session [

	| service |
	service := RowanQueryService
		           command: #browseClassReferences:
		           withArgs: (Array with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: session
		onCompletion: nil.
	^ service
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicCopyClass: oldClassService to: newClassName [

	oldClassService
		command: #copyClassTo:;
		commandArgs: (Array with: newClassName).
	self issueCommand: oldClassService onCompletion: nil.
	self
		updateAfterFindClass: (RowanClassService new name: newClassName)
		onCompletion: nil
]

{ #category : 'tab labels' }
JadeiteBrowserPresenter >> basicDictionaryTabLabel [

	| label | 
	label := dictionaryListPresenter selectedItem
		         ifNil: [ 'Dictionary' ]
		         ifNotNil: [ :dictionaryService | dictionaryService name ].
	^ self selectedClass
		  ifNil: [ label ]
		  ifNotNil: [ self selectedClass name ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicOnDropClassList: dragDropSession [
	| classService failedCompilations newSelections |
	failedCompilations := OrderedCollection new.
	classService := dragDropSession suggestedTarget.
	classService meta: self isClassSideSelected.
	dragDropSession dragObjects do: 
			[:dragDropObject |
			
			[dragDropObject object source ifNil: [self updateService: dragDropObject object].
			classService
				saveMethod: dragDropObject object source
				category: dragDropObject object category
				session: gciSession]
					on: GsCompileError
					do: [:ex | failedCompilations add: dragDropObject object]].
	failedCompilations isEmpty
		ifTrue: 
			[self selectedClass == classService
				ifFalse: 
					[self isHierarchyTabSelected
						ifTrue: [self selectClassInClassHierarchyNamed: classService name]
						ifFalse: [self selectClassNamed: classService name]].
			newSelections := methodListPresenter list select: 
							[:methodService |
							(dragDropSession dragObjects collect: [:ea | ea object selector]) includes: methodService selector].
			methodListPresenter selections: newSelections].
	^failedCompilations
]

{ #category : 'tab labels' }
JadeiteBrowserPresenter >> basicProjectTabLabel [

	^ self isDictionaryTabSelected
		  ifTrue: [ self basicDictionaryTabLabel ]
		  ifFalse: [
			  projectListPresenter selections isEmpty ifTrue: [ 'Projects' ].
			  super basicProjectTabLabel ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicRemoveClass: theClassService [

	| service |
	self isHierarchyTabSelected ifTrue: [
		| path newPath |
		path := classHierarchyPresenter selection selectedPath.
		newPath := path copyFrom: 1 to: path size - 1.
		classHierarchyPresenter selection selectPath: newPath ].
	service := self selectedDictionaryOrPackage.
	service
		command: #removeClass:;
		commandArgs: (Array with: theClassService).
	self issueCommand: service onCompletion: nil.
	self selectedClass
		ifNil: [
			self resetClassTemplate "just emptied the last class in the package" ]
		ifNotNil: [
			classDefinitionPresenter value: self selectedClass template.
			self resetClassDefinitionPane ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicRemoveDictionaries: dictionaryNames [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #removeDictionariesNamed:;
		commandArgs: (Array with: dictionaryNames).
	self issueCommand: browserService onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicRemoveGlobal: qualifiedString [

	| symbol rs dictionaryService globalDictionaryName |
	rs := ReadStream on: qualifiedString.
	globalDictionaryName := rs upTo: $..
	dictionaryService := dictionaryListPresenter list detect: [ :service |
		                     service name = globalDictionaryName ].
	symbol := rs upToEnd asSymbol.
	dictionaryService
		command: #removeGlobalNamed:;
		commandArgs: (Array with: symbol).
	self issueCommand: dictionaryService onCompletion: nil.
	self removeGlobalsTab.
	self buildGlobalsTab
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicUnloadProjects: projectNames [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService onCompletion: nil.
	projectListPresenter unselectAll.
	packageListPresenter clear.
	classListPresenter clear.
	self clearMethodLists.
	self refreshGlobalSelections.
	dictionaryListPresenter clear
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicUpdateProject [

	self updateProjectPackages.
	self updateProjectInfo.
	self todo: 'projectInfoTab ensureVisible'.
	self sundryCleanup
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> buildGlobalsTab [
	| globalsTabView cardLabel |
	globalsTab
		ifNil: 
			[globalsTab := ListPresenter new.
			globalsTab
				when: #actionPerformed
				send: #inspectGlobal
				to: self.
			globalsTab parentPresenter: self textAreaTabs.
			globalsTabView := globalsTab createView: 'Editable list view'.
			globalsTabView backcolor: JadeiteTextStyles default colorForNoEdits.
			globalsTabView hasColumnHeaders: false.
			globalsTabView contextMenu: self globalsMenu.
			3 timesRepeat: [globalsTabView addColumn].
			1 to: 4
				do: 
					[:index |
					(globalsTabView allColumns at: index)
						isEditable: false;
						isAutoResize: true;
						getContentsBlock: [:each | each at: index]]]
		ifNotNil: [globalsTabView := globalsPresenter view].
	cardLabel := CardLabel text: 'Globals'.
	cardLabel iconBlock: [Icon fromId: (File composeStem: 'Dictionary' extension: 'ico')].
	globalsTabView
		arrangement: cardLabel;
		getImageBlock: nil;
		name: 'globalsTab'.
	classListPresenter list: ListModel new.
	self updateGlobalsTab
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> buildPackageList [
	true ifTrue:[^self]. "needed?"
	classListPresenter list: ListModel new.
	self todo: [ 
		| newCard |
		(packageDictionaryCards view cards includes:
			 dictionaryListPresenter view) ifTrue: [ 
			packageDictionaryCards view removeSubView: dictionaryListPresenter view.
			dictionaryListPresenter list: ListModel new ].
		packageDictionaryCards view cards isEmpty ifTrue: [ 
			newCard := packageDictionaryCards add: packageListPresenter. 
			self createListViewFor: newCard.
			packageDictionaryCards view cards first arrangement: 'Packages'.
			self setupPackageMenu.
			
			classHierarchyPresenter model: JadeiteTreeModel new ].
		packageListPresenter view isDropTarget: true ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> buildProjectInfoTab: infoTab [
	| infoTabView |
	infoTabView := infoTab createView: 'Editable list view'.
	infoTabView backcolor: JadeiteTextStyles default colorForNoEdits.
	infoTabView
		hasColumnHeaders: false;
		hasGridLines: false;
		isMultiSelect: true.
	(infoTabView allColumns at: 1)
		isEditable: false;
		width: 175;
		getContentsBlock: [:each | (each at: 1) prettyPrintInstVar: (each at: 2)].
	infoTabView addColumn.
	(infoTabView allColumns at: 2)
		isEditable: false;
		isAutoResize: true;
		getContentsBlock: 
				[:each |
				(each at: 2)
					ifNil: [String new]
					ifNotNil: 
						[:iv |
						| service |
						service := each at: 1.
						iv = 'isDirty' ifTrue: [service toolTip] ifFalse: [service instVarNamed: iv]]].
	infoTabView getImageBlock: nil.
	^infoTabView
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> buildProjectListView [
	| listView |
	projectInfoList := ListPresenter new.
	projectInfoList parentPresenter: projectInfoTab.
	listView := self buildProjectInfoTab: projectInfoList.
	listView arrangement: 2.
	projectInfoTab view addSubView: listView
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> buildProjectReadMeTab [
	| cardLabel |
	projectReadMeTab := TextPresenter new.
	(projectReadMeTab
		parentPresenter: self textAreaTabs presenter;
		createView: 'Scintilla view';
		view)
		wordWrap: true;
		backcolor: JadeiteTextStyles default colorForNoEdits.
	self selectedProjectName ifNotNil: [self updateProjectReadMe].
	cardLabel := CardLabel text: 'ReadMe'.
	cardLabel iconBlock: nil.
	projectReadMeTab view
		arrangement: cardLabel;
		name: 'projectReadMeTab'.
	projectReadMeTab view contextMenu: classDefinitionPresenter view contextMenu
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> buildProjectTab [
	| cardLabel |
	projectInfoTab := Presenter new.
	projectInfoTab parentPresenter: self textAreaTabs presenter.
	projectInfoTab createView: 'Container view'.
	projectInfoTab view layoutManager: ProportionalLayout new.
	self buildProjectListView.
	self buildAddPackageView.
	projectInfoList view contextMenu: self projectInfoMenu.
	cardLabel := CardLabel text: 'Project'.
	cardLabel iconBlock: nil.
	projectInfoTab view
		arrangement: cardLabel;
		name: 'projectInfoTab'
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> canDiscardEdits [

	self methodSourcePresenter hasUnacceptedEdits ifTrue: [
		(MessageBox confirm:
			 'You have unsaved changes. Discard changes and continue?')
			ifTrue: [
				self methodSourcePresenter hasUnacceptedEdits: false.
				^ true ].
		^ false ].
	^ true
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> categoriesMenuStrings [

	false ifTrue: [
		self addMethodCategory; renameMethodCategory; removeMethodCategories; fileOutCategories.
	].
	^#(
		'&Categories'
		'&Add//addMethodCategory'
		'&Rename//renameMethodCategory'
		'&Remove//removeMethodCategories'
		'-'
		'&Browse category methods//browseSelectedCategoryMethods'
		'-'
		'&File out categories ...//fileOutCategories'
	)

]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> checkout [
	projectListPresenter selection checkoutUsing: self
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> checkoutTag [
	| selection |
	selection := projectListPresenter selection.
	self checkoutTag: selection
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> classCommentChanged [
	inUpdate ifTrue: [^self].
	self selectedClass ifNil: [^self].
	classCommentPresenter value = self selectedClass comment
		ifTrue: 
			[classCommentPresenter view
				backcolor: JadeiteTextStyles default colorForNoEdits;
				isModified: false;
				yourself]
		ifFalse: 
			[classCommentPresenter view
				backcolor: JadeiteTextStyles default colorForUnsavedEdits;
				isModified: true;
				yourself]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> classContainer [
	^classContainer
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> classDisplayColor: classService [

	| color |
	(classService shouldColorAsExtension: self) ifTrue: [
		color := self extensionColor ].
	^ color
]

{ #category : 'events' }
JadeiteBrowserPresenter >> classSelected: classService [

	classService ifNotNil: [
		self clearMethodLists.
		self refreshClass: methodListPresenter selectedItem.
		self updateTabLabel ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> classesMenuStrings [
	| definedLabel containedDictionaryLabel menuStrings |
	false
		ifTrue: 
			[self
				browseClassReferences;
				fileOutClass;
				addSubclass;
				copyClass;
				renameClass;
				removeClass;
				removePriorVersions;
				showSUnitBrowserOnClass].
	definedLabel := self definedClassMenuItemLabel.
	containedDictionaryLabel := self containedDictionaryLabel.
	menuStrings := #('&Classes' '&Browse Class References//browseClassReferences' 'Browse SUnit//showSUnitBrowserOnClass' 'Add &Subclass//addSubclass' '&Rename ... //renameClass' 'Copy ...//copyClass' '&Remove//removeClass' '-')
				asOrderedCollection.
	menuStrings add: '&Expand Full Hierarchy//expandFullHierarchy'.
	menuStrings add: '-'.
	menuStrings addLast: 'Move To Package ...//moveClassToPackage'.
	menuStrings add: '-'.
	menuStrings addLast: definedLabel , '//gotoClassDefinedPackage'.
	menuStrings addLast: containedDictionaryLabel , '//gotoDictionary'.
	menuStrings addLast: '&File Out Class ...//fileOutClass'.

	^menuStrings
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> cleanupProjectInfoTab [
	self projectListPresenter selectionIfNone: 
			[projectInfoTab
				ifNotNil: 
					[self clearProjectTabs.
					]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> clearComponentList [
	"packageGroupPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)"
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> clearFilterLists [
	categoryListPresenter clear.
	variableListPresenter clear.
	packageMethodListPresenter clear.
]

{ #category : 'sunit support' }
JadeiteBrowserPresenter >> clearMethodListTestResultIn: methodServices [

	methodServices do: [ :methodService |
		| listedService |
		listedService := methodListPresenter list
			                 detect: [ :methodListService |
			                 methodListService = methodService ]
			                 ifNone: [  ].
		listedService ifNotNil: [ listedService testResult: nil ] ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> clearMethodLists [

	self selectedClass ifNil: [ self clearFilterLists ].
	methodListPresenter clear.
	methodSourcePresenter value: String new.
	definedMethodPackageText text: String new.
	self resetCategoryText
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> clearProjectTabs [
	"projectReadMeTab value: String new.
	projectInfoList list: ListModel new"
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> comparisonPresenter [

	^comparisonPresenter
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> componentPackageContainer [
	^componentPackageContainer
]

{ #category : 'tab labels' }
JadeiteBrowserPresenter >> computeNumberedLabelUsing: labelString [

	| numberedLabelString cardNumber |
	cardNumber := (self parentPresenter cards collect: [ :page |
		               page activePresenter ]) indexOf: self.
	cardNumber = 0 ifTrue: [
		cardNumber := self parentPresenter cards size ].
	numberedLabelString := cardNumber printString , ' ' , labelString.
	^ numberedLabelString
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> computedExtensionCategoryName [

	^ RowanClassService computedExtensionCategoryName
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectCancelActions [

	methodSourcePresenter whenResetDo: [ self resetMethodSource ].
	classCommentPresenter whenResetDo: [
		self resetClassComment.
		classCommentPresenter isModified: false ].
	classDefinitionPresenter whenResetDo: [
		self resetClassTemplate.
		classDefinitionPresenter isModified: false ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectClassPresenters [

	classListPresenter
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [
					self classSelected: self selectedClass ] ];
		whenNoneSelectedDo: [ self clearMethodLists ].
	classHierarchyPresenter
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [ :classService |
					self classSelected: classService ] ];
		whenActivatedDo: [ :selection |
			self expandAt: selection selectedItem ].
	classListHierarchyTabs whenSelectedPageChangedDo: [ :selection |
		self isHierarchyTabSelected
			ifTrue: [ self updateHierarchy ]
			ifFalse: [
				classHierarchyPresenter selectedItem ifNotNil: [ :sel |
					classListPresenter
						selectIndex: (classListPresenter items indexOf: sel)
						scrollToSelection: true ] ].
		self classSelected: self selectedClass ].
	classDefinitionPresenter whenSubmitDo: [ :text | self editSave ].
	classCommentPresenter whenSubmitDo: [ :text | self editSave ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectFilterPresenters [

	categoryListPresenter whenSelectionChangedDo: [ :selection |
		selection isEmpty ifFalse: [
			self refreshCategoryListWithSelection: selection ] ].
	variableListPresenter whenSelectionChangedDo: [ :selection |
		selection isEmpty ifFalse: [
			self refreshMethodsOn: methodListPresenter ] ].
	packageMethodListPresenter whenSelectionChangedDo: [ :selection |
		selection isEmpty ifFalse: [
			self refreshMethodsOn: methodListPresenter ] ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectMethodPresenters [

	methodListPresenter whenSelectionChangedDo: [ :selection |
		self methodSelectionChanged ].
	methodSourcePresenter whenSubmitDo: [ :text | self editSave ].
	instanceRadioButton whenChangedDo: [ :selection |
		self classSelected: self selectedClass ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectPackageDictionaryPresenters [

	packageListPresenter
		whenSelectionChangedDo: [ :selection | self updatePackage ];
		whenNoneSelectedDo: [ self clearMethodLists ].
	packageDictionaryTabs whenSelectedPageChangedDo: [ :selection |
		self classListPresenter clear.
		self classHierarchyPresenter roots: Array new.
		self isDictionaryTabSelected
			ifTrue: [ self updateDictionaries ]
			ifFalse: [
				self updateProjectSelecting: self projectListPresenter selectedItem.
				self updatePackage ].
		self updateClasses ].
	dictionaryListPresenter whenSelectionChangedDo: [ :selection |
		self updateDictionary ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectPresenters [

	self connectClassPresenters.
	self connectPackageDictionaryPresenters.
	projectListPresenter
		whenSelectionChangedDo: [ :selection |
			self updateProjectSelecting: selection selectedItem ];
		whenNoneSelectedDo: [ self clearMethodLists ].
	self connectFilterPresenters.
	methodFilterTabs whenSelectedPageChangedDo: [ :selection |
		self filterTabChanged: selection ].
	self connectMethodPresenters.
	self connectCancelActions.
	textAreaTabs whenSelectedPageChangedDo: [ :selection |
		self textTabChanged ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> contextObject [
	^self selectedClass ifNil: [^gciSession oopNil value] ifNotNil: [:classService | classService oop]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> copyInfo [
	self copyProjectInfo
	
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> copyProjectInfo [
	projectInfoList selectionIfNone: 
			[MessageBox notify: 'No selection to copy'.
			^self].
	projectInfoList selection last ifNil: [^self].
	(projectInfoList selection first perform: projectInfoList selection last asSymbol) displayString
		copyToClipboard
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> createListViewFor: newCard [
	"Editable because creating the desired ListView gave 
	mysterious errors when connecting the view."

	| listView |
	listView := newCard createView: 'Editable list view'.
	listView
		isMultiSelect: true;
		hasColumnHeaders: false;
		getImageBlock: nil;
		hasGridLines: false.
	(listView allColumns at: 1)
		isEditable: false;
		getImageBlock: nil;
		isAutoResize: true;
		customDrawBlock: [:each | each item displayStringFor: each].
	^listView
]

{ #category : 'private' }
JadeiteBrowserPresenter >> currentMethodSourceFrom: sourceString [

	| source fromStream writeStream |
	sourceString isEmpty ifTrue:[^sourceString]. 
	fromStream := ReadStream on: sourceString.
	writeStream := WriteStream on: String new.
	[
		fromStream atEnd not.
	] whileTrue: [
		| char |
		(char := fromStream next) == Character cr ifTrue: [
			fromStream peek ~~ Character lf ifTrue: [
				writeStream nextPut: Character lf.
			].
		] ifFalse: [
			writeStream nextPut: char.
		].
	].
	source := writeStream contents.
	[
		source last codePoint <= 32.
	] whileTrue: [
		source := source copyFrom: 1 to: source size - 1.
	].
	^source.

]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> debug [
	self jadeDebug
]

{ #category : 'sunit support' }
JadeiteBrowserPresenter >> debugMethodTests: methodServices [

	self clearMethodListTestResultIn: methodServices.
	self refreshClassAndMethodPresenters.
	[
	methodServices do: [ :methodService |
		methodService
			command: #debugTest:inClassName:;
			commandArgs:
				(Array with: methodService selector with: methodService className).
		self issueCommand: methodService onCompletion: nil ] ] ensure: [
		self refreshClassAndMethodPresenters ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> defaultLayout [ 

	^SpPanedLayout newVertical positionOfSlider: 0.5
]

{ #category : 'private' }
JadeiteBrowserPresenter >> defaultMethod [
	^JadePresenter defaultMethodTemplate
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> dictionaryMenu [
	^Menu fromStrings: self dictionaryMenuStrings
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> dictionaryMenuStrings [
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1 ifTrue: [(self
				addDictionary;
				removeDictionaries) fileOutDictionaries].
	^#('Dictionaries' 'Insert Dictionary//addDictionary' 'Remove Dictionaries//removeDictionaries' '-' 'File Out Selected Dictionaries ...//fileOutDictionaries')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> displayMultipleCategories [
	"display a generic indication of multiple categories unless all selected methods
	are in the same category"

	| categories |
	categories := (methodListPresenter selections collect: [:methodService | methodService category])
				asSet.
	categories size = 1
		ifTrue: [methodCategoryText text: 'Category: ' , categories anyOne]
		ifFalse: [methodCategoryText text: 'Categories: (Multiple)']
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> displayStringFor: methodService in: displayThing [
	methodService isExtension
		ifTrue: 
			[displayThing forecolor: Color darkMagenta.
			methodService inSelectedPackage ifFalse: [displayThing font beUnderlined]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> displayVariable: displayThing [
	self selectedClass
		ifNotNil: 
			[:selectedClass |
			(selectedClass instVarNames includes: displayThing item asSymbol)
				ifTrue: [displayThing font beBold]].
	^displayThing
]

{ #category : 'drag & drop' }
JadeiteBrowserPresenter >> dropMethods: methodServices onSelectedClass: classService [

	| failedCompilations selection |
	failedCompilations := OrderedCollection new.
	methodServices do: [ :methodService |
		[
		classService meta: methodService meta. 
		classService
			saveMethod: methodService source
			category: methodService category
			session: GciSession current ]
			on: GsCompileError
			do: [ :ex | failedCompilations add: methodService ] ].
	failedCompilations ifNotEmpty: [
		| ws |
		ws := WriteStream on: String new.
		ws nextPutAll: 'Methods failing compilation:'.
		failedCompilations do: [ :methodService |
			ws
				cr;
				nextPutAll: methodService selectorPrintString ].
		UIManager default alert: ws contents ].
	selection := methodServices
		             detect: [ :service |
		             (failedCompilations includes: service) not ]
		             ifNone: [ ^ self ].
	self selectClassNamed: classService name.
	self selectMethod: selection
]

{ #category : 'drag & drop' }
JadeiteBrowserPresenter >> dropMethods: methodServices onSelectedPackage: packageListIndex [

	| packageService className | 
	packageService := self packageListPresenter items at: packageListIndex.
	className := self selectedClass name. 
	self
		moveMethods: methodServices
		inClass: self selectedClass
		toPackageNamed: packageService name.
	self packageListPresenter selectIndex: packageListIndex.
	self selectClassNamed: className. 
	self methodListPresenter selectItem: methodServices first. 
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editDelete [

	View focus clearSelection.
	self methodValueChanged.

]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editRevert [
	self isOkayToChange
		ifTrue: 
			[methodSourcePresenter value: methodListPresenter selection source.
			self displayNoMods: methodSourcePresenter]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editSave [
	| currentCard |
	currentCard := textAreaTabs view currentCard.
	^currentCard presenterProvider value saveAction ifNotNil: [:action | action value]
	
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editSaveClass [
	"a two stage class compilation is used. First stage compiles
	the class and stores an anonymous method to be used in 
	stage  two. If a compile error occurs, it is handled nicely. 
	If a compile error happens during the method recompilation
	a debugger is raised as not much information is available 
	without a stack."

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #compileClass:;
		commandArgs: (Array with: classDefinitionPresenter text asString).
	self selectedClass ifNotNil: [ :classService |
		browserService selectedClass: classService name ].
	[
	[ self issueCommand: browserService onCompletion: nil ]
		on: Error
		do: [ :ex |
			(ex isKindOf: GsCompileError)
				ifTrue: [ self handleClassCompileError: ex ]
				ifFalse: [ self statusBarText: 'ERROR: ' , ex messageText ].
			^ self ].

	[
	browserService
		command: #recompileMethodsAfterClassCompilation;
		commandArgs: #(  ).
	self issueCommand: browserService onCompletion: nil ]
		on: GsApplicationError , GsCompileError
		do: [ :ex |
			('*poolDictionaries not supported yet*' match: ex description)
				ifTrue: [
				^ MessageBox notify: 'Pool Dictionaries not supported yet' ].
			^ self showMethodRecompilationError: ex ] ] ensure: [
		self resetClassDefinitionPane ].
	self
		updateAfterFindClass: browserService selectedClass
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editSaveClassComment [

	| classService |
	classService := self selectedClass ifNil: [ ^ self ].
	classService
		command: #classComment:;
		commandArgs:
			(Array with: classCommentPresenter text asString trimBoth).
	self issueCommand: classService onCompletion: nil.
	self refreshFromServer.
	classCommentPresenter view isModified: false.
	self todo: [
		classCommentPresenter backcolor:
			JadeiteTextStyles default colorForNoEdits ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editSaveMethod [
	| selection |
	selection := self selectedClass.
	selection ifNil: [^self].
	selection meta: self isClassSideSelected.
	self editSaveMethod: selection.
	self updateSUnitTab.
	self redrawAllViews.
	self updateSystemTab.
]

{ #category : 'actions' }
JadeiteBrowserPresenter >> editSaveMethod: classService [
	"save a method from the method source tab.
	Tests may not be smart enough to select the method source tab first (and set the underlying adapter & widget) so we select the tab here."
	| compileResult |
	self selectMethodSourceTab. 
	compileResult := self
				editSaveMethod: classService
				in: methodSourcePresenter
				category: self targetCategory.
	self statusBarText message ifNotNil:[:text | text isEmpty ifFalse:[^self]].  "don't reselect methods when status bar is full so as not to upset the compile information"
	classService selectedMethods
		ifNotNil: 
			[:methodServices |
			methodServices notEmpty
				ifTrue: 
					["there will be no method selected on a compiler error"
					self selectMethodsFrom: classService]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> editSaveReadMe [

	| service |
	service := RowanFileService new
		           command: #write:;
		           commandArgs: (Array with: projectReadMeTab value);
		           path: self projectReadmePath.
	self issueCommand: service onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> expandAt: classService [

	| path |
	classService subclassServices: Array new.
	classService
		command: #oneLevelClassHierarchy;
		commandArgs: Array new.
	self issueCommand: classService onCompletion: nil.
	classHierarchyPresenter childrenFor: classService.
	path := classHierarchyPresenter selection selectedPath.
	classHierarchyPresenter recalculateChildrenFor: path.
	classHierarchyPresenter
		collapsePath: path;
		expandPath: path.
	classHierarchyPresenter selectItem: classService
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> expandFullHierarchy [
	self selectClassHierarchyTab.
	self selectClassInClassHierarchyNamed: self selectedClass. 
	self expandAt: self selectedClass. 
	classHierarchyPresenter view ensureSelectionVisible
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> expandSelectionOneLevel: selection [

	| thePath |
	selection command: #oneLevelClassHierarchy.
	self issueCommand: selection onCompletion: nil.
	thePath := classHierarchyPresenter selection selectedPaths first.
	classHierarchyPresenter roots: classHierarchyPresenter roots. "This resets the underlying morph"
	classHierarchyPresenter expandPath: thePath.
	classHierarchyPresenter selectItem: selection.
	self scrollToClassHierarchySelection: thePath
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> extensionColor [

	^ Color purple lighter 
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> fileOutCategoriesOnPath: path [

	| service |
	service := self selectedClass.
	service
		command: #fileoutCategories:on:;
		commandArgs:
			(Array with: categoryListPresenter selections with: path).
	self issueCommand: service onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> fileOutClassOnPath: path [

	| service |
	service := self selectedClass.
	service
		command: #fileoutClassOn:;
		commandArgs: (Array with: path).
	self issueCommand: service onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> fileOutDictionariesOnPath: path [
	| service |
	service := RowanFileService new
				path: path;
				session: gciSession.
	service fileOutDictionaries: self selectedDictionaryNames
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> fileOutMethodsOnPath: path [
	| service |
	service := RowanFileService new
				path: path;
				session: gciSession.
	service fileOutMethods: methodListPresenter selections
]

{ #category : 'events' }
JadeiteBrowserPresenter >> filterTabChanged: tab [
	self isClassSelected
		ifTrue: [RowanServiceUpdater current updateService: self selectedClass session: gciSession]
		ifFalse: 
			[self clearFilterLists.
			^self].
	self populateFilterList.
	self isCategoryTabSelected
		ifTrue: 
			[^methodListPresenter selectionOrNil
				ifNil: [self selectMethodSourceTab]
				ifNotNil: 
					[:methodService |
					self selectCategoryFrom: methodService.
					self selectMethodSourceTab]].
	methodListPresenter selectionOrNil ifNotNil: [self selectMethodSourceTab]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> findProjectNamed: projectName [

	| projectService | 
	projectService := projectListPresenter list
		                  detect: [ :service |
		                  service name = projectName ]
		                  ifNone: [
			                  nil
			                  "may not be found if class is not in symbol list but class visible in a debugger (currently)" ].
	projectService ifNil: [ ^nil ].
	projectListPresenter selectedItem = projectService ifFalse: [
		projectListPresenter selection: projectService.
		projectListPresenter refresh ].
	
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> findRemovedServices [

	| browserService |
	browserService := RowanBrowserService new
		                  command: #findRemovedServices:;
		                  commandArgs:
			                  (Array with:
					                   RowanServiceUpdater current activeServices
						                   asArray).
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: nil
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> gciSession: aSession [
	"make sure my subpresenters have the session, too"
	gciSession := aSession.
	methodSourcePresenter _gciSession: aSession
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> globalsMenu [
	^Menu fromStrings: self globalsMenuStrings
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> globalsMenuStrings [
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				inspectGlobal;
				browseGlobalClass;
				browseGlobalReferences;
				removeGlobal].
	^#('Projects' 'Inspect//inspectGlobal' 'Browse Class//browseGlobalClass' 'Browse References//browseGlobalReferences' 'Remove Global//removeGlobal')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> globalsTab [
	^globalsTab
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> gotoClassDefinedPackage [
	" find will go to the class in it's defined package project"

	| selectedCategory selectedMethod |
	selectedCategory := categoryListPresenter selectionIfNone: [  ].
	selectedMethod := methodListPresenter selectionIfNone: [  ].
	self updateAfterFindClass: self selectedClass onCompletion: nil.
	selectedCategory ifNotNil: [ :category |
		categoryListPresenter selection: category ].
	selectedMethod ifNotNil: [
		methodListPresenter selection:
			(methodListPresenter list detect: [ :methodService |
				 methodService selector = selectedMethod selector ]). "It better be there"
		self updateMenuBar "to refresh method menu" ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> gotoDictionary [
	" find will go to the class in the dictionary it lives"

	| selectedClass | 
	selectedClass := self selectedClass.
	self selectNoneProject.
	^self updateAfterFindClassInDictionary: selectedClass
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> gotoDictionaryNamed: dictionaryName [
	| dictionaryService |
	dictionaryService := dictionaryListPresenter list detect: [:service | service name = dictionaryName]
				ifNone: [^self].
	dictionaryListPresenter selections: (Array with: dictionaryService)
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> gotoPackageDictionary [
	| selectedPackage dictionaryService |
	selectedPackage := packageListPresenter selectionIfNone: [^MessageBox notify: 'No Package Selected'].
	self selectNoneProject.
	dictionaryService := dictionaryListPresenter list
				detect: [:service | service name = selectedPackage dictionaryName]
				ifNone: [^self].
	dictionaryListPresenter selections: (Array with: dictionaryService)
]

{ #category : 'actions' }
JadeiteBrowserPresenter >> handleClassCompileError: ex [
	classDefinitionPresenter reportCompileError: ex gsArguments
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hasCategorySelected [

	^categoryListPresenter selections notEmpty
]

{ #category : 'history' }
JadeiteBrowserPresenter >> hasCommandHistoryBack [
	historyIndex ifNil: [ ^false ].
	^1 < historyIndex
]

{ #category : 'history' }
JadeiteBrowserPresenter >> hasCommandHistoryForward [

	historyList ifNil: [ ^ false ].
	historyIndex ifNil: [ ^ false ].
	^ historyIndex < historyList size
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hasMethods [
	^true
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hidePackageGroups [
	componentPackageContainer view arrangement: 1/5.
	packageDictionaryContainer view arrangement: 100. 
	projectListContainer view arrangement: 1/5. 
	classContainer view arrangement: 1/5. 
	packageGroupPresenter view creationParentView hide
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hidePackageList [
	componentPackageContainer view arrangement: 1 / 6.
	packageDictionaryContainer view hide
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hierarchyClassDoubleClicked [
	self expandFullHierarchy
]

{ #category : 'history' }
JadeiteBrowserPresenter >> historyBack [

	self jumpToHistoryIndex: ((historyIndex - 1) max: 1).
	
]

{ #category : 'history' }
JadeiteBrowserPresenter >> historyForward [

	self jumpToHistoryIndex: historyIndex + 1.
	
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeCategoryListPresenter [

	| listPresenter |
	listPresenter := JadeiteListPresenter new.
	^ listPresenter beMultipleSelection
		  dropEnabled: true;
		  displayColor: [ :jadeiteCategory |
			  jadeiteCategory isString
				  ifTrue: [ Color black ]
				  ifFalse: [
					  jadeiteCategory isComputed
						  ifTrue: [ self extensionColor ]
						  ifFalse: [ Color black ] ] ];
		  wantsDrop: [ :transfer |
			  transfer passenger allSatisfy: #isMethodService ];
		  acceptDrop: [ :transfer |
			  self
				  moveMethods: transfer passenger
				  toCategory:
					  (self categoryListPresenter items at: transfer index) ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeClassCommentTab [

	classCommentPresenter := JadeiteTextDocument new _gciSession:
		                         self gciSession.
	classCommentPresenter
		saveAction: [ self editSaveClassComment ];
		whenResetDo: [ self resetClassComment ].
	classCommentTab := JadeiteNotebookPage
		                   title: 'Class Comment'
		                   icon: nil
		                   provider: [ classCommentPresenter ].
	textAreaTabs addPage: classCommentTab
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeClassDefinitionTab [

	classDefinitionPresenter := JadeiteTextDocument new _gciSession:
		                            self gciSession.
	classDefinitionPresenter saveAction: [ self editSaveClass ].
	classDefinitionPage := JadeiteNotebookPage
		                       title: 'Class Definition'
		                       icon: nil
		                       provider: [ classDefinitionPresenter ].

	textAreaTabs addPage: classDefinitionPage
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeClassHierarchy [

	| classHierarchyPage |
	classHierarchyPresenter := JadeiteTreePresenter new
		                           display: [ :m | m displayString ];
		                           displayColor: [ :classService |
			                           self classDisplayColor: classService ];
		                           children: [ :service |
			                           service subclassServices ].
	classHierarchyPresenter
		isActiveOnDoubleClick;
		wantsDrop: [ :transfer |
			transfer passenger allSatisfy: #isMethodService ];
		acceptDrop: [ :transfer |
			self
				dropMethods: transfer passenger
				onSelectedClass: transfer target ].
	classHierarchyPage := JadeiteNotebookPage
		                      title: 'Hierarchy'
		                      icon: nil
		                      provider: [ classHierarchyPresenter ].
	classListHierarchyTabs addPage: classHierarchyPage
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeClassTabs: listPresenters [

	| classListPage |
	classListHierarchyTabs := self instantiate: JadeiteNotebookPresenter.
	classListPresenter := JadeiteListPresenter newNameSortedList
		                      wantsDrop: [ :transfer |
			                      transfer passenger allSatisfy:
					                      #isMethodService ];
		                      displayIcon: [ :classService |
			                      self testClassResultIconFor: classService ];
		                      acceptDrop: [ :transfer |
			                      self
				                      dropMethods: transfer passenger
				                      onSelectedClass:
					                      (self classListPresenter items at:
							                       transfer index) ].
	classListPresenter beSingleSelection.
	classListPresenter displayColor: [ :classService |
		self classDisplayColor: classService ].
	classListPage := JadeiteNotebookPage
		                 title: 'Class'
		                 icon: nil
		                 provider: [ classListPresenter ].
	classListHierarchyTabs addPage: classListPage.
	self initializeClassHierarchy.
	listPresenters add: classListHierarchyTabs.
	self initializeFullClassMenu
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeDefinedClassPackageText: classColumn [

	definedClassPackageText := SpTextPresenter new
		                           beNotEditable;
		                           beWrapWord;
		                           withoutScrollBars.
	definedClassPackageText addStyle: 'jadeiteTextBackgroundColor'.
	classColumn
		add: definedClassPackageText
		withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeDefinedMethodPackageText: methodColumn [

	definedMethodPackageText := SpTextPresenter new
		                           beNotEditable;
		                           beWrapWord;
		                           withoutScrollBars.
	definedMethodPackageText addStyle: 'jadeiteTextBackgroundColor'.
	methodColumn
		add: definedMethodPackageText
		withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeFilterTabs: methodPanedLayout [

	| categoryPage variablePage |
	methodFilterTabs := self instantiate: JadeiteNotebookPresenter.
	categoryListPresenter := self initializeCategoryListPresenter.
	self initializeCategoryListMenu.
	variableListPresenter := JadeiteListPresenter new.
	packageMethodListPresenter := JadeiteListPresenter new
		                              displayBold: [ :categoryString |
			                              self selectedClass definedPackageName
			                              = categoryString ];
		                              wantsDrop: [ :transfer |
			                              transfer passenger allSatisfy:
					                              #isMethodService ];
		                              acceptDrop: [ :transfer |
			                              self
				                              moveMethodsToPackageFilterUsing:
					                              transfer ].
	self initializeVariableListMenu.
	categoryPage := JadeiteNotebookPage
		                title: 'Category'
		                icon: nil
		                provider: [ categoryListPresenter ].
	variablePage := JadeiteNotebookPage
		                title: 'Variable'
		                icon: nil
		                provider: [ variableListPresenter ].
	packageMethodListPage := JadeiteNotebookPage
		                         title: 'Package'
		                         icon: nil
		                         provider: [ packageMethodListPresenter ].
	methodFilterTabs addPage: categoryPage.
	methodFilterTabs addPage: variablePage.
	methodFilterTabs addPage: packageMethodListPage.
	methodPanedLayout add: methodFilterTabs
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeLowerTabs [

	| box |
	box := SpBoxLayout newTopToBottom.
	textAreaTabs := self instantiate: JadeiteNotebookPresenter.
	self initializeClassDefinitionTab.
	self initializeClassCommentTab.
	self initializeMethodSourceTab.
	self initializeProjectTab.
	box add: textAreaTabs.
	statusBarText := self newStatusBar.
	box add: statusBarText height: 20.
	self layout add: box
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeMethodList: methodPanedPresenter [

	| methodsBox radioButtonBox |
	methodsBox := SpBoxLayout newVertical.
	self initializeMethodListHeader: methodsBox.
	methodListPresenter := JadeiteListPresenter new
		                       display: #selector;
		                       beMultipleSelection;
		                       displayColor: [ :methodService |
			                       methodService isExtension
				                       ifTrue: [ self extensionColor ]
				                       ifFalse: [ Color black ] ];
		                       displayUnderline: [ :methodService |
			                       methodService isExtension and: [
					                       methodService inSelectedPackage ] ];
		                       displayIcon: [ :methodService |
			                       self testMethodResultIconFor: methodService ];
		                       dragEnabled: true.
	methodsBox add: methodListPresenter.
	radioButtonBox := SpBoxLayout newHorizontal.
	instanceRadioButton := self newRadioButton label: 'Instance'.
	classRadioButton := self newRadioButton label: 'Class'.
	instanceRadioButton associatedRadioButtons: { classRadioButton }.
	radioButtonBox
		add: instanceRadioButton;
		add: classRadioButton.

	methodsBox add: radioButtonBox withConstraints: [ :constraints |
		constraints height: 50 * self currentWorld displayScaleFactor ].
	self initializeDefinedMethodPackageText: methodsBox.
	methodPanedPresenter add: methodsBox.
	self initializeFullMethodListMenu
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeMethodListHeader: methodColumn [

	| methodTopBox |
	methodTopBox := SpBoxLayout newHorizontal.
	methodCategoryText := SpTextPresenter new beNotEditable.
	methodCategoryText addStyle: 'jadeiteTextBackgroundColor'.
	methodTopBox
		add: methodCategoryText
		withConstraints: [ :c | c width: 300 ].
	backButton := self newButton
		              icon: (self iconNamed: #glamorousLeft);
		              help: 'Method Navigation Back';
		              action: [ self historyBack ].
	methodTopBox add: backButton.
	forwardButton := self newButton
		                 icon: (self iconNamed: #glamorousRight);
		                 help: 'Method Navigation Forward';
		                 action: [ self historyForward ].
	methodTopBox add: forwardButton.
	methodColumn add: methodTopBox withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeMethodSourceTab [

	methodSourcePresenter := JadeiteMethodSourcePane new _gciSession:
		                         self gciSession.
	methodSourcePresenter
		application: self application;
		saveAction: [ self editSaveMethod ];
		whenResetDo: [ self resetMethodSource ];
		whenTextChangedDo: [ self sourcePaneChanged ]. 
	methodSourcePage := JadeiteNotebookPage
		                    title: 'Method Source'
		                    icon: nil
 		                    provider: [ methodSourcePresenter ].
	textAreaTabs addPage: methodSourcePage
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializePackageDictionaryTabsIn: panedPresenter [

	| packageListPage dictionaryListPage |
	packageDictionaryTabs := self instantiate: JadeiteNotebookPresenter.
	packageListPresenter := JadeiteListPresenter newNameSortedList
		                        wantsDrop: [ :transfer |
			                        transfer passenger allSatisfy:
					                        #isMethodService ];
		                        acceptDrop: [ :transfer |
			                        self
				                        dropMethods: transfer passenger
				                        onSelectedPackage: transfer index ].
	packageListPage := JadeiteNotebookPage
		                   title: 'Package'
		                   icon: nil
		                   provider: [ packageListPresenter ].
	packageDictionaryTabs addPage: packageListPage.
	self initializePackageMenu.
	dictionaryListPresenter := JadeiteListPresenter newNameSortedList.
	dictionaryListPage := JadeiteNotebookPage
		                      title: 'Dictionary'
		                      icon: nil
		                      provider: [ dictionaryListPresenter ].
	packageDictionaryTabs addPage: dictionaryListPage.
	panedPresenter add: packageDictionaryTabs
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializePresenters [
	"in order to get scroll bars to (kind of) work, create a paned layout with 
	project & package list. Then create a nother paned layout with the first
	paned layout + the class list, etc.  Then add the final paned layout to the 
	upper box layout. ... Seems unnecessarily complicated. Would be better if 
	I could just add a resizer between two arbitrary widgets."

	| listPresenters classColumn panedLayout1 filterLayout panedLayout2 panedLayout3 panedLayout4 methodLayout |
	super initializePresenters.
	listPresenters := SpBoxLayout newLeftToRight.
	listPresenters spacing: 10.
	self layout add: listPresenters.
	panedLayout1 := SpPanedLayout newHorizontal.
	self initializeProjectListPresenterIn: panedLayout1.
	self initializePackageDictionaryTabsIn: panedLayout1.
	panedLayout2 := SpPanedLayout newHorizontal positionOfSlider: 0.66.
	panedLayout2 add: panedLayout1.
	classColumn := SpBoxLayout newVertical.
	panedLayout2 add: classColumn.
	self initializeClassTabs: classColumn.
	self initializeDefinedClassPackageText: classColumn.
	panedLayout3 := SpPanedLayout newHorizontal positionOfSlider: 0.75.
	panedLayout3 add: panedLayout2.
	filterLayout := SpBoxLayout newHorizontal.
	self initializeFilterTabs: filterLayout.
	panedLayout3 add: filterLayout.
	panedLayout4 := SpPanedLayout newHorizontal positionOfSlider: 0.75.
	panedLayout4 add: panedLayout3.
	methodLayout := SpBoxLayout newHorizontal.
	self initializeMethodList: methodLayout.
	panedLayout4 add: methodLayout.
	listPresenters add: panedLayout4.
	self initializeLowerTabs.
	packageGroupPresenter := JadeiteListPresenter new.
	self whenBuiltDo: [ self addStyle: 'jadeiteTextBackgroundColor' ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeProjectListPresenterIn: tabs [

	projectListPresenter := JadeiteListPresenter new
		                        display: [ :projectService | 
			                        projectService displayName ];
		                        displayBold: [ :projectService | 
			                        projectService isDirty ];
		                        displayColor: [ :projectService | 
			                        projectService isSkew
				                        ifTrue: [ Color red ]
				                        ifFalse: [ self theme textColor ] ].
	projectListPresenter owner: self. 
	tabs add: projectListPresenter.
	self initializeProjectListMenu
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeProjectTab [

	| column1 |
	column1 := SpStringTableColumn evaluated: [ :array |
		           self projectInfoLabelDisplay: array ].
	column1
		displayBold: [ true ];
		beNotExpandable.
	projectInfoList := JadeiteTablePresenter new
		                   addColumn: column1;
		                   addColumn:
			                   (SpStringTableColumn evaluated: [ :array |
					                    self projectInfoValueDisplay: array ]).
	projectInfoTab := JadeiteNotebookPage
		                  title: 'Project'
		                  icon: nil
		                  provider: [ projectInfoList ].
	textAreaTabs addPage: projectInfoTab
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> insertCompileErrorText: string into: presenter [
	"parameters ignored in this presenter"

	statusBarText value: string
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> insertIfFalse [
	^self insertIfFalse: methodSourcePresenter
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> insertIfTrue [
	^self insertIfTrue: methodSourcePresenter
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> inspectGlobal [
	| selection |
	selection := globalsTab selectionIfNone: [^self].
	^JadeInspector showOn: (OopType32 fromInteger: (selection at: 3)) session: gciSession
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> inspectMethod [
	| inspector |
	methodListPresenter selections isEmpty ifTrue: [^self].
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector inspect: (OopType64 fromInteger: methodListPresenter selections first oop)
		inContext: gciSession oopNil value
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> inspectorContextObject [

	^self contextObject
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isApplyingUpdates [

	^RowanServiceUpdater current isApplyingUpdates
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isCategorySelected [
	^self categoryListPresenter selectedItem isNotNil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> isCategoryTabSelected [
	methodFilterTabs ifNil:[^true]. 
	methodFilterTabs selectedPage ifNil:[^true]. 
	^methodFilterTabs selectedPage title = 'Category'
	
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isClassDefinitionTabSelected [
	^textAreaTabs currentCard name = 'classDefinition'
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isClassHierarchyTabSelected [
	^classListHierarchyTabs currentCard name = 'Hierarchy'
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isClassSelected [
	^self selectedClass notNil
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isClassSideSelected [
	^instanceRadioButton state not

]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isComparisonTabSelected [
	self todo:[^textAreaTabs currentCard name = 'comparisonTab'].
	^false
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isDictionaryTabSelected [

	^packageDictionaryTabs selectedPage title = 'Dictionary'

]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isHierarchyTabSelected [
	classListHierarchyTabs ifNil: [ ^false ].
	classListHierarchyTabs currentCard ifNil: [ ^false ].
 	^classListHierarchyTabs currentCard name = 'Hierarchy'
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isLoadSpecTabSelected [
	^textAreaTabs currentCard name = 'loadSpecTab'.

]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isMethodSourceTabSelected [
	^textAreaTabs currentCard name = 'methodSource'
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> isMethodVisible: methodSelection [

	^ (methodListPresenter list
		   detect: [ :svc | svc selector = methodSelection selector ]
		   ifNone: [  ]) notNil
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isNoneProjectSelected [
	"temporary refactoring for old way of doing dictionaries"
	^self isDictionaryTabSelected
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isOkayToChange [
	methodSourcePresenter view isModified
		ifTrue: [(self isOkayToChangeSource: methodSourcePresenter) ifFalse: [^false]].
	classDefinitionPresenter view isModified
		ifTrue: 
			[classDefinitionPresenter ensureVisible.
			(JadePresenter unsavedChangesDialogIn: self)
				ifTrue: 
					[gciSession isValidSession
						ifTrue: 
							[classDefinitionPresenter view isModified: false.
							^true]
						ifFalse: 
							[classDefinitionPresenter
								selectAll;
								copySelection]]
				ifFalse: [^false].
			classDefinitionPresenter view isModified: false].
	classCommentPresenter view isModified
		ifTrue: 
			[classCommentPresenter ensureVisible.
			gciSession isValidSession
				ifTrue: 
					[(JadePresenter unsavedChangesDialogIn: self
						text: 'Stay on window with unsaved changes? Class comment has unsaved changes.') ifTrue: [^false]]
				ifFalse: 
					[(JadePresenter unsavedChangesDialogIn: self
						text: 'Copy changes to Clipboard? Class comment has unsaved changes')
							ifTrue: 
								[classCommentPresenter
									selectAll;
									copySelection]].
			classCommentPresenter view isModified: false].
	self postOkToChangeEvent.
	^true
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> isPackageTabSelected [	
	
	methodFilterTabs ifNil:[^true]. 
	^methodFilterTabs selectedPage title = 'Package'

]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isProjectInfoTabSelected [

	^textAreaTabs currentCard name = 'projectInfoTab'.

]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isProjectItemEnabled: command [
	(command = #refreshFromServer or: [command = #loadProject]) ifTrue: [^true].
	self selectedProjectName = RowanProjectService noneProject name ifTrue: [^false].
	(#(#unloadProjects #reloadProject) includes: command)
		ifTrue: 
			[^self selectedProjectName isNil
				ifTrue: [false]
				ifFalse: [('UnPackaged' = self selectedProjectName) not]].
	^projectListPresenter selections isEmpty not
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isRowanProjectSelected [
	^projectListPresenter selections notEmpty
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isSourceTabSelected [

	^textAreaTabs currentCard name = 'methodSource'.

]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isSunitTabSelected [
	^self textAreaTabs currentCard name = 'sunit'
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isValidClassService: classService [
	"some browsers don't consider every class service valid for display"
	^true
]

{ #category : 'services' }
JadeiteBrowserPresenter >> issueCommand: service onCompletion: aBlock [

	^RowanServiceUpdater current issueCommand: service session: gciSession onCompletion: aBlock
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> jadeDebug [
	RowanServiceUpdater current inUpdateWhile: [self jadeExecuteAndDisplay: false shouldDebug: true]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> jadeInspect [
	| inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector evaluateSelectedTextIn: methodSourcePresenter
		thenInspectInContext: self inspectorContextObject
]

{ #category : 'history' }
JadeiteBrowserPresenter >> jumpToHistoryIndex: anInteger [

	| historyEntry |
	historyEntry := historyList at: anInteger ifAbsent: [ ^ self ].
	historyIndex := anInteger.
	historyEntry className = self selectedClassName ifFalse: [
		self selectProjectNamed: historyEntry projectName.
		self selectPackageNamed: historyEntry packageName.
		self selectClassNamed: historyEntry className ].
	historyEntry meta
		ifTrue: [ classRadioButton state: true ]
		ifFalse: [ instanceRadioButton state: true ].
	(self isMethodVisible: historyEntry) ifFalse: [
		self selectCategoryNamed: historyEntry category ].
	self selectMethod: historyEntry
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> makeSameSelectionsIn: newPresenter as: previousPresenter [

	| projectService packageService dictionaryService classService isMeta methodService |
	projectService := previousPresenter projectListPresenter
		                  selectionIfNone: [  ].
	packageService := previousPresenter packageListPresenter
		                  selectionIfNone: [  ].
	dictionaryService := previousPresenter dictionaryPresenter
		                     selectionIfNone: [  ].
	classService := previousPresenter selectedClass.
	classService ifNotNil: [
		isMeta := classService meta.
		methodService := previousPresenter methodListPresenter
			                 selectionIfNone: [  ] ].
	projectService ifNil: [ ^ self ].
	newPresenter gotoProjectNamed: projectService name.
	packageService
		ifNil: [
			dictionaryService
				ifNil: [ ^ self ]
				ifNotNil: [
				newPresenter gotoDictionaryNamed: dictionaryService name ] ]
		ifNotNil: [ newPresenter gotoPackageNamed: packageService name ].
	classService ifNil: [ ^ self ].
	newPresenter updateAfterFindClass: classService onCompletion: nil.
	previousPresenter isHierarchyTabSelected ifTrue: [
		newPresenter classHierarchyTabs lastCard ].
	isMeta ifTrue: [ newPresenter setClassSide ].
	methodService ifNil: [ ^ self ].
	newPresenter findMethod: methodService selector
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> maxAutoCompleteListSize [
	^50
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> methodListCommands [

	^#(#JadeiteRemoveMethodCommand #JadeiteBrowseImplementorsCommand)
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> methodMenu: aMenu [
	self methodMenuBreak: aMenu
]

{ #category : 'events' }
JadeiteBrowserPresenter >> methodSelectionChanged [

	self resetStatusBar.
	self updateMethodSource.
	self methodSourcePresenter methodService:
		self methodListPresenter selectedItem.
	methodListPresenter selections isEmpty
		ifTrue: [ self selectClassDefinitionTab ]
		ifFalse: [
			methodListPresenter selections size = 1 ifTrue: [
				self selectMethodSourceTab ].
			methodListPresenter selections size > 1 ifTrue: [
				self displayMultipleCategories ].
			methodListPresenter selectedItem ifNil: [
				definedMethodPackageText text: String new.
				self resetCategoryText ].
			self updateHistory ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> methodToReformat [
	^methodListPresenter selectionIfNone: [RowanMethodService new]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> methodValueChanged [
	inUpdate ifTrue: [^self].
	self methodSourceEqual
		ifTrue: 
			[methodSourcePresenter view
				backcolor: JadeiteTextStyles default colorForNoEdits;
				isModified: false;
				yourself.
			self updateMethodStepPoints.
			self statusBarText: '']
		ifFalse: 
			[methodSourcePresenter view
				backcolor: JadeiteTextStyles default colorForUnsavedEdits;
				clearContainerIndicators;
				yourself].
	self updateSystemTab.
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> methodsMenuStrings [
	false
		ifTrue: 
			["This helps us find senders"
			self
				browseBreakpointList;
				browseImplementors;
				browseImplementorsOf;
				browseSenders;
				browseSendersOf;
				browseHierarchyImplementors;
				browseHierarchySenders;
				browseMethodsContaining;
				browseLiteralReferences;
				browseSelectedMethods;
				browseMethodHistory;
				inspectMethod;
				clearMethodBreakpoints;
				removeMethods;
				runMethodTests;
				fileOutSelectedMethods;
				findMethod;
				moveMethodToPackage;
				removeMethods;
				runMethodTests;
				gotoMethodDefinedPackage;
				runAll;
				runSelected].
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' 'Inspect//inspectMethod' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) .../Ctrl+Shift+X/removeMethods' 
	'-'
	'Move To Package ...//moveMethodToPackage'
	'File Out Selected Methods ...//fileOutSelectedMethods'
	'-'
	'Run All Tests/Ctrl+Shift+A/runAll' 'Run Selected Test(s)/Ctrl+Shift+S/runMethodTests' 'Debug Selected &Test(s)/Ctrl+Shift+B/runMethodTests' '-' 'Go To Defining Package//gotoMethodDefinedPackage')
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> methodsUpdate: classService [

	classService meta = self isClassSideSelected ifFalse: [ ^ self ].
	classListPresenter list isEmpty ifTrue: [
		classService initializePresenterList: methodListPresenter ].
	classService displayMethodsOn: methodListPresenter browser: self.
	methodListPresenter selections isEmpty ifTrue: [
		self setDefaultMethod.
		definedMethodPackageText text: String new.
		self resetCategoryText. ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> moveMethods: methodServices toCategory: targetCategory [

	| classService |
	classService := self selectedClass.
	self selectCategoriesNamed:
		(categoryListPresenter selections copyWith: targetCategory).
	classService
		command: #moveMethods:to:;
		commandArgs: (Array with: methodServices with: targetCategory categoryName).
	self issueCommand: classService onCompletion: nil.
	self selectMethodsFrom: classService
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> moveMethodsToPackageFilterUsing: transfer [

	| packageName |
	packageName := self packageMethodListPresenter items at:
		               transfer index.
	self
		moveMethods: transfer passenger
		inClass: self selectedClass
		toPackageNamed: packageName.
	self packageMethodListPresenter selectIndex: transfer index.
	^ self methodListPresenter selectItem: transfer passenger first
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> newProjectNamed: projectName [
	RowanBrowserService new
		newProjectNamed: projectName
		session: self gciSession
		windowHandle: self view handle value
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> noClassSelectedInEitherPresenter [
	classListPresenter selectionIfNone: [classHierarchyPresenter selectionIfNone: [^true]].
	^false
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDragClass: aSession [
	^self onDragClass: aSession className: self selectedClass
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDragMethod: aSession [
	| list |
	list := methodListPresenter selections collect: 
					[:each |
					(aSession newDragObject: each)
						format: #method data: each;
						yourself].
	aSession
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy;
		yourself
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDragOverPackageList: aSession [
	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #package) ifTrue: [^self].
	(aSession isFormatAvailable: #class) ifTrue: [^self onDragClassOrMethodOverPackageList: aSession].
	(aSession isFormatAvailable: #method) ifTrue: [^self onDragClassOrMethodOverPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropClassesOnPackage: packageService session: aSession [
	| classes |
	classes := aSession dragObjects collect: [:each | each format: #class].
	classes isEmpty ifFalse: [^self moveClassToPackageNamed: packageService name].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropClassesOnPackageList: aSession [ 

	self
		onDropClassesOnPackage: aSession suggestedTarget 
		session: aSession.
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropMethodsOnClassHierarchy: aSession [
	^self onDropOnClassList: aSession
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropMethodsOnPackageList: aSession [
	self onDropMethodsOnPackageList: aSession suggestedTarget session: aSession
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropMethodsOnPackageList: packageServiceOrName session: aSession [
	| methods |
	methods := aSession dragObjects collect: [:each | each format: #method].
	methods isEmpty
		ifFalse: 
			[^self moveMethodsToPackageNamed: ((packageServiceOrName class canUnderstand: #name)
						ifTrue: [packageServiceOrName name]
						ifFalse: [packageServiceOrName])].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropOnClassList: dragDropSession [
	| failedCompilations |
	failedCompilations := self basicOnDropClassList: dragDropSession.
	failedCompilations isEmpty
		ifFalse: 
			[MessageBox notify: 'Methods failing compilation: '
						, (failedCompilations collect: [:methodService | methodService selector]) asArray printString]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropOnMethodCategory: aSession [
	| methodServices targetCategory |
	methodServices := aSession dragObjects collect: [:each | each format: #method].
	targetCategory := aSession suggestedTarget trimBlanks.
	self moveMethods: methodServices toCategory: targetCategory
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onDropOnPackageList: aSession [
	(aSession isFormatAvailable: #class) ifTrue: [^self onDropClassesOnPackageList: aSession].
	(aSession isFormatAvailable: #method) ifTrue: [^self onDropMethodsOnPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onViewClosed [
	super onViewClosed.
	RowanServiceUpdater current removeEventsTriggeredFor: packageGroupPresenter
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onViewOpened [
	super onViewOpened.
	RowanServiceUpdater current logComment: 'Opening Projects Browser {' , self identityHash printString , '}'.
	self registerPresentersForUpdates.
	projectListPresenter view contextMenu: self class projectMenu.
	self setupPackageMenu.
	self updateMenuBar.
	self updateProjects.
	definedClassPackageText view isMultiline: false.
	definedClassPackageText view alignment: #left.
	definedMethodPackageText view isMultiline: false.
	definedMethodPackageText view alignment: #left.
	self buildPackageList.
	self
		buildProjectTab;
		buildProjectReadMeTab.
	self selectProjectTab.
	JadePresenter packageListVisible ifTrue: [self showPackageList] ifFalse: [self hidePackageList].
	JadePresenter packageGroupsVisible
		ifTrue: [self showPackageGroups]
		ifFalse: [self hidePackageGroups].
]

{ #category : 'actions' }
JadeiteBrowserPresenter >> openBrowser [

	^self parentPresenter openBrowser
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> openSourceStyler [
	| textStyles |
	textStyles := methodSourcePresenter view editStyles textStyles.
	JadeiteTextStyles default textStyles: textStyles.
	classDefinitionPresenter view textStyles: textStyles.
	originalSourcePresenter view textStyles: textStyles.
	classCommentPresenter view textStyles: textStyles.
	comparisonPresenter afterPresenter view textStyles: textStyles.
	comparisonPresenter beforePresenter view textStyles: textStyles
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> packageDictionaryCards [
	"for testing"

	^packageDictionaryCards
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> packageGroupPresenter [
	^packageGroupPresenter
]

{ #category : 'accessing' }
JadeiteBrowserPresenter >> packageMethodListPresenter [

	^ packageMethodListPresenter
]

{ #category : 'dolphin' }
JadeiteBrowserPresenter >> parentPresenter [

	"yuck"

	(self owner isKindOf: JadeiteBrowser) ifTrue: [ ^ self owner ].
	^ self owner owner
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> pkgsMenuStrings [
	0 == 1
		ifTrue: 
			[self
				savePackage;
				removePackages].
	^#('&Packages' 
	'&Write Package...//savePackage'
	'&Remove Package(s)...//removePackages'
	'&Edit Package Groups...//editPackageGroups'
	'Go to Associated Dictionary//gotoPackageDictionary')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> populateFilterList [

	| listModel |
	self selectedClass ifNil: [ ^ self ]. "can legitimately be nil during test run setUp"
	listModel := ListModel new searchPolicy: SearchPolicy equality.
	self isCategoryTabSelected
		ifTrue: [
			listModel addAll:
				(self selectedClass jadeiteCategories).
			categoryListPresenter list: listModel asOrderedCollection.
			self addComputedCategories ]
		ifFalse: [
			listModel addAll: self selectedClass variables.
			variableListPresenter list:
				listModel asSortedCollection asOrderedCollection ]
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> preUpdate: services [

	services do: [ :service | 
		service preUpdate: self  ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> previousTabViewArrangement [
	^previousTabViewArrangement
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> previousTabViewArrangement: anObject [
	previousTabViewArrangement := anObject
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> previousTopViewArrangement [
	^previousTopViewArrangement
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> previousTopViewArrangement: anObject [
	previousTopViewArrangement := anObject
]

{ #category : 'displaying' }
JadeiteBrowserPresenter >> projectInfoLabelDisplay: array [

	array last = 'isSkew' ifTrue: [ ^ 'Skew' ].
	array last = 'isDirty' ifTrue: [ ^ 'Dirty State' ].
	^ array last normalizeCamelCase capitalized
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectInfoList [
	^projectInfoList
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectInfoMenu [
	^Menu fromStrings: self projectInfoMenuStrings
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectInfoMenuStrings [
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				copyInfo
				].
	^#('Dictionaries' 
	'Copy//copyInfo'
	'Browse Commit In GitHub//openCommitInGitHub')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectInfoTab [
	^projectInfoTab
]

{ #category : 'displaying' }
JadeiteBrowserPresenter >> projectInfoValueDisplay: array [

	^ array last isEmpty ifFalse: [
		  array last = 'isDirty'
			  ifTrue: [ array first perform: #toolTip ]
			  ifFalse: [ array first perform: array last asSymbol ] ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectMenuCommands [
	^self class projectMenu items collect: [:item | item command]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectReadMeTab [
	^projectReadMeTab
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectReadmePath [
	^JadePresenter rowanProjectsHomeEnvVarString , '/' , self selectedProjectName , '/README.md'
]

{ #category : 'tab labels' }
JadeiteBrowserPresenter >> projectTabLabel [
	"Selections get mixed up switching between system presenters unless the tabs
	have a unique label. Rather silly, but we'll give the tab a unique number"

	| labelString numberedLabelString label |
	labelString := self basicProjectTabLabel.
	numberedLabelString := self computeNumberedLabelUsing: labelString.
	label := CardLabel text: numberedLabelString iconBlock: nil.
	methodSourcePresenter view isModified ifTrue: [
		label := CardLabel
			         text: numberedLabelString
			         iconBlock: [ Icon fromId: 'Changed.ico' ] ].
	^ label
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> protectedDictionaries [
	^#('Published' 'Globals' 'UserGlobals')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> redrawAllViews [
	"for now, just update a few views. Not sure if there's a better way to do this."
	projectListPresenter view invalidate.
	packageListPresenter view invalidate.
	classListPresenter view invalidate.
	categoryListPresenter view invalidate. 
	methodListPresenter view invalidate. 
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refresh [
	self refreshFromServer
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> refreshCategoryListWithSelection: selection [

	| methodSelections |
	categoryListPresenter selectedItem isComputed ifTrue: [
		| extensions |
		extensions := self selectedClass methods select: [ :methodService |
			              methodService isExtension ].
		methodListPresenter list: extensions.
		^ self ].
	methodSelections := methodListPresenter selections.
	self refreshMethodsOn: methodListPresenter.

	methodListPresenter selections:
		(methodSelections select: [ :methodService |
			 methodListPresenter list includes: methodService ]).
	self selectMethodSourceTab.
	selection selectedItem ifNotNil: [ :sel |
		methodCategoryText text: 'Category: ' , sel categoryName ]
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> refreshClass: selectedMethod [

	| selection presenter |
	RowanServiceUpdater current isApplyingUpdates ifTrue: [ ^ self ].
	self noClassSelectedInEitherPresenter ifTrue: [
		self resetClassTemplate.
		self resetDefinedClassPackage.
		^ self ].
	selectedMethod ifNil: [ textAreaTabs selectPage: classDefinitionPage ].
	presenter := self isClassListTabSelected
		             ifTrue: [ classListPresenter ]
		             ifFalse: [ classHierarchyPresenter ].
	selection := self selectedClass.
	selection wasRemoved ifTrue: [ ^ self ].
	selection meta: self isClassSideSelected.
	selection
		selectedPackageServices: packageListPresenter selections
		browser: self.
	selection
		updateAfterCommand: false;
		command: #fastRefresh.
	self issueCommand: selection onCompletion: nil.
	selection updateAfterCommand: true.
	self updateClassInfo.
	self selectMethodWithSameSelectorAs: selectedMethod.
	self updateTabLabel
]

{ #category : 'sunit support' }
JadeiteBrowserPresenter >> refreshClassAndMethodPresenters [

	classListPresenter refresh.
	classHierarchyPresenter refresh.
	^ methodListPresenter refresh
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refreshFromServer [

	| services |
	services := OrderedCollection new.
	services addAll: projectListPresenter selections.
	services addAll: packageListPresenter selections.
	classListPresenter selectedItem ifNotNil: [ :classService |
		services add: classService ].
	classHierarchyPresenter selectedItem ifNotNil: [ :classService |
		services add: classService ].
	services addAll: methodListPresenter selections.
	self updateServices: services.
	self updateSUnitTab.
	RowanBrowserService new checkForAddedProjects:
		projectListPresenter items asArray.
	self redrawAllViews
]

{ #category : 'actions' }
JadeiteBrowserPresenter >> refreshGlobalSelections [
	"refresh selections in all browsers."

	| browserService |
	browserService := RowanBrowserService new
		                  command: #findRemovedServices:;
		                  commandArgs:
			                  (Array with:
					                   RowanServiceUpdater current activeServices
						                   asSet asArray).
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: nil.
	self updateServices: RowanServiceUpdater current selectedServices
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refreshMethodsOn: presenter [

	| classService |
	classService := self selectedClass ifNil: [ ^ self ].
	classService meta: self isClassSideSelected.
	classService filters: self selectedFilters.
	self selectedFilterTab selectedItems isEmpty ifTrue: [
		self clearMethodLists ].
	self updateService: classService.
	methodListPresenter selections isEmpty
		ifTrue: [
			self resetCategoryText.
			definedMethodPackageText text: String new ]
		ifFalse: [ self updateMethodSource ].
	methodListPresenter withWidgetDo: [ :w | w resetPosition ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refreshProjectInfoTab [
	| service |
	service := self projectListPresenter selectionIfNone: [^self cleanupProjectInfoTab].
	service wasUpdated: true. 
	self todo:[self updateProjectInfoTabFor: service]
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerClassHierarchyForUpdates [

	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #classHierarchyUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #updatedClass:browser:
		browser: self.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #updatedClassInHierarchy:browser:
		browser: self.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #removedClass:.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #removed:.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #updatedOneLevelInClassHierarchy:browser:
		browser: self
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerClassListForUpdates [

	RowanServiceUpdater current
		register: classListPresenter
		selector: #classesUpdate:browser:
		browser: self.
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerFilterListsForUpdates [

	RowanServiceUpdater current
		register: categoryListPresenter
		selector: #filterCategoryUpdate:browser:
		browser: self;
		register: variableListPresenter
		selector: #filterVariableUpdate:browser:
		browser: self;
		register: packageMethodListPresenter
		selector: #filterPackageUpdate:browser:
		browser: self
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerMethodPresentersForUpdates [

	RowanServiceUpdater current
		register: methodListPresenter
		selector: #classMethodsUpdate:browser:
		browser: self;
		register: methodListPresenter
		selector: #methodUpdate:browser:
		browser: self;
		register: methodListPresenter selector: #removed:;
		register: methodSourcePresenter
		selector: #methodSourceUpdate:browser:
		browser: self
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerPackageDictionaryListsForUpdates [

	RowanServiceUpdater current
		register: packageListPresenter
		selector: #projectPackagesUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: dictionaryListPresenter
		selector: #dictionaryListUpdate:
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerPresentersForUpdates [
	super registerPresentersForUpdates. 
	self registerProjectListForUpdates.
	self registerPackageDictionaryListsForUpdates.
	self registerClassListForUpdates.
	self registerClassHierarchyForUpdates.
	self registerFilterListsForUpdates.
	self registerMethodPresentersForUpdates
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerProjectListForUpdates [
	RowanServiceUpdater current
		register: projectListPresenter
		selector: #projectsUpdate:browser:
		browser: self;
		register: projectListPresenter selector: #removedProject:;
		register: projectListPresenter selector: #newProject:;
		register: projectListPresenter selector: #removed:;
		register: projectListPresenter selector: #projectsUpdate:
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeAppropriateTab [
	self isNoneProjectSelected ifTrue: [self removeProjectTabs] ifFalse: [self removeGlobalsTab]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeClass [

	| classService answeringService classReferenceBrowser queryService |
	classService := self selectedClass ifNil: [ ^ self ].
	answeringService := RowanAnsweringService new.
	answeringService
		command: #classHasSubclasses:;
		commandArgs: (Array with: classService oop).
	self issueCommand: answeringService onCompletion: nil.
	answeringService answer ifTrue: [
		^ MessageBox notify: 'Cannot remove class with subclasses' ].
	(self selectedDictionaryOrPackage confirmClassRemoval: classService)
		ifFalse: [ ^ self ].
	queryService := self
		                basicBrowseClassReferences: classService name
		                session: self gciSession.
	queryService hasResults ifTrue: [
		classReferenceBrowser := self browseClassReferences:
			                         classService name ].
	self basicRemoveClass: classService.
	queryService hasResults ifTrue: [
		MessageBox notify: classService name
			,
			' was removed. You will need to remove references to the class or your code may not load in the future.' ].
	^ classReferenceBrowser
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeDictionaries [
	| dictionaryNames |
	dictionaryListPresenter selections isEmpty ifTrue: [^self].
	dictionaryNames := dictionaryListPresenter selections
				collect: [:dictionaryService | dictionaryService name].
	(dictionaryNames includesAnyOf: self protectedDictionaries)
		ifTrue: 
			[^MessageBox notify: 'Cannot remove protected dictionaries ' , self protectedDictionaries printString].
	(MessageBox
		confirm: 'Really remove dictionary(s) ' , (dictionaryNames fold: [:a :b | a , ' ' , b]) , ' ?
This will commit the transaction.')
			ifFalse: [^self].
	self basicRemoveDictionaries: dictionaryNames
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeGlobal [
	| selection string |
	selection := globalsTab selectionIfNone: [^self].
	string := self selectedGlobalName: selection.
	MessageBox confirm: 'Really remove #' , string , '?'.
	^self basicRemoveGlobal: (selection at: 1)
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeGlobalsTab [
	| globalsTabView |
	globalsTabView := self view viewNamed: 'globalsTab' ifNone: [nil].
	globalsTabView ifNotNil: [self textAreaTabs removeSubView: globalsTabView].
	globalsTab := nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removePackages [

	| projectService |
	(MessageBox confirm: 'Really remove package(s)?') ifFalse: [ ^ self ].
	projectService := projectListPresenter selection.
	projectService
		command: #removePackagesNamed:;
		commandArgs: (Array with: packageListPresenter selections).
	self issueCommand: projectService onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeProjectTabs [
	| projectInfoView projectReadMeView |
	projectInfoView := self view viewNamed: 'projectInfoTab' ifNone: [nil].
	projectInfoView ifNotNil: [self textAreaTabs removeSubView: projectInfoView].
	projectInfoTab := nil.
	projectReadMeView := self view viewNamed: 'projectReadMeTab' ifNone: [nil].
	projectReadMeView ifNotNil: [self textAreaTabs removeSubView: projectReadMeView].
	projectReadMeTab := nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> resetCategoryText [

	categoryListPresenter selections size = 1 ifTrue: [
		^ methodCategoryText text:
			  'Category: ' , categoryListPresenter selectedItem categoryName ].
	categoryListPresenter selections size > 1 ifTrue: [
		^ self displayMultipleCategories ].
	methodCategoryText text: 'Category: '.
	String new
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> resetClassComment [

	^ classCommentPresenter value: (self selectedClass
			   ifNil: [ String new ]
			   ifNotNil: [ :classService | classService comment ])
]

{ #category : 'actions' }
JadeiteBrowserPresenter >> resetClassTemplate [
	"as yet unclassified"

	| presenter |
	presenter := packageListPresenter.
	presenter list isEmpty ifTrue: [
		classDefinitionPresenter value: String new.
		^ self ].
	classDefinitionPresenter value: (presenter selections isEmpty
			 ifTrue: [ String new ]
			 ifFalse: [
				 self selectedClassTab activePresenter selection selectedItem ifNil:[
					  presenter selectedItem defaultTemplate ]
					 ifNotNil: [ self selectedClassTab activePresenter selectedItem template ] ]).
	self resetClassDefinitionPane
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> resetMethodSource [

	methodSourcePresenter text:
		methodSourcePresenter methodService source.
	^ methodSourcePresenter isModified: false
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> runAll [
	self selectSUnitTab.
	self sunitPresenter runAll
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> runSelected [
	^self runMethodTests. 
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> scrollToClassHierarchySelection: thePath [

	"scroll setting is broken in spec2 as of this version of Pharo (10). 
	selectingItem: doesn't keep the underlying morph selection indices up to date
	so we have to roll our own scrolling. Good enough for now. "

	classHierarchyPresenter withAdapterDo: [ :theAdapter | 
		| scrollBar sum |
		scrollBar := theAdapter widget verticalScrollBar.
		sum := thePath inject: 0 into: [ :theSum :obj | theSum + obj ].
		scrollBar setValue: scrollBar scrollDelta * sum ]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectCategoriesNamed: selections [

	categoryListPresenter selectItems: selections
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectCategoryTab [
	methodFilterTabs selectPageIndex: 1
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassCommentTab [
	textAreaTabs selectPage: classCommentTab 
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassDefinitionTab [
	textAreaTabs selectPage: classDefinitionPage
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassHierarchyTab [
	classListHierarchyTabs selectPageIndex: 2
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassInClassHierarchyNamed: className [
	| service path |
	service := RowanClassService new name: className. 
	path := (classHierarchyPresenter pathIndexOf: (Array with: service)) first. 
	path = 0 ifTrue:[^self]. 
	classHierarchyPresenter selectPath: path scrollToSelection: true;
	expandPath: path. 
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassInClassListNamed: className [

	| selection |
	selection := classListPresenter list
		             detect: [ :classService |
		             classService name = className ]
		             ifNone: [  ].
	selection ifNil: [ ^ self ] ifNotNil: [ :sel |
		classListPresenter selectedItem = sel ifFalse: [
			classListPresenter selectItem: sel ] ].
	self classSelected: self selectedClass.
	classListPresenter verticalAlignment desiredVisibleRow:
		classListPresenter selection selectedIndex.
	^ selection
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassListTab [

	self isHierarchyTabSelected ifTrue: [
		classHierarchyPresenter selectedItem ifNotNil: [ :selection |
			classListPresenter selectItem: selection ] ].
	classListHierarchyTabs selectPageIndex: 1
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectClassNamed: className [
	self isClassListTabSelected
		ifTrue: [self selectClassInClassListNamed: className]
		ifFalse: [self selectClassInClassHierarchyNamed: className]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectDictionaryNamed: dictionaryName [
	| dictionaryService |
	dictionaryService := dictionaryListPresenter list detect: [:service | service name = dictionaryName]
				ifNone: [^self].
	dictionaryListPresenter selections: (Array with: dictionaryService)
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectMethod: methodSelection [

	self selectMethods: (Array with: methodSelection)
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectMethodSourceTab [

	textAreaTabs selectPage: methodSourcePage
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectMethodWithSameSelectorAs: selectedMethod [
	"if possible, after a class selection, select a method of the same name 
	for convenience. Otherwise, don't select anything."

	selectedMethod ifNil: [ self methodSelectionChanged ] ifNotNil: [
		| sameNameMethod |
		sameNameMethod := methodListPresenter list
			                  detect: [ :methodService |
			                  methodService selector = selectedMethod selector ]
			                  ifNone: [  ].
		sameNameMethod
			ifNil: [
				self selectedClass ifNotNil: [ :classService |
					methodListPresenter unselectAll ] ]
			ifNotNil: [ :match |
				methodListPresenter selectItem: match.
				self updateMethodSource ] ]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectMethods: methodSelections [

	| newMethodSelections newSelection |
	newMethodSelections := OrderedCollection new.
	methodSelections do: [ :methodSelection |
		newSelection := methodListPresenter list
			                detect: [ :svc |
			                svc selector = methodSelection selector ]
			                ifNone: [  ].
		newSelection ifNotNil: [ newMethodSelections add: newSelection ] ].
	newMethodSelections isEmpty ifTrue: [ ^ self ].
	^ methodListPresenter
		  selectIndexes: (newMethodSelections collect: [ :methodService |
				   methodListPresenter items indexOf: methodService ])
		  scrollToSelection: true
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectMethodsFrom: classService [

	| selections selectedMethods |
	selections := OrderedCollection new.
	selectedMethods := classService selectedMethods.
	(self selectedClass ifNotNil: [ :selectedClass |
		 selectedClass name = selectedMethods first className ])
		ifFalse: [
		self selectClassNamed: selectedMethods first className ].
	(selectedMethods size = 1 and: [ self isCategoryTabSelected ])
		ifTrue: [
			| category |
			category := selectedMethods first category.
			(categoryListPresenter model includes: category) ifFalse: [
				categoryListPresenter model add: category ].
			categoryListPresenter selection: category ].
	selectedMethods do: [ :methodService |
		| selection |
		selection := methodListPresenter list
			             detect: [ :svc |
			             svc selector == methodService selector ]
			             ifNone: [  ].
		selection ifNotNil: [ :sel | selections add: sel ] ].
	methodListPresenter selections: selections
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectNewPackage: newPackage [
	| thePackageService | 
	thePackageService := packageListPresenter list
				detect: [:packageService | packageService name = newPackage] ifNone:[^self].
	packageListPresenter selection: thePackageService
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectNoneProject [
	"get rid of none project"
	self todo:[projectListPresenter selection: (projectListPresenter list
				detect: [:projectService | projectService name = RowanProjectService noneProject name])]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectPackageNamed: packageName [

	| answeringService service |
	self packageListPresenter hasSelection ifTrue: [
		self packageListPresenter selectedItem name = packageName ifTrue: [
			^ self ] ].
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageNamed:;
		commandArgs: (Array with: packageName).
	self issueCommand: answeringService onCompletion: nil.
	service := answeringService answer.
	service selectIn: self
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectPackageOrDictionaryFor: classService [

	| answeringService service |
	service := self isDictionaryTabSelected
		           ifTrue: [
			           classService dictionaryName ifNotNil: [ :nm |
				           service := RowanDictionaryService new name: nm ] ]
		           ifFalse: [
			           classService packageName ifNotNil: [ :nm |
				           RowanPackageService new name: nm ] ].
	service ifNotNil: [ service selectIn: self ] ifNil: [
		answeringService := RowanAnsweringService new.
		answeringService
			command: #packageOrDictionaryFor:;
			commandArgs: (Array with: classService).
		RowanServiceUpdater current
			issueCommand: answeringService
			session: self gciSession.
		service := answeringService answer.
		service selectIn: self ]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectProjectNamed: projectName [

	| projectService index |
	self projectListPresenter selectedItem name = projectName ifTrue: [
		^ self ].
	projectService := self projectListPresenter list
		                  detect: [ :service | service name = projectName ]
		                  ifNone: [ ^ self ].
	index := self projectListPresenter list indexOf: projectService.
	self projectListPresenter selectIndex: index scrollToSelection: true.
	^ projectService "return for testing"
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectProjectTab [
	self selectSourceTabNamed: 'projectInfoTab'
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedClass [

	^self selectedClassTab ifNotNil: [:tab | tab activePresenter ifNotNil: [ :pres | pres  selectedItem]]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedClassTab [

	^ classListHierarchyTabs ifNotNil: [ classListHierarchyTabs currentCard ]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedDictionaryNames [
	^dictionaryListPresenter selections collect: [:dictionaryService | dictionaryService name]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedDictionaryOrPackage [
	^self isNoneProjectSelected
		ifTrue: [dictionaryListPresenter selectedItem]
		ifFalse: [packageListPresenter selectedItem]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedFilterTab [

	^ self isCategoryTabSelected
		  ifTrue: [ categoryListPresenter ]
		  ifFalse: [
			  self isVariablesTabSelected
				  ifTrue: [ variableListPresenter ]
				  ifFalse: [ packageMethodListPresenter ] ]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedFilters [

	^ self selectedFilterTab selections collect: [ :filter |
		  filter isJadeiteCategory
			  ifTrue: [ filter categoryName ]
			  ifFalse: [ filter ] ]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedGlobalName: selection [
	| string rs |
	rs := ReadStream on: (selection at: 1).
	rs upTo: $..
	string := rs upToEnd.
	^string
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> selectedMethods [

	^ methodListPresenter selectedItems
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedPackageNames [
	^packageListPresenter selections collect: [:packageService | packageService name]
]

{ #category : 'selections' }
JadeiteBrowserPresenter >> selectedPackageServices [
	^packageListPresenter selectedItems
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> setClassSide [

	classRadioButton state: true
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> setCompileErrorColor [
	statusBarText view backcolor: Color red faded
]

{ #category : 'private' }
JadeiteBrowserPresenter >> setDefaultMethod [

	methodSourcePresenter value: self defaultMethod
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> setInstanceSide [

	instanceRadioButton state: true
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> setStatusBarDefault [
	self todo:[statusBarText view backcolor: statusBarText view defaultBackcolor]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> shouldShowNoneTabLabel [
	^dictionaryListPresenter list isEmpty
		or: [dictionaryListPresenter selections isEmpty or: [dictionaryListPresenter selections size > 1]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> showDictionaryList [
	| newCard |
	packageDictionaryCards ifNil:[^self].
	(packageDictionaryCards view cards includes: packageListPresenter view)
		ifTrue: 
			[packageDictionaryCards view removeSubView: packageListPresenter view.
			packageListPresenter list: ListModel new].
	packageDictionaryCards view cards isEmpty
		ifTrue: 
			[newCard := packageDictionaryCards add: dictionaryListPresenter.
			self createListViewFor: newCard.
			packageDictionaryCards view cards first arrangement: 'Dictionaries'.
			dictionaryListPresenter view contextMenu: self dictionaryMenu.
			classListPresenter list: ListModel new.
			classHierarchyPresenter model: JadeiteTreeModel new].
	self updateDictionaries.
	self clearComponentList
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> showPackageGroups [
	componentPackageContainer view arrangement: 1/4.
	packageDictionaryContainer view arrangement: 0.5. 
	projectListContainer view arrangement: 3/20. 
	classContainer view arrangement: 1/5. 
	packageGroupPresenter view creationParentView show
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> showPackageList [
	componentPackageContainer view arrangement: 1 / 3.
	packageDictionaryContainer view show.
	self view
		hide;
		show	"ugh - this seems necessary for some reason to get the gui to update"
]

{ #category : 'events' }
JadeiteBrowserPresenter >> sourcePaneChanged [

	methodSourcePresenter isModified
		ifTrue: [ methodSourcePage icon: (self iconNamed: #protocolPrivate) ]
		ifFalse: [ methodSourcePage icon: nil ].
	classDefinitionPresenter isModified
		ifTrue: [
		classDefinitionPage icon: (self iconNamed: #protocolPrivate) ]
		ifFalse: [ classDefinitionPage icon: nil ].
	classCommentPresenter isModified
		ifTrue: [ classCommentTab icon: (self iconNamed: #protocolPrivate) ]
		ifFalse: [ classCommentTab icon: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> statusBarText [
	
	^statusBarText 
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> statusBarText: string [
	self todo: [statusBarText value: string]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> symbolExists: newClassName [
	^(RowanAnsweringService new symbolExists: newClassName asSymbol session: self gciSession) not
]

{ #category : 'sunit support' }
JadeiteBrowserPresenter >> testClassResultIconFor: classService [
	^ classService isTestCase
		  ifTrue: [
			  | testResult |
			  testResult := (classService visibleTests collect: [
				                 :methodService | methodService testResult ])
				                asSet asArray.
			  testResult size = 1 ifFalse: [
				  testResult := testResult copyWithout: 'passed' ].
			  testResult := testResult isEmpty
				                ifTrue: [  ]
				                ifFalse: [ testResult first ].
			  testResult = 'passed'
				  ifTrue: [
				  self
					  testItemButtonWithIconNamed: #testGreen
					  service: classService ]
				  ifFalse: [
					  testResult = 'failure'
						  ifTrue: [
						  self
							  testItemButtonWithIconNamed: #testYellow
							  service: classService ]
						  ifFalse: [
							  testResult = 'failure'
								  ifTrue: [
								  self
									  testItemButtonWithIconNamed: #testRed
									  service: classService ]
								  ifFalse: [
								  self
									  testItemButtonWithIconNamed: #testNotRun
									  service: classService ] ] ] ]
		  ifFalse: [ nil ]
]

{ #category : 'sunit support' }
JadeiteBrowserPresenter >> testItemButtonWithIconNamed: iconName service: clickedService [

	| methodServices |
	methodServices := clickedService isClassService
		                  ifTrue: [ clickedService visibleTests ]
		                  ifFalse: [ { clickedService } ].
	^ IconicButtonMorph new
		  target: self;
		  labelGraphic: (self iconNamed: iconName);
		  actionSelector: #debugMethodTests:;
		  arguments: (Array with: methodServices);
		  color: Color transparent;
		  helpText: 'Run Tests';
		  borderWidth: 0;
		  yourself
]

{ #category : 'sunit support' }
JadeiteBrowserPresenter >> testMethodResultIconFor: methodService [

	^ methodService isTestMethod
		  ifTrue: [
			  | testResult |
			  testResult := methodService testResult.
			  testResult = 'passed'
				  ifTrue: [
					  self
						  testItemButtonWithIconNamed: #testGreen
						  service: methodService ]
				  ifFalse: [
					  testResult = 'failure'
						  ifTrue: [
							  self
								  testItemButtonWithIconNamed: #testYellow
								  service: methodService ]
						  ifFalse: [
							  testResult = 'failure'
								  ifTrue: [
									  self
										  testItemButtonWithIconNamed: #testRed
										  service: methodService ]
								  ifFalse: [
									  self
										  testItemButtonWithIconNamed: #testNotRun
										  service: methodService ] ] ] ]
		  ifFalse: [ nil ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> textTabChanged [
	textAreaTabs ifNil: [ ^self ].
	self todo:[textAreaTabs currentCard name = 'projectInfo' ifTrue: [projectInfoTab ensureVisible].
	textAreaTabs currentCard name = 'sunit'
		ifTrue: [sunitPresenter methodListPresenter setFocus	"to ensure sunit bar is enabled"].
	self updateMenuBar]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> togglePackageGroupsColumn [
	packageGroupPresenter view creationParentView isWindowVisible
		ifTrue: 
			[JadePresenter packageGroupsVisible: false.
			JadePresenter hidePackageGroups]
		ifFalse: 
			[JadePresenter packageGroupsVisible: true.
			JadePresenter showPackageGroups]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> unloadProjects [
	| projectNames ws |
	projectNames := projectListPresenter selections collect: [:projectService | projectService name].
	projectNames isEmpty ifTrue: [^self].
	ws := WriteStream on: String new.
	projectNames do: 
			[:projectName |
			ws
				space;
				nextPutAll: projectName].
	(MessageBox
		confirm: 'Really unload project(s) - ' , ws contents , '?  You will lose any unsaved changes! '
		caption: 'UNLOAD PROJECTS WARNING!') ifFalse: [^self].
	self basicUnloadProjects: projectNames
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> unsubcribePresenters [
	self class allInstVarNames do:[:instVarName |
		RowanServiceUpdater current removeActionsWithReceiver: (self instVarNamed: instVarName) ].
	self dependents do:[:dependent | 
	 	self removeDependent: dependent].
	self announcer subscriptions removeSubscriber: self.
	self owner removeAll "remove the pages from the notebook"
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateAfterFindClass: classService [

	classService ifNil: [ ^ self ].
	classService projectName ifNil: [
		self updateService: classService.
		(self findProjectNamed: classService projectName) ifNotNil: [
			self isDictionaryTabSelected
				ifTrue: [ self updateAfterFindClassInDictionary: classService ]
				ifFalse: [ self updateAfterFindClassInPackage: classService ] ] ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateAfterFindClass: classService onCompletion: completionBlock [

	^self updateAfterFindClass: classService
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateAfterFindClassInDictionary: classService [
	| dictionaryService |
	Cursor wait showWhile: 
			[dictionaryService := dictionaryListPresenter list
						detect: [:service | service name = classService dictionaryName]
						ifNone: [^self].
			dictionaryListPresenter selections: (Array with: dictionaryService).
			self isClassListTabSelected
				ifTrue: [self selectClassNamed: classService name asString]
				ifFalse: 
					[self updateClass: classService.  "It's legal for the classService to not be filled in yet. That would break the hierarchy update" 
					self selectClassInClassListNamed: classService name.
					self updateHierarchy]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateAfterFindClassInPackage: classService [

	self selectPackageOrDictionaryFor: classService.

	classService isMeta ifTrue: [ self setClassSide ].
	self isClassHierarchyTabSelected ifTrue: [
		classHierarchyPresenter model asBag
			detect: [ :svc | svc name = classService name ]
			ifNone: [ self updateHierarchy ] ].
	self selectClassNamed: classService name asString
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateClass: classService [
	" a class service was updated, refresh our display"

	| update |
	classService selectedPackageServices: self packageListPresenter selections browser: self.
	update := classListPresenter model asBag
				detect: [:listClassService | listClassService name = classService name]
				ifNone: [^self].
	update replicateFrom: classService.
	classListPresenter view invalidate.
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateClassInfo [

	| service |
	self resetCategoryText.
	service := self selectedClass ifNil: [
		           self resetDefinedClassPackage.
		           ^ self ].
	classCommentPresenter value: service comment.
	classDefinitionPresenter view isModified ifTrue: [
		service template = classDefinition ifTrue: [ ^ self ].
		classDefinition ifNotNil: [
			(MessageBox
				 confirm: 'Copy changes to clipboard?'
				 caption: 'Class has unsaved changes!') ifTrue: [
				classDefinitionPresenter text copyToClipboard ] ] ].
	classDefinitionPresenter value: service template.
	self resetClassDefinitionPane.
	self todo: [
		self setTestClass: service.
		self isSunitTabSelected ifFalse: [
			classDefinitionPresenter ensureVisible ].
		self updateClassMenu: nil.
		self updateSUnitTab ].
	definedClassPackageText view text:
		'Defined Package: ' , self selectedClass definedPackageName.
	self sundryCleanup
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateClassMenu: menu [
	| gotoPackageItem gotoDictionaryItem |
	(menu class canUnderstand: #items) ifFalse: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	gotoPackageItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoClassDefinedPackage]
				ifNone: [^self].
	menu removeItem: gotoPackageItem.
	gotoPackageItem description: self definedClassMenuItemLabel.
	menu addItem: gotoPackageItem.
	gotoDictionaryItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoDictionary]
				ifNone: [^self].
	menu removeItem: gotoDictionaryItem.
	gotoDictionaryItem description: self containedDictionaryLabel.
	menu addItem: gotoDictionaryItem
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateClasses [
	self isDictionaryTabSelected
		ifTrue: [self updateServices: dictionaryListPresenter selections]
		ifFalse: [self updateServices: packageListPresenter selections]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateDictionaries [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateDictionaries.
	self issueCommand: browserService onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateDictionary [
	self isPackageListTabSelected  ifTrue:[^self]. 
	classListPresenter model: ListModel new.
	self todo:[classHierarchyPresenter model: JadeiteTreeModel new].
	self updateServices: dictionaryListPresenter selections.
	self isClassListTabSelected ifFalse: [self updateHierarchy].
	self updateTabLabel.
	self todo:[self updateGlobalsTab].
	dictionaryListPresenter selections isEmpty ifTrue:[^self]. 
	classDefinitionPresenter value: dictionaryListPresenter selectedItem defaultTemplate.
	self resetClassDefinitionPane.
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateGlobalsTab [
	| array |
	array := Array writeStream: 10.
	array nextPut: (Array
				with: 'Name'
				with: 'Class'
				with: 'Oop'
				with: 'Value').
	dictionaryListPresenter selections isEmpty
		ifFalse: 
			[dictionaryListPresenter selections do: 
					[:dictionaryService |
					dictionaryService globals
						ifNotNil: [:globals | globals do: [:globalArray | array nextPut: globalArray]]]].
	globalsTab list: array contents
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateHierarchy [

	| service |
	classHierarchyPresenter roots: Array new.
	self isDictionaryTabSelected
		ifTrue: [
		dictionaryListPresenter selections isEmpty ifTrue: [ ^ self ] ]
		ifFalse: [
			projectListPresenter selectionOrNil ifNil: [ ^ self ].
			packageListPresenter selections isEmpty ifTrue: [ ^ self ] ].
	service := classListPresenter selectionOrNil ifNil: [
		           ^ self updateHierarchyForPacktionaries ].
	service
		updateAfterCommand: false;
		command: #classHierarchy.
	self issueCommand: service onCompletion: nil.
	self selectClassNamed: service name
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateHierarchyForPacktionaries [

	| service |
	service := RowanBrowserService new.
	self isNoneProjectSelected
		ifTrue: [
			service
				command: #classHierarchyForDictionariesNamed:;
				commandArgs: (Array with: self selectedDictionaryNames) ]
		ifFalse: [
			service
				command: #classHierarchyForPackagesNamed:;
				commandArgs: (Array with: self selectedPackageNames) ].
	self issueCommand: service onCompletion: nil
]

{ #category : 'history' }
JadeiteBrowserPresenter >> updateHistory [

	| methodService |
	methodListPresenter hasSelection ifFalse: [ ^ self ].
	methodService := self methodListPresenter selectedItem.
	(historyList includes: methodService) ifTrue: [ ^ self ].
	historyList := historyList copyFrom: 1 to: historyIndex. "trim"
	historyList add: methodService.
	historyIndex := historyList size.
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateMenuBar [
	| shellView menuBar methodFilterMenu textAreaMenu methodMenu |
	methodFilterMenu := Menu fromStrings: (self isCategoryTabSelected
						ifTrue: [self categoriesMenuStrings]
						ifFalse: [self variablesMenuStrings]).
	textAreaMenu := Menu fromStrings: (self isGlobalsTabSelected
						ifTrue: [self globalsMenuStrings]
						ifFalse: [self editMenuStrings]).
	shellView := self parentPresenter parentPresenter view.
	menuBar := shellView menuBar
				clear;
				addItem: (Menu fromStrings: self jadeMenuStrings);
				addItem: self class projectMenu;
				addItem: (Menu fromStrings: self pkgsMenuStrings);
				addItem: (Menu fromStrings: self classesMenuStrings);
				addItem: methodFilterMenu;
				addItem: (methodMenu := Menu fromStrings: self methodsMenuStrings);
				addItem: textAreaMenu;
				yourself.
	shellView menuBar: menuBar.
	self updateMethodMenu: methodMenu
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateMethodSource [

	RowanServiceUpdater current isApplyingUpdates ifTrue: [ ^ self ].
	methodSourcePresenter view isModified ifTrue: [ ^ self ].
	self sundryCleanup.
	methodListPresenter selections isEmpty ifTrue: [
		definedMethodPackageText text: String new.
		self resetCategoryText.
		self todo: [ ^ self methodSourcePresenter setDefaultMethod ] ].

	self updateServices: methodListPresenter selections.

	UIManager default defer: [
		methodListPresenter selections isEmpty
			ifTrue: [
				self methodSourcePresenter removeAllTextSegmentDecorations.
				methodSourcePresenter value: self defaultMethod ]
			ifFalse: [
				self updateMethodSourceGlyphs.
				definedMethodPackageText text:
					'Defined Package: '
					, methodListPresenter selectedItem definedPackage.
				methodCategoryText text:
					'Category: ' , methodListPresenter selectedItem category ] ]
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updatePackage [

	self resetClassComment.
	self resetClassTemplate.
	packageListPresenter selections isEmpty ifTrue: [ ^ self ].
	classListPresenter model: ListModel new.
	classHierarchyPresenter clear.
	self selectClassListTab.
	self updateClasses.
	self isClassListTabSelected ifFalse: [ self updateHierarchy ].
	self updatePackageInfo.
	self resetSunitTestList.
	packageListPresenter selectionIfNone: [ self selectProjectTab ].
	self updateTabLabel.
	definedClassPackageText text: String new
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updatePackageGroupPackages [
	"Do the package selection & class gathering as such for a performance improvement"

	| classes |
	packageListPresenter clear.
	packageGroupPresenter selections isEmpty ifTrue: [^self].
	self updateServices: packageGroupPresenter selections.
	packageListPresenter noEventsDo: [packageListPresenter selections: packageListPresenter list].
	classes := Set new.
	packageListPresenter selections do: [:packageService | classes addAll: packageService classes].
	classListPresenter list: classes asArray.
	self sundryCleanup
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updatePackageMenu: menu [
	| gotoPackageDictionaryItem |
	(menu class canUnderstand: #items) ifFalse: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	gotoPackageDictionaryItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoPackageDictionary]
				ifNone: [^self].
	menu removeItem: gotoPackageDictionaryItem.
	packageListPresenter selectionIfNone: [^self].
	gotoPackageDictionaryItem description: self containedPackageDictionaryLabel.
	menu addItem: gotoPackageDictionaryItem
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateProjectInfo [

	| service |
	self todo: [
		self removeAppropriateTab.
		self isNoneProjectSelected ifTrue: [ ^ self buildGlobalsTab ].
		projectInfoTab ifNil: [
			self buildProjectTab.
			self buildProjectReadMeTab ].
		
		self updateTabLabel.
		self updateProjectReadMe.
		addPackagePresenter view enable ].
	service := projectListPresenter selectionIfNone: [
			           self clearProjectTabs.
			           ^ self ].
	self updateProjectInfoTabFor: service
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateProjectInfoTabFor: service [
	| array |
	array := WriteStream on: Array new. 
	array nextPut: (Array with: service with: 'rowanProjectsHome').
	array nextPut: (Array with: RowanProjectService new with: String new).
	service wasUpdated
		ifTrue: 
			[array nextPut: (Array with: service with: 'name').
			array nextPut: (Array with: service with: 'sha').
			array nextPut: (Array with: service with: 'diskSha').
			array nextPut: (Array with: service with: 'branch').
			array nextPut: (Array with: service with: 'isSkew').
			array nextPut: (Array with: service with: 'isDirty').
			array nextPut: (Array with: service with: 'projectUrl').
			array nextPut: (Array with: service with: 'packageConvention').
			service == service ifFalse: [array nextPut: (Array with: RowanProjectService new with: nil)]].
	projectInfoList items: array contents
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateProjectPackages [
	projectListPresenter selections isEmpty ifTrue: [^self].
	self updateServices: projectListPresenter selections.
	self sundryCleanup
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateProjectReadMe [

	| service |
	service := RowanFileService new
		           command: #readmeContents;
		           path: self projectReadmePath.
	self issueCommand: service onCompletion: nil.
	projectReadMeTab value: service answer
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateProjectSelecting: selectedProject [

	self packageListPresenter clear.
	self dictionaryListPresenter clear.
	self cleanupProjectInfoTab.
	self updateTabLabel.
	classHierarchyPresenter clear.
	classListPresenter clear.
	self selectClassListTab.
	self packageListPresenter selectionIfNone: [
		classListPresenter clear.
		classHierarchyPresenter clear ].
	self buildPackageList.
	self updateTabLabel.
	self basicUpdateProject.
	definedClassPackageText text: String new
]

{ #category : 'tab labels' }
JadeiteBrowserPresenter >> updateSystemTab [
	| projectTabLabel | 
	projectTabLabel := self projectTabLabel.
	self arrangement: projectTabLabel.
]

{ #category : 'tab labels' }
JadeiteBrowserPresenter >> updateTabLabel [
 	self owner ifNotNil:[
		self updateSystemTab]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> variablesMenuStrings [
	false
		ifTrue: 
			[self addVariableAccessors.
			self
				browseInstVarReaders;
				browseInstVarWriters].
	^#('&Variables' '&Add Accessors//addVariableAccessors' '&Browse Inst Var Readers//browseInstVarReaders' '&Browse Inst Var Writers//browseInstVarWriters')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> writeProject [
	| projectServices |
	projectServices := projectListPresenter selections.
	projectServices isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^self basicWriteProject: projectServices
]
