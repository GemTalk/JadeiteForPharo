"
browser tests that depend on Rowan available = true should go here
"
Class {
	#name : 'JadeiteForPharoBrowserTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'dictionary',
		'failedMethodPresenter'
	],
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

{ #category : 'accessing' }
JadeiteForPharoBrowserTestCase >> application [
	"Spec2 needs this to open a browser via preferences"
	^JadeiteConsoleApplication new gciSession: GciSession current 
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> assertNoSelectedClass [

	self assertIsNil: self projectsPresenter selectedClass
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> deleteFileInTestFile [

	| path |
	path := self fileInFilePath.
	(session executeString: '''' , path , ''' asFileReference exists')
		ifTrue: [
		session executeString: '''' , path , ''' asFileReference delete' ].
	^ path
]

{ #category : 'constants' }
JadeiteForPharoBrowserTestCase >> fileInClassName [

	^ 'TestFileIn'
]

{ #category : 'constants' }
JadeiteForPharoBrowserTestCase >> fileInFileName [

	^ 'TestFileIn.gs'
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> fileInFilePath [

	| answeringService sem path |
	answeringService := RowanAnsweringServiceClient new
		                    command: #pathInWorkingDirectoryFor:;
		                    commandArgs: (Array with: self fileInFileName).
	sem := Semaphore new.
	self issueCommand: answeringService onCompletion: [ :svc |
		path := svc answer.
		sem signal ].
	sem wait.
	^ path
]

{ #category : 'accessing' }
JadeiteForPharoBrowserTestCase >> gciSession [

	^GciSession current 
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> performTest [

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'Rowan not available. Test not run' ].
	^ super performTest
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> setUp [

	super setUp.
	JadeitePreferences isRowanAvailable ifFalse: [ ^ self ].
	JadeitePreferences isRowanLoaded: true.
	self setupProjectBrowser
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> tearDown [

	self destroy: failedMethodPresenter.
	secondPresenter ifNotNil: [ self destroy: secondPresenter owner ].
	dictionary ifNotNil: [
		[ self projectsPresenter removeDictionary ]
			on: ProvideAnswerNotification
			do: [ :not | not resume: true ] ].
	super tearDown
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_abortOnVariablesTab [

	self unloadSampleProject1.
	self commitTransaction.
	self ensureRowanSampleClassesLoaded.
	self selectRowanSample1Test.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selectIndex: 1.
	self abortTransaction.
	[
	self assert:
		self projectsPresenter variableListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self packageListPresenter list isEmpty ] ensure: [
		self ensureRowanSampleClassesLoaded ]
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
				self ensureRowanSampleClassesLoaded]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_abstractTestClassesHaveNoRunButton [

	self
		testsJadeiteForPharoIssue: #issue166
		title: 'Running sunit tests from button on class'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/166'.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
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
JadeiteForPharoBrowserTestCase >> test_addDictionary [

	| firstAnswer secondAnswer |
	self projectsPresenter selectDictionaryListTab.
	self projectsPresenter selectProjectNamed: 'UnPackaged'.
	firstAnswer := 'JfPTestDictionary'.
	secondAnswer := true.
	[ self projectsPresenter addDictionary ]
		on: ProvideAnswerNotification
		do: [ :not1 |
			| resumeValue |
			resumeValue := firstAnswer ifNil: [ secondAnswer ].
			firstAnswer := nil.
			not1 resume: resumeValue ].
	dictionary := self dictionaryListPresenter selectedItem. "will get removed in tearDown"
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'JfPTestDictionary'
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

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_browseInExistingBrowserFromMethodList [

	| sunitTestMethod index |
	"dolphin issue"
	self
		testsIssue: #issue827
		withTitle:
		'Would be nice to be able to request that all browse menu items be routed to an existing project browser'.
	self
		testsJadeiteForPharoIssue: #issue267
		title:
		'could use "Browse in existing package browser" from method browsers'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/267'.
	self newBrowser.
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
	sunitTestMethod := methodListBrowser methodListPresenter items
		                   detect: [ :methodService |
		                   methodService className = 'SUnitTest' ].
	index := methodListBrowser methodListPresenter items indexOf:
		         sunitTestMethod.
	methodListBrowser methodListPresenter selectIndex: index.
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
	projectsBrowser tabs selectPageIndex: 1.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanSample1Test'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #testError
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
JadeiteForPharoBrowserTestCase >> test_browseUnsavedMethod [
	"an unsaved method shouldn't be overwritten with original source
	if a new browser is opened on the same method."

	self selectRowanAnsweringService.
	self selectCategoryNamed: 'client commands'.
	self selectMethodNamed: #allProcesses.
	self deny:
		self methodSourcePresenter adapter widget hasUnacceptedEdits.
	self methodSourcePresenter text: self methodSourcePresenter text
		, ' add some text to make method pane dirty'.
	self assert:
		self methodSourcePresenter adapter widget hasUnacceptedEdits.

	secondBrowser := self projectsPresenter browseMethodClass presenter.
	self assert:
		self methodSourcePresenter adapter widget hasUnacceptedEdits.
	secondPresenter := secondBrowser activePresenter.
	self deny: secondPresenter methodSourcePresenter adapter widget
			hasUnacceptedEdits.
	"note to self - browseMethodClass selects the correct method interactively but not in the test.
	Need to track down. After quite a bit of time, it's likely a hard timing/process problem. 
	Since it's only a test problem, can defer. "
	secondPresenter methodListPresenter resetSelection.
	secondPresenter methodListPresenter selection:
		(secondPresenter methodListPresenter list detect: [ :svc |
			 svc selector = #allProcesses ]).
	self assert:
		self methodSourcePresenter adapter widget hasUnacceptedEdits.
	self deny: secondPresenter methodSourcePresenter adapter widget
			hasUnacceptedEdits.
	self methodSourcePresenter adapter widget cancel
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

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_classRenameNoReferences [

	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.

	[
	self projectsPresenter selectClassNamed: 'TestClass'.
	self projectsPresenter
		basicRenameClass: self projectsPresenter selectedClass
		to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
			 detect: [ :classService |
			 classService name asString = 'TestClass' ]
			 ifNone: [  ]).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RenamedClass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self classListPresenter selectedItem
			onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_classRenameNoReferencesHierarchy [

	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.

	[
	self projectsPresenter selectClassNamed: 'TestClass'.
	self selectHierarchyTab.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self projectsPresenter
		basicRenameClass: self projectsPresenter selectedClass
		to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
			 detect: [ :classService |
			 classService name asString = 'TestClass' ]
			 ifNone: [  ]).
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'RenamedClass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_classRenameResetsClassDefinition [

	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.

	[
	self projectsPresenter selectClassNamed: 'TestClass'.
	self projectsPresenter
		basicRenameClass: self projectsPresenter selectedClass
		to: 'RenamedClass'.
	self assert: ('*Object rwSubclass: ''RenamedClass''*' match:
			 self projectsPresenter classDefinitionPresenter text) ] ensure: [
		self projectsPresenter
			basicRemoveClass: self classListPresenter selectedItem
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_classRenameShowsMethods [
	"don't lose the method display on rename"

	| methodList |
	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	"essentially by not using the test dialog box we test Jadeite's part of the fix for #513. The rest was in Rowan"
	self
		testsIssue: #issue513
		withTitle: 'Class rename also updates method sends (3.0.76)'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.

	[
	self projectsPresenter selectClassNamed: 'TestClass'.
	methodList := self methodListPresenter list.
	self projectsPresenter
		basicRenameClass: self projectsPresenter selectedClass
		to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
			 detect: [ :classService |
			 classService name asString = 'TestClass' ]
			 ifNone: [  ]).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RenamedClass'.
	self
		assert: self methodListPresenter list asOrderedCollection
		equals: methodList asOrderedCollection ] ensure: [
		self projectsPresenter
			basicRemoveClass: self classListPresenter selectedItem
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_classRenameWithReferences [

	| list |
	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  ^TestClass'
		in: 'RefersToTestClass'
		category: 'foo'.

	self projectsPresenter selectClassNamed: 'TestClass'.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			basicRenameClass: self projectsPresenter selectedClass
			to: 'RenamedClass' ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RenamedClass'.
	list := methodListBrowser methodListPresenter list collection.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self
		assert:
			methodListBrowser methodSourcePresenter adapter widget textArea
				selection asString
		equals: 'RenamedClass'
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_classRenameWithReferencesFailingCompile [

	| list |
	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'Sub'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'SubString'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  | subString | subString := SubString. ^Sub'
		in: 'RefersToTestClass'
		category: 'wontCompile'. "method refers to both. Will fail compilation
							based on current limitations in recompile method server code"
	self projectsPresenter selectClassNamed: 'Sub'.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			basicRenameClass: self projectsPresenter selectedClass
			to: 'RenamedClass' ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RenamedClass'.
	list := methodListBrowser methodListPresenter list collection.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self assert: list first failedCompile. "should show up as red. No way to easily test that"
	"Not really sure this assertion should be valid anymore. self
		assert:
		methodListBrowser methodSourcePresenter codePane selectionInterval
		equals: (46 to: 48)" "select old class on compile"
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_classRenameWithReferencesHierarchy [

	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  ^TestClass'
		in: 'RefersToTestClass'
		category: 'foo'.

	[
	self projectsPresenter selectClassNamed: 'TestClass'.
	self selectHierarchyTab.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			basicRenameClass: self projectsPresenter selectedClass
			to: 'RenamedClass' ].
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'RenamedClass'.
	self
		assert: methodListBrowser methodListPresenter list collection size
		equals: 1.
	self
		assert:
		methodListBrowser methodListPresenter list collection first selector
		equals: #meth.
	self
		assert:
			methodListBrowser methodSourcePresenter adapter widget textArea
				selection asString
		equals: 'RenamedClass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_classRenameWithReferencesSimilarNameButNoFailCompile [

	| list |
	self
		testsIssue: #issue439
		withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'Sub'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'SubString'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  | subString | subString := SubString. ^Sub'
		in: 'RefersToTestClass'
		category: 'foo'.

	[
	self projectsPresenter selectClassNamed: 'SubString'.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			basicRenameClass: self projectsPresenter selectedClass
			to: 'RenamedClass' ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RenamedClass'.
	list := methodListBrowser methodListPresenter list collection.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self
		assert:
			methodListBrowser methodSourcePresenter adapter widget textArea
				selection asString
		equals: 'RenamedClass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self classListPresenter selectedItem
			onCompletion: [  ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_compileClass [

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
		assert: self projectsPresenter classDefinitionPresenter text
		equals: 'Object rwSubclass: ''TestClass''
	instVarNames: #( abc)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()
' replaceCrWithLf
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
JadeiteForPharoBrowserTestCase >> test_currentPackageFirstInMoveList [

	| browserService packageServices first |
	self projectsPresenter unsetCurrentProject.
	self selectRowanAnsweringService.
	browserService := RowanBrowserService new
		                  command: #allPackages;
		                  commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: browserService
		session: session
		onCompletion: [ :svc |
			packageServices := projectsBrowser packageListForSearchDialog: svc ].
	first := packageServices first.
	projectsBrowser setCurrentPackage.
	RowanServiceUpdater current
		issueCommand: browserService
		session: session
		onCompletion: [ :svc |
			packageServices := projectsBrowser packageListForSearchDialog: svc ].
	self assert: packageServices first name equals: 'Rowan-Services-Core'.
	self deny: packageServices first equals: first.
	self projectsPresenter unsetCurrentProject
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
				projectService name = 'RowanServicesTestProject' ifFalse: [
					self assert: projectService displayName = projectService name ] ] ] ].

	jadeiteShell projectListPresenter items do: [ :projectService |
		projectService name = 'RowanClientServices'
			ifTrue: [
			self assert: projectService displayName = '*RowanClientServices' ]
			ifFalse: [
				projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
					projectService name = 'RowanServicesTestProject' ifFalse: [
						self assert: projectService displayName = projectService name ] ] ] ].

	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self projectsPresenter setCurrentProject.
	self assert: self projectListPresenter selectedItem isCurrent.
	self
		assert: self projectListPresenter selectedItem displayName
		equals: '*Rowan'.
	self projectListPresenter items do: [ :projectService |
		projectService name = 'Rowan' ifFalse: [
			projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
				projectService name = 'RowanServicesTestProject' ifFalse: [
					self assert: projectService displayName = projectService name ] ] ] ].
	jadeiteShell projectListPresenter items do: [ :projectService |
		projectService name = 'Rowan'
			ifTrue: [ self assert: projectService displayName = '*Rowan' ]
			ifFalse: [
				projectService name = 'RowanSample1' ifFalse: [ "RowanSample1 is no longer on disk"
					projectService name = 'RowanServicesTestProject' ifFalse: [
						self assert: projectService displayName = projectService name ] ] ] ]
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
JadeiteForPharoBrowserTestCase >> test_fileIn [

	| classes newClass fileName path answeringService sem fileService |
	projectsBrowser unsetCurrentProject.
	self openProjectBrowser.
	self
		selectServiceNamed: 'UnPackaged'
		in: self projectsPresenter projectListPresenter.
	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	self projectsPresenter setCurrentProject.
	self projectsPresenter setCurrentPackage.
	self projectsPresenter packageListPresenter unselectAll.

	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self assertIsNil: newClass.

	self
		saveClass: 'TestingFileIn'
		superclass: 'Object'
		instVars: #(  )
		package: 'UnPackaged-RowanClientServices'.

	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self denyIsNil: newClass.
	self projectsPresenter selectClassNamed: 'TestingFileIn'.
	fileName := 'test_fileIn.txt'.
	answeringService := RowanAnsweringServiceClient new
		                    command: #pathInWorkingDirectoryFor:;
		                    commandArgs: (Array with: fileName).
	sem := Semaphore new.
	self issueCommand: answeringService onCompletion: [ :svc |
		path := svc answer.
		sem signal ].
	sem wait.
	self projectsPresenter fileOutClassOnPath: path.

	self abortTransaction.

	self projectsPresenter packageListPresenter unselectAll.
	self
		selectServiceNamed: 'UnPackaged'
		in: self projectsPresenter projectListPresenter.
	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self assertIsNil: newClass.

	projectsBrowser basicFileInServerFile: path.
	self
		selectServiceNamed: 'UnPackaged'
		in: self projectsPresenter projectListPresenter.
	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self denyIsNil: newClass.

	self abortTransaction.
	fileService := RowanFileServiceClient new path: path.
	fileService
		command: #remove;
		commandArgs: Array new.
	self issueCommand: fileService onCompletion: [  ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_fileIn2 [

	| path className |
	self openProjectBrowser.
	path := self deleteFileInTestFile.
	[ "Create Test Class with methods and fileout"
	className := self fileInClassName.
	self
		saveClass: className
		superclass: 'Object'
		instVars: #( 'instVarA' )
		package: 'RowanSample1-Core'.
	self saveMethod: 'method1 ^true' in: self fileInClassName.
	self saveMethod: 'method2 ^true' in: self fileInClassName.
	self saveMethod: 'method3 ^true' in: self fileInClassName.
	self projectsPresenter fileOutClassOnPath: path.
	"Remove Class "
	self assert:
		(session executeString: '''' , path , ''' asFileReference exists') ]
		ensure: [
			self projectsPresenter
				basicRemoveClass: self projectsPresenter selectedClass
				onCompletion: [  ] ].
	[
	self assertIsNil:
		(session executeString: 'Rowan globalNamed: ''' , className , '''').

	"File In"
	projectsBrowser basicFileInServerFile: path.

	"Assertions: Verify file existence, filed in class exists, and method functionality"
	self assert: (session executeString:
			 '(Rowan globalNamed: ''' , className , ''') notNil').
	self assert:
		(session executeString: self fileInClassName , ' new method1').
	self assert:
		(session executeString: self fileInClassName , ' new method2').
	self assert:
		(session executeString: self fileInClassName , ' new method3') ]
		ensure: [ self deleteFileInTestFile ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_fileInOnBrowser [
	"document that we moved our file-in menu option to the browser per issue #263"

	self
		testsJadeiteForPharoIssue: #issue263
		title:
		'Filein of server code is possible: please add menu item/file selection dialog'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/263'.
	JadeiteTestManager replacing: self uiManager.
	RowanBrowserService new unsetCurrentPackage.
	RowanBrowserService new unsetCurrentProject.
	[ projectsBrowser fileInServerFile ]
		on: ProvideAnswerNotification
		do: [ :ex |
			self
				assert: ex messageText
				equals: 'Current Project and Current Package must be set first' ].
	self uiManager restore
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_fileoutPackage [

	| fileOutPath fileOutRef |
	Smalltalk os isWindows ifTrue: [
		^ self skip:
			  'JadeiteForPharoBrowserTestCase>>#test_fileoutPackage only runs on linux pharo client (currently)' ].

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
		FileSystem disk workingDirectory / 'JfP_test_Rowan-Client-Services'
			deleteIfAbsent: [ "workaround for rowan creating extra file on fileout"
			 ] ]
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

	"Select the RowanAnsweringService class and confirm it is selected."

	self selectRowanAnsweringService.
	self selectHierarchyTab.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'RowanAnsweringService'.

	"Select the Rowan-Services-Tests package and verify it is the selected item and we switched to class side."

	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
	self
		assert: self packageListPresenter selectedItem name
		equals: 'Rowan-Services-Tests'.
	self assert: self projectsPresenter isClassListTabSelected.

	self assertNoSelectedClass
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hotKeyBrowse [
	"ctrl-b"

	| widget editor sem |
	self selectRowanAnsweringService.
	self selectMethodNamed: #updateServices:.
	self
		assert: self methodSourcePresenter text asString replaceLfWithCr
		equals: 'updateServices: services
	services
		do: [ :service | 
			service update.
			RowanCommandResult addResult: service ]'.
	widget := self methodSourcePresenter adapter widget.
	editor := widget scrollPane textArea editor.
	self methodSourcePresenter adapter widget selectFrom: 82 to: 82. "On RowanCommandResult"
	secondPresenter := self
		                   waitForNew: JadeiteBrowser
		                   while: [ editor browseIt: nil ].
	sem := Semaphore new.
	[
	[
	secondPresenter activePresenter isNil or: [
		secondPresenter selectedClass isNil ] ] whileTrue: [
		(Delay forMilliseconds: 10) wait ] ] fork.
	sem waitTimeoutSeconds: 2.
	self
		assert: secondPresenter selectedClass name
		equals: 'RowanCommandResult'
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hotKeyImplementors [
	"ctrl-m"

	| widget editor |
	self selectRowanAnsweringService.
	self selectMethodNamed: #updateServices:.
	self
		assert: self methodSourcePresenter text asString replaceLfWithCr
		equals: 'updateServices: services
	services
		do: [ :service | 
			service update.
			RowanCommandResult addResult: service ]'.
	widget := self methodSourcePresenter adapter widget.
	editor := widget scrollPane textArea editor.
	self methodSourcePresenter adapter widget selectFrom: 69 to: 69. "On update message"
	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: [ editor implementorsOfIt: nil ].
	self
		assert: methodListBrowser methodListPresenter selectedItem selector
		equals: #update.
	self assert: ('*Implementors of ''update'' for*' match:
			 methodListBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hotKeyMethodsContainingClass [
	"ctrl-shift-e"

	| widget editor |
	self selectRowanAnsweringService.
	self selectMethodNamed: #basicSortedSymbols.
	self
		assert: self methodSourcePresenter text asString replaceLfWithCr
		equals: 'basicSortedSymbols
  | sortedSymbols |
  sortedSymbols := SortedCollection new.
  ((AllUsers userWithId: #''SymbolUser'') resolveSymbol: #''AllSymbols'') value
    keysDo: [ :symbol | 
      symbol charSize = 1
        ifTrue: [ sortedSymbols add: symbol ] ].
  ^sortedSymbols asArray'.
	widget := self methodSourcePresenter adapter widget.
	editor := widget scrollPane textArea editor.
	self methodSourcePresenter adapter widget selectFrom: 67 to: 67.
	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: [ editor methodStringsContainingIt: nil ].
	self assert: ('*Methods Containing ''SortedCollection'' for*' match:
			 methodListBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hotKeyMethodsContainingMessage [
	"ctrl-shift-e"

	| widget editor |
	self selectRowanAnsweringService.
	self selectMethodNamed: #basicSortedSymbols.
	self
		assert: self methodSourcePresenter text asString replaceLfWithCr
		equals: 'basicSortedSymbols
  | sortedSymbols |
  sortedSymbols := SortedCollection new.
  ((AllUsers userWithId: #''SymbolUser'') resolveSymbol: #''AllSymbols'') value
    keysDo: [ :symbol | 
      symbol charSize = 1
        ifTrue: [ sortedSymbols add: symbol ] ].
  ^sortedSymbols asArray'.
	widget := self methodSourcePresenter adapter widget.
	editor := widget scrollPane textArea editor.
	self methodSourcePresenter adapter widget selectFrom: 100 to: 100.
	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: [ editor methodStringsContainingIt: nil ].
	self assert: ('*Methods Containing ''userWithId:'' for*' match:
			 methodListBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hotKeyMethodsContainingSymbol [
	"ctrl-shift-e"

	| widget editor |
	self selectRowanAnsweringService.
	self selectMethodNamed: #basicSortedSymbols.
	self
		assert: self methodSourcePresenter text asString replaceLfWithCr
		equals: 'basicSortedSymbols
  | sortedSymbols |
  sortedSymbols := SortedCollection new.
  ((AllUsers userWithId: #''SymbolUser'') resolveSymbol: #''AllSymbols'') value
    keysDo: [ :symbol | 
      symbol charSize = 1
        ifTrue: [ sortedSymbols add: symbol ] ].
  ^sortedSymbols asArray'.
	widget := self methodSourcePresenter adapter widget.
	editor := widget scrollPane textArea editor.
	self methodSourcePresenter adapter widget selectFrom: 113 to: 113.
	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: [ editor methodStringsContainingIt: nil ].
	self assert: ('*Methods Containing ''SymbolUser'' for*' match:
			 methodListBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_hotKeySenders [
	"ctrl-n"

	| widget editor |
	self selectRowanAnsweringService.
	self selectMethodNamed: #updateServices:.
	self
		assert: self methodSourcePresenter text asString replaceLfWithCr
		equals: 'updateServices: services
	services
		do: [ :service | 
			service update.
			RowanCommandResult addResult: service ]'.
	widget := self methodSourcePresenter adapter widget.
	editor := widget scrollPane textArea editor.
	self methodSourcePresenter adapter widget selectFrom: 69 to: 69. "On update message"
	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: [ editor sendersOfIt: nil ].
	self assert:
		('*Senders of ''update'' for*' match: methodListBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_isCurrentProjectAndPackageSet [

	| selectedProject selectedPackage |
	"Unsets any current project and package, confirming neither is set."
	projectsBrowser unsetCurrentProject.
	projectsBrowser unsetCurrentPackage.
	self deny: projectsBrowser isCurrentProjectAndPackageSet.

	"Selects and sets the first project as current, asserting it is current."

	self projectListPresenter selectIndex: 1.
	selectedProject := self projectListPresenter selectedItem.
	self deny: selectedProject isCurrent.
	projectsBrowser setCurrentProject.
	self assert: selectedProject isCurrent.
	self deny: projectsBrowser isCurrentProjectAndPackageSet.

	"Selects and sets the first package as current, asserting both are now set correctly."

	self packageListPresenter selectIndex: 1.
	selectedPackage := self packageListPresenter selectedItem.
	self deny: selectedPackage isCurrent.
	projectsBrowser setCurrentPackage.
	self assert: selectedPackage isCurrent.
	self assert: projectsBrowser isCurrentProjectAndPackageSet
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
JadeiteForPharoBrowserTestCase >> test_methodsFailingCompilationInstVarAdded [

	| className |
	className := 'Foo'.
	self
		saveClass: className
		superclass: 'Object'
		instVars: #(  )
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'aMethodWithVar | meth | meth := 1. ^meth'
		in: className
		category: 'other'.
	self
		saveMethod: 'methodWithoutVar ^1'
		in: className
		category: 'other'.
	self projectsPresenter selectClassNamed: className.
	self assert: self methodListPresenter items size equals: 2.
	self
		assert: self methodListPresenter items first selector
		equals: 'aMethodWithVar'.
	self
		assert: self methodListPresenter items last selector
		equals: 'methodWithoutVar'.
	self assert: self classListPresenter selectedItem version equals: 1.
	failedMethodPresenter := self
		                         waitForNew:
		                         JadeiteFailedCompileMethodListPresenter
		                         while: [
			                         self
				                         saveClass: className
				                         superclass: 'Object'
				                         instVars: #( 'meth' )
				                         package: 'RowanSample1-Tests' ].
	self assert: self methodListPresenter items size equals: 1.
	self
		assert: self methodListPresenter items first selector
		equals: 'methodWithoutVar'.
	self assert: self classListPresenter selectedItem version equals: 2.
	self
		assert: failedMethodPresenter
		isKindOf: JadeiteFailedCompileMethodListPresenter.
	self
		assert: failedMethodPresenter methodListPresenter items size
		equals: 1.
	self
		assert:
		failedMethodPresenter methodListPresenter items first searchString
		equals: failedMethodPresenter firstReferenceString.
	self
		assert: failedMethodPresenter methodSourcePresenter text
		equals:
		'aMethodWithVar | variable has already been declared->meth | meth := 1. ^meth'.
	failedMethodPresenter window close
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodsFailingCompilationInstVarRemoved [

	| className sources |
	"We don't know what order the methods will appear in the list. 
	Test that both expected sources were present. "
	className := 'Foo'.
	self
		saveClass: className
		superclass: 'Object'
		instVars: #( 'abc' )
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'abc: param abc := param. '
		in: className
		category: 'accessing'.
	self saveMethod: 'abc  ^abc' in: className category: 'accessing'.
	self projectsPresenter selectClassNamed: className.
	self assert: self methodListPresenter items size equals: 2.
	self
		assert: self methodListPresenter items first selector
		equals: 'abc'.
	self
		assert: self methodListPresenter items last selector
		equals: 'abc:'.
	self assert: self classListPresenter selectedItem version equals: 1.
	failedMethodPresenter := self
		                         waitForNew:
		                         JadeiteFailedCompileMethodListPresenter
		                         while: [
			                         self
				                         saveClass: className
				                         superclass: 'Object'
				                         instVars: #(  )
				                         package: 'RowanSample1-Tests' ].
	self assert: self methodListPresenter items size equals: 0.
	self assert: self classListPresenter selectedItem version equals: 2.
	self
		assert: failedMethodPresenter
		isKindOf: JadeiteFailedCompileMethodListPresenter.
	self
		assert: failedMethodPresenter methodListPresenter items size
		equals: 2.
	self
		assert:
		failedMethodPresenter methodListPresenter items first searchString
		equals: failedMethodPresenter firstReferenceString.
	self
		assert:
		failedMethodPresenter methodListPresenter selection selectedIndex
		equals: 1.
	sources := OrderedCollection new.
	sources add: failedMethodPresenter methodSourcePresenter text.
	failedMethodPresenter methodListPresenter adapter widget
		selectIndex: 1.
	failedMethodPresenter methodListPresenter adapter widget
		selectIndex: 2.
	sources add: failedMethodPresenter methodSourcePresenter text.
	self assert: (sources includes: 'abc  ^undefined symbol->abc').
	self assert:
		(sources includes: 'abc: param undefined symbol->abc := param. ').
	failedMethodPresenter window close
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodsFailingCompilationSuperClassInstVarAddition [

	| superclassName subclassName |
	superclassName := 'Foo'.
	self
		saveClass: superclassName
		superclass: 'Object'
		instVars: #(  )
		package: 'RowanSample1-Tests'.
	subclassName := 'FooSub'.
	self
		saveClass: subclassName
		superclass: 'Foo'
		instVars: #(  )
		package: 'RowanSample1-Tests'.
	self projectsPresenter selectClassNamed: subclassName.
	self
		saveMethod: 'aMethodWithVar | meth | meth := 1. ^meth'
		in: subclassName
		category: 'other'.
	self
		saveMethod: 'methodWithoutVar ^1'
		in: subclassName
		category: 'other'.
	self assert: self methodListPresenter items size equals: 2.
	self
		assert: self methodListPresenter items first selector
		equals: 'aMethodWithVar'.
	self
		assert: self methodListPresenter items last selector
		equals: 'methodWithoutVar'.
	self assert: self classListPresenter selectedItem version equals: 1.
	self projectsPresenter selectClassNamed: superclassName.
	failedMethodPresenter := self
		                         waitForNew:
		                         JadeiteFailedCompileMethodListPresenter
		                         while: [
			                         self
				                         saveClass: superclassName
				                         superclass: 'Object'
				                         instVars: #( 'meth' )
				                         package: 'RowanSample1-Tests' ].
	(Delay forMilliseconds: 250) wait.
	self projectsPresenter selectClassNamed: subclassName.
	self assert: self methodListPresenter items size equals: 1.
	self
		assert: self methodListPresenter items first selector
		equals: 'methodWithoutVar'.
	self assert: self classListPresenter selectedItem version equals: 2.
	self projectsPresenter selectClassNamed: superclassName.
	self assert: self classListPresenter selectedItem version equals: 2.
	self
		assert: failedMethodPresenter
		isKindOf: JadeiteFailedCompileMethodListPresenter.
	self
		assert: failedMethodPresenter methodListPresenter items size
		equals: 1.
	self
		assert: failedMethodPresenter methodSourcePresenter text
		equals:
		'aMethodWithVar | variable has already been declared->meth | meth := 1. ^meth'.
	failedMethodPresenter window close
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodsFailingCompilationSuperClassInstVarRemoval [

	| superclassName subclassName |
	superclassName := 'Foo'.
	self
		saveClass: superclassName
		superclass: 'Object'
		instVars: #( 'meth' )
		package: 'RowanSample1-Tests'.
	subclassName := 'FooSub'.
	self
		saveClass: subclassName
		superclass: 'Foo'
		instVars: #(  )
		package: 'RowanSample1-Tests'.
	self projectsPresenter selectClassNamed: subclassName.
	self
		saveMethod: 'aMethodWithVar meth := 1. ^meth'
		in: subclassName
		category: 'other'.
	self
		saveMethod: 'methodWithoutVar ^1'
		in: subclassName
		category: 'other'.
	self assert: self methodListPresenter items size equals: 2.
	self
		assert: self methodListPresenter items first selector
		equals: 'aMethodWithVar'.
	self
		assert: self methodListPresenter items last selector
		equals: 'methodWithoutVar'.
	self assert: self classListPresenter selectedItem version equals: 1.
	self projectsPresenter selectClassNamed: superclassName.
	failedMethodPresenter := self
		                         waitForNew:
		                         JadeiteFailedCompileMethodListPresenter
		                         while: [
			                         self
				                         saveClass: superclassName
				                         superclass: 'Object'
				                         instVars: #(  )
				                         package: 'RowanSample1-Tests' ].
	(Delay forMilliseconds: 250) wait.
	self projectsPresenter selectClassNamed: subclassName.
	self assert: self methodListPresenter items size equals: 1.
	self
		assert: self methodListPresenter items first selector
		equals: 'methodWithoutVar'.
	self assert: self classListPresenter selectedItem version equals: 2.
	self projectsPresenter selectClassNamed: superclassName.
	self assert: self classListPresenter selectedItem version equals: 2.
	self
		assert: failedMethodPresenter
		isKindOf: JadeiteFailedCompileMethodListPresenter.
	self
		assert: failedMethodPresenter methodListPresenter items size
		equals: 1.
	self
		assert: failedMethodPresenter methodSourcePresenter text
		equals: 'aMethodWithVar undefined symbol->meth := 1. ^meth'.
	failedMethodPresenter window close
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectInfoTab [
	"test a few of the values to ensure the format the gui is expecting doesn't change"

	| mockService items |
	mockService := MockService new.
	self projectsPresenter updateProjectInfoTabFor: mockService.

	items := self projectsPresenter projectInfoList items.
	self assert: items notEmpty.
	self assert: (items anySatisfy: [ :each |
			 each column1 = 'Name' and: [ each column2 = 'MyProject' ] ]).
	self assert: (items anySatisfy: [ :each |
			 each column1 = 'SHA' and: [ each column2 = 'abc123' ] ]).
	self assert: (items anySatisfy: [ :each |
			 each column1 = 'Disk SHA' and: [ each column2 = 'def456' ] ]).
	self assert: items second column4 equals: 'MockPackageService'.
	self assert: items second column5 equals: 'MockDictionary'
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectInfoTabShowsRequiredProjects [
	"Assume Rowan required projects won't change - big assumption"

	| items headerRow firstRow secondRow |
	self
		testsJadeiteForPharoIssue: #issue330
		title:
		'Project Browser should provided way of listing/displaying required projects & projects that are required'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/330'.

	self selectRowanDictionaryOrPackage.

	items := self projectsPresenter projectInfoList items.
	self assert: items notEmpty.
	headerRow := items first.
	self assert: headerRow column1 equals: 'Attribute'.
	self assert: headerRow column2 equals: 'Value'.
	self assert: headerRow column3 equals: 'Required Projects'.
	self assert: headerRow column4 equals: 'Packages'.
	self assert: headerRow column5 equals: 'Package''s Dictionary Name'.
	firstRow := items second.
	self assert: firstRow column3 equals: 'Cypress'.
	secondRow := items third.
	self assert: secondRow column3 equals: 'STON'
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
			 each column1 = 'Name' and: [ each column2 = 'UnPackaged' ] ]).
	self assert: (items anySatisfy: [ :each |
			 each column1 = 'SHA' and: [ each column2 = '' ] ]). "handles blanks"
	self assert: (items anySatisfy: [ :each |
			 each column1 = 'Disk SHA' and: [ each column2 = '' ] ]).
	self assert: (items anySatisfy: [ :each | each column4 = 'Packages' ])
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

	"Select the target project using self sampleProject1Name."
	targetProject := self projectNamed: self sampleProject1Name.
	self denyIsNil: targetProject.
	self projectListPresenter selection: targetProject.

	"Select the first item in each of the package, class, category, and method list presenters."
	self packageListPresenter selection:
		self packageListPresenter list first.
	self classListPresenter selection: self classListPresenter list first.
	self categoryListPresenter selection:
		self categoryListPresenter list first.
	self methodListPresenter selection:
		self methodListPresenter list first.

	"Unload the project using self sampleProject1Name."
	self unloadProject: self sampleProject1Name.

	"Confirm the target project is nil."
	targetProject := self projectNamed: self sampleProject1Name.
	self assertIsNil: targetProject.

	"Assert that all list presenters are empty."
	self assert: self projectListPresenter selections isEmpty.
	self assert: self packageListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self categoryListPresenter list isEmpty.
	self assert: self methodListPresenter list isEmpty
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_renameClassWhileSelectedInSUnitBrowser [

	| sunitBrowser |
	self
		testsJadeiteForPharoIssue: #issue328
		title:
		'Walkback when test class renamed that is selected in SUnit browser '
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/328'.
	self selectRowanSample1Test.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'RowanSample1Test'.
	self
		waitForNew: JadeiteSUnitPresenter
		while: [ sunitBrowser := self openSUnitBrowser ].
	[
	self
		selectServiceNamed: 'RowanSample1-Tests'
		in: sunitBrowser packageListPresenter.
	self
		selectServiceNamed: 'RowanSample1Test'
		in: sunitBrowser classListPresenter.
	self projectsPresenter
		basicRenameClass: self projectsPresenter selectedClass
		to: 'RowanSample1Test2'.
	self
		assert: sunitBrowser classListPresenter selectedItem name
		equals: 'RowanSample1Test2'.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'RowanSample1Test2' ] ensure: [ self destroy: sunitBrowser ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_resetClassDefinitionTemplate_noProjectSelection [

	self projectListPresenter unselectAll.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_resetClassDefinitionTemplate_packageSelected [

	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self
		selectServiceNamed: 'RowanSample1-Tests'
		in: self packageListPresenter.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_resetClassDefinitionTemplate_projectSelection [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_runButtonSelectsClass [

	| browserTest |
	self
		testsJadeiteForPharoIssue: #issue166
		title: 'Running sunit tests from button on class'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/166'.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
	browserTest := self classListPresenter items detect: [ :classService |
		               classService name = 'RowanBrowserServiceTest' ].
	self assertIsNil: self classListPresenter selectedItem.
	self projectsPresenter debugMethodTests: browserTest.
	self assert: self classListPresenter selectedItem equals: browserTest
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_runClassTestsInBrowser [

	| classService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	classService := self classListPresenter selectedItem.
	self
		assert:
			(self projectsPresenter classListPresenter displayIcon value:
				 classService) labelGraphic
		equals: (Smalltalk ui icons iconNamed: #testNotRun).
	self projectsPresenter debugMethodTests: classService.
	(Delay forMilliseconds: 2000) wait. "arbitrary wait could be improved. "
	self
		assert:
			(self projectsPresenter classListPresenter displayIcon value:
				 classService) labelGraphic
		equals: (Smalltalk ui icons iconNamed: #testGreen)
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
	self projectsPresenter debugMethodTests: methodService.
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
JadeiteForPharoBrowserTestCase >> test_titleChangedAfterTabRemoved [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	projectsBrowser openBrowserTab.
	projectsBrowser findClassService:
		(RowanClassService new name: 'AbstractFileReference').
	self
		assert: projectsBrowser tabs pages first title
		equals: '1 RowanClientServices'.
	self
		assert: projectsBrowser tabs pages last title
		equals: '2 AbstractFileReference'.
	self assert: projectsBrowser tabs pages size equals: 2.
	projectsBrowser openBrowserTab.
	projectsBrowser findClassService:
		(RowanClassService new name: 'Collection').
	self assert: projectsBrowser tabs pages size equals: 3.
	self
		assert: projectsBrowser tabs pages first title
		equals: '1 RowanClientServices'.
	self
		assert: projectsBrowser tabs pages second title
		equals: '2 AbstractFileReference'.
	self
		assert: projectsBrowser tabs pages last title
		equals: '3 Collection'.
	projectsBrowser openBrowserTab.
	projectsBrowser findClassService:
		(RowanClassService new name: 'CypressError').
	self
		assert: projectsBrowser tabs pages first title
		equals: '1 RowanClientServices'.
	self
		assert: projectsBrowser tabs pages second title
		equals: '2 AbstractFileReference'.
	self
		assert: projectsBrowser tabs pages third title
		equals: '3 Collection'.
	self
		assert: projectsBrowser tabs pages last title
		equals: '4 CypressError'.

	"remove tabs"
	projectsBrowser tabs removePageAt: 1.
	self
		assert: projectsBrowser tabs pages first title
		equals: '1 AbstractFileReference'.
	self
		assert: projectsBrowser tabs pages second title
		equals: '2 Collection'.
	self
		assert: projectsBrowser tabs pages last title
		equals: '3 CypressError'.

	projectsBrowser tabs removePageAt: 1.
	self
		assert: projectsBrowser tabs pages first title
		equals: '1 Collection'.
	self
		assert: projectsBrowser tabs pages last title
		equals: '2 CypressError'.

	projectsBrowser tabs removePageAt: 1.
	self
		assert: projectsBrowser tabs pages last title
		equals: '1 CypressError'
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

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> unloadProject: projectName [

	self projectsPresenter
		basicUnloadProjects: (Array with: projectName)
		onCompletion: [  ]
]

{ #category : 'support' }
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
