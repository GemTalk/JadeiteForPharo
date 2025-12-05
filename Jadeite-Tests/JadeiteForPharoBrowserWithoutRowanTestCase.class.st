Class {
	#name : 'JadeiteForPharoBrowserWithoutRowanTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoBrowserWithoutRowanTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor.
	Currently don't look at super classes"

	^ {
		  JadeiteBrowserWithoutRowan.
		  JadeiteBrowserPresenterWithoutRowan } asOrderedCollection
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> classHierarchyServices [

	^ self classHierarchyPresenter adapter widget dataSource allShownItems
		  collect: [ :service | service data ]
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> compileClassExpectedClassDefinition [

	^ JadeitePreferences isRowanAvailable
		  ifTrue: [ self jfp_compileClassExpectedClassDefinition ]
		  ifFalse: [ self jfpwor_compileClassExpectedClassDefinition ]
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> jfp_compileClassExpectedClassDefinition [

	^ 'Object rwSubclass: ''TestClass''
	instVarNames: #( abc)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()' replaceCrWithLf
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> jfpwor_compileClassExpectedClassDefinition [

	^ '(Object subclass: ''TestClass''
  instVarNames: #( abc)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
) category: ''Kernel''' replaceCrWithLf
]

{ #category : 'private' }
JadeiteForPharoBrowserWithoutRowanTestCase >> performTest [

	JadeitePreferences isRowanAvailable ifTrue: [
		^ self skip: 'Rowan is available. Test not run' ].
	^ super performTest
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanAnsweringService [

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
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1Class [
	"tests put the sample class in a few locations"

	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: RowanClassCategoryService new nilCategoryDisplayName;
			 substringIndex: 1;
			 yourself).
	self classCategoryPresenter selectedItem ifNil: [
		self classCategoryPresenter selectItem:
			(RowanClassCategoryService new
				 name: 'Kernel';
				 substringIndex: 1;
				 yourself) ].
	self classCategoryPresenter selectedItem ifNil: [
		self classCategoryPresenter selectItem:
			(RowanClassCategoryService new
				 name: 'RowanSample1-Core';
				 substringIndex: 2;
				 yourself) ].
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
		selectServiceNamed: self rowanSampleDictionaryName
		in: browser dictionaryListPresenter.



	browser classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Kernel';
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
		^ super
			  selectServicesNamed: #( self rowanSampleDictionaryName )
			  in: presenter "think/hope we only select one package at a time in practice" ].
	(self projectListPresenter == presenter and: [
		 services first = 'Rowan' ]) ifTrue: [
		^ super selectServicesNamed: #( 'Published' ) in: presenter ].
	^ super selectServicesNamed: services in: presenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> servicesTestsLoaded [

	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self classListPresenter selectedItem ifNil: [ ^ false ].
	^ true
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> setUp [

	super setUp.
	self setupProjectBrowser
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> tearDown [

	GciSession current isValidSession ifTrue: [
		JadeitePreferences isRowanAvailable
		"	ifTrue: [ self unloadSampleProject1 ]"
			ifFalse: [
				JadeiteBrowserPresenter
					basicRemoveDictionaryNamed: self rowanSampleDictionaryName
					onCompletion: [  ] ] ].
	super tearDown
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_abortRemovesCategory [

	| className classCategoryService children |
	true ifTrue: [
			^ self skip:
				  'Test hangs. Need better solutions for abort that does not issue commands in abort events on the client' ].
	className := 'PublishedClass'.
	self selectServiceNamed: 'Published' in: self dictionaryListPresenter.
	self
		saveClass: className
		superclass: 'Object'
		instVars: #(  )
		package: nil
		dictionaryName: 'Published'
		classCategory: ''.
	self
		assert: self classListPresenter selectedItem name
		equals: className.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService nilClassCategory name.
	classCategoryService := self classCategoryPresenter roots first.
	children := self classCategoryPresenter children value:
		            classCategoryService.
	self assert: children size equals: 2.
	self assert: children first name equals: 'STON-Core'.
	self
		assert: children last name
		equals: RowanClassCategoryService nilClassCategory name.
	self abortTransaction.
	self assertIsNil: (self classListPresenter list
			 detect: [ :classService | classService name = className ]
			 ifNone: [ ]).
	self
		assert: self classCategoryPresenter selectedItem name
		equals: 'All'.
	children := self classCategoryPresenter children value:
		            classCategoryService.
	self assert: children size equals: 1.
	self assert: children first name equals: 'STON'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_abstractTestClassesHaveNoRunButton [

	self
		testsJadeiteForPharoIssue: #issue166
		title: 'Running sunit tests from button on class'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/166'.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan';
			 substringIndex: 1;
			 yourself).
	self classListPresenter items do: [ :classService |
		| isAbstract stream |
		stream := WriteStream on: String new.
		stream
			nextPut: $[;
			nextPutAll: classService name;
			nextPutAll: ' isAbstract] on: Error do:[:ex | nil]'.
		isAbstract := session executeString: stream contents.

		isAbstract
			ifNil: [
				self assertIsNil:
					(self classListPresenter displayIcon value: classService) ]
			ifNotNil: [
				isAbstract
					ifTrue: [
						self assertIsNil:
							(self classListPresenter displayIcon value: classService) ]
					ifFalse: [
						self assert:
							((self classListPresenter displayIcon value: classService)
								 isKindOf: IconicButtonMorph) ] ] ]
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
JadeiteForPharoBrowserWithoutRowanTestCase >> test_changeClassCategoryWhenHierarchyViewOpen [

	| canonicalizationClasses canonicalizationHierarchyClasses |
	self projectsPresenter selectDictionaryNamed: 'Globals'.
	self selectClassCategoryNamed: 'Canonicalization'.
	canonicalizationClasses := (self classListPresenter items
		                            asSortedCollection: [ :x :y |
		                            x name < y name ]) asArray.
	canonicalizationClasses do: [ :classService |
		self assert: classService classCategory equals: 'Canonicalization' ].
	self selectHierarchyTab.
	canonicalizationHierarchyClasses := ((self classHierarchyServices
		                                      select: [ :classService |
			                                      self updateService:
				                                      classService.
			                                      classService classCategory
			                                      = 'Canonicalization' ])
		                                     asSortedCollection: [ :x :y |
		                                     x name < y name ]) asArray.
	self
		assert: canonicalizationClasses
		equals: canonicalizationHierarchyClasses.
	self selectClassCategoryNamed: 'Announcements-Core-GemStone-Test'.
	canonicalizationHierarchyClasses := (self classHierarchyServices
		                                     select: [ :classService |
			                                     self updateService:
				                                     classService.
			                                     classService classCategory
			                                     = 'Canonicalization' ])
		                                    asArray.
	self assert: canonicalizationHierarchyClasses isEmpty
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classDefUpdatesOnClassCategoryChange [

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self todo: 'not updated for rowan-stubbed servers yet' ].
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter unselectAll.
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
	self classCategoryPresenter unselectAll.
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
	self classCategoryPresenter unselectAll.
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
	self classCategoryPresenter unselectAll.
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
	self classCategoryPresenter unselectAll.
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
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classDefinitionTemplate [

	JadeitePreferences isRowanAvailable ifTrue: [
		^ self skip:
			  'test_classDefinitionTemplate only available in stubbed image' ].
	self
		testsJadeiteForPharoIssue: #issue418
		title:
		'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/314'.
	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: self dictionaryListPresenter.
	self
		assert: (self projectsPresenter classCategoryPresenter selectedItem
				isKindOf: RowanAllClassCategoryService).
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: '(Object subclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: RowanSample1Dictionary
	options: #()) category:  ''''
' replaceCrWithLf.

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
self
		assert: (self projectsPresenter classCategoryPresenter selectedItem
				isKindOf: RowanAllClassCategoryService).
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: '(Object subclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: RowanClientServices
	options: #()) category:  ''''
' replaceCrWithLf
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classListNotEmptyAfterHierarchy [

	| canonicalizationClasses canonicalizationHierarchyClasses |
	self projectsPresenter selectDictionaryNamed: 'Globals'.
	self selectClassCategoryNamed: 'Canonicalization'.
	canonicalizationClasses := (self classListPresenter items
		                            asSortedCollection: [ :x :y |
		                            x name < y name ]) asArray.
	canonicalizationClasses do: [ :classService |
		self assert: classService classCategory equals: 'Canonicalization' ].
	self selectHierarchyTab.
	canonicalizationHierarchyClasses := ((self classHierarchyServices
		                                      select: [ :classService |
			                                      self updateService:
				                                      classService.
			                                      classService classCategory
			                                      = 'Canonicalization' ])
		                                     asSortedCollection: [ :x :y |
		                                     x name < y name ]) asArray.
	self
		assert: canonicalizationClasses
		equals: canonicalizationHierarchyClasses.
	self selectClassCategoryNamed: 'Announcements-Core-GemStone-Test'.
	self selectClassListTab.
	self deny: self classListPresenter items isEmpty.
	self classListPresenter items do: [ :classService |
		self
			assert: classService classCategory
			equals: 'Announcements-Core-GemStone-Test' ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_compileClass [

	self
		testsIssue: #issue390
		withTitle:
		'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'abc' )
		package: 'RowanSample1-Core'.

	self
		assert: self projectsPresenter selectedClass name
		equals: 'TestClass'.
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: self compileClassExpectedClassDefinition
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_createClassWithDifferentCategorySelected [

	self projectsPresenter selectDictionaryNamed: 'RowanClientServices'.
	self projectsPresenter classDefinitionPresenter text:
		'(Object subclass: ''NewSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: UserGlobals
	options: #()) category: ''NewCategory'''.
	self projectsPresenter classDefinitionPresenter triggerSubmitAction.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'NewSubclass'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_findClass [

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'classes are in different packages' ].
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RwGsPlatform'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanKernel'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: 'Rowan-GemStone-Core'.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'CypressClassDefinition')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'CypressClassDefinition'.
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

	self jadeiteTestResourceClass current
		createRowanSample1ProjectWithEmpyClassCategory.
	self projectsPresenter findClassNamed: 'RowanSample1'.
	self
		assert: self classCategoryPresenter roots last name
		equals: 'All'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService new nilCategoryDisplayName.
	self assert: self classListPresenter items size equals: 1.
	self
		assert: self classListPresenter items first name
		equals: 'RowanSample1'.
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
		selectServicesNamed: (Array with: 'Globals')
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Collections';
			 substringIndex: 1;
			 yourself).
	names := self classListPresenter model collection collect: [
		         :classService | classService name ].
	self assert: (names includes: 'IdentityBag').
	self selectHierarchyTab.
	(Delay forMilliseconds: 500) wait.
	hierarchyModel := self classHierarchyPresenter model.

	self assert: hierarchyModel first name equals: 'Object'.
	
	hierarchyModel := self classHierarchyPresenter childrenFor:
		                  hierarchyModel first.
	self denyIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'Association' ]
			 ifNone: [  ]).
	self denyIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'Collection' ]
			 ifNone: [  ]).
	self assertIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'RwGsPlatform' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_jfpworFindClass [

	JadeitePreferences isRowanAvailable ifTrue: [
		^ self skip: 'classes are in different packages' ].
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RwGsPlatform'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'UserGlobals'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Stubs'.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'CypressClassDefinition')
		methodService: nil
		onCompletion: [  ].
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'Collection')
		methodService: nil
		onCompletion: [  ].
	
	self
		assert: self classListPresenter selectedItem name
		equals: 'Collection'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'Globals'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Collections'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_nilClassCategory [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self jadeiteTestResourceClass current
		createRowanSample1ProjectWithEmpyClassCategory.
	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: self dictionaryListPresenter.
	self
		assert: self classCategoryPresenter roots last name
		equals: 'All'.

	self assert: self classListPresenter items size equals: 2.
	self assert:
		((self classListPresenter items collect: [ :ea | ea name ])
			 includes: 'RowanSample1').
	self assert:
		((self classListPresenter items collect: [ :ea | ea name ])
			 includes: 'RowanSample1Test').
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: String new;
			 substringIndex: 1;
			 yourself).
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService new nilCategoryDisplayName.
	self assert: self classListPresenter items size equals: 1.
	self
		assert: self classListPresenter items first name
		equals: 'RowanSample1'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate [
	"selected dictionary only"

	self
		selectServiceNamed: 'RowanKernel'
		in: self dictionaryListPresenter.
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self assert: ('*RowanKernel*' match:
			 self projectsPresenter classDefinitionPresenter text).

	"selected project and package"
	self selectClassCategoryNamed: 'GemStone-Interactions-Core'. "Selects GemStone"
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self assert: self projectsPresenter classDefinitionPresenter text replaceLfWithCr equals: '(Object subclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: RowanKernel
	options: #()) category:  ''GemStone''
'.

	"selected project and class"
	self
		selectServiceNamed: 'GsInteraction'
		in: self classListPresenter.
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self
		assert: self classListPresenter selectedItem name
		equals: 'GsInteraction'.
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: self classListPresenter selectedItem template.

	"selected project and class in class hierarchy"
	self selectServiceNamed: 'GsInteractionRequest' in: self classListPresenter.
	self projectsPresenter selectClassHierarchyTab.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'GsInteractionRequest'.
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: self classHierarchyPresenter selectedItem template
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate_classCategorySelected [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 3;
			 yourself).
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate_dictionarySelection [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate_noDictionarySelection [

	self dictionaryListPresenter unselectAll.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_runTestInBrowser [

	| methodService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
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
	self projectsPresenter debugMethodTests: methodService.
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
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
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
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	classService := RowanClassService new
		                name: 'TestClass';
		                meta: false.
	self assert:
		(self dictionaryListPresenter selectedItem classes includes:
			 classService)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassChangedCategory [

	| classService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
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
		jfpwor_classDefinitionFor: 'TestClass'
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
		jfpwor_classDefinitionFor: 'TestClass'
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
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
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
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
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
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
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
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests';
				 substringIndex: 3;
				 yourself).
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	"----------------Change the category and see if the category selection changes ------------------"
	self
		jfpwor_classDefinitionFor: 'TestClass'
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
		jfpwor_classDefinitionFor: 'TestClassWithNewCategory'
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

	"in hierarchy don't lose selection""Rowan-Services""Rowan""not in hierarchy, selection cleared"

	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
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
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 2;
			 yourself).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 1;
			 yourself).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
	self classCategoryPresenter unselectAll.
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
		'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'.

	self jadeiteTestResourceClass current
		createRowanSample1ProjectWithEmpyClassCategory.
	self
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
