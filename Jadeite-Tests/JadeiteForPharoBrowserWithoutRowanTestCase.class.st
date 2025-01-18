Class {
	#name : 'JadeiteForPharoBrowserWithoutRowanTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> saveClass: className superclass: superName instVars: instVars category: aString [
	self projectsPresenter classDefinitionPresenter
		value: superName, ' rwSubclass: ', className printString, '
	instVarNames: ' , instVars printString
				, '
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ', aString printString, '
	options: #()'.
	^self projectsPresenter editSaveClass
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanAnsweringService [
	" A little weird but select the answering service twice. 
	The first selection may reset the class category which causes
	a refresh in the class list and the test can't keep up (but manually can)"

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter.
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1Class [
	"big assumption - RowanSample1 class will always be in RowanSample1 project"

	self
		selectServiceNamed: 'SampleSymbolDict'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: RowanClassCategoryService new nilCategoryDisplayName;
			 substringIndex: 1;
			 yourself).
	self classCategoryPresenter selectedItem ifNil: [
			self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'RowanSample1-Core';
			 substringIndex: 2;
			 yourself).
		  ].
	self
		selectServiceNamed: self sampleClassName
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1Test [

	self selectRowanSample1TestIn: self projectsPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1TestIn: browser [

	self
		selectServiceNamed: 'SampleSymbolDict'
		in: browser dictionaryListPresenter.
	browser classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: RowanClassCategoryService new nilCategoryDisplayName;
			 substringIndex: 1;
			 yourself).
	browser classCategoryPresenter selectedItem ifNil: [
		browser classCategoryPresenter selectItem:
			(RowanClassCategoryService new
				 name: 'RowanSample1-Test';
				 substringIndex: 2;
				 yourself) ].
	self
		selectServiceNamed: 'RowanSample1Test'
		in: browser classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanServicesPackage [
	"no package list"
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectServicesNamed: services in: presenter [
	"no selection done for package list. Not used in JfPwoR"

	self packageListPresenter == presenter ifTrue: [ ^ self ].
	(self projectListPresenter == presenter and: [
		 services first = 'RowanSample1' ]) ifTrue: [
		^ super selectServicesNamed: #( 'SampleSymbolDict' ) in: presenter "think/hope we only select one package at a time in practice" ].
	(self projectListPresenter == presenter and: [
		 services first = 'Rowan' ]) ifTrue: [
		^ super selectServicesNamed: #( 'Published' ) in: presenter ].
	^ super selectServicesNamed: services in: presenter
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> setUp [

	super setUp.
	JadeitePreferences isRowanLoaded: false.
	self setupProjectBrowser
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_browseClass [
	"project browser opened in setup"

	projectsBrowser ifNotNil: [
		self closeBrowser: projectsBrowser.
		self setupProjectBrowser ].
	self assert: projectsBrowser class equals: JadeiteBrowserWithoutRowan.
	self denyIsNil: (self dictionaryListPresenter list
			 detect: [ :projectService | projectService name = 'RowanKernel' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classDefUpdatesOnClassCategoryChange [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Tests''
	options: #()' trimBlanks replaceCrWithLf.

	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 3;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Core''
	options: #()' trimBlanks replaceCrWithLf.

	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services';
			 substringIndex: 2;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services''
	options: #()' trimBlanks replaceCrWithLf.

	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan';
			 substringIndex: 1;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan''
	options: #()' trimBlanks replaceCrWithLf.

	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Tests''
	options: #()' trimBlanks replaceCrWithLf.
	self projectsPresenter selectClassNamed: 'RowanAnsweringServiceTest'.
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals:
			'RowanServicesTest rwSubclass: ''RowanAnsweringServiceTest''
	instVarNames: #( service)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Tests''
	options: #()' trimBlanks replaceCrWithLf
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_findClass [

	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform')
		onCompletion: nil.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RwGsPlatform'.
	self
		assert: self classListPresenter selectedItem definedPackageName
		equals: 'Rowan-GemStone-Core'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanKernel'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: 'Rowan-GemStone-Core'.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'CypressClassDefinition')
		onCompletion: nil.
	self
		assert: self classListPresenter selectedItem name
		equals: 'CypressClassDefinition'.
	self
		assert: self classListPresenter selectedItem definedPackageName
		equals: 'Cypress-Definitions'.
	self
		assert: self dictionaryListPresenter selectedItem name 
		equals: 'Globals'.
	self
		assert: self classCategoryPresenter selectedItem name 
		equals: 'Cypress-Definitions'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_findClassWithNilClassCategory [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self jadeiteTestResourceClass current createRowanSample1Project.
	self projectsPresenter findClassNamed: 'RowanSample1'.
	self
		assert: self classCategoryPresenter roots first name
		equals: 'no class category'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService new nilCategoryDisplayName.
	self assert: self classListPresenter items size equals: 2.
	self
		assert: self classListPresenter items first name
		equals: 'RowanSample1'.
	self
		assert: self classListPresenter items second name
		equals: 'RowanSample1Test'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanSample1'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_hierarchyExpansion [

	| hierarchyModel names |
	self todo: 'Not a great test of expansion in JfPwoR. Fix later.'.
	self
		testsIssue: #issue156
		withTitle: 'Double click on hierarchy class should expand list #156'.
	self
		selectServicesNamed: (Array with: 'RowanKernel')
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan';
			 substringIndex: 1;
			 yourself).
	names := self classListPresenter model collection collect: [
		         :classService | classService name ].
	self assert: (names includes: 'RwPlatform').
	self selectHierarchyTab.
	(Delay forMilliseconds: 500) wait.
	hierarchyModel := self classHierarchyPresenter model.

	self assert: hierarchyModel first name equals: 'Object'.
	
	hierarchyModel := self classHierarchyPresenter childrenFor:
		                  hierarchyModel first.
	self denyIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'RwPlatform' ]
			 ifNone: [  ]).
	self assertIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'RwGsPlatform' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_nilClassCategory [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self jadeiteTestResourceClass current createRowanSample1Project.
	self
		selectServiceNamed: 'SampleSymbolDict'
		in: self dictionaryListPresenter.
	self assert:
		self classCategoryPresenter roots first name = 'no class category'.
	self assert: self classListPresenter items size equals: 0.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: String new;
			 substringIndex: 1;
			 yourself).
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService new nilCategoryDisplayName.
	self assert: self classListPresenter items size equals: 2.
	self
		assert: self classListPresenter items first name
		equals: 'RowanSample1'.
	self
		assert: self classListPresenter items second name
		equals: 'RowanSample1Test'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_runTestInBrowser [

	| methodService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		selectServiceNamed: 'test_disableBreakpointsInterface'
		in: self methodListPresenter.
	methodService := self methodListPresenter selectedItem.
	self
		assert:
			(self projectsPresenter methodListPresenter displayIcon value:
				 methodService) labelGraphic
		equals: (Smalltalk ui icons iconNamed: #testNotRun).
	self projectsPresenter debugMethodTests: (Array with: methodService).
	(Delay forMilliseconds: 500) wait. "arbitrary wait could be improved. "
	self
		assert:
			(self projectsPresenter methodListPresenter displayIcon value:
				 methodService) labelGraphic
		equals: (Smalltalk ui icons iconNamed: #testGreen)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClass [
	| classService | 
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	classService := RowanClassService new name: 'TestClass'; meta: false. 
	self assert: (self dictionaryListPresenter selectedItem classes includes: classService)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassChangedCategory [

	| classService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests';
				 substringIndex: 3).
	classService := RowanClassService new
		                name: 'TestClass';
		                meta: false.
	self assert:
		(self dictionaryListPresenter selectedItem classes includes:
			 classService).
	"----------------Change the category and see if the category selection changes ------------------"
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Core'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Core';
				 substringIndex: 3)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassInHierarchy [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self selectHierarchyTab.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self assert: self classCategoryPresenter selectedItem equals:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassInHierarchyChangedCategory [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self selectHierarchyTab.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self assert: self classCategoryPresenter selectedItem equals:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	"----------------Change the category and see if the category selection changes ------------------"
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Core'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Core';
				 substringIndex: 3)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassNewCategory [
	"test won't work until Rowan Stub is available. 
Even then it may not work as the test has never been successfully run"
	true ifTrue: [ ^self ].
	self selectServiceNamed: 'Globals' in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Kernel';
			 substringIndex: 1;
			 yourself).
	self selectServiceNamed: 'Array' in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'Array'.
	self
		saveClass: 'TestClassWithNewCategory'
		superclass: 'Object'
		instVars: #( 'test_saveClassNewCategory' )
		category: 'Rowan-Services-Tests-NewCategory'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClassWithNewCategory'.
	self assert:
		('Object rwSubclass: ''TestClassWithNewCategory''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests-NewCategory';
				 substringIndex: 4)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_selectClassButCategoryIsUnchanged [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 2;
			 yourself).
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem firstSubstringsToIndex
		equals: 'Rowan-Services'.
	self
		assertIsNil: self classListPresenter selectedItem. 
		
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem firstSubstringsToIndex
		equals: 'Rowan-Services'. "not changed to Rowan-Services-Core"
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_selectClassCategory [
	"basic test to just ensure class category presenter gets correct selection"

	self selectRowanAnsweringService.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Core'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_selectClassCategoryInSamePath [
	"should be able to select a new class category higher in the path
	without losing the selection"

	self selectRowanAnsweringService.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Core'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.

	"in hierarchy don't lose selection"
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 2; "Rowan-Services"
			 yourself).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 1; "Rowan"
			 yourself).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.

	"not in hierarchy, selection cleared"
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self assertIsNil: self classListPresenter selectedItem
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_twoBrowsersAddSameCategoryToClassAndInstance [

	self
		testsIssue: #issue418
		withTitle:
			'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight';
		selectRowanSample1Test;
		selectHierarchyTab;
		openSecondBrowser.
	(Delay forMilliseconds: 500) wait.
	self
		selectRowanSample1TestIn: secondPresenter;
		selectHierarchyTabIn: secondPresenter;
		selectClassSide;
		deny:
			(self projectsPresenter categoryListPresenter list includes:
					 'fnoodle');
		deny:
			(secondPresenter categoryListPresenter list includes: 'fnoodle').
	self assert: self projectsPresenter isClassSideSelected.
	self projectsPresenter basicAddMethodCategory: 'fnoodle'.
	self
		assert: self projectsPresenter categoryListPresenter selectedItem
		equals: 'fnoodle';
		deny:
			(secondPresenter categoryListPresenter list includes: 'fnoodle').
	self deny: secondPresenter isClassSideSelected.
	secondPresenter basicAddMethodCategory: 'fnoodle'.
	self
		assert: secondPresenter categoryListPresenter selectedItem
		equals: 'fnoodle';
		assert: (self categoryListPresenter list includes: 'fnoodle')
]
