Class {
	#name : 'JadeiteSUnitPresenter',
	#superclass : 'JadeiteSUnitAbstractPresenter',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait + JadeiteClassTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait + JadeiteClassTrait classTrait',
	#instVars : [
		'packageListPresenter',
		'classListPresenter',
		'status',
		'testCounter',
		'methodColumns',
		'toolbar',
		'testSemaphore'
	],
	#category : 'Jadeite-SUnitBrowser',
	#package : 'Jadeite-SUnitBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter class >> defaultAdditionalAccelerators [

	^super defaultAdditionalAccelerators , #(#(#debug 'Ctrl+Shift+B'))
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> activePresenter [
	"only presenter is myself"
	^self	
]

{ #category : 'menus' }
JadeiteSUnitPresenter >> addSUnitMethodListMenuItems [

	self methodListPresenter contextMenu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Run All';
					icon: (self iconNamed: #glamorousSpawn);
					action: [ self runAll ] ];
			addItem: [ :item |
				item
					name: 'Run Selected';
					icon: (self iconNamed: #glamorousGo);
					action: [ self runSelected ];
					enabled: [ self methodListPresenter selectedItems notEmpty ] ];
			addItem: [ :item |
				item
					name: 'Debug All';
					icon: (self iconNamed: #glamorousSpawn);
					action: [ self debugAll ] ];
			addItem: [ :item |
				item
					name: 'Debug Selected';
					icon: (self iconNamed: #glamorousGo);
					action: [ self debug ];
					enabled: [ self methodListPresenter selectedItems notEmpty ] ] ]
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> addToolbarItemsToMenuGroup: group [

	^ self newJadeiteSUnitToolbar items do: [ :toolbarItem |
		  group addItem: [ :item |
			  item
				  name: toolbarItem label;
				  description: toolbarItem label;
				  icon: toolbarItem icon;
				  action: toolbarItem action ] ]
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> addUpdatedTestClasses: classServices [
	"don't show class unless the package concurs"

	| inSelectedPackage |
	inSelectedPackage := OrderedCollection new.
	packageListPresenter selections do: 
			[:packageService |
			packageService classes
				ifNotNil: 
					[classServices
						do: [:classService | (packageService classes includes: classService) ifTrue: [inSelectedPackage add: classService]]]].
	classListPresenter model addAll: inSelectedPackage
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> basicDelete [

	classListPresenter selection
		command: #removeMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	self issueCommand: classListPresenter selection onCompletion: [  ]
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> basicRunAll [

	testProcess := [
	               [
	               self reset.
	               methodListPresenter resetSelection.
	               testResults := (classListPresenter selections size > 1
		                               or: [
		                               classListPresenter selections isEmpty ])
		                              ifTrue: [
		                              self runTests:
			                              methodListPresenter model ]
		                              ifFalse: [
			                              self
				                              runTests: methodListPresenter model
				                              in:
				                              classListPresenter selections first
					                              name ] ] ensure: [
		               testSemaphore signal.
		               testProcess := nil.
		               shouldStopTestRun := false ] ] fork
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> basicRunSelected [
	"if multiple classes are selected, we really don't know which test class
	the user intended for the test to be run so pick the class the test is defined in"

	classListPresenter selectedItems isEmpty ifTrue: [ ^ self ].
	testProcess := [
	               [
	               testResults := classListPresenter selections size = 1
		                              ifTrue: [
			                              self
				                              runTests:
				                              methodListPresenter selections
				                              in:
				                              classListPresenter selections first
					                              name ]
		                              ifFalse: [
		                              self runTests:
			                              methodListPresenter selections ] ]
		               ensure: [
			               testSemaphore signal.
			               testProcess := nil.
			               shouldStopTestRun := false ] ] fork
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> browseMethods [
	^self browseSelectedMethods
]

{ #category : 'testing' }
JadeiteSUnitPresenter >> canDiscardEdits [

	^true
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> classHierarchyPresenter [

	"for trait menus"
	^nil
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> classListPresenter [
	^classListPresenter
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> connectPresenters [

	super connectPresenters.
	packageListPresenter whenSelectionChangedDo: [ :selection | 
		self onPackageChanged ].
	classListPresenter whenSelectionChangedDo: [ :selection | 
		self onClassesChanged ]
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> debug [ 
	self debugTests: methodListPresenter selections
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> debugAll [

	self reset.
	methodListPresenter resetSelection.
	self debugTests: methodListPresenter model
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> debugTests: methodServices [

	| className |
	classListPresenter selections isEmpty ifTrue: [ ^ self ].
	className := classListPresenter selections size = 1
		             ifTrue: [ classListPresenter selections first name ]
		             ifFalse: [ nil ].
	[self debugTestMethodServices: methodServices className: className] fork
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> delete [
	| selectors writeStream |
	selectors := methodListPresenter selections collect: [:methodService | methodService selector].
	selectors isEmpty ifTrue: [^self].
	writeStream := WriteStream on: String new.
	writeStream nextPutAll: 'Really delete these test methods?'.
	selectors do: 
			[:symbol |
			writeStream
				cr;
				nextPutAll: symbol].
	MessageBox confirm: writeStream contents
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> editSelectAll [
	^classListPresenter view hasFocus
		ifTrue: [classListPresenter selections: classListPresenter list]
		ifFalse: [super editSelectAll]
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> gciSession: anObject [

	gciSession := anObject
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> getTestCounter [

	^'Total Tests: ', testCounter first printString
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> initializeClassList [
	classListPresenter
		model: (ListModel new list: (SortedCollection sortBlock: [:x :y | x name < y name]))
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> initializeMenuBar [

	^ self newMenuBar addGroup: [ :group |
		  self addToolbarItemsToMenuGroup: group ]
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> initializePresenters [

	| listPresenters |
	super initializePresenters.
	textResultPresenter := (JadeiteTextDocument new text: String new)
		                       beNotEditable;
		                       beNotWrapWord;
		                       withoutLineNumbers.
	self layout
		add: textResultPresenter
		withConstraints: [ :constraints |
			constraints height: 4 * StandardFonts defaultFont pointSize ].
	listPresenters := SpBoxLayout newHorizontal.
	listPresenters spacing: 10.
	self layout add: listPresenters.

	packageListPresenter := JadeiteListPresenter newNameSortedList
		                        headerTitle: 'Packages'.
	listPresenters add: packageListPresenter.
	classListPresenter := JadeiteListPresenter newNameSortedList
		                      headerTitle: 'Classes'.
	classListPresenter beMultipleSelection.
	self initializeBrowseClassMenu.
	listPresenters add: classListPresenter.
	methodListPresenter := JadeiteListPresenter newNameSortedList
		                       headerTitle: 'Test Selector'.
	methodListPresenter
		beMultipleSelection;
		displayIcon: [ :item | item testResultIconForBrowser: self ].
	self initializeBrowseMethodListMenu.
	self addSUnitMethodListMenuItems.
	listPresenters add: methodListPresenter
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent:
		100 @ 60 * StandardFonts defaultFont pointSize.
	self updateCaption.
	aWindowPresenter menu: self initializeMenuBar
]

{ #category : 'testing' }
JadeiteSUnitPresenter >> isClassHierarchyTabSelected [
	"support for class references"
	^false
]

{ #category : 'menus' }
JadeiteSUnitPresenter >> isClassSelected [
	"for updates only" 
	^true
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> isNoneProjectSelected [
	"no concept of dictionaries in sunit browser"

	^false
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> isRowanProjectSelected [
	"no projects in sunit browser" 
	^false
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> isValidClassService: classService [
	^classService isTestCase
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> methodListPresenter [
	^methodListPresenter
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> newJadeiteSUnitToolbar [

	| theToolbar |
	theToolbar := self newJadeiteToolbar.
	theToolbar
		addItem: (SpToolbarButtonPresenter new
				 label: 'Run All';
				 icon: (self iconNamed: #glamorousSpawn);
				 help: 'run all tests in the selected classes';
				 action: [ self runAll ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Run Selected';
				 icon: (self iconNamed: #glamorousGo);
				 help: 'run selected tests';
				 action: [ self runSelected ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Debug All';
				 icon: (self iconNamed: #glamorousSpawn);
				 help: 'debug all tests in the selected classes';
				 action: [ self debugAll ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Debug Selected';
				 icon: (self iconNamed: #glamorousGo);
				 help: 'debug selected tests';
				 action: [ self debug ];
				 yourself).
	^ theToolbar
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> onClassesChanged [

	self todo: [
		classListPresenter selections size > 1
			ifTrue: [ methodListPresenter view columnsList: methodColumns ]
			ifFalse: [
				methodListPresenter view columnsList:
					(Array with: methodColumns second) ] ].
	self updateMethods.
	methodListPresenter view resortOnLastColumnClicked.
	self todo: [
		status value: nil.
		status value: self ].
	self reset
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> onPackageChanged [

	self updateClassesOnCompletion: [
		self todo: [
			status value: nil.
			status value: self ].
		self reset.
		classListPresenter unselectAll.
		methodListPresenter list: Array new ]
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> packageListPresenter [
	^packageListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> packagesSize [
	^'Packages: ' , packageListPresenter model size printString
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> refresh [

	| packageSelections classSelections methodSelections |
	packageSelections := packageListPresenter selections.
	classSelections := classListPresenter selections.
	methodSelections := methodListPresenter selections.
	self updateProjectPackagesOnCompletion: nil.
	packageListPresenter selections:
		(packageListPresenter list select: [ :packageService |
			 packageSelections includes: packageService ]).
	classListPresenter selections:
		(classListPresenter list select: [ :packageService |
			 classSelections includes: packageService ]).
	methodListPresenter selections:
		(methodListPresenter list select: [ :packageService |
			 methodSelections includes: packageService ]).
	self reset
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> refreshFromServerAfterAbort: browserService [
	browserService testPackages: packageListPresenter
]

{ #category : 'registration' }
JadeiteSUnitPresenter >> registerPresentersForUpdates [
	RowanServiceUpdater current register: packageListPresenter selector: #testPackages:.
	RowanServiceUpdater current
		register: classListPresenter
		selector: #testClasses:browser:
		browser: self.
	RowanServiceUpdater current
		register: classListPresenter
		selector: #renamedClass:browser:
		browser: self.
	RowanServiceUpdater current register: classListPresenter selector: #removedClass:.
	RowanServiceUpdater current
		register: methodListPresenter
		selector: #sunitMethodsUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: methodListPresenter
		selector: #testResultUpdate:browser:
		browser: self
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> runAll [

	testSemaphore := Semaphore new.
	self basicRunAll
]

{ #category : 'actions' }
JadeiteSUnitPresenter >> runSelected [
	
	testSemaphore := Semaphore new. 
	self basicRunSelected
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> runTestMethodServices: methodServices className: className [
	| jadeResult |
	jadeResult := super runTestMethodServices: methodServices className: className.
	self todo: [self methodListPresenter view ensureSelectionVisible].
	^jadeResult
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectClassNamed: name [
	"for testing at the moment"

	| classService |
	classService := classListPresenter list detect: [:service | service name = name] ifNone: [^self].
	classListPresenter selection: classService
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectMethodNamed: selector [
	"for testing at the moment" 
	| methodService |
	methodService := methodListPresenter list detect: [:service | service selector = selector] ifNone: [^self].
	methodListPresenter selections: (Array with: methodService)
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectMethodsNamed: selectors [
	| methodServices |
	methodServices := methodListPresenter list select: [:service | selectors includes: service selector].
	methodListPresenter selections: (Array with: methodServices)
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectPackageNamed: packageName [
	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = packageName]
				ifNone: [^self].
	packageListPresenter selectItem: packageService
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectPackageNamed: packageName classNamed: className [
	| classService |
	self selectPackageNamed: packageName.
	classService := classListPresenter list detect: [:service | service name asString = className]
				ifNone: [^self].
	classListPresenter selectItem: classService
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectPackageOrDictionaryNamed: name for: anObject [
	"for testing at the moment"

	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = name] ifNone: [^self].
	packageListPresenter selection: packageService
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectedClass [

	^self classListPresenter selectedItem 
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> selectedClassTab [

	"for trait menus"
	^classListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectedFilters [
	"no categories in sunit browser"
	^Array new 
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectedPackageServiceNames [
	^packageListPresenter selections collect: [:packageService | packageService name]
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> selectedPackageServices [
	^packageListPresenter selections
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> setColorFor: aJadeTestResult [

	textResultPresenter value: aJadeTestResult summary.
	aJadeTestResult failures do: [ :eachSymbol | 
		methodListPresenter model do: [ :eachTest | 
			eachTest selector = eachSymbol ifTrue: [ eachTest setFailure ] ] ].
	aJadeTestResult errors do: [ :eachSymbol | 
		methodListPresenter model do: [ :eachTest | 
			eachTest selector = eachSymbol ifTrue: [ eachTest setError ] ] ].
	aJadeTestResult passed do: [ :eachSymbol | 
		methodListPresenter model do: [ :eachTest | 
			eachTest selector = eachSymbol ifTrue: [ eachTest setPassed ] ] ].
	methodListPresenter view invalidate.
	self setResultsPaneColor: aJadeTestResult backgroundColor
]

{ #category : 'constants' }
JadeiteSUnitPresenter >> shellName [
	^'Jadeite SUnit Browser'
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> status [
	^status
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> status: anObject [
	status := anObject
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> testCasesSize [
	^'Test Cases:' , methodListPresenter model size printString
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> testClassesSize [
	^'Test Classes:' , classListPresenter model size printString
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> testResults [
	^testResults
]

{ #category : 'as yet unclassified' }
JadeiteSUnitPresenter >> testResults: anObject [
	^testResults := anObject
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> testSemaphore [

	^ testSemaphore
]

{ #category : 'accessing' }
JadeiteSUnitPresenter >> testSemaphore: anObject [

	testSemaphore := anObject
]

{ #category : 'updates' }
JadeiteSUnitPresenter >> update: newMethods orRemove: removals [
	| listModel |
	methodListPresenter model do: 
			[:existing |
			| new |
			new := newMethods detect: [:newService | newService = existing]
						ifNone: 
							[removals add: existing.
							nil].
			new
				ifNotNil: 
					[existing replicateFrom: new.
					new replicateFrom: existing.
					newMethods remove: new	"order matters so we get the right test result"]].
	listModel := ListModel withAll: ((methodListPresenter model union: newMethods)
						asSortedCollection: [:x :y | x selector < y selector]).
	listModel removeAll: removals. 
	methodListPresenter model: listModel.
	methodListPresenter view invalidate. 
]

{ #category : 'updates' }
JadeiteSUnitPresenter >> updateClassesOnCompletion: completionBlock [

	| packageServices |
	self initializeClassList.
	packageServices := packageListPresenter selections.
	packageServices do: [ :packageService |
		packageService command: #testClasses ].
	RowanServiceUpdater current
		issueCommands: packageServices
		session: self gciSession
		onCompletion: completionBlock
]

{ #category : 'updates' }
JadeiteSUnitPresenter >> updateMethods [

	| classServices |
	classServices := classListPresenter selections.
	RowanServiceUpdater current critical: [
		classServices do: [ :service |
			service
				updateAfterCommand: false;
				command: #fastRefresh;
				commandArgs: Array new ].
		RowanServiceUpdater current
			issueCommands: classServices
			session: self gciSession
			onCompletion: [
				classServices do: [ :service | service updateAfterCommand: true ].
				self updateMethodsFrom: classServices ] ]
]

{ #category : 'updates' }
JadeiteSUnitPresenter >> updateMethodsFrom: classServices [
	| newMethods selectedSelectors removals packageNames |
	classServices isEmpty ifTrue: [^methodListPresenter list: ListModel new].
	selectedSelectors := methodListPresenter selections
				collect: [:methodService | methodService selector].
	removals := OrderedCollection new.
	newMethods := OrderedCollection new.
	classServices do: 
			[:classService |
			| tests |
			"show the class that the test will be run under"
			tests := classService visibleTests.
			tests do: [:methodService | methodService className: classService name].
			newMethods addAll: tests].
	self update: newMethods orRemove: removals.
	packageNames := packageListPresenter selections collect: [:service | service name].
	methodListPresenter model
		do: [:methodService | methodService inSelectedPackage: (packageNames includes: methodService packageName)].
	methodListPresenter selections: (methodListPresenter model
				select: [:methodService | selectedSelectors includes: methodService selector]).
	methodListPresenter view invalidate.
	methodListPresenter view resortOnLastColumnClicked
]

{ #category : 'initialization' }
JadeiteSUnitPresenter >> updatePresenter [

	super updatePresenter.
	testCounter := Array with: 0 with: OrderedCollection new.
	self updateProjectPackagesOnCompletion: [  ]
]

{ #category : 'updates' }
JadeiteSUnitPresenter >> updateProjectPackagesOnCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #packagesWithTests.
	self issueCommand: browserService onCompletion: [
		testCounter at: 1 put: browserService testCount.
		completionBlock value ]
]
