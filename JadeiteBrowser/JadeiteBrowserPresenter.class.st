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
		'classRadioButton'
	],
	#pools : [
		'ScintillaConstants'
	],
	#category : 'JadeiteBrowser'
}

{ #category : 'utility' }
JadeiteBrowserPresenter class >> browseSendersOf: string session: session [
	| service shell |
	service := RowanQueryService command: #sendersOf: withArgs: (Array with: string asSymbol).
	self issueCommands: (Array with: service) session: session.
	shell := self
				openMethodListOn: service
				selecting: string
				session: session.
	shell updateCaptionFromSearchString: 'Senders of ' , string asString printString.
	^shell
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

	^BrowserUpdate current issueCommand: service session: gciSession
]

{ #category : 'utility' }
JadeiteBrowserPresenter class >> issueCommands: service session: gciSession [

	^BrowserUpdate current issueCommands: service session: gciSession
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
JadeiteBrowserPresenter class >> projectMenuStrings [
	"put on the class side so it can be shared with the projectlist in the console"

	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self new
				createNewProject;
				loadProject;
				reloadProject;
				unloadProjects;
				pullFromGit;
				gitCommit;
				pushToGit;
				projectChanges;
				writeProject;
				checkoutTag;
				checkout;
				auditProject;
				projectLog;
				refresh].
	^#('Projects' 'Browse//openJadeiteProjectsBrowser' 'Create ...//createNewProject' 'Load ...//loadProject' 'Refresh From Disk //reloadProject' 'Unload//unloadProjects' '-' 'Pull from Git//pullFromGit' 'Commit to Git ...//gitCommit' 'Push to Git//pushToGit' '-' '&Changes//projectChanges' 'Write ...//writeProject' 'Checkout Git Tag ...//checkoutTag' 'Checkout Git Branch ...//checkout' '-' 'Edit Components//editComponents' 'Edit Load Spec From File ...//editLoadSpecFromFile' '-' 'Audit//auditProject' 'Git Log//projectLog' '&Refresh//refreshFromServer')
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> abortTransaction [

	super abortTransaction.
	self gciSession autoCommit:
		(self gciSession autoCommit value == #failed
			 ifTrue: [ true ]
			 ifFalse: [ self gciSession autoCommit value ])
]

{ #category : 'api-events' }
JadeiteBrowserPresenter >> abortedTransaction [

	self selectedClass ifNotNil: [ :classService |
		self updateAfterFindClass: classService ].
	self resetClassTemplate.
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
		methodSourcePresenter addStyle: 'jadedTextBackgroundColor' ].
	classDefinitionPresenter whenBuiltDo: [
		classDefinitionPresenter addStyle: 'jadedTextBackgroundColor' ].
	classCommentPresenter whenBuiltDo: [
		classCommentPresenter addStyle: 'jadedTextBackgroundColor' ].
	projectInfoList whenBuiltDo: [
		projectInfoList addStyle: 'jadedTextBackgroundColor' ]
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
JadeiteBrowserPresenter >> auditProject [
	^self auditProjectFor: projectListPresenter selection name
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicAddDictionaryNamed: newDictionaryName [
	| insertionIndex dictionaryService |
	insertionIndex := dictionaryListPresenter selectionByIndex = 0
				ifTrue: [dictionaryListPresenter list size + 1]
				ifFalse: [dictionaryListPresenter selectionByIndex + 1].
	dictionaryService := RowanDictionaryService new name: newDictionaryName.
	dictionaryService
		command: #insertAt:;
		commandArgs: (Array with: insertionIndex).
	self issueCommand: dictionaryService.
	dictionaryListPresenter
		selection: (dictionaryListPresenter list detect: [:newService | newService name = newDictionaryName])
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicAddMethodCategory: string [
	| service |
	(self categoryListPresenter list includes: string)
		ifFalse: 
			[service := self selectedClass
						command: #addCategory:;
						commandArgs: (Array with: string).
			service meta: self isClassSideSelected.
			self issueCommand: service].
	self selectCategoriesNamed: (Array with: string)
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
	service := RowanQueryService command: #browseClassReferences: withArgs: (Array with: className).
	BrowserUpdate current issueCommands: (Array with: service) session: session.
	^service
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicCopyClass: oldClassService to: newClassName [
	oldClassService
		command: #copyClassTo:;
		commandArgs: (Array with: newClassName).
	self issueCommand: oldClassService.
	self updateAfterFindClass: (RowanClassService new name: newClassName)
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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
	self isHierarchyTabSelected ifTrue:[
		| path newPath |
		path := classHierarchyPresenter selection selectedPath.
		newPath := path copyFrom: 1 to: path size - 1. 
		classHierarchyPresenter selection selectPath: newPath.
		].	
	service := self selectedDictionaryOrPackage.
	service
		command: #removeClass:;
		commandArgs: (Array with: theClassService).
	self issueCommand: service.
	self selectedClass
		ifNil: [self resetClassTemplate	"just emptied the last class in the package"]
		ifNotNil: 
			[classDefinitionPresenter value: self selectedClass template.
			self resetClassDefinitionPane]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicRemoveDictionaries: dictionaryNames [
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #removeDictionariesNamed:;
		commandArgs: (Array with: dictionaryNames).
	self issueCommand: browserService
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicRemoveGlobal: qualifiedString [
	| symbol rs dictionaryService globalDictionaryName |
	rs := ReadStream on: qualifiedString.
	globalDictionaryName := rs upTo: $..
	dictionaryService := dictionaryListPresenter list
				detect: [:service | service name = globalDictionaryName].
	symbol := rs upToEnd asSymbol.
	dictionaryService
		command: #removeGlobalNamed:;
		commandArgs: (Array with: symbol).
	self issueCommand: dictionaryService.
	self removeGlobalsTab.
	self buildGlobalsTab
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicUnloadProjects: projectNames [
	super basicUnloadProjects: projectNames.
	dictionaryListPresenter model: ListModel new
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> basicUpdateProject [
	self updateProjectPackages.
	self updateProjectInfo.
	self todo: 'projectInfoTab ensureVisible'.
	self sundryCleanup
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> browseGlobalClass [
	| selection |
	selection := globalsTab selectionIfNone: [^self].
	^self openBrowserInNewTab: false on: (RowanClassService new name: (selection at: 2))
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> browseGlobalReferences [
	| selection string |
	selection := globalsTab selectionIfNone: [^self].
	string := self selectedGlobalName: selection.
	^JadePresenter browseSymbolReferencesTo: '#' , string session: gciSession
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
		color := Color magenta twiceDarker ].
	"classService isInSymbolList == true ifFalse: [
		color := Color red twiceDarker ]."
	^color
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
JadeiteBrowserPresenter >> clearMethodPresenters [
	categoryListPresenter clear.
	variableListPresenter clear.
	packageMethodListPresenter clear.
	methodListPresenter clear.
	methodSourcePresenter value: String new. 
	definedMethodPackageText text: String new.
	methodCategoryText text: String new. 
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

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectCancelActions [

	methodSourcePresenter whenResetDo: [
		methodSourcePresenter text:
			methodSourcePresenter methodService source.
		methodSourcePresenter isModified: false ].
	classCommentPresenter whenResetDo: [
		self resetClassComment.
		classCommentPresenter isModified: false ].
	classDefinitionPresenter whenResetDo: [
		self resetClassTemplate classDefinitionPresenter isModified: false ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectClassPresenters [

	classListPresenter whenSelectionChangedDo: [ :selection |
		self
			refreshClass;
			updateTabLabel ].
	classHierarchyPresenter whenSelectionChangedDo: [ :selection |
		self
			refreshClass;
			updateTabLabel ].
	classListHierarchyTabs whenSelectedPageChangedDo: [ :selection |
		self updateHierarchy ].
	classListHierarchyTabs whenSelectedPageChangedDo: [ :selection |
		self refreshClass ].
	classDefinitionPresenter whenSubmitDo: [ :text | self editSave ].
	classCommentPresenter whenSubmitDo: [ :text | self editSave ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectPackageDictionaryPresenters [

	packageListPresenter whenSelectionChangedDo: [ :selection |
		self updatePackage ].
	packageDictionaryTabs whenSelectedPageChangedDo: [ :selection |
		self classListPresenter list: ListModel new.
		self classHierarchyPresenter roots: Array new.
		self isDictionaryTabSelected
			ifTrue: [ self updateDictionaries ]
			ifFalse: [
				self updateProject.
				self updatePackage ].
		self updateClasses ].
	dictionaryListPresenter whenSelectionChangedDo: [ :selection |
		self updateDictionary ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> connectPresenters [

	self connectClassPresenters.
	self connectPackageDictionaryPresenters projectListPresenter
		whenSelectionChangedDo: [ :selection | self updateProject ].
	categoryListPresenter whenSelectionChangedDo: [ :selection |
		self refreshMethodsOn: methodListPresenter ].
	variableListPresenter whenSelectionChangedDo: [ :selection |
		self refreshMethodsOn: methodListPresenter ].
	methodListPresenter whenSelectionChangedDo: [ :selection |
		self methodSelectionChanged ].
	methodFilterTabs whenSelectedPageChangedDo: [ :selection |
		self filterTabChanged: selection ].
	methodSourcePresenter whenSubmitDo: [ :text | self editSave ].
	self connectCancelActions.
	textAreaTabs whenSelectedPageChangedDo: [ :selection |
		self textTabChanged ].
	instanceRadioButton whenChangedDo: [ :selection | self refreshClass ]
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

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> createSchematicWiringForClassHierarchy [
		
	classHierarchyPresenter
		when: #drag:
			send: #onDragClass:
			to: self;
		when: #dragCut:
			send: #onDragCutClassHierarchy:
			to: self;
		when: #dragOver:
			send: #onDragOverClassHierarchy:
			to: self;
		when: #drop:
			send: #onDropOnClassHierarchy:
			to: self;
		when: #aboutToDisplayMenu:
			send: #updateClassMenu:
			to: self;
		when: #selectionChanging:
			send: #aboutToChange:
			to: self;
		when: #selectionChanging:
			send: #releasedReferencedServices:
			to: self;
		when: #selectionChanged
			send: #refreshClass
			to: self;
		when: #actionPerformed
			send: #hierarchyClassDoubleClicked
			to: self
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> createSchematicWiringForClassList [
	"dolphin does not consistently send #selectionChanging: events after
	the class list has been updated. It always sends #selectionChanged. 
	However, in order to avoid conflicting updates and commands to the server
	we sometimes need to update the selection on the #selectionChanging. 
	Hence, two very similar methods. See issue #334. 
	"

	classListPresenter
		when: #drag:
			send: #onDragClass:
			to: self;
		when: #dragCut:
			send: #onDragCutClassList:
			to: self;
		when: #dragOver:
			send: #onDragOverClassList:
			to: self;
		when: #drop:
			send: #onDropOnClassList:
			to: self;
		when: #keyTyped:
			send: #delayUpdate
			to: self;
		when: #aboutToDisplayMenu:
			send: #updateClassMenu:
			to: self;
		when: #selectionChanging:
			send: #aboutToChange:
			to: self;
		when: #selectionChanging:
			send: #releasedReferencedServices:
			to: self;
		when: #selectionChanged:
			send: #selectedClassChanged:
			to: self
			with: true;
		when: #selectionChanged
			send: #refreshClass
			to: self;
		when: #labelOf:changedTo:
			send: #labelOfClass:changedTo:
			to: self;
		when: #aboutToEditLabel:accept:
			send: #aboutToEditClassLabel:accept:
			to: self;
		when: #labelOf:editedTo:accept:
			send: #labelOfClass:editedTo:accept:
			to: self;
		when: #keyTyped:
			send: #selectServiceStartingWith:
			to: classListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> createSchematicWiringForMethodList [
	methodListPresenter
		when: #drag: 				send: #onDragMethod: 			to: self; 
		when: #dragCut: 			send: #onDragCutMethod: 			to: self; 
		when: #keyTyped: 			send: #delayUpdate 				to: self; 
		when: #aboutToDisplayMenu: 	send: #updateMethodMenu:		to: self;
		when: #selectionChanging:		send: #aboutToChange:			to: self; 
		when: #keyTyped: 			send: #selectServiceStartingWith: 	to: methodListPresenter; 
		when: #selectionChanged 		send: #methodSelectionChanged 	to: self
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> createSchematicWiringForMethodSource [
	super createSchematicWiringForMethodSource.
	methodSourcePresenter
		when: #textChanged
			send: #updateMethodSourceColor
			to: self;
		when: #valueChanged
			send: #methodValueChanged
			to: self;
		when: #autoComplete:startingAt:accept:
			send: #onAutoComplete:startingAt:accept:
			to: self search;
		when: #timerTick:
			send: #onTimerTick:
			to: self search;
		when: #charAdded:
			send: #onCharAdded:
			to: self search
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> createSchematicWiringForProjectList [

	projectListPresenter 
		when: #'drag:'				send: #'onDragPackageList:'		to: self;
		when: #'dragCut:'			send: #'onDragCutPackageList:'		to: self;
		when: #'dragOver:'			send: #'onDragOverPackageList:'	to: self;
		when: #'drop:'				send: #'onDropOnPackageList:'		to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanging:'	send: #'releasedReferencedServices:'	to: self;
		when: #'selectionChanged' 		send: #'ensureVisible'				to: projectListPresenter;
		when: #'selectionChanged'		send: #'updateProject' 			to: self

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
		commandArgs: (Array with: classDefinitionPresenter text).
	self selectedClass ifNotNil: [:classService | browserService selectedClass: classService name]. 
	[self issueCommand: browserService] on: Error
		do: 
			[:ex |
			(ex isKindOf: GsCompileError)
				ifTrue: [self handleClassCompileError: ex]
				ifFalse: [self statusBarText: 'ERROR: ' , ex messageText].
			^self].
	
	[browserService
		command: #recompileMethodsAfterClassCompilation;
		commandArgs: #().
	self issueCommand: browserService]
			on: GsApplicationError, GsCompileError
			do: 
				[:ex |
				('*poolDictionaries not supported yet*' match: ex description)
					ifTrue: [^MessageBox notify: 'Pool Dictionaries not supported yet'].
				^self showMethodRecompilationError: ex].
	self resetClassDefinitionPane.
	self updateAfterFindClass: browserService selectedClass
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
	| compileResult |
	compileResult := self
				editSaveMethod: classService
				in: methodSourcePresenter
				category: self targetCategory.
	compileResult == false
		ifTrue: [self updateService: classService	"If we got a compile error our methods need a refresh"].
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
	self issueCommand: service
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> expandFullAt: classService [
	Cursor wait showWhile: 
			[classHierarchyPresenter model removeChildrenOf: classService.
			classService command: #fullHierarchy.
			self issueCommand: classService.
			self selectClassNamed: classService name.
			classHierarchyPresenter view expandAll: classService ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> expandFullHierarchy [
	self selectClassHierarchyTab.
	self selectClassInClassHierarchyNamed: self selectedClass. 
	self expandFullAt: self selectedClass. 
	classHierarchyPresenter view ensureSelectionVisible
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> expandSelectionOneLevel: selection [

	| thePath |
	selection command: #oneLevelClassHierarchy.
	self issueCommand: selection.
	thePath := classHierarchyPresenter selection selectedPaths first.
	classHierarchyPresenter roots: classHierarchyPresenter roots. "This resets the underlying morph"
	classHierarchyPresenter expandPath: thePath.
	classHierarchyPresenter selectItem: selection.
	self scrollToClassHierarchySelection: thePath
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> fileOutCategoriesOnPath: path [
	| service |
	service := self selectedClass.
	service
		command: #fileoutCategories:on:;
		commandArgs: (Array with: categoryListPresenter selections with: path).
	self issueCommand: service
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> fileOutClassOnPath: path [
	| service |
	service := self selectedClass.
	service command: #fileoutClassOn:; commandArgs: (Array with: path).
	self issueCommand: service
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

{ #category : 'api-events' }
JadeiteBrowserPresenter >> filterTabChanged: tab [
	self isClassSelected
		ifTrue: [BrowserUpdate current updateService: self selectedClass session: gciSession]
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
JadeiteBrowserPresenter >> findRemovedServices [
	| browserService |
	browserService := RowanBrowserService new
				command: #findRemovedServices:;
				commandArgs: (Array with: BrowserUpdate current activeServices asArray).
	BrowserUpdate current issueCommands: (Array with: browserService) session: self gciSession
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
	selectedCategory := categoryListPresenter selectionIfNone: [].
	selectedMethod := methodListPresenter selectionIfNone: [].
	self updateAfterFindClass: self selectedClass.
	selectedCategory ifNotNil: [:category | categoryListPresenter selection: category].
	selectedMethod
		ifNotNil: 
			[methodListPresenter selection: (methodListPresenter list
						detect: [:methodService | methodService selector = selectedMethod selector]).	"It better be there"
			self updateMenuBar	"to refresh method menu"]
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

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hasCategorySelected [

	^categoryListPresenter selections notEmpty
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> hasExactlyOneCategorySelected [

	^categoryListPresenter selections size = 1
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

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeCategoryListPresenter [

	^ JadeiteListPresenter new beMultipleSelection
		  dropEnabled: true;
		  wantsDrop: [ :transfer |
			  transfer passenger allSatisfy: #isMethodService ];
		  acceptDrop: [ :transfer |
			  self
				  moveMethods: transfer passenger
				  toCategory:
					  (self categoryListPresenter items at: transfer index) ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeCategoryText: methodColumn [

	methodCategoryText := SpTextPresenter new
		                           beNotEditable;
		                           beWrapWord;
		                           withoutScrollBars.
	methodCategoryText addStyle: 'jadedTextBackgroundColor'.
	methodColumn
		add: methodCategoryText
		withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeClassCommentTab [

	| classCommentTab |
	classCommentPresenter := JadeiteTextDocument new _gciSession:
		                         self gciSession.
	classCommentPresenter saveAction: [ self editSaveClass ].
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
		                           display: [ :m |
			                           m displayString ];
		                           displayColor: [ :classService |
			                           self classDisplayColor: classService ];
		                           children: [ :service |
			                           service subclassServices ifNil: [
					                           service command:
							                           #oneLevelClassHierarchy.
					                           self issueCommand: service ] ].
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
	classListPresenter := JadeiteListPresenter newNameSortedList.
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
	self initializeClassMenu
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeDefinedClassPackageText: classColumn [

	definedClassPackageText := SpTextPresenter new
		                           beNotEditable;
		                           beNotWrapWord;
		                           withoutScrollBars.
	definedClassPackageText addStyle: 'jadedTextBackgroundColor'.
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
	definedMethodPackageText addStyle: 'jadedTextBackgroundColor'.
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
	self initializeCategoryText: methodsBox.
	methodListPresenter := JadeiteListPresenter new
		                       display: #selector;
		                       beMultipleSelection;
		                       displayColor: [ :methodService |
			                       methodService isExtension
				                       ifTrue: [ Color magenta twiceDarker ]
				                       ifFalse: [ Color black ] ];
		                       displayUnderline: [ :methodService |
			                       methodService isExtension and: [
					                       methodService inSelectedPackage ] ];
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
	self initializeMethodListMenu
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeMethodSourceTab [

	methodSourcePresenter := JadeiteMethodSourcePane new _gciSession:
		                         self gciSession.
	methodSourcePresenter
		application: self application;
		saveAction: [ self editSaveMethod ];
		whenResetDo: [
			methodSourcePresenter text:
					methodSourcePresenter methodService source.
			methodSourcePresenter isModified: false ].
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
	packageListPresenter := JadeiteListPresenter newNameSortedList.
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
	packageMethodListPresenter := JadeiteListPresenter new.
	self whenBuiltDo: [ self addStyle: 'jadedTextBackgroundColor' ]
]

{ #category : 'initialization' }
JadeiteBrowserPresenter >> initializeProjectListPresenterIn: tabs [

	projectListPresenter := JadeiteListPresenter new
		                        display: [ :projectService | 
			                        projectService name ];
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
JadeiteBrowserPresenter >> isCategorySelected [
	^self categoryListPresenter selectedItem isNotNil
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isClassDefinitionTabSelected [
	^textAreaTabs currentCard name = 'classDefinition'
]

{ #category : 'testing' }
JadeiteBrowserPresenter >> isClassHierarchyTabSelected [
	^classHierarchyTabs currentCard name = 'classHierarchy'
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
JadeiteBrowserPresenter >> issueCommand: service [

	^BrowserUpdate current issueCommand: service session: gciSession
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> jadeDebug [
	BrowserUpdate current inUpdateWhile: [self jadeExecuteAndDisplay: false shouldDebug: true]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> jadeInspect [
	| inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector evaluateSelectedTextIn: methodSourcePresenter
		thenInspectInContext: self inspectorContextObject
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> makeSameSelectionsIn: newPresenter as: previousPresenter [
	| projectService packageService dictionaryService classService isMeta methodService |
	projectService := previousPresenter projectListPresenter selectionIfNone: [].
	packageService := previousPresenter packageListPresenter selectionIfNone: [].
	dictionaryService := previousPresenter dictionaryPresenter selectionIfNone: [].
	classService := previousPresenter selectedClass.
	classService
		ifNotNil: 
			[isMeta := classService meta.
			methodService := previousPresenter methodListPresenter selectionIfNone: []].
	projectService ifNil: [^self].
	newPresenter gotoProjectNamed: projectService name.
	packageService
		ifNil: 
			[dictionaryService
				ifNil: [^self]
				ifNotNil: [newPresenter gotoDictionaryNamed: dictionaryService name]]
		ifNotNil: [newPresenter gotoPackageNamed: packageService name].
	classService ifNil: [^self].
	newPresenter updateAfterFindClass: classService.
	previousPresenter isHierarchyTabSelected ifTrue: [newPresenter classHierarchyTabs lastCard].
	isMeta ifTrue: [newPresenter selectClassTab].
	methodService ifNil: [^self].
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

{ #category : 'api-events' }
JadeiteBrowserPresenter >> methodSelectionChanged [

	self resetStatusBar.
	self updateMethodSource.
	[self methodSourcePresenter methodService:
		self methodListPresenter selectedItem] on: Error do:[:ex | ^self "spec2 has bugs"].
	methodListPresenter selections isEmpty ifTrue: [
		^ textAreaTabs selectPage: classDefinitionPage ].
	methodListPresenter selections size = 1 ifTrue: [
		self selectMethodSourceTab ].
	self isComparisonTabSelected ifTrue: [ ^ self ].
	methodListPresenter selections size > 1 ifTrue: [
		self todo: [
			self updateMultiMethodComparison.
			self displayMultipleCategories.
			self selectComparisonTab ] ].
	methodListPresenter selectedItem ifNil: [
		definedMethodPackageText text: String new.
		methodCategoryText text: String new ]
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

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> methodsUpdate: classService [

	classService meta = self isClassSideSelected ifFalse: [ ^ self ].
	classListPresenter list isEmpty ifTrue: [
		classService initializePresenterList: methodListPresenter ].
	classService displayMethodsOn: methodListPresenter browser: self.
	methodListPresenter selections isEmpty ifTrue: [
		self setDefaultMethod.
		definedMethodPackageText text: String new.
		methodCategoryText text: String new ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> moveMethods: methodServices toCategory: targetCategory [
	| classService |
	classService := self selectedClass.
	self selectCategoriesNamed: (categoryListPresenter selections copyWith: targetCategory).
	classService
		command: #moveMethods:to:;
		commandArgs: (Array with: methodServices with: targetCategory).
	self issueCommand: classService.
	self selectMethodsFrom: classService
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> moveMethodsToPackageNamed: packageName [
	| packageServiceToSelect selectedClass selectedMethods newSelectedMethods |
	methodListPresenter selections isEmpty ifTrue: [^self].
	selectedClass := self selectedClass.
	selectedMethods := methodListPresenter selections.
	self selectedClass
		command: #moveMethodSelectors:toPackageNamed:;
		commandArgs: (Array with: (selectedMethods collect: [:methodService | methodService selector])
					with: packageName).
	self issueCommand: self selectedClass.
	packageServiceToSelect := packageListPresenter list
				detect: [:packageService | packageService name = packageName] ifNone:[^self].
	packageListPresenter selections: (self selectedPackageServices asOrderedCollection
				add: packageServiceToSelect;
				yourself).
	self selectClassNamed: selectedClass name.
	newSelectedMethods := selectedMethods select:[:oldSelMethod | methodListPresenter list includes: oldSelMethod]. 
	methodListPresenter selections: newSelectedMethods.
	self view invalidate
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
	BrowserUpdate current removeEventsTriggeredFor: packageGroupPresenter
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> onViewOpened [
	super onViewOpened.
	BrowserUpdate current logComment: 'Opening Projects Browser {' , self identityHash printString , '}'.
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
JadeiteBrowserPresenter >> projectLog [
	projectListPresenter selection projectLogUsing: self session: gciSession

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

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> projectTabLabel [

	"Selections get mixed up switching between system presenters unless the tabs
	have a unique label. Rather silly, but we'll give the tab a unique number"

	| cardNumber labelString numberedLabelString label |
	labelString := self basicProjectTabLabel. 
	cardNumber := self parentPresenter view cards indexOf: self view.
	numberedLabelString := cardNumber printString , ' ' , labelString.
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
JadeiteBrowserPresenter >> pullFromGit [
	| projectServices ws |
	projectServices := projectListPresenter selections.
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox
		confirm: 'It is recommended that you commit changes before doing a pulling projects - ' , ws contents
				, ' -  from git. Really proceed?')
			ifFalse: [^self].
	projectServices do: [:service | service command: #pullFromGit].
	self issueCommands: projectServices
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> queryCommand: aCommandQuery [
	| command |
	command := aCommandQuery command.
	#openJadeiteProjectsBrowser = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	#loadProject = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	command = #beginTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isBeginTransactionEnabled.
			^true].
	command = #flipAutoCommit
		ifTrue: 
			[aCommandQuery isEnabled: self transactionMode = #autoBegin.
			^true].
	command = #beginTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isBeginTransactionEnabled.
			^true].
	command = #commitTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isCommitEnabled.
			^true].
	(#(#inspectGlobal #browseGlobalClass #browseGlobalReferences) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: globalsTab selections isEmpty not.
			^true].
	(#(#removeDictionaries) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self dictionaryPresenter selections notEmpty.
			^true].
	#browseMethodHistory = command
		ifTrue: 
			[| selections |
			selections := self methodListPresenter selections.
			aCommandQuery isEnabled: (selections size = 1 and: [selections first hasMethodHistory]).
			^true].
	(#(#reformatSource) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self methodListPresenter selections size <= 1.
			^true].
	#gitCommit == command
		ifTrue: 
			[aCommandQuery isEnabled: self allSelectedProjectsDirty.
			^true].
	#createNewProject = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	(self projectMenuCommands includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (self isProjectItemEnabled: command).
			^true].
	#gotoDictionary = command
		ifTrue: 
			[self updateClassMenu: nil.
			self selectedClass
				ifNil: 
					[aCommandQuery isEnabled: false.
					^true].
			self isNoneProjectSelected
				ifTrue: 
					[aCommandQuery isEnabled: false.
					^true].
			aCommandQuery isEnabled: true.
			^true].
	(#(#browseInstVarReaders #browseInstVarWriters) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self variableListPresenter selections size = 1.
			^true].
	#expandFullHierarchy = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	(#browseSelectedCategoryMethods = command or: [#fileOutCategories = command])
		ifTrue: 
			[aCommandQuery isEnabled: categoryListPresenter selections notEmpty.
			^true].
	#inspectMethod = command
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections size = 1.
			^true].
	#fileOutSelectedMethods = command
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
			^true].
	command == #editDelete
		ifTrue: 
			[aCommandQuery isEnabled: methodSourcePresenter hasSelection.
			^true].
	#checkoutTag == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: self isNoneProjectSelected not.
			^true].
	#gotoPackageDictionary = aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: (packageListPresenter selectionIfNone: []) ~~ nil.
			^true].
	(#(#unloadProjects #reloadProject) includes: aCommandQuery command)
		ifTrue: 
			[self halt.
			aCommandQuery isEnabled: ((Array with: RowanService notRowanizedPackageName with: 'UnPackaged')
						includes: self selectedProjectName).
			^true].
	^super queryCommand: aCommandQuery
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refresh [
	self refreshFromServer
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> refreshClass [

	| selection presenter classTabPresenter |
	self selectedClassTab ifNil: [ ^ self ].
	classTabPresenter := self selectedClassTab activePresenter ifNil: [
		                     self selectedClassTab retrievePresenter ].
	classTabPresenter selectedItem ifNil: [ self clearMethodPresenters ].
	methodListPresenter selectedItem ifNil: [ 
	textAreaTabs selectPage: classDefinitionPage].
	presenter := self isClassListTabSelected
		             ifTrue: [ classListPresenter ]
		             ifFalse: [ classHierarchyPresenter ].
	self todo: [ self setMethodFilterFor: presenter ].
	selection := presenter selectionIfNone: [
		             ^ self noClassSelectedInEitherPresenter ifTrue: [
			               self resetClassTemplate.
			               self resetDefinedClassPackage ] ].
	BrowserUpdate current isApplyingUpdates ifTrue: [ ^ self ].
	selection wasRemoved ifTrue: [ ^ self ].
	selection meta: self isClassSideSelected.
	self isNoneProjectSelected ifFalse: [
		selection
			selectedPackageServices: packageListPresenter selections
			browser: self ].
	selection
		updateAfterCommand: false;
		command: #fastRefresh.
	self issueCommand: selection.
	self isHierarchyTabSelected ifTrue: [
		self expandSelectionOneLevel: selection ].
	selection updateAfterCommand: true.

	self updateClassInfo.
	self methodSelectionChanged
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refreshFromServer [
	| services |
	services := OrderedCollection new.
	services addAll: projectListPresenter selections.
	services addAll: packageListPresenter selections.
	classListPresenter selectedItem ifNotNil: [:classService | services add: classService].
	classHierarchyPresenter selectedItem ifNotNil: [:classService | services add: classService].
	services addAll: methodListPresenter selections.
	self updateServices: services.
	self updateSUnitTab.
	self todo:[self updateProjects.	"don't like this double round trip, but also don't want RowanBrowserService to have to understand update on the server" "is this necessary?"]. 
	self redrawAllViews
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refreshFromServerAfterAbort: browserService [

	self gciSession autoCommit:
		(self gciSession autoCommit value == #failed
			 ifTrue: [ true ]
			 ifFalse: [ self gciSession autoCommit value ])
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> refreshMethodsOn: presenter [

	| classService | 
	classService := self selectedClass ifNil: [ ^ self ].
	classService meta: self isClassSideSelected.
	self isCategoryTabSelected
		ifTrue: [ classService filters: categoryListPresenter selections ]
		ifFalse: [
			self isVariablesTabSelected
				ifTrue: [ classService filters: variableListPresenter selections ]
				ifFalse: [
				classService filters: packageMethodListPresenter selections ] ].
	classService displayMethodsOn: presenter browser: self.
	
	methodListPresenter selections 
		isEmpty ifTrue: [
			methodCategoryText text: String new.
			definedMethodPackageText text: String new ]
		ifFalse: [ self updateMethodSource ]
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

	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #classHierarchyUpdate:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #updatedClass:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #updatedClassInHierarchy:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #removedClass:.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #removed:.
	"BrowserUpdate current
		register: classHierarchyPresenter
		selector: #updatedOneLevelInClassHierarchy:browser:
		browser: self <<< Needed?"
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerClassListForUpdates [

	BrowserUpdate current
		register: classListPresenter
		selector: #classesUpdate:browser:
		browser: self.
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerFilterListsForUpdates [

	BrowserUpdate current
		register: categoryListPresenter
		selector: #filterUpdate:browser:
		browser: self.
	BrowserUpdate current
		register: variableListPresenter
		selector: #filterUpdate:browser:
		browser: self
]

{ #category : 'registration' }
JadeiteBrowserPresenter >> registerMethodPresentersForUpdates [

	BrowserUpdate current
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

	BrowserUpdate current
		register: packageListPresenter
		selector: #projectPackagesUpdate:browser:
		browser: self.
	BrowserUpdate current
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

	BrowserUpdate current
		register: projectListPresenter
		selector: #projectsUpdate:browser:
		browser: self;
		register: projectListPresenter selector: #removedProject:;
		register: projectListPresenter selector: #newProject:;
		register: projectListPresenter selector: #projectsUpdate:;
		register: projectListPresenter selector: #removed:
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeAppropriateTab [
	self isNoneProjectSelected ifTrue: [self removeProjectTabs] ifFalse: [self removeGlobalsTab]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> removeClass [
	| classService answeringService classReferenceBrowser queryService |
	classService := self selectedClass ifNil: [^self].
	answeringService := RowanAnsweringService new.
	answeringService
		command: #classHasSubclasses:;
		commandArgs: (Array with: classService oop).
	self issueCommand: answeringService.
	answeringService answer ifTrue: [^MessageBox notify: 'Cannot remove class with subclasses'].
	(self selectedDictionaryOrPackage confirmClassRemoval: classService) ifFalse: [^self].
	queryService := self basicBrowseClassReferences: classService name session: self gciSession.
	queryService hasResults
		ifTrue: [classReferenceBrowser := self browseClassReferences: classService name].
	self basicRemoveClass: classService.
	queryService hasResults
		ifTrue: 
			[MessageBox notify: classService name
						, ' was removed. You will need to remove references to the class or your code may not load in the future.'].
	^classReferenceBrowser
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
	(MessageBox confirm: 'Really remove package(s)?') ifFalse: [^self].
	projectService := projectListPresenter selection.
	projectService
		command: #removePackagesNamed:;
		commandArgs: (Array with: packageListPresenter selections).
	self issueCommand: projectService
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

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectClassHierarchyTab [
	self todo:[classHierarchyTabs lastCard]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectClassListTab [
	self todo:[classHierarchyTabs firstCard]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectDictionaryNamed: dictionaryName [
	| dictionaryService |
	dictionaryService := dictionaryListPresenter list detect: [:service | service name = dictionaryName]
				ifNone: [^self].
	dictionaryListPresenter selections: (Array with: dictionaryService)
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectMethodSourceTab [
	| methodSourceTab selection |
	methodListPresenter selectionOrNil ifNotNil: [ textAreaTabs  selectPage: methodSourcePage].
	
	
	self todo:[selection := self isCategoryTabSelected
				ifTrue: [categoryListPresenter selectionOrNil]
				ifFalse: [variableListPresenter selectionOrNil].
	selection
		ifNotNil: 
			[methodSourceTab ensureVisible.
			methodListPresenter selectionOrNil ifNil: [methodSourcePresenter setDefaultMethod]]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectNewPackage: newPackage [
	| thePackageService | 
	thePackageService := packageListPresenter list
				detect: [:packageService | packageService name = newPackage] ifNone:[^self].
	packageListPresenter selection: thePackageService
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectNoneProject [
	"get rid of none project"
	self todo:[projectListPresenter selection: (projectListPresenter list
				detect: [:projectService | projectService name = RowanProjectService noneProject name])]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectPackageNamed: packageName [
	| answeringService service |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageNamed:;
		commandArgs: (Array with: packageName).
	self issueCommand: answeringService.
	service := answeringService answer.
	service selectIn: self
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectPackageOrDictionaryFor: classService [
	| answeringService service |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageOrDictionaryFor:;
		commandArgs: (Array with: classService).
	self issueCommand: answeringService.
	service := answeringService answer.
	service selectIn: self
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectProjectNamed: projectName [
	| projectService |
	projectService := projectListPresenter list detect: [:service | service name = projectName]
				ifNone: [^self].
	projectListPresenter selections: (Array with: projectService).
	^projectService "return for testing"
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectProjectTab [
	self selectSourceTabNamed: 'projectInfoTab'
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedClassTab [

	^ classListHierarchyTabs ifNotNil: [ classListHierarchyTabs currentCard ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedDictionaryNames [
	^dictionaryListPresenter selections collect: [:dictionaryService | dictionaryService name]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedDictionaryOrPackage [
	^self isNoneProjectSelected
		ifTrue: [dictionaryListPresenter selectedItem]
		ifFalse: [packageListPresenter selectedItem]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedFilters [
	^self isCategoryTabSelected
		ifTrue: [categoryListPresenter selections]
		ifFalse: 
			[self isVariablesTabSelected
				ifTrue: [variableListPresenter selections]
				ifFalse: [packageMethodListPresenter selections]]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedGlobalName: selection [
	| string rs |
	rs := ReadStream on: (selection at: 1).
	rs upTo: $..
	string := rs upToEnd.
	^string
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedPackageNames [
	^packageListPresenter selections collect: [:packageService | packageService name]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedPackageServices [
	^packageListPresenter selectedItems
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> selectedProjectName [
	^(projectListPresenter selectionOrNil ifNil: [^nil]) name
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> setCompileErrorColor [
	statusBarText view backcolor: Color red faded
]

{ #category : 'private' }
JadeiteBrowserPresenter >> setDefaultMethod [

	methodSourcePresenter value: self defaultMethod
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

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateAfterFindClass: classService [

	| projectService |
	classService ifNil: [ ^ self ].
	classService projectName ifNil: [ self updateService: classService ].
	classService projectName ifNil: [ ^self "could not be updated" ].
	projectService := projectListPresenter list
		                  detect: [ :service |
		                  service name = classService projectName ]
		                  ifNone: [
			                  ^ self "may not be found if class is not in symbol list but class visible in a debugger (currently)" ].
	projectListPresenter selection: projectService.
	projectListPresenter refresh.
	self isDictionaryTabSelected ifTrue: [
		self updateAfterFindClassInDictionary: classService ].
	self updateAfterFindClassInPackage: classService
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
	packageListPresenter list detect: [:service | service name = classService definedPackageName]
		ifNone: [self projectListPresenter selectionByIndex: 0	"display full list of packages"].
	self selectPackageOrDictionaryFor: classService.
	classService meta == true ifTrue: [self selectClassTab].
	self isClassListTabSelected
		ifTrue: [self selectClassNamed: classService name asString]
		ifFalse: 
			[self selectClassInClassListNamed: classService name.
			classHierarchyPresenter model asBag detect: [:svc | svc name = classService name]
				ifNone: [self updateHierarchy].
			self selectClassNamed: classService name]
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
	self issueCommand: browserService
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateDictionary [
	self isPackageListTabSelected  ifTrue:[^self]. 
	packageListPresenter selections isEmpty ifTrue:[
	classListPresenter model: ListModel new].
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
		ifTrue: [ dictionaryListPresenter selections isEmpty ifTrue: [ ^ self ] ]
		ifFalse: [
			projectListPresenter selectionOrNil ifNil: [ ^ self ].
			packageListPresenter selections isEmpty ifTrue: [ ^ self ] ].
	Cursor wait showWhile: [
		service := classListPresenter selectionOrNil ifNil: [
			           ^ self updateHierarchyForPacktionaries ].
		BrowserUpdate current applyUpdateWhile: [
			service
				updateAfterCommand: false;
				command: #classHierarchy.
			self issueCommand: service.
			self selectClassNamed: service name ] ]
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateHierarchyForPacktionaries [
	| service |
	service := RowanBrowserService new.
	self isNoneProjectSelected
		ifTrue: 
			[service
				command: #classHierarchyForDictionariesNamed:;
				commandArgs: (Array with: self selectedDictionaryNames)]
		ifFalse: 
			[service
				command: #classHierarchyForPackagesNamed:;
				commandArgs: (Array with: self selectedPackageNames)].
	self issueCommand: service
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

	BrowserUpdate current isApplyingUpdates ifTrue: [
		^ self ].
	methodSourcePresenter view isModified ifTrue: [ ^ self ].
	self sundryCleanup.
	methodListPresenter selections isEmpty ifTrue: [
		definedMethodPackageText text: String new.
		methodCategoryText text: 'Category: '.
		self todo: [ ^ self methodSourcePresenter setDefaultMethod ] ].
	self updateServices: methodListPresenter selections.
	methodListPresenter selections isEmpty ifTrue: [ ^ self ].
	self updateMethodSourceGlyphs.
	definedMethodPackageText text:
		'Defined Package: '
		, methodListPresenter selectedItem definedPackage.
	methodCategoryText text:
		'Category: ' , methodListPresenter selectedItem category.
	self todo: [
		methodListPresenter selections size > 1
			ifTrue: [
				self updateMultiMethodComparison.
				self displayMultipleCategories ]
			ifFalse: [
				self showSuperClassComparison.
				self updateSingleMethodSource.
				methodCategoryText value:
					'Category: ' , methodListPresenter selection category ].
		self updateSUnitTab.
		self displayUncompilableSourceIn: methodSourcePresenter ]
]

{ #category : 'as yet unclassified' }
JadeiteBrowserPresenter >> updateMethodSourceColor [
	"not sure why, but presenters do not seem to acknowledge that keys
	like 'Del' actually change the value. This hook, sent from #textChanged
	event makes sure we show a visible change when those characters are
	pressed.

	#postToInputQueue sent so that we don't get a gpFault if done at the 
	wrong time. That's presumably a dolphin bug."

	
	[methodSourcePresenter view isModified
		ifTrue: [methodSourcePresenter view backcolor: JadeiteTextStyles default colorForUnsavedEdits]
		ifFalse: [methodSourcePresenter view backcolor: JadeiteTextStyles default colorForNoEdits].
	methodSourcePresenter view invalidate]
			postToInputQueue
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updatePackage [
	self resetClassComment.
	packageListPresenter selections isEmpty ifTrue:[^self]. 
	classListPresenter model: ListModel new.
	self todo:[classHierarchyPresenter model: JadeiteTreeModel new].
	self updateClasses.
	self isClassListTabSelected ifFalse: [self updateHierarchy].
	self updatePackageInfo.
	self resetSunitTestList.
	packageListPresenter selectionIfNone: [self selectProjectTab].
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
JadeiteBrowserPresenter >> updateProject [
	self clearComponentList.
	self projectListPresenter selectionIfNone: [
		packageListPresenter clear.
		dictionaryListPresenter clear.
		self cleanupProjectInfoTab.
		self updateTabLabel.
		^ self ].
	self todo: [ classHierarchyPresenter model: JadeiteTreeModel new ].
	self packageListPresenter selectionIfNone: [
		classListPresenter clear.
		classHierarchyPresenter clear ].
		self buildPackageList.
		self updateTabLabel.
		self basicUpdateProject 
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

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateProjectReadMe [
	| service |
	service := RowanFileService new
				command: #readmeContents;
				path: self projectReadmePath. 
	self issueCommand: service.
	projectReadMeTab value: service answer replaceLfWithCrLf
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateProjects [
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	BrowserUpdate current issueCommand: browserService  session: gciSession.
	projectListPresenter items: browserService projects
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateService: service [
	^self updateServices: (Array with: service) 
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateSystemTab [
	| projectTabLabel | 
	projectTabLabel := self projectTabLabel.
	self view arrangement: projectTabLabel.
	self parentPresenter view updateTabs
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateTabLabel [
 	self owner ifNotNil:[
		self updateSystemTab]
]

{ #category : 'updates' }
JadeiteBrowserPresenter >> updateTabs [
	self halt. 
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
