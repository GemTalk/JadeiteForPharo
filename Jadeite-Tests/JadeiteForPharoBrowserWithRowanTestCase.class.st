Class {
	#name : 'JadeiteForPharoBrowserWithRowanTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoBrowserWithRowanTestCase >> setUp [

	super setUp.
	JadeitePreferences isRowanLoaded: true.
	self setupProjectBrowser
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_abortRemovesProjectAndPackage [
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
JadeiteForPharoBrowserWithRowanTestCase >> test_acceptDefinedMethodInExtensionClass [
	self testsIssue: #issue375
		withTitle: '(3.0.53) accept non-extension method in an extension package .... lose selected class'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Extensions' in: self packageListPresenter.
	self selectServiceNamed: self sampleClassName in: self classListPresenter.
	self selectMethodNamed: #foo.	"select a method defined in it's class package while the extension class is selected"
	self methodSourcePresenter value: 'foo   ^foot'.
	self assert: self methodSourcePresenter text equals: 'foo   ^foot'.
	self assert: self methodListPresenter selectedItem selector equals: #foo.
	self assert: self classListPresenter selectedItem name equals: 'RowanSample1'.
	self assert: self packageListPresenter selectedItem name equals: 'RowanSample1-Extensions'.
	self methodSourcePresenter text: 'foo   ^footy'.
	self assert: self methodSourcePresenter text equals: 'foo   ^footy'.
	self assert: self methodListPresenter selectedItem selector equals: #foo.
	self assert: self classListPresenter selectedItem name equals: 'RowanSample1'.
	self assert: self packageListPresenter selectedItem name equals: 'RowanSample1-Extensions'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_addDuplicatePackage [
	"don't open the add package dialog window as it's hard to test a modal window,
	just fill in the values so the browser can extract them and do the actual work."

	| projectService packageName modalWindow |
	self
		testsIssue: #issue266
		withTitle:
		'Add package with existing name results in package in two projects'.

	packageName := 'NewPackage'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	projectService := self projectListPresenter selection.
	modalWindow := JadeiteAddPackageDialog
		               newModalWindowOn: session
		               projectService:
		               self projectListPresenter selectedItem.
	modalWindow presenter packageNamePresenter: packageName.
	self projectsPresenter basicAddPackage: modalWindow.
	self
		assert: self packageListPresenter selectedItem name
		equals: packageName.
	self
		assert: (self packageListPresenter list select: [ :service |
				 service name = packageName ]) size
		equals: 1.
	modalWindow := JadeiteAddPackageDialog
		               newModalWindowOn: session
		               projectService:
		               self projectListPresenter selectedItem.
	modalWindow presenter packageNamePresenter: packageName.
	self projectsPresenter basicAddPackage: modalWindow. "should just select the project in the list"
	self
		assert: self packageListPresenter selectedItem name
		equals: packageName.
	self
		assert: (self packageListPresenter list select: [ :service |
				 service name = packageName ]) size
		equals: 1
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_browseClass [
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
JadeiteForPharoBrowserWithRowanTestCase >> test_browseProject [

	| projectListPresenter service |
	RowanServiceUpdater uninstallTestUpdater.
	projectListPresenter := self projectsPresenter projectListPresenter.
	service := projectListPresenter items detect: [ :projectService |
		           projectService name = 'Rowan' ].
	projectListPresenter selectItem: service.
	secondBrowser := self projectsPresenter browseProject.
	[
	secondBrowser activePresenter projectListPresenter selectedItem isNil ]
		whileTrue: [ (Delay forMilliseconds: 10) wait ].
	self assert: [
		secondBrowser activePresenter projectListPresenter selectedItem name
		= 'Rowan' ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_deselectProjectOnly [
	"make sure it updates the tab label"

	self deselectProjects.
	self assert: self projectBrowserTabs first title equals: '1 Projects'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: self projectBrowserTabs first title equals: '1 Rowan'.
	self deselectProjects.
	self assert: self projectBrowserTabs first title equals: '1 Projects'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_hierarchyExpansion [
	"When no classes are selected and the hierarchy tab is chosen, we should
	see a hierarchy showing all superclasses of the packaged classes. 
	Subclasses are available with the > arrow. 
	"

	| hierarchyModel |
	self
		testsIssue: #issue156
		withTitle: 'Double click on hierarchy class should expand list #156'.
	self
		selectServicesNamed: (Array with: 'Rowan')
		in: self projectListPresenter.
	self
		selectServicesNamed: #( 'Rowan-Kernel' )
		in: self packageListPresenter.
	self assert: self classListPresenter model collection size equals: 2.
	self
		assert: self classListPresenter model collection first name
		equals: 'Rowan'.
	self
		assert: self classListPresenter model collection last name
		equals: 'RwPlatform'.
	self selectHierarchyTab.
	
	hierarchyModel := self classHierarchyPresenter model.
	
	self assert: hierarchyModel first name equals: 'Object'.
	
	hierarchyModel := self classHierarchyPresenter childrenFor:
		                  hierarchyModel first.
		
	self assert: hierarchyModel first name equals: 'Rowan'.
	self assert: (self classHierarchyPresenter itemAtPath: #(1 1)) equals: hierarchyModel first.
	self assert: (self classHierarchyPresenter isExpanded: #(1 1)). 
	self assert: (self classHierarchyPresenter childrenFor: hierarchyModel first) isEmpty.
	
	self assert: hierarchyModel last name equals: 'RwPlatform'.
	self assert: (self classHierarchyPresenter itemAtPath: #(1 2)) equals: hierarchyModel last.
	self assert: (self classHierarchyPresenter isExpanded: #(1 2)). 
	self assert: (self classHierarchyPresenter childrenFor: hierarchyModel last) notEmpty.
	
	hierarchyModel := self classHierarchyPresenter childrenFor:
		                  hierarchyModel last.
		
	self assert: hierarchyModel first name equals: 'RwGsPlatform'.
	self assert: (self classHierarchyPresenter itemAtPath: #(1 2 1)) equals: hierarchyModel first.
	self assert: (self classHierarchyPresenter isExpanded: #(1 2 1)). 
	self assert: (self classHierarchyPresenter childrenFor: hierarchyModel first) isEmpty.
	
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_projectLoadAddedInAlphabeticalOrder [

	| projects |
	self
		testsJadeiteForPharoIssue: #issue21
		title:
		'loading a new project externally and then aborting ends up with new project at bottom of console'.
	JadeiteApplication abortTransactionInSession: session.
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
		equals:
			(projects asSortedCollection: [ :x :y |
				 x asLowercase < y asLowercase ]) asOrderedCollection
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_projectOrderDoesNotChange [

	| projectsBefore projectsAfter |
	self
		testsJadeiteForPharoIssue: #issue21
		title:
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
		self testResourceClass current
			tearDown;
			"reset the world after abort. Need to improve this. "setUp ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_projectRemoved [
	"Gracefully remove a project from the project list if it was 
	removed behind the tool's back"

	| sampleProject |
	self
		selectServicesNamed: (Array with: 'RowanSample1')
		in: self projectListPresenter.
	sampleProject := self projectNamed: 'RowanSample1'.
	self denyIsNil: sampleProject.
	self
		selectServicesNamed: (Array with: 'Rowan')
		in: self projectListPresenter.
	session executeString:
		'Rowan projectTools delete deleteProjectNamed: ''RowanSample1''. true'. "delete project behind tool's back"
	self auditAll.
	self
		selectServicesNamed: (Array with: 'RowanSample1')
		in: self projectListPresenter. "expect project to disappear but not walkback"
	sampleProject := self projectNamed: 'RowanSample1'.
	self assertIsNil: sampleProject
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_removeProject [

	| targetProject |
	self testsIssue: #issue129 withTitle: 'Expose unload project.'.
	targetProject := self projectListPresenter list
		                 detect: [ :projectService |
		                 projectService name = self sampleProject1Name ]
		                 ifNone: [  ].
	self denyIsNil: targetProject.
	self projectListPresenter selection: targetProject.
	"just select an element in each list to test cleanup after removal"
	self packageListPresenter selection:
		self packageListPresenter list first.
	self classListPresenter selection: self classListPresenter list first.
	self categoryListPresenter selection:
		self categoryListPresenter list first.
	self methodListPresenter selection:
		self methodListPresenter list first.
	self projectsPresenter
		basicUnloadProjects:
		(Array with: self projectListPresenter selectedItem name)
		onCompletion: nil.
	targetProject := self projectListPresenter list
		                 detect: [ :projectService |
		                 projectService name = self sampleProject1Name ]
		                 ifNone: [  ].
	self assertIsNil: targetProject.
	"make sure browser cleans itself up"

	[
	self assert: self projectListPresenter selections isEmpty.
	self assert: self packageListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self categoryListPresenter list isEmpty.
	self assert: self methodListPresenter list isEmpty ] ensure: [
		self cloneRowanSample1.
		self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_runTestInBrowser [

	| methodService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
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
JadeiteForPharoBrowserWithRowanTestCase >> test_selectVariable [

	self selectRowanServicesPackage.
	self
		selectServiceNamed: 'RowanClassService'
		in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self selectVariableNamed: 'instVarNames'.
	self methodListPresenter list do: [ :methodService |
		RowanServiceUpdater current
			updateService: methodService
			session: session
			onCompletion: [  ].
		self assert:
			(methodService source substrings includes: 'instVarNames') ].
	self selectVariableNamed: 'isNewClass'.
	self methodListPresenter list do: [ :methodService |
		RowanServiceUpdater current
			updateService: methodService
			session: session
			onCompletion: [  ].
		self assert:
			(methodService source substrings includes: 'isNewClass') ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithRowanTestCase >> test_twoBrowsersAddSameCategoryToClassAndInstance [

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
