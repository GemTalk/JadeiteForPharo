"
browser tests that depend on Rowan available = true should go here
"
Class {
	#name : 'JadeiteForPharoBrowserTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoBrowserTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor"

	^ {
		  JadeiteBrowser.
		  JadeiteBrowserPresenter } asOrderedCollection
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> projectInfoMockService [

	| mockService |
	mockService := Object new.
	mockService class compile: 'wasUpdated ^true'.
	mockService class compile: 'name ^''MyProject'''.
	mockService class compile: 'sha ^''abc123'''.
	mockService class compile: 'diskSha ^''def456'''.
	mockService class compile: 'branch ^''main'''.
	mockService class compile: 'isSkew ^false'.
	mockService class compile: 'isDirty ^true'.
	mockService class compile: 'projectUrl ^''http://project.url'''.
	mockService class compile: 'packageConvention ^''convention'''.
	mockService class compile: 'rowanProjectsHome ^''aPath'''.
	mockService class compile: 'toolTip ^''is dirty state tool tip'''.
	mockService class compile:
		'packageServices 
			^Array with: (RowanPackageServiceClient new name: ''MockPackageService''; dictionaryName: ''MockDictionary''; yourself)'.

	^ mockService
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> setUp [

	super setUp.
	JadeitePreferences isRowanLoaded: true.
	self setupProjectBrowser
]

{ #category : 'tests' }
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
JadeiteForPharoBrowserTestCase >> test_acceptDefinedMethodInExtensionClass [
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
JadeiteForPharoBrowserTestCase >> test_addDuplicatePackage [
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
JadeiteForPharoBrowserTestCase >> test_browseClass [
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
JadeiteForPharoBrowserTestCase >> test_browseInExistingBrowserTabLabel [

	self
		testsJadeiteForPharoIssue: #issue275
		title:
		'Used the new menu item Browse in existing browser from a method list ... and the new tab is named Projects and not the name of the selected package'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/275'.
	JadeiteBrowser browserClass allInstances do: [ :browser |
		self destroy: browser ].
	projectsBrowser := nil.
	self setupProjectBrowser.
	self assert: projectsBrowser tabs pages size equals: 1.
	self selectRowanSample1Test.
	self selectMethodNamed: #testError.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanSample1Test'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #testError.
	methodListBrowser := self projectsPresenter browseImplementors.
	self assert: methodListBrowser window adapter widget isActive.
	methodListBrowser methodListPresenter unselectAll.
	methodListBrowser methodListPresenter selectIndex: 2.
	self
		assert: methodListBrowser methodListPresenter selectedItem className
		equals: 'SUnitTest'.

	methodListBrowser browseMethodClassInExistingBrowser.

	self assert: projectsBrowser window isTopWindow.
	self assert: projectsBrowser tabs pages size equals: 2.
	self assert: projectsBrowser tabs selectedPageIndex equals: 2.
	self
		assert: self classListPresenter selectedItem name
		equals: 'SUnitTest'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #testError.
	self assert: projectsBrowser tabs selectedPage title equals: '2 SUnitTest'.
	projectsBrowser tabs selectPageIndex: 1.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanSample1Test'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #testError.
	self assert: projectsBrowser tabs selectedPage title equals: '1 RowanSample1Test'.
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_browseProject [

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
JadeiteForPharoBrowserTestCase >> test_categoryExtensionMethodsDisplayed [

	| extensionCategory nonExtensionCategory nonExtensionMethod |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Core-37x'
		in: self packageListPresenter.
	self projectsPresenter selectClassNamed: 'RowanMethodService'.
	extensionCategory := self categoryListPresenter list
		                     detect: [ :jadeiteCategory |
		                     jadeiteCategory isComputed ]
		                     ifNone: [  ].
	self denyIsNil: extensionCategory.
	self assert: extensionCategory categoryName equals: 'extensions'.
	self categoryListPresenter selectItem: extensionCategory.
	self assert: self methodListPresenter list isNotEmpty.
	self assert: (self methodListPresenter list allSatisfy: #isExtension).
	self
		assert: self categoryListPresenter list size
		equals: (self categoryListPresenter list indexOf: extensionCategory).
	"test that a category with a non extension method shows at least one non extension method"
	nonExtensionMethod := self projectsPresenter selectedClass methods
		                      detect: [ :methodService |
		                      methodService isExtension not ]
		                      ifNone: [  ].
	nonExtensionCategory := self categoryListPresenter list
		                        detect: [ :jadeiteCategory |
			                        jadeiteCategory isComputed not and: [
				                        jadeiteCategory categoryName
				                        = nonExtensionMethod category ] ]
		                        ifNone: [  ].
	self categoryListPresenter selectItem: nonExtensionCategory.
	self assert:
		(self methodListPresenter list anySatisfy: [ :methodService |
			 methodService isExtension not ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_categoryExtensionMethodsShownWithNonExtensionMethods [

	| extensionCategory nonExtensionCategory nonExtensionMethod allExtensionMethods |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Core-37x'
		in: self packageListPresenter.
	self projectsPresenter selectClassNamed: 'RowanMethodService'.
	extensionCategory := self categoryListPresenter list
		                     detect: [ :jadeiteCategory |
		                     jadeiteCategory isComputed ]
		                     ifNone: [  ].
	nonExtensionMethod := self projectsPresenter selectedClass methods
		                      detect: [ :methodService |
		                      methodService isExtension not ]
		                      ifNone: [  ].
	nonExtensionCategory := self categoryListPresenter list
		                        detect: [ :jadeiteCategory |
			                        jadeiteCategory isComputed not and: [
				                        jadeiteCategory categoryName
				                        = nonExtensionMethod category ] ]
		                        ifNone: [  ].
	self categoryListPresenter selectItems: {
			extensionCategory.
			nonExtensionCategory }.
	allExtensionMethods := self classListPresenter selectedItem  methods select: [
		                       :methodService | methodService isExtension ].
	self assert:
		(self methodListPresenter list includesAll: allExtensionMethods).
	self assert:
		(self methodListPresenter list includes: nonExtensionMethod)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_classExtras [

	| classExtras |
	self
		testsJadeiteForPharoIssue: #issue229
		title: 'Error while browsing a Package'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/229'.
	self selectRowanAnsweringService.
	classExtras := self projectsPresenter classExtrasText.
	self
		assert: classExtras text
		equals: 'Defined Package: Rowan-Services-Core
Dictionary: RowanClientServices'.

	self
		selectServiceNamed: 'Rowan-Services-Extensions'
		in: self packageListPresenter.
	self assert: classExtras text equals: String new.
	self selectServiceNamed: 'RwGsPlatform' in: self classListPresenter.
	self
		assert: classExtras text
		equals: 'Defined Package: Rowan-GemStone-Core
Dictionary: RowanKernel'.
	self projectsPresenter selectClassHierarchyTab.
	self
		assert: classExtras text
		equals: 'Defined Package: Rowan-GemStone-Core
Dictionary: RowanKernel'.
	self projectsPresenter selectDictionaryListTab.
	self assert: classExtras text equals: String new
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_copyProjectAspect [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self projectsPresenter selectProjectInfoTab.
	1 to: self projectsPresenter projectInfoList items size do: [ :index |
		| copyString selectedItem |
		self projectsPresenter projectInfoList selectIndex: index.
		selectedItem := self projectsPresenter projectInfoList selectedItem.
		(selectedItem isBlankLine not and: [ selectedItem header not ])
			ifTrue: [
				[ self projectsPresenter copyProjectInfo ]
					on: ProvideAnswerNotification
					do: [ :ex |
					self assert: (selectedItem value , '*' match: ex messageText) ].
				copyString := selectedItem value.
				self assert: Clipboard clipboardText equals: copyString ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_createProject [

	| projectName |
	self
		testsJadeiteForPharoIssue: #issue172
		title: 'Ability to create a new project'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/172'.
	projectName := 'TestProject'.
	self assertIsNil: (self projectNamed: projectName).
	self assertIsNil: (self projectInConsoleNamed: projectName).
	self projectsPresenter basicCreateProject: projectName.
	[
	self denyIsNil: (self projectNamed: projectName).
	self denyIsNil: (self projectInConsoleNamed: projectName).
	self
		assert: self projectListPresenter selectedItem name
		equals: projectName.
	self assert: self packageListPresenter items isEmpty ] ensure: [
		self unloadProjectAndDeleteOnDisk: self projectListPresenter selectedItem name.
		self assertIsNil: (self projectNamed: projectName) ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_currentPackage [

	self selectRowanAnsweringService.
	self projectsPresenter setCurrentPackage.
	self assert: self packageListPresenter selectedItem isCurrent.
	self
		assert: self packageListPresenter selectedItem displayName
		equals: '*Rowan-Services-Core'.
	self packageListPresenter items do: [ :packageService |
		packageService name = 'Rowan-Services-Core' ifFalse: [
			self assert: packageService displayName = packageService name ] ].
	self
		selectServiceNamed: 'Rowan-Services-Core-37x'
		in: self packageListPresenter.
	self projectsPresenter setCurrentPackage.
	self assert: self packageListPresenter selectedItem isCurrent.
	self
		assert: self packageListPresenter selectedItem displayName
		equals: '*Rowan-Services-Core-37x'.
	self packageListPresenter items do: [ :packageService |
		packageService name = 'Rowan-Services-Core-37x' ifFalse: [
			self assert: packageService displayName = packageService name ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_currentProject [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self projectsPresenter setCurrentProject.
	self assert: self projectListPresenter selectedItem isCurrent.
	self
		assert: self projectListPresenter selectedItem displayName
		equals: '*RowanClientServices'.
	self projectListPresenter items do: [ :projectService |
		projectService name = 'RowanClientServices' ifFalse: [
			projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
				self assert: projectService displayName = projectService name ] ] ].

	jadeiteShell projectListPresenter items do: [ :projectService |
		projectService name = 'RowanClientServices'
			ifTrue: [
			self assert: projectService displayName = '*RowanClientServices' ]
			ifFalse: [
				projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
					self assert: projectService displayName = projectService name ] ] ].

	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self projectsPresenter setCurrentProject.
	self assert: self projectListPresenter selectedItem isCurrent.
	self
		assert: self projectListPresenter selectedItem displayName
		equals: '*Rowan'.
	self projectListPresenter items do: [ :projectService |
		projectService name = 'Rowan' ifFalse: [
			projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
				self assert: projectService displayName = projectService name ] ] ].
	jadeiteShell projectListPresenter items do: [ :projectService |
		projectService name = 'Rowan'
			ifTrue: [ self assert: projectService displayName = '*Rowan' ]
			ifFalse: [
				projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
					self assert: projectService displayName = projectService name ] ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_deselectProjectOnly [
	"make sure it updates the tab label"

	self deselectProjects.
	self assert: self projectBrowserTabs first title equals: '1 Projects'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: self projectBrowserTabs first title equals: '1 Rowan'.
	self deselectProjects.
	self assert: self projectBrowserTabs first title equals: '1 Projects'
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_dirtyBolding [

	| packageBoldAction packageService projectBoldAction projectService |
	packageBoldAction := self packageListPresenter instVarNamed:
		                     #boldAction.
	self denyIsNil: [ packageBoldAction ].
	packageService := RowanPackageService new isDirty: true.
	self assert: (packageBoldAction value: packageService).
	packageService := RowanProjectService new isDirty: false.
	self deny: (packageBoldAction value: packageService).

	projectBoldAction := self projectListPresenter instVarNamed:
		                     #boldAction.
	self denyIsNil: [ projectBoldAction ].
	projectService := RowanPackageService new isDirty: true.
	self assert: (projectBoldAction value: projectService).
	projectService := RowanProjectService new isDirty: false.
	self deny: (projectBoldAction value: projectService)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_existsOnDiskDisplay [
	"only test the display which was broken"

	| projectService |
	self
		testsIssue: #issue176
		withTitle:
		'Project Dirty-on-disk to italic font decoration not being applied'.
	"https://github.com/GemTalk/JadeiteForPharo/issues/176"


	projectService := self projectListPresenter items detect: [ :svc |
		                  svc name = 'RowanClientServices' ].
	[
	projectService existsOnDisk: true.
	self assert: projectService displayName = 'RowanClientServices'.
	projectService existsOnDisk: false.
	self assert: projectService displayName = '(RowanClientServices)' ]
		ensure: [ projectService existsOnDisk: true ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_fileoutPackage [

	| fileOutPath fileOutRef |
	self
		testsJadeiteForPharoIssue: #issue260
		title:
		'fileout package creates two files and an extra extension .gs.gs'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/260'.
	fileOutRef := FileSystem disk workingDirectory
	              / 'JfP_test_Rowan-Client-Services.gs'.
	fileOutRef deleteIfAbsent: [  ].
	self deny: fileOutRef exists.
	fileOutPath := fileOutRef pathString.
	self selectRowanServicesPackage.
	self projectsPresenter
		basicPackageFileout: self packageListPresenter selectedItem
		to: fileOutPath.
	[
	self assert: fileOutRef exists.
	self assert: fileOutRef extension equals: 'gs'.
	fileOutRef deleteIfAbsent: [  ].
	self projectsPresenter
		basicPackageFileout: self packageListPresenter selectedItem
		to:
			(FileSystem disk workingDirectory
			 / 'JfP_test_Rowan-Client-Services') pathString.
	self assert: fileOutRef exists.
	self assert: fileOutRef extension equals: 'gs' ] ensure: [
		FileSystem disk workingDirectory
		/ 'JfP_test_Rowan-Client-Services.gs' deleteIfAbsent: [  ].
		FileSystem disk workingDirectory
		/ 'JfP_test_Rowan-Client-Services' deleteIfAbsent: [  ] "workaround for rowan creating extra file on fileout"
		 ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_findClass [

	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform')
		methodService: nil
		onCompletion: nil.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RwGsPlatform'.
	self
		assert: self classListPresenter selectedItem definedPackageName
		equals: 'Rowan-GemStone-Core'.
	self
		assert: self packageListPresenter selectedItem name
		equals: 'Rowan-GemStone-Core'.
	self
		assert: self projectListPresenter selectedItem name
		equals: 'Rowan'.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'CypressClassDefinition')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'CypressClassDefinition'.
	self
		assert: self classListPresenter selectedItem definedPackageName
		equals: 'Cypress-Definitions'.
	self
		assert: self packageListPresenter selectedItem name
		equals: 'Cypress-Definitions'.
	self
		assert: self projectListPresenter selectedItem name
		equals: 'Cypress'.
	self
		assert:
		(self projectListPresenter selectedItem sortedPackages collect:
			 #name)
		equals: (self packageListPresenter list collect: #name).
	self
		assert:
		(self packageListPresenter selectedItem sortedClasses collect: #name)
		equals: (self classListPresenter list collect: #name)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_gitBranchSelection [
	"It's a little hard to test loading a branch because it 
	might disturb development code so just test that the branches get
	listed."

	| listDialog loadedProject |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	listDialog := self waitForListDialogWindowWhile: [
		              self projectsPresenter gitCheckoutBranch ].
	[
	self denyIsNil: listDialog list.
	loadedProject := listDialog list
		                 detect: [ :string | string first = $* ]
		                 ifNone: [  ].
	self denyIsNil: loadedProject "* in the name means loaded project. A good sign we've got a valid list" ]
		ensure: [ listDialog cancel ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hierarchyExpansion [
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
JadeiteForPharoBrowserTestCase >> test_hierarchySelectionChangePackage [

	self
		testsIssue: #issue175
		withTitle:
		'[jpf] change packages from hierarchy view gives walkback'. "https://github.com/GemTalk/JadeiteForPharo/issues/175"
	self selectRowanAnsweringService.
	self selectHierarchyTab.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'RowanAnsweringService'.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
	self
		assert: self packageListPresenter selectedItem name
		equals: 'Rowan-Services-Tests'.
	self assert: self projectsPresenter isClassListTabSelected.
	self assertIsNil: self projectsPresenter selectedClass
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodCompileError [

	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self
		selectServiceNamed: 'RowanSample1-Extensions'
		in: self packageListPresenter.
	self
		selectServiceNamed: self sampleClassName
		in: self classListPresenter.
	self selectMethodNamed: #foo. "select a method defined in it's class package while the extension class is selected"
	self methodSourcePresenter value: self compileErrorMethodText.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: nil.
	self
		assert: self methodSourcePresenter text
		equals: self compileErrorMethodTextShowingCompileError.
	self
		assert: self projectsPresenter statusBarText message
		equals: 'CompileError - expected a right bracket (])'.
	self methodSourcePresenter hasUnacceptedEdits: false
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectInfoTab [
	"test a few of the values to ensure the format the gui is expecting doesn't change"
	| mockService items |
	mockService := self projectInfoMockService.
	self projectsPresenter updateProjectInfoTabFor: mockService.

	items := self projectsPresenter projectInfoList items.
	self assert: items notEmpty.
	self assert: (items anySatisfy: [ :each |
			 each label = 'Name' and: [ each value = 'MyProject' ] ]).
	self assert: (items anySatisfy: [ :each |
			 each label = 'SHA' and: [ each value = 'abc123' ] ]).
	self assert: (items anySatisfy: [ :each |
			 each label = 'Disk SHA' and: [ each value = 'def456' ] ]).
	self assert: (items anySatisfy: [ :each | each label = 'Packages' ]).
	self assert:
		(items anySatisfy: [ :each | each value = 'MockDictionary' ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectInfoTabUnpackaged [
	
	| unpackagedService items |
	unpackagedService := self projectsPresenter selectProjectNamed:
		                     'UnPackaged'.
	self projectsPresenter selectProjectInfoTab.

	items := self projectsPresenter projectInfoList items.
	self assert: items notEmpty.
	self assert: (items anySatisfy: [ :each |
			 each label = 'Name' and: [ each value = 'UnPackaged' ] ]).
	self assert: (items anySatisfy: [ :each |
			 each label = 'SHA' and: [ each value = '' ] ]). "handles blanks"
	self assert: (items anySatisfy: [ :each |
			 each label = 'Disk SHA' and: [ each value = '' ] ]).
	self assert: (items anySatisfy: [ :each | each label = 'Packages' ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectLoadAddedInAlphabeticalOrder [

	| projects projectName |
	self
		testsJadeiteForPharoIssue: #issue21
		title:
		'loading a new project externally and then aborting ends up with new project at bottom of console'.
	JadeiteApplication abortTransactionInSession: session.
	projectName := 'TestAlphabatizingProject'.
	self assertIsNil: (self projectNamed: projectName).
	self projectsPresenter basicCreateProject: projectName.
	self denyIsNil: (self projectNamed: projectName).
	[
	self unloadProject: projectName.
	self assertIsNil: (self projectNamed: projectName).
	projectsBrowser
		installProjectFromPath:
			'$ROWAN_PROJECTS_HOME/' , projectName , '/rowan/specs/'
			, projectName , '.ston'
		projectsHome: '$ROWAN_PROJECTS_HOME'.
	projects := self projectList collect: [ :projectService |
		            projectService name ].
	self
		assert: projects
		equals:
			(projects asSortedCollection: [ :x :y |
				 x asLowercase < y asLowercase ]) asOrderedCollection ] ensure: [
		self unloadProjectAndDeleteOnDisk: projectName ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectOrderDoesNotChange [

	| projectsBefore projectsAfter projectName |
	self
		testsJadeiteForPharoIssue: #issue21
		title:
		'loading a new project externally and then aborting ends up with new project at bottom of console'.

	projectName := 'TestAlphabatizingProject'.
	self assertIsNil: (self projectNamed: projectName).
	self projectsPresenter basicCreateProject: projectName.
	self denyIsNil: (self projectNamed: projectName).
	projectsBefore := self projectList collect: [ :projectService |
		                  projectService name ].
	self unloadProject: projectName.
	[
	projectsBrowser
		installProjectFromPath:
			'$ROWAN_PROJECTS_HOME/' , projectName , '/rowan/specs/'
			, projectName , '.ston'
		projectsHome: '$ROWAN_PROJECTS_HOME'.
	projectsAfter := self projectList collect: [ :projectService |
		                 projectService name ].
	self assert: projectsBefore equals: projectsAfter ] ensure: [
		self unloadProjectAndDeleteOnDisk: projectName ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectRemoved [
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
JadeiteForPharoBrowserTestCase >> test_removeProject [

	| targetProject |
	self testsIssue: #issue129 withTitle: 'Expose unload project.'.
	targetProject := self projectNamed: self sampleProject1Name.
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
	self unloadProject: self sampleProject1Name.
	targetProject := self projectNamed: self sampleProject1Name.
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
JadeiteForPharoBrowserTestCase >> test_runTestInBrowser [

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
JadeiteForPharoBrowserTestCase >> test_saveClassOnHierarchyStaysOnHierarchy [

	self
		testsJadeiteForPharoIssue: #issu280
		title:
		'Saving a class while in hierarchy view switches you back to class view'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/280'.
	self selectServiceNamed: 'UnPackaged' in: self projectListPresenter.
	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self packageListPresenter.
	self selectHierarchyTab.
	self
		saveClass: 'TestSaveOnHierarchy'
		superclass: 'Object'
		instVars: #( 'oneInstVar' )
		package: 'UnPackaged-RowanClientServices'.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'TestSaveOnHierarchy'.
	self assert: self projectsPresenter isHierarchyTabSelected.
	self projectsPresenter
		basicRemoveClass: self classListPresenter selectedItem
		onCompletion: nil
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_selectVariable [

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
JadeiteForPharoBrowserTestCase >> test_setCurrentAfterCreatingPackage [

	self
		testsJadeiteForPharoIssue: #issue262
		title:
		'Set current project walkback (wrong number of args) when package is not committed #262'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/262'.
	self selectServiceNamed: 'UnPackaged' in: self projectListPresenter.
	self projectsPresenter
		basicAddPackageNamed: 'JfPTestSetCurrentPackage'
		symbolDictionary: 'Globals'
		componentName: 'UnPackaged'.
	self projectsPresenter setCurrentProject. "error here in bug"
	self assert: self projectListPresenter selectedItem isCurrent. 
	self assert: self projectListPresenter selectedItem displayName equals: '*UnPackaged'.
	self abortTransaction 
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_setCurrentPackage [
	"setting current package sets the current project"

	| servicesProjectService servicesPackageService |
	self projectsPresenter unsetCurrentProject.
	self assert: self projectListPresenter list notEmpty.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.
	self
		selectServiceNamed: 'Rowan-Services-Core'
		in: self packageListPresenter.
	servicesPackageService := self packageListPresenter selectedItem.
	self
		assert: servicesPackageService displayName
		equals: 'Rowan-Services-Core'.
	self deny: servicesPackageService isCurrent.

	self projectsPresenter setCurrentPackage.

	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.
	self
		assert: servicesPackageService displayName
		equals: '*Rowan-Services-Core'.
	self assert: servicesPackageService isCurrent.
	self projectsPresenter unsetCurrentProject
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_setCurrentProject [

	| servicesProjectService rowanProjectService |
	self projectsPresenter unsetCurrentProject.
	self assert: self projectListPresenter list notEmpty.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.
	self projectsPresenter setCurrentProject.
	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.

	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	rowanProjectService := self projectListPresenter selectedItem.
	self assert: rowanProjectService displayName equals: 'Rowan'.
	self deny: rowanProjectService isCurrent.
	self projectsPresenter setCurrentProject.
	self assert: rowanProjectService displayName equals: '*Rowan'.
	self assert: rowanProjectService isCurrent.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.

	self projectsPresenter unsetCurrentProject.
	self assert: rowanProjectService displayName equals: 'Rowan'.
	self deny: rowanProjectService isCurrent
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

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_unsetCurrentPackage [

	| servicesProjectService servicesPackageService |
	self projectsPresenter unsetCurrentProject.
	self assert: self projectListPresenter list notEmpty.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.
	self
		selectServiceNamed: 'Rowan-Services-Core'
		in: self packageListPresenter.
	servicesPackageService := self packageListPresenter selectedItem.
	self
		assert: servicesPackageService displayName
		equals: 'Rowan-Services-Core'.
	self deny: servicesPackageService isCurrent.

	self projectsPresenter setCurrentPackage.

	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.
	self
		assert: servicesPackageService displayName
		equals: '*Rowan-Services-Core'.
	self assert: servicesPackageService isCurrent.

	self projectsPresenter unsetCurrentPackage.
	self
		assert: servicesPackageService displayName
		equals: 'Rowan-Services-Core'.
	self deny: servicesPackageService isCurrent.
	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.

	self projectsPresenter unsetCurrentProject.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_unsetCurrentProject [

	| servicesProjectService |
	self projectsPresenter unsetCurrentProject.
	self projectListPresenter items do: [ :projectService |
		self deny: (projectService displayName includes: $*).
		self deny: projectService isCurrent ].
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.

	self projectsPresenter setCurrentProject.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.

	self projectsPresenter unsetCurrentProject.
	self projectListPresenter items do: [ :projectService |
		self deny: (projectService displayName includes: $*).
		self deny: projectService isCurrent ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> unloadProject: projectName [

	self projectsPresenter
		basicUnloadProjects: (Array with: projectName)
		onCompletion: [  ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> unloadProjectAndDeleteOnDisk: projectName [
	"WARNING! This will remove the project's local disk directory"

	| testService |
	self unloadProject: projectName.
	testService := RowanTestService new.
	testService
		command: #deleteProjectNamedOnDisk:;
		commandArgs: (Array with: projectName).
	self issueCommand: testService onCompletion: [  ]
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> waitForListDialogWindowWhile: aBlock [

	| existingListDialogs newMethodLists count |
	RsrGarbageCollector maximumReclamation.
	existingListDialogs := JadeiteSearchDialogWindow allInstances.
	aBlock fork.
	count := 0.
	[
	count > 100 or: [
		(newMethodLists := JadeiteSearchDialogWindow allInstances
			                   asOrderedCollection) size
		> existingListDialogs size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	newMethodLists removeAll: existingListDialogs.
	^ newMethodLists first
]
