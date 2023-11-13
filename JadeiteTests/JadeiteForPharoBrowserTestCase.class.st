Class {
	#name : 'JadeiteForPharoBrowserTestCase',
	#superclass : 'JadeiteForPharoBrowserAbstractTestCase',
	#category : 'JadeiteTests'
}

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> addChildrenOf: item to: items [
	| children |
	children := self classHierarchyPresenter childrenFor: item.
	children isEmpty ifTrue:[^self].
	children do:[:child |
		items add: child. 
		self addChildrenOf: child to: items]
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> hierarchyVisibleItems [
	"return a collection of all visible items in the tree"
	| items |

	items := OrderedCollection new. 
	items add: self classHierarchyPresenter roots first. 
	self addChildrenOf: self classHierarchyPresenter roots first to: items. 
	^items

]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> morphicMethodSourceHasUnacceptedEdits [

	^self methodSourcePresenter withAdapterDo: [ :adapter | adapter widgetDo:[:widget | widget hasUnacceptedEdits ] ]
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> openSecondBrowser [
	secondBrowser := JadeiteTestResource current openWindow: [self transcript openBrowser].
	secondBrowser caption: 'second browser'.
	secondPresenter := secondBrowser currentCard.
	secondPresenter selectClassListTab.
	^secondBrowser
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> projectList [
	^self projectListPresenter list
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_abortRemovesClassAndMethod [
	self testsIssue: #issue617 withTitle: 'Abort walkback if removing method from removed class'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestAbortRemovesClass'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Tests'.
	
	[self
		saveMethod: 'terrific ^''yippee'''
		in: 'TestAbortRemovesClass'
		category: 'deleteme'.
	self denyIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'TestAbortRemovesClass']
				ifNone: []).
	self abortTransaction.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'TestAbortRemovesClass']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_abortRemovesProjectAndPackage [
	self selectRowanSample1Test.
	[self denyIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self denyIsNil: (self packageListPresenter list
				detect: [:packageService | packageService name = 'RowanSample1-Tests']
				ifNone: []).
	self abortTransaction.
	self assertIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self assertIsNil: (self packageListPresenter list
				detect: [:packageService | packageService name = 'RowanSample1-Tests']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_addAccessors [

	self
		testsIssue: #issue382
		withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'var1' 'var2' 'var3' )
		package: 'RowanSample1-Core'.

	[
	self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #( 'var1' ).
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var1.
	self
		assert: self methodListPresenter selections first selector
		equals: #var1.
	self selectMethodNamed: #var1:.
	self
		assert: self methodListPresenter selections first selector
		equals: #var1:.
	self variableListPresenter selections: #( 'var3' ).
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var3.
	self
		assert: self methodListPresenter selections first selector
		equals: #var3.
	self selectMethodNamed: #var3:.
	self
		assert: self methodListPresenter selections first selector
		equals: #var3:.
	self assertIsNil: (self methodListPresenter list
			 detect: [ :methodService | methodService selector = #var2 ]
			 ifNone: [  ]).
	self assertIsNil: (self methodListPresenter list
			 detect: [ :methodService | methodService selector = #var2: ]
			 ifNone: [  ]) ] ensure: [
		self projectsPresenter basicRemoveClass:
			self projectsPresenter selectedClass ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_addRemoveCategory [
	self selectRowanSample1Class.
	self deny: (self categoryListPresenter list includes: 'jadeite test').
	self projectsPresenter basicAddMethodCategory: 'jadeite test'.
	self assert: (self categoryListPresenter list includes: 'jadeite test').
	self assert: self categoryListPresenter selectedItem = 'jadeite test'.
	self projectsPresenter basicRemoveMethodCategories.
	self deny: (self categoryListPresenter list includes: 'jadeite test')
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_addStarredCategory [
	self testsIssue: #issue956
		withTitle: '[3.2.12] Use of *category to specify package depends on a repository quality that needs to be visible'.
	self selectRowanSample1Class.
	self projectsPresenter basicAddMethodCategory: '*blasdfqewr'.
	
	[self assert: (self categoryListPresenter list includes: '*blasdfqewr').
	self assert: self categoryListPresenter selectionOrNil equals: '*blasdfqewr']
			ensure: 
				["there's currently a bug in rowan #875 that affects removal of starred categories. Use abort temporarily instead."
				self abortTransaction.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hierarchyDoubleClick [

	| rowanService answeringService rowanServicePath rowanServiceChildren |
	self selectRowanServicesPackage.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter.
	self selectHierarchyTab.
	[
	answeringService := self projectsPresenter selectedClass.
	self assert: answeringService name equals: 'RowanAnsweringService'.
	rowanService := self hierarchyVisibleItems detect: [ :service |
		                service name = 'RowanService' ].
	self classHierarchyPresenter selectItem: rowanService.
	rowanServiceChildren := self classHierarchyPresenter childrenFor:
		                        rowanService.
	self assert: rowanServiceChildren size equals: 1.
	self assert: rowanServiceChildren first equals: answeringService. "don't expect full RowanService hierarchy to be there yet."
	rowanServicePath := self classHierarchyPresenter selection
		                    selectedPath.
	self classHierarchyPresenter doubleClickAtPath: rowanServicePath.
	rowanServiceChildren := self classHierarchyPresenter childrenFor:
		                        rowanService.
	self assert: rowanServiceChildren size > 1.
	self assert: (rowanServiceChildren includes: answeringService).
	self assert: (rowanServiceChildren includes:
			 (self hierarchyVisibleItems detect: [ :service |
				  service name = 'RowanPackageService' ])).
	self assert: (rowanServiceChildren includes:
			 (self hierarchyVisibleItems detect: [ :service |
				  service name = 'RowanProjectService' ])) ] ensure: [
		self selectClassListTab ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodListBrowserOverwritesMethods [

	| methodList classMethod instanceMethod|
	self
		testsJadeiteForPharoIssue: #issue10
		withTitle:
		'changed method in method browsers reverts to original source after save'.
	self selectRowanSample1Class.
	self selectClassSide.
	self
		saveMethod: 'foo  ^''class side'''
		in: 'RowanSample1'
		category: 'dontcare'
		meta: true.
	self selectMethodNamed: 'foo'.
	methodListBrowser := projectsBrowser browseImplementorsOf: 'foo'.
	methodList := methodListBrowser methodListPresenter list asOrderedCollection.
	self assert: methodList size equals: 2.
	methodList do: [ :methodService |
		self assert: methodService className equals: 'RowanSample1' ].
	classMethod := methodList detect: [ :methodService | methodService meta ]. 
	instanceMethod := methodList detect: [ :methodService | methodService meta not ].
	self deny: classMethod equals: instanceMethod. 
	self assert: classMethod displayClassName equals: 'RowanSample1 class'. 
	self assert: instanceMethod displayClassName equals: 'RowanSample1'.
	methodListBrowser methodListPresenter selectItem: instanceMethod. 
	self assert: methodListBrowser methodSourcePresenter text asString equals: 'foo ^''foo'''.
	self
		saveMethod: 'foo  ^''the class side'''
		in: 'RowanSample1'
		category: 'dontcare'
		meta: true. "this should not write over the method list source pane"
	self deny: methodListBrowser methodListPresenter selectedItem meta. 
	self assert: methodListBrowser methodSourcePresenter text asString equals: 'foo ^''foo'''.
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodSourcechangeIndicator [
	"It's hard to test that a glyph is displayed but we can test 
	the state that changes when the indicator is turned on and off"

	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	self deny: self morphicMethodSourceHasUnacceptedEdits.
	self methodSourcePresenter text: 'foo  ^''instance side'''.
	self assert: self morphicMethodSourceHasUnacceptedEdits.
	self 
		saveMethod: 'foo  ^''instance side'''
		in: 'RowanSample1'
		category: 'dontcare'
		meta: false.
	self deny: self morphicMethodSourceHasUnacceptedEdits.
	self methodSourcePresenter text: 'foo  ^''dontcare'''.
	self assert: self morphicMethodSourceHasUnacceptedEdits.	
	self projectsPresenter resetMethodSource. 
	self assert: self methodSourcePresenter text = 'foo  ^''instance side'''. 
	self deny: self morphicMethodSourceHasUnacceptedEdits.
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_openProjectsBrowser [
	"project browser opened in setup"

	projectsBrowser ifNotNil: [
		self closeBrowser: projectsBrowser.
		self setupProjectBrowser ].
	self assert: projectsBrowser class equals: JadeiteBrowser.
	self denyIsNil: (self projectList
			 detect: [ :projectService | projectService name = 'Rowan' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectLoadAddedInAlphabeticalOrder [

	| projects |
	self
		testsJadeiteForPharoIssue: #issue21
		withTitle:
		'loading a new project externally and then aborting ends up with new project at bottom of console'.
	JadeiteApplication abortTransactionInSession: session.
	[
	projects := self projectList collect: [ :projectService |
		            projectService name ].
	self deny: (projects includes: 'RowanSample1').
	projectsBrowser
		installProjectFromPath:
		'/uffda1/users/ewinger/rowanStones/checkouts/gemstone37rowanv3_externals_st/RowanSample1/rowan/specs/RowanSample1.ston'
		projectsHome: '$ROWAN_PROJECTS_HOME'.
	projects := self projectList collect: [ :projectService |
		            projectService name ].
	self
		assert: projects
		equals: projects asSortedCollection asOrderedCollection ] ensure: [
		JadeiteTestResource current
			tearDown;
			"reset the world after abort. Need to improve this. "setUp ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectOrderDoesNotChange [

	| projectsBefore projectsAfter |
	self
		testsJadeiteForPharoIssue: #issue21
		withTitle:
		'loading a new project externally and then aborting ends up with new project at bottom of console'.
	projectsBefore := self projectList collect: [ :projectService |
		                  projectService name ].
	JadeiteApplication abortTransactionInSession: session.
	[
	projectsBrowser
		installProjectFromPath:
		'/uffda1/users/ewinger/rowanStones/checkouts/gemstone37rowanv3_externals_st/RowanSample1/rowan/specs/RowanSample1.ston'
		projectsHome: '$ROWAN_PROJECTS_HOME'.
	projectsAfter := self projectList collect: [ :projectService |
		                 projectService name ].
	self assert: projectsBefore equals: projectsAfter ] ensure: [
		JadeiteTestResource current
			tearDown;
			"reset the world after abort. Need to improve this. "setUp ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_removeProject [
	| targetProject |
	self testsIssue: #issue129 withTitle: 'Expose unload project.'.
	targetProject := self projectListPresenter list
				detect: [:projectService | projectService name = self sampleProject1Name]
				ifNone: [].
	self denyIsNil: targetProject.
	self projectListPresenter selection: targetProject.
	"just select an element in each list to test cleanup after removal"
	self packageListPresenter selection: self packageListPresenter list first.
	self classListPresenter selection: self classListPresenter list first.
	self categoryListPresenter selection: self categoryListPresenter list first.
	self methodListPresenter selection: self methodListPresenter list first.
	self projectsPresenter basicUnloadProjects: (Array with: self projectListPresenter selectedItem name).
	targetProject := self projectListPresenter list
				detect: [:projectService | projectService name = self sampleProject1Name]
				ifNone: [].
	self assertIsNil: targetProject.
	"make sure browser cleans itself up"
	
	[self assert: self projectListPresenter selections isEmpty.
	self assert: self packageListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self categoryListPresenter list isEmpty.
	self assert: self methodListPresenter list isEmpty]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_twoBrowsersAddSameCategoryToClassAndInstance [

	self
		testsIssue: #issue418
		withTitle:
			'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight';
		selectRowanSample1Test;
		selectHierarchyTab;
		openSecondBrowser;
		selectServiceNamed: 'RowanSample1'
		in: secondPresenter projectListPresenter;
		selectServiceNamed: 'RowanSample1-Tests'
		in: secondPresenter packageListPresenter;
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
