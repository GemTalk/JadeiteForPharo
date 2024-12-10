Class {
	#name : 'JadeiteForPharoWithoutRowanBrowserTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoWithoutRowanBrowserTestCase >> saveClass: className superclass: superName instVars: instVars category: aString [
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
JadeiteForPharoWithoutRowanBrowserTestCase >> selectRowanAnsweringService [
	" A little weird but select the answering service twice. 
	The first selection may reset the class category which causes
	a refresh in the class list and the test can't keep up (but manually can)"

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoWithoutRowanBrowserTestCase >> selectRowanSample1Class [
	"big assumption - RowanSample1 class will always be in RowanSample1 project"

	self
		selectServiceNamed: 'SampleSymbolDict'
		in: self dictionaryListPresenter.
	self
		selectServiceNamed: self sampleClassName
		in: self classListPresenter.
	self
		selectServiceNamed: self sampleClassName
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoWithoutRowanBrowserTestCase >> selectRowanSample1Test [

	self
		selectServiceNamed: 'SampleSymbolDict'
		in: self dictionaryListPresenter.
	self
		selectServiceNamed: 'RowanSample1Test'
		in: self classListPresenter.
	self
		selectServiceNamed: 'RowanSample1Test'
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoWithoutRowanBrowserTestCase >> selectRowanServicesPackage [
	"no package list"
]

{ #category : 'selection' }
JadeiteForPharoWithoutRowanBrowserTestCase >> selectServicesNamed: services in: presenter [
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
JadeiteForPharoWithoutRowanBrowserTestCase >> setUp [

	super setUp.
	JadeitePreferences isRowanLoaded: false.
	self setupProjectBrowser
]

{ #category : 'tests' }
JadeiteForPharoWithoutRowanBrowserTestCase >> test_browseClass [
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
JadeiteForPharoWithoutRowanBrowserTestCase >> test_hierarchyExpansion [

	| hierarchyModel names |
	self todo: 'Not a great test of expansion in JfPwoR. Fix later.'.
	self
		testsIssue: #issue156
		withTitle: 'Double click on hierarchy class should expand list #156'.
	self
		selectServicesNamed: (Array with: 'RowanKernel')
		in: self dictionaryListPresenter.
	names := self classListPresenter model collection collect: [
		         :classService | classService name ].
	self assert: (names includes: 'Rowan').
	self assert: (names includes: 'RwPlatform').
	self selectHierarchyTab.
	(Delay forMilliseconds: 500) wait.
	hierarchyModel := self classHierarchyPresenter model.

	self assert: hierarchyModel first name equals: 'Object'.

	hierarchyModel := self classHierarchyPresenter childrenFor:
		                  hierarchyModel first.

	self denyIsNil:
		(hierarchyModel detect: [ :svc | svc name = 'Rowan' ] ifNone: [  ]).
	self denyIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'RwPlatform' ]
			 ifNone: [  ]).
	self assertIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'RwGsPlatform' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoWithoutRowanBrowserTestCase >> test_saveClass [

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
		equals: 'TestClass'
]

{ #category : 'tests' }
JadeiteForPharoWithoutRowanBrowserTestCase >> test_selectCategory [
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
JadeiteForPharoWithoutRowanBrowserTestCase >> test_twoBrowsersAddSameCategoryToClassAndInstance [

	self
		testsIssue: #issue418
		withTitle:
			'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight';
		selectRowanSample1Test;
		selectHierarchyTab;
		openSecondBrowser.
	(Delay forMilliseconds: 500) wait. 
	self
		selectServiceNamed: 'SampleSymbolDict'
		in: secondPresenter dictionaryListPresenter;
		selectServiceNamed: 'RowanSample1Test'
		in: secondPresenter classListPresenter;
		selectServiceNamed: 'RowanSample1Test'
		in: secondPresenter classListPresenter;
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
