Class {
	#name : 'JadeiteForPharoSUnitBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'sunitBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> application [
	"Spec2 needs this to open a browser via preferences"
	^JadeiteConsoleApplication new gciSession: GciSession current 
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> assertClassInList: name [
	self denyIsNil: (sunitBrowser classListPresenter list
				detect: [:classService | classService name = name]
				ifNone: [])
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> assertPackageInList: name [
	self denyIsNil: (sunitBrowser packageListPresenter list
				detect: [:packageService | packageService name = name]
				ifNone: [])
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> denyClassInList: name [
	self assertIsNil: (sunitBrowser classListPresenter list
				detect: [:classService | classService name = name]
				ifNone: [])
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> denyPackageInList: name [
	self assertIsNil: (sunitBrowser packageListPresenter list
				detect: [:packageService | packageService name = name]
				ifNone: [])
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> gciSession [

	^GciSession current 
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> setUp [ 

	super setUp. 
	sunitBrowser := self openSUnitBrowser. 
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> setupAbstractSuperWithTest [
	"setup abstract super class with single test + 2 subclasses"

	| source |
	projectsBrowser := self testResourceClass current openProjectsBrowser.
	self
		saveClass: 'JadeiteTest'
		superclass: 'TestCase'
		instVars: #(  )
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self
		selectServiceNamed: 'RowanSample1-Tests'
		in: self packageListPresenter.
	self selectServiceNamed: 'JadeiteTest' in: self classListPresenter.
	self selectClassTab.
	source := 'isAbstract
		^self name = #JadeiteTest'.
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: nil.
	self selectInstanceSide.
	source := 'test_className
		"fail in one subclass only" 
		self assert: self class name = #JadeiteTestSubclass1'.
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: nil.
	self
		saveClass: 'JadeiteTestSubclass1'
		superclass: 'JadeiteTest'
		instVars: #(  )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'JadeiteTestSubclass2'
		superclass: 'JadeiteTest'
		instVars: #(  )
		package: 'RowanSample1-Tests'
]

{ #category : 'accessing' }
JadeiteForPharoSUnitBrowserTestCase >> sunitPresenter [

	^sunitBrowser
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> tearDown [ 

	super tearDown. 
	self destroy: sunitBrowser
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_abortNoSelections [

	self
		testsIssue: #issue383
		withTitle:
		'(3.0.53) the commit button on the SUnit browser is silent'.
	self transcript
		basicUnloadProjects: (Array with: self sampleProject1Name)
		onCompletion: [  ].
	self commitTransaction. "ensure that the sample package wasn't committed"
	self denyPackageInList: 'RowanSample1-Tests'.
	self testResourceClass current createRowanSample1Project.
	self assertPackageInList: 'RowanSample1-Tests'.
	sunitBrowser abortTransaction.
	self denyPackageInList: 'RowanSample1-Tests'
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_abortWithSelections [
	"don't lose selection on abort which removes another package"

	self
		testsIssue: #issue383
		withTitle:
		'(3.0.53) the commit button on the SUnit browser is silent'.
	self transcript
		basicUnloadProjects: (Array with: self sampleProject1Name)
		onCompletion: [  ].
	self commitTransaction. "ensure that the sample package wasn't committed"
	sunitBrowser
		selectPackageNamed: 'Rowan-Services-Tests'
		classNamed: 'RowanTestClassServiceTest'.
	sunitBrowser selectMethodNamed: #test_addCategory.
	sunitBrowser abortTransaction.
	self
		assert: sunitBrowser packageListPresenter selectedItem name
		equals: 'Rowan-Services-Tests'.
	self
		assert: sunitBrowser classListPresenter selectedItem name
		equals: 'RowanTestClassServiceTest'.
	self
		assert: sunitBrowser methodListPresenter selectedItems size
		equals: 1.
	self
		assert:
		sunitBrowser methodListPresenter selectedItems first selector
		equals: #test_addCategory
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_abstractTestAppearsOnlyInSubclasses [
	| subclass1MethodService subclass2MethodService classNames |
	self testsIssue: #issue755
		withTitle: 'SUnit browser runs test in abstract test class if more than one test class selected'.
	self testsIssue: #issue756
		withTitle: 'SUnit Browser does not handle duplicated test method selectors well'.
	self setupAbstractSuperWithTest.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter. 
	classNames := sunitBrowser classListPresenter list
				collect: [:classService | classService name].
	self assert: (classNames includes: 'JadeiteTestSubclass1').
	self assert: (classNames includes: 'JadeiteTestSubclass2').
	self deny: (classNames includes: 'JadeiteTest').
	self selectServicesNamed: #('JadeiteTestSubclass1' 'JadeiteTestSubclass2')
		in: self sunitPresenter classListPresenter.
	subclass1MethodService := self sunitPresenter methodListPresenter list detect: 
					[:methodService |
					methodService selector = #test_className and: [methodService className = 'JadeiteTestSubclass1']]
				ifNone: [].
	self denyIsNil: subclass1MethodService.
	subclass2MethodService := self sunitPresenter methodListPresenter list detect: 
					[:methodService |
					methodService selector = #test_className and: [methodService className = 'JadeiteTestSubclass2']]
				ifNone: [].
	self denyIsNil: subclass2MethodService.
	self sunitPresenter runAll.
	[self sunitPresenter testProcess isNil] whileFalse: [(Delay forMilliseconds: 10) wait].
	self assert: subclass1MethodService testResult equals: #passed.
	self assert: subclass2MethodService testResult equals: #failure
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_addNewNonTestClassDoesNotGetAdded [

	self
		testsIssue: #issue879
		withTitle: 'Removing class does not remove class from sunit browser'.
	self
		selectServiceNamed: 'RowanSample1-Tests'
		in: self sunitPresenter packageListPresenter.
	self denyClassInList: 'NewSubclass'.
	projectsBrowser := self testResourceClass current openProjectsBrowser.
	self selectRowanSample1Test.
	self denyClassInList: 'NewSubclass'.
	self
		saveClass: 'NewNonTestClass'
		withInstVars: #( 'abc' )
		package: 'RowanSample1-Tests'.
	[ self denyClassInList: 'NewSubclass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ].
	self denyClassInList: 'NewSubclass'
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_addNewTestClass [

	self
		testsIssue: #issue879
		withTitle: 'Removing class does not remove class from sunit browser'.
	self
		selectServiceNamed: 'RowanSample1-Tests'
		in: self sunitPresenter packageListPresenter.
	self denyClassInList: 'NewSubclass'.
	projectsBrowser := self testResourceClass current openProjectsBrowser.
	self selectRowanSample1Test.
	self projectsPresenter addSubclass.
	self projectsPresenter editSaveClass.
	[ self assertClassInList: 'NewSubclass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ].
	self denyClassInList: 'NewSubclass'
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_addNewTestPackage [
	"test package should show up when test method is added"

	| packageName className methodService |
	"doesn't matter which component for test""don't pick a symbol list so default symbol list is used"
	packageName := 'AddedPackage'.
	className := 'AddedTestClass'.
	self denyClassInList: className.
	projectsBrowser := self testResourceClass current openProjectsBrowser.
	self selectRowanSample1Test.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self addPackageNamed: packageName.

	[
	| classService1 |
	self denyPackageInList: packageName. "not added until method is created"
	self
		saveClass: className
		superclass: 'TestCase'
		instVars: #( 'abc' )
		package: packageName.
	self denyPackageInList: packageName. "not added until method is created"
	classService1 := RowanClassService named: className.
	classService1
		saveMethod: 'test_blah'
		category: 'tests'
		session: session
		onCompletion: [].
	self assertPackageInList: packageName.
	self
		selectServiceNamed: packageName
		in: self sunitPresenter packageListPresenter.
	self assertClassInList: className.
	self
		selectServiceNamed: className
		in: self sunitPresenter classListPresenter.
	methodService := self sunitPresenter methodListPresenter list
		                 detect: [ :svc | svc selector = #test_blah ]
		                 ifNone: [  ].
	self assert: methodService selector equals: #test_blah.
	self
		assert: self sunitPresenter methodListPresenter list size
		equals: 1 ] ensure: [
		self abortTransaction.
		self cloneRowanSample1.
		self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_missingPackages [
	"packages weren't showing up in an sunit browser due to a timing issue. 
	Not directly reproducible, but open and close the sunit browser a number of times
	and make sure packages are there. #openSUnitBrowser is a traits method so we can 
	just send it to self"

	self destroy: sunitBrowser. "opened in setUp"
	25 timesRepeat: [
		sunitBrowser := self openSUnitBrowser.
		self assert: sunitBrowser packageListPresenter list notEmpty.
		self destroy: sunitBrowser ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_runServerTest [

	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self sunitPresenter packageListPresenter.
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self sunitPresenter classListPresenter.
	self
		selectServiceNamed: 'test_loadedPackageExists'
		in: self sunitPresenter methodListPresenter.
	self assert: sunitBrowser textResultPresenter text equals: String new.
	self
		assert:
		sunitBrowser textResultPresenter adapter widget scrollPane color
		equals: JadeiteApplication defaultBackgroundColor.
	self assertIsNil: sunitBrowser testResults.
	sunitBrowser testSemaphore: Semaphore new.
	sunitBrowser basicRunSelected.
	sunitBrowser testSemaphore waitTimeoutMilliseconds: 500.
	self
		assert: sunitBrowser textResultPresenter text
		equals: '1 run, 1 passed, 0 failures, 0 errors'.
	self
		assert:
		sunitBrowser textResultPresenter adapter widget scrollPane color
		equals: JadeTestResult new colorPass
]
