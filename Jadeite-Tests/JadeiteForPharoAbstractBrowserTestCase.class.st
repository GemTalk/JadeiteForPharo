Class {
	#name : 'JadeiteForPharoAbstractBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'secondBrowser',
		'secondPresenter',
		'transcriptWritesWereEnabled'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteForPharoAbstractBrowserTestCase class >> isAbstract [

	^ self name = #JadeiteForPharoAbstractBrowserTestCase
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> addChildrenOf: item to: items [
	| children |
	children := self classHierarchyPresenter childrenFor: item.
	children isEmpty ifTrue:[^self].
	children do:[:child |
		items add: child. 
		self addChildrenOf: child to: items]
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> hierarchyVisibleItems [
	"return a collection of all visible items in the tree"
	| items |

	items := OrderedCollection new. 
	items add: self classHierarchyPresenter roots first. 
	self addChildrenOf: self classHierarchyPresenter roots first to: items. 
	^items

]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> methodMenuItemNamed: aString [

	self methodListPresenter contextMenu menuGroups do: [ :group |
		group menuItems do: [ :item |
			item name = aString ifTrue: [ ^ item ] ] ].
	^ nil
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> morphicMethodSourceHasUnacceptedEdits [

	^self methodSourcePresenter withAdapterDo: [ :adapter | adapter widgetDo:[:widget | widget hasUnacceptedEdits ] ]
]

{ #category : 'not working tests' }
JadeiteForPharoAbstractBrowserTestCase >> moveMethodToCategory [
	"not sure why the code works but the test just won't pass"
	self selectRowanSample1Class.
	self projectsPresenter basicAddMethodCategory: 'foo'.
	self saveSampleMethod.
	self selectMethodNamed: 'sampleMethod'.
	self
		assert: self methodListPresenter selectedItem category
		equals: 'foo'.
	self projectsPresenter
		moveMethods: (Array with: self methodListPresenter selectedItem)
		toCategory: (JadeiteCategory named: 'accessing').
	self
		assert: self methodListPresenter selectedItem category
		equals: 'accessing'.
	self
		assert: self categoryListPresenter selectedItem categoryName
		equals: 'accessing'
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> openSecondBrowser [

	secondBrowser := self jadeiteTestResourceClass current openWindow: [
		                 self transcript openBrowser ].
	secondBrowser caption: 'second browser'.
	secondPresenter := secondBrowser currentCard.
	secondPresenter selectClassListTab.
	^ secondBrowser
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> projectBrowserTabs [

	^ projectsBrowser tabs pages
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAbstractBrowserTestCase >> projectInConsoleNamed: aString [
	^jadeiteShell projectListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> projectList [
	^self projectListPresenter list
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAbstractBrowserTestCase >> projectNamed: aString [
	^self projectListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> selectRowanAnsweringService [

	self selectRowanDictionaryOrPackage.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> selectRowanClassServiceNamed: className [

	self selectRowanDictionaryOrPackage.
	self selectServiceNamed: className in: self classListPresenter
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> selectRowanDictionaryOrPackage [

	JadeitePreferences isRowanLoaded
		ifTrue: [
			self
				selectServiceNamed: 'RowanClientServices'
				in: self projectListPresenter.
			self
				selectServiceNamed: 'Rowan-Services-Core'
				in: self packageListPresenter ]
		ifFalse: [
			self
				selectServiceNamed: 'RowanClientServices'
				in: self dictionaryListPresenter.
			self classCategoryPresenter selectItem:
				(RowanClassCategoryService new
					 name: 'Rowan';
					 substringIndex: 1;
					 yourself) ]
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> setupMultipleReferencesToString [

	| source |
	self selectRowanSample1Test.
	source := 'flub1
| array |
array := Array new. 
array add: ''blerf''.
array add: ''blerf''. 
array add: ''blerf''. 
^array'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: [  ].
	source := 'flub2
| array |
array := Array new. 
array add: ''blerf''.
array add: ''blerf''. 
array add: ''blerf''. 
^array'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: [  ].
	source := 'flub3
| array |
array := Array new. 
array add: ''blerf''.
array add: ''blerf''. 
array add: ''blerf''.  
^array'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: [  ]
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> tearDown [

	super tearDown.
	(session isNotNil and: [ session isValidSession ]) ifTrue: [
		transcriptWritesWereEnabled == true ifTrue: [
			transcript flipTranscript ] ].
	methodListBrowser ifNotNil: [
		self destroy: methodListBrowser.
		methodListBrowser := nil ].
	secondBrowser ifNotNil: [ :two |
		two tabs selectedPage ifNotNil: [
			two activePresenter methodSourcePresenter adapter ifNotNil: [ :a |
				a widget hasUnacceptedEdits: false ] ] ].
	self destroy: secondBrowser
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_abortOnVariablesTab [

	self unloadSampleProject1.
	self commitTransaction.
	self ensureRowanSampleProjectsLoaded.
	self selectRowanSample1Test.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selectIndex: 1.
	self abortTransaction.
	[
	self assert:
		self projectsPresenter variableListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self packageListPresenter list isEmpty ] ensure: [
		self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_abortRemovesClassAndMethod [
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

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_abuseMethodList [
	"This test doesn't appear to do much but it does exercise
	list selection aggressively. There have been occassions when
	selecting methods was progressively getting slower with no 
	explanation. This might catch one of those occasions for debugging."

	self
		testsJadeiteForPharoIssue: #issue44
		title:
		'While editing a method, can click on other methods, but method text pane not updated'.
	self selectRowanAnsweringService. 
	1 to: self projectsPresenter methodListPresenter list size do: [
		:index |
		self projectsPresenter methodListPresenter resetSelection.
		self projectsPresenter methodListPresenter adapter ifNotNil: [ :a |
			a widget selectIndexes: { index } andMakeVisibleIf: true.
			self
				assert:
				self projectsPresenter methodListPresenter selection selectedIndex
				equals: index ] ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_addAccessors [

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
	self selectVariableNamed: 'var1'.
	self projectsPresenter basicAddVariableAccessors.
	self selectMethodNamed: #var1.
	self
		assert: self methodListPresenter selections first selector
		equals: #var1.
	self selectMethodNamed: #var1:.
	self
		assert: self methodListPresenter selections first selector
		equals: #var1:.
	self selectVariableNamed: 'var3'.
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
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_addAccessorsClassTab [

	self
		testsIssue: #issue382
		withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'format' )
		package: 'RowanSample1-Core'.

	[
	"can't just select string because SpCollectionListModel uses identity equality"
	self projectsPresenter selectClassListTab.
	self projectsPresenter selectVariableTab.
	self selectVariableNamed: 'format'.
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #format.
	self
		assert: self methodListPresenter selections first selector
		equals: #format.
	self selectMethodNamed: #format:.
	self
		assert: self methodListPresenter selections first selector
		equals: #format: ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_addAccessorsVerifySource [

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
	self selectVariableNamed: 'var1'.
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var1.
	self assert: self methodSourcePresenter text equals: 'var1
	^var1' replaceCrWithLf .
	self selectMethodNamed: #var1:.
	self assert: self methodSourcePresenter text equals: 'var1: object
	var1 := object' replaceCrWithLf ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_addRemoveCategory [
	self selectRowanSample1Class.
	self deny: (self categoryListPresenter list includes: 'jadeite test').
	self projectsPresenter basicAddMethodCategory: 'jadeite test'.
	self assert: (self categoryListPresenter list includes: 'jadeite test').
	self assert: self categoryListPresenter selectedItem = 'jadeite test'.
	self projectsPresenter basicRemoveMethodCategories.
	self deny: (self categoryListPresenter list includes: 'jadeite test')
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_addStarredCategory [
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
JadeiteForPharoAbstractBrowserTestCase >> test_browseClassMethodSourceNotDirty [
	"was seeing method source dirty when method selected.
	Seemed to happen more when browser first opened."

	self selectRowanSample1Test.
	secondBrowser := self projectsPresenter browseClass.
	(Delay forMilliseconds: 500) wait. 
	self
		assert: secondBrowser activePresenter selectedClass name
		equals: 'RowanSample1Test'.
	secondPresenter := secondBrowser currentCard.
	secondPresenter selectMethodNamed: 'test1'.
	self deny:
		secondBrowser activePresenter methodSourcePresenter
			hasUnacceptedEdits
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAbstractBrowserTestCase >> test_browseInExistingBrowserFromMethodList [

	self
		testsIssue: #issue827
		withTitle:
		'Would be nice to be able to request that all browse menu items be routed to an existing project browser'. "dolphin issue"
	self
		testsJadeiteForPharoIssue: #issue267
		title:
		'could use "Browse in existing package browser" from method browsers'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/267'.
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
	projectsBrowser tabs selectPageIndex: 1.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanSample1Test'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #testError
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_browseLiteralReferences [

	| methodListPresenter source |
	self
		testsIssue: #issue256
		withTitle:
		'Find string literals in addition to ''methods containing string'' would be useful'.
	self selectRowanSample1Class.
	source := 'theAString ^''apple'''.
	self methodSourcePresenter text: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: nil.
	source := 'invokeA ^self apple'.
	self methodSourcePresenter text: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: nil.
	source := 'theASymbol ^#apple'.
	self methodSourcePresenter text: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selectedItem
		onCompletion: nil.
	self selectMethodNamed: #theAString.
	self selectMethodNamed: #invokeA.
	methodListPresenter := self projectsPresenter
		                       browseLiteralReferences: '''apple'''.
	[
	self assert: methodListPresenter list size equals: 1.
	self
		assert: methodListPresenter listPresenter selectedItem selector
		equals: #theAString.
	methodListPresenter list do: [ :methodService |
		self assert: ('*''apple''*' match: methodService source) ] ]
		ensure: [ self destroy: methodListPresenter ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAbstractBrowserTestCase >> test_browseMenuItemEnablement [
	"several items should not be enabled when multiple methods selected or none selected"

	self
		testsIssue: #issue399
		withTitle:
		'The "exactly one object" warning may also provide an unrelated debugger stack'.
	self selectRowanSample1Test.
	self selectCategoryNamed: 'tests'.
	self selectMethodNamed: #test1.
	self assert:
		(self methodMenuItemNamed: 'Browse Senders') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Senders Of ...') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Implementors') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Implementors Of ...') isEnabled
			value.
	self assert:
		(self methodMenuItemNamed: 'Browse Hierarchy Senders') isEnabled
			value.
	self assert:
		(self methodMenuItemNamed: 'Browse Hierarchy Implementors')
			isEnabled value.
	self selectMethodsNamed: #( #test1 #test2 ).
	self deny:
		(self methodMenuItemNamed: 'Browse Senders') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Senders Of ...') isEnabled value.
	self deny:
		(self methodMenuItemNamed: 'Browse Implementors') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Implementors Of ...') isEnabled
			value.
	self deny:
		(self methodMenuItemNamed: 'Browse Hierarchy Senders') isEnabled
			value.
	self deny:
		(self methodMenuItemNamed: 'Browse Hierarchy Implementors')
			isEnabled value.
	self selectMethodsNamed: #(  ).
	self deny:
		(self methodMenuItemNamed: 'Browse Senders') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Senders Of ...') isEnabled value.
	self deny:
		(self methodMenuItemNamed: 'Browse Implementors') isEnabled value.
	self assert:
		(self methodMenuItemNamed: 'Browse Implementors Of ...') isEnabled
			value.
	self deny:
		(self methodMenuItemNamed: 'Browse Hierarchy Senders') isEnabled
			value.
	self deny:
		(self methodMenuItemNamed: 'Browse Hierarchy Implementors')
			isEnabled value
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_canDiscardSelectionEdits [

	| hitException |
	self
		testsIssue: #issue162
		withTitle: 'Unsaved changes warning rather alarming'. "https://github.com/GemTalk/JadeiteForPharo/issues/162"
	self selectRowanSample1Test.
	self selectServiceNamed: #test1 in: self methodListPresenter.
	self methodSourcePresenter text: 'test1  ^''I am changed'''.
	self assert:
		self methodSourcePresenter adapter widget hasUnacceptedEdits.
	hitException := false.
	[ self methodListPresenter adapter selectIndex: 2 ]
		on: ProvideAnswerNotification
		do: [ :ex |
			hitException := true.
			self assert: ex messageText equals: 'canDiscardSelectionEdits'.
			ex resume: true ].
	self assert: hitException.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #test2
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_categorySelection [

	self
		testsJadeiteForPharoIssue: #issue24
		title: 'Selected category pane wrong if no category selected'.
	self selectRowanAnsweringService.
	self
		assert: self methodListPresenter list size
		equals: self projectsPresenter selectedClass methods size. "no category - all methods in list."
	self selectCategoryNamed: 'client commands'.
	self methodListPresenter list do: [ :methodService |
		self assert: methodService category equals: 'client commands' ]. "only category methods in list"
	self categoryListPresenter unselectAll.
	self
		assert: self methodListPresenter list size
		equals: self projectsPresenter selectedClass methods size. "no category - all methods in list."
	self
		selectMethodsNamed: {#transcriptObject} 
		in: self methodListPresenter. "no category selected still"
	self
		assert: self methodListPresenter selectedItem selector
		equals: #transcriptObject.
	self selectCategoryNamed: 'private'. "select category of selected method retains method selection."
	self methodListPresenter list do: [ :methodService |
		self assert: methodService category equals: 'private' ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_categorySelectionNotSticky [
	"method selection was retained incorrectly on category changes.
	Method selection should only be retained if selected method is 
	in post category selection method list."

	| updatingCategoryIndex |
	self
		testsJadeiteForPharoIssue: #issue24
		title: 'Selected category pane wrong if no category selected'.
	self selectRowanAnsweringService.
	self selectCategoryNamed: 'accessing'.
	self selectMethodsNamed: { #answer } in: self methodListPresenter.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #answer.
	updatingCategoryIndex := self categoryListPresenter list indexOf:
		                         'Updating'.
	"select a different category with the underlying morphic code. That exposes the bug. "
	self categoryListPresenter adapter ifNotNil: [ :a |
		a widget
			selectIndexes: { updatingCategoryIndex }
			andMakeVisibleIf: true ].
	self assert: self methodListPresenter selectedItems isEmpty "#answer is not in private category so no selection should be made"
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_categoryUpdates [

	| flub1MethodInMethodList |
	self
		testsIssue: #issue693
		withTitle:
		'Would like to be able to open method browser on all methods in selected categories'.
	self setupMultipleReferencesToString.

	[
	self selectCategoriesNamed: #( 'as yet unclassified' ).
	self
		assert: (self methodListPresenter list collect: [ :methodService |
				 methodService selector ]) asArray
		equals: #( #flub1 #flub2 #flub3 ).
	self selectCategoriesNamed: #( 'as yet unclassified'
	   'tests' ).
	self waitForMethodListBrowserWhile: [
		self projectsPresenter browseSelectedCategoryMethods ].
	self
		assert:
			(methodListBrowser methodListPresenter list collection collect: [
				 :methodService | methodService selector ]) asArray
		equals:
		#( #flub1 #flub2 #flub3 #test1 #test2 #testError #testFailure ).
	flub1MethodInMethodList := methodListBrowser methodListPresenter list
		                           detect: [ :methodService |
		                           methodService selector = #flub1 ]
		                           ifNone: [  ].
	self
		assert: flub1MethodInMethodList category
		equals: 'as yet unclassified'.
	self projectsPresenter
		moveMethods: (Array with:
				 self projectsPresenter methodListPresenter list first)
		toCategory: (JadeiteCategory named: 'tests'). "#flub1"
	self assert: flub1MethodInMethodList category equals: 'tests' ]
		ensure: [ self abortTransaction ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_classCommentReset [
	"also tests that abort restores original comment from class service"

	| originalComment |
	self
		testsJadeiteForPharoIssue: #issue49
		title: 'Class Comment tab doesn''t work correctly'.
	self selectRowanSample1Class.
	self projectsPresenter selectClassCommentTab.
	originalComment := self projectsPresenter selectedClass comment.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: originalComment.
	self projectsPresenter classCommentPresenter text: 'test comment'.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: 'test comment'.
	self projectsPresenter resetClassComment.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: originalComment
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_classCommentSave [
	"also tests that abort restores original comment from class service"

	| comment |
	self
		testsJadeiteForPharoIssue: #issue49
		title: 'Class Comment tab doesn''t work correctly'.
	comment := 'test comment'.
	self jadeiteTestResourceClass current createRowanSample1Project.
	self selectRowanSample1Class.
	self projectsPresenter selectClassCommentTab.
	self projectsPresenter classCommentPresenter text: comment.
	self projectsPresenter editSaveClassComment.
	self commitTransaction.

	self projectsPresenter classCommentPresenter text: 'new comment'.
	self projectsPresenter editSaveClassComment.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: self projectsPresenter selectedClass comment.

	[
	self abortTransaction.
	self selectRowanSample1Class.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: comment.
	self
		assert: self projectsPresenter selectedClass comment
		equals: comment ] ensure: [
		self jadeiteTestResourceClass current unloadSampleProject1.
		self commitTransaction.
		self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAbstractBrowserTestCase >> test_classCopy [

	| oldInstanceSelectors newInstanceSelectors oldClassClassSelectors newClassClassSelectors oldInstVarNames newInstVarNames oldClassVarNames newClassVarNames |
	self
		testsJadeiteForPharoIssue: #issue133
		title:
		'Copy... and Rename... menu items for Class is missing in JfP'.
	self selectRowanAnsweringService.
	oldInstVarNames := self projectsPresenter selectedClass instVarNames.
	oldClassVarNames := self projectsPresenter selectedClass
		                    classVarNames.
	oldInstanceSelectors := self projectsPresenter selectedClass methods
		                        collect: [ :methodService |
		                        methodService selector ].
	self projectsPresenter
		basicCopyClass: self projectsPresenter selectedClass
		to: 'Fnoodle'.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'Fnoodle'.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'Fnoodle'.
	self updateService: self projectsPresenter selectedClass. "shouldn't have to do this ... but"
	newInstVarNames := self projectsPresenter selectedClass instVarNames.
	newClassVarNames := self projectsPresenter selectedClass
		                    classVarNames.
	newInstanceSelectors := self projectsPresenter selectedClass methods
		                        collect: [ :methodService |
		                        methodService selector ].
	self assert: oldInstVarNames equals: newInstVarNames.
	self assert: oldClassVarNames equals: newClassVarNames.
	self assert: oldInstanceSelectors equals: newInstanceSelectors.
	self selectClassSide.
	newClassClassSelectors := self projectsPresenter selectedClass
		                          methods collect: [ :methodService |
		                          methodService selector ].
	self selectRowanAnsweringService.
	self selectClassSide.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'RowanAnsweringService'.
	oldClassClassSelectors := self projectsPresenter selectedClass
		                          methods collect: [ :methodService |
		                          methodService selector ].
	self assert: oldClassClassSelectors equals: newClassClassSelectors
]

{ #category : 'as yet unclassified' }
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameNoReferences [

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
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameNoReferencesHierarchy [

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
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameResetsClassDefinition [

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
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameShowsMethods [
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
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameWithReferences [

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
		assert: methodListBrowser methodSourcePresenter codePane selection
		equals: 'RenamedClass'
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameWithReferencesFailingCompile [

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
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameWithReferencesHierarchy [

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
		assert: methodListBrowser methodListPresenter list collection  first selector
		equals: #meth.
	self
		assert: methodListBrowser methodSourcePresenter codePane selection
		equals: 'RenamedClass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_classRenameWithReferencesSimilarNameButNoFailCompile [

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
		assert: methodListBrowser methodSourcePresenter codePane selection
		equals: 'RenamedClass' ] ensure: [
		self projectsPresenter
			basicRemoveClass: self classListPresenter selectedItem
			onCompletion: [  ] ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_compileClass [

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
JadeiteForPharoAbstractBrowserTestCase >> test_compileClassCompilerError [

	self
		testsIssue: #issue390
		withTitle:
		'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Class.
	self projectsPresenter classDefinitionPresenter value:
		'Object rwSubclass: ''TestClass''
	instVarNames: # abc )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
	self projectsPresenter editSaveClass.
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: 'Object rwSubclass: ''TestClass''
	instVarNames: invalid pound sign # abc )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_compileErrorDisplay [

	| source |
	self
		testsIssue: #issue459
		withTitle: 'CompileWarnings should be more noticable ... '.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	source := 'test1 self assert: RowanSample1 new foo = ''abc'. "won't compile"
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod.
	self
		assert: self methodSourcePresenter selectionInterval
		equals: (46 to: 81)
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_confirmDiscardMethodChanges [
	"The list selection code is what is run if the user clicks on a list item ... at least currently"
	| changedMethodSource |
	self
		testsJadeiteForPharoIssue: #issue44
		title:
		'While editing a method, can click on other methods, but method text pane not updated'.
	self selectRowanSample1Test.
	self selectMethodNamedInProjectBrowser: #test1.
	changedMethodSource := 'test1
	
	self assert: RowanSample1 new foo = ''foo''
	"add this line to make a change"'.
	self methodSourcePresenter text: changedMethodSource.
	MessageBox expectResult: [ true ] during: [
		self projectsPresenter methodListPresenter withAdapterDo: [ :adapter | "manipulate the underlying morph widget where the confirmation is done"
			adapter widgetDo: [ :w |
				w selectIndexes: #( 2 ) andMakeVisibleIf: true ] ].
		self
			assert:
			self projectsPresenter methodListPresenter selectedItem selector
			equals: #test2 "selected method" ].
	self selectMethodNamedInProjectBrowser: #test1.
	self methodSourcePresenter text: changedMethodSource.
	MessageBox expectResult: [ false ] during: [
		self projectsPresenter methodListPresenter withAdapterDo: [ :adapter |
			adapter widgetDo: [ :w |
				w selectIndexes: #( 2 ) andMakeVisibleIf: true ] ].
		self
			assert:
			self projectsPresenter methodListPresenter selectedItem selector
			equals: #test1. "did not select method"
		self
			assert: self methodSourcePresenter text asString
			equals: changedMethodSource ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_discardMethodChangesRevertsSource [
	"If you reselect the same method that has changes and discard text was not being updated."
	| methodSelectorsList newSource originalSource |
	self selectRowanSample1Test.
	methodSelectorsList := (self methodListPresenter list collect: [
		                        :methodService | methodService selector ])
		                       asArray.
	self
		assert: methodSelectorsList
		equals: #( #test1 #test2 #testError #testFailure ).
	self projectsPresenter methodListPresenter
		selectIndex: 1
		scrollToSelection: true.
	originalSource := self methodSourcePresenter text. 
	newSource := 'test1  | array | array := Array new. ^''foo'''.
	self projectsPresenter selectMethodSourceTab.
	self selectCategoryNamed: 'tests'.
	self selectMethodNamed: #test1.
	self methodSourcePresenter text: newSource.
	self assert: self methodSourcePresenter adapter widget hasUnacceptedEdits.
	["reselect same method" 
	self projectsPresenter methodListPresenter
		selectIndex: 1
		scrollToSelection: true ]
		on: ProvideAnswerNotification
		do: [ :notification | 
		notification resume: true "Yes to discard changes" ].
	self
		assert:
		self projectsPresenter methodListPresenter selection selectedIndex
		equals: 1.
	self assert: self methodSourcePresenter text equals: originalSource
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_doubleClickHierarchyAction [

	| selectedPath selectedItem index oc |
	self
		testsJadeiteForPharoIssue: #issue233
		title: 'Double-click in hierarchy needs extra selection'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/233'.
	self classHierarchyPresenter selection whenChangedDo: [ :selection |
		selectedPath := selection.
		selectedItem := self classHierarchyPresenter selectedItem ].
	self selectRowanAnsweringService.
	self selectHierarchyTab.
	self assert: selectedPath equals: #( 1 1 1 1 1 1 ).
	self classHierarchyPresenter doubleClickAtPath: #( 1 1 1 1 1 ).
	"subclasses of RowanService should be displayed"
	index := 0.
	oc := #( 1 1 1 1 1 1 ) asOrderedCollection.
	self classHierarchyPresenter selectedItem subclassServices do: [
		:subclassService |
		index := index + 1.
		oc at: 6 put: index.
		self classHierarchyPresenter selectItem: subclassService.
		self
			assert: (self classHierarchyPresenter itemAtPath: oc)
			equals: subclassService ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_hierarchyDoubleClick [

	| rowanService answeringService rowanServicePath rowanServiceChildren |
	self selectRowanAnsweringService.
	self selectHierarchyTab.

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
				  service name = 'RowanProjectService' ])) 
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_historyNavigation [

	self selectRowanClassServiceNamed: 'RowanClassService'.
	self selectMethodNamed: 'classCategory'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'classCategory'.
	self selectMethodNamed: 'meta'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'meta'.
	self projectsPresenter historyBack.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'classCategory'.
	self projectsPresenter historyForward.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'meta'
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_historyNavigationClassChange [

	self selectRowanClassServiceNamed: 'RowanClassService'.
	self selectClassSide.
	self selectMethodNamed: 'forClassNamed:'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'forClassNamed:'.
	self selectRowanClassServiceNamed: 'RowanAnsweringService'.
	self selectInstanceSide.
	self selectMethodNamed: 'answer'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'answer'.
	self projectsPresenter historyBack.
	self
		assert: self classListPresenter selectedItem className
		equals: 'RowanClassService'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'forClassNamed:'.
	self assert: self projectsPresenter isClassSideSelected.
	self projectsPresenter historyForward.
	self
		assert: self classListPresenter selectedItem className
		equals: 'RowanAnsweringService'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'answer'.
	self deny: self projectsPresenter isClassSideSelected
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_historyNavigationMetaChange [

	self selectRowanClassServiceNamed: 'RowanClassService'.
	self selectClassSide.
	self selectMethodNamed: 'forClassNamed:'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'forClassNamed:'.
	self selectInstanceSide.
	self selectMethodNamed: 'meta'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'meta'.
	self projectsPresenter historyBack.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'forClassNamed:'.
	self assert: self projectsPresenter isClassSideSelected.
	self projectsPresenter historyForward.
	self
		assert: self methodListPresenter selectedItem selector
		equals: 'meta'.
	self deny: self projectsPresenter isClassSideSelected
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_instVarReaders [
	"should browse the whole hierarchy"

	| list superClassName subclassName |
	self selectRowanSample1Class.
	superClassName := 'FooInstVarReaders'.
	subclassName := 'FooInstVarReadersSubclass'.
	self
		saveClass: superClassName
		superclass: 'Object'
		instVars: (Array with: 'fooInstVar')
		package: 'RowanSample1-Core'.
	self selectServiceNamed: superClassName in: self classListPresenter.
	self
		saveClass: subclassName
		superclass: superClassName
		instVars: Array new
		package: 'RowanSample1-Core'.
	self selectServiceNamed: superClassName in: self classListPresenter.
	self
		saveMethod: 'fooInstVar ^fooInstVar'
		in: superClassName
		category: 'other'.
	self
		saveMethod: 'fooInstVarSize ^fooInstVar size'
		in: superClassName
		category: 'other'.
	self selectServiceNamed: subclassName in: self classListPresenter.
	self
		saveMethod: 'fooInstVarSubSize ^fooInstVar size'
		in: subclassName
		category: 'other'.
	self
		saveMethod: 'doesNotShowUpInList ^1'
		in: subclassName
		category: 'other'.
	self projectsPresenter selectVariableTab.
	self selectVariableNamed: 'fooInstVar'.
	methodListBrowser := self projectsPresenter browseInstVarReaders.
	list := methodListBrowser methodListPresenter list collection.
	self assert: list size equals: 3.
	self
		assert: (list select: [ :methodService |
				 methodService className = superClassName ]) size
		equals: 2.
	self
		assert: (list select: [ :methodService |
				 methodService className = subclassName ]) size
		equals: 1.
	self
		assert:
		(list collect: [ :methodService | methodService selector ]) asArray
		equals: #( #fooInstVar #fooInstVarSize #fooInstVarSubSize )
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_instVarWriters [
	"should browse the whole hierarchy"

	| list superclassName subClassName |
	self selectRowanSample1Class.
	superclassName := 'FooInstVarWriters'.
	subClassName := 'FooInstVarWritersSubclass'.
	self
		saveClass: superclassName
		superclass: 'Object'
		instVars: (Array with: 'fooInstVar')
		package: 'RowanSample1-Core'.
	self selectServiceNamed: superclassName in: self classListPresenter.
	self
		saveClass: subClassName
		superclass: superclassName
		instVars: Array new
		package: 'RowanSample1-Core'.
	self selectServiceNamed: superclassName in: self classListPresenter.
	self
		saveMethod: 'fooInstVar: anObject fooInstVar := anObject'
		in: superclassName
		category: 'other'.
	self
		saveMethod: 'fooInstVarSize fooInstVar := fooInstVar size'
		in: superclassName
		category: 'other'.
	self selectServiceNamed: subClassName in: self classListPresenter.
	self
		saveMethod: 'fooInstVarSubSize fooInstVar := fooInstVar size'
		in: subClassName
		category: 'other'.
	self
		saveMethod: 'doesNotShowUpInList ^1'
		in: subClassName
		category: 'other'.
	self projectsPresenter selectVariableTab.
	self selectVariableNamed: 'fooInstVar'.
	methodListBrowser := self projectsPresenter browseInstVarWriters.
	list := methodListBrowser methodListPresenter list collection.
	self assert: list size equals: 3.
	self
		assert: (list select: [ :methodService |
				 methodService className = superclassName ]) size
		equals: 2.
	self
		assert: (list select: [ :methodService |
				 methodService className = subClassName ]) size
		equals: 1.
	self
		assert:
		(list collect: [ :methodService | methodService selector ]) asArray
		equals: #( #fooInstVar: #fooInstVarSize #fooInstVarSubSize )
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_invalidSession [

	| gotNotification |
	self selectRowanClassServiceNamed: 'RowanPackageService'.
	self selectMethodNamed: 'initialize'.
	self assert: ('initialize*' match: self methodSourcePresenter text).
	gotNotification := false.
	session library channel close.
	RowanServiceUpdater uninstallTestUpdater.
	[ self selectMethodNamed: 'name' ]
		on: JadeiteInvalidSessionNotification
		do: [ :notification |
			gotNotification := true.
			notification resume: true ].
	self assert: gotNotification.
	self deny: JadeiteConnectionProfile connectionProfile isConnected
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_jadeiteCategories [
	"somewhere, there's a hole in the code where strings get 
	put into the method category list. They should always be 
	JadeiteCategory instances."

	projectsBrowser findClassNamed: 'Collection'.
	self assert: self projectsPresenter isCategoryTabSelected.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self projectsPresenter basicAddMethodCategory: 'deleteThisCategory'.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self categoryListPresenter selectItem:
		(JadeiteCategory named: 'deleteThisCategory').
	self projectsPresenter basicRemoveMethodCategories.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self projectsPresenter
		basicRenameCategoryFrom: 'Adding'
		to: 'Fladding'.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self selectClassSide.
	self assert: self projectsPresenter isCategoryTabSelected.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self selectInstanceSide.
	self assert: self projectsPresenter isCategoryTabSelected.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self projectsPresenter selectVariableTab.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	self projectsPresenter selectCategoryTab.
	self projectsPresenter categoryListPresenter items do: [ :item |
		self assert: item isKindOf: JadeiteCategory ].
	JadeitePreferences isRowanLoaded ifTrue: [
		self projectsPresenter selectPackageFilterTab.
		self projectsPresenter categoryListPresenter items do: [ :item |
			self assert: item isKindOf: JadeiteCategory ].
		self projectsPresenter selectCategoryTab.
		self projectsPresenter categoryListPresenter items do: [ :item |
			self assert: item isKindOf: JadeiteCategory ] ].
	self abortTransaction
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_methodListBrowserOverwritesMethods [
	"expect RowanSample1 to have a foo method already"

	| methodList classMethod instanceMethod |
	self
		testsJadeiteForPharoIssue: #issue10
		title:
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
	methodList := methodListBrowser methodListPresenter list
		              asOrderedCollection.

	classMethod := methodList detect: [ :methodService |
		               methodService meta and: [
			               methodService className = 'RowanSample1' ] ].
	instanceMethod := methodList detect: [ :methodService |
		                  methodService meta not and: [
			                  methodService className = 'RowanSample1' ] ].
	self deny: classMethod equals: instanceMethod.
	self
		assert: classMethod displayClassName
		equals: 'RowanSample1 class'.
	self assert: instanceMethod displayClassName equals: 'RowanSample1'.
	methodListBrowser methodListPresenter resetSelection.
	methodListBrowser methodListPresenter selectItem: instanceMethod.
	self
		assert: methodListBrowser methodSourcePresenter text asString
		equals: 'foo ^''foo'''.
	self
		saveMethod: 'foo  ^''the class side'''
		in: 'RowanSample1'
		category: 'dontcare'
		meta: true. "this should not write over the method list source pane"
	self deny: methodListBrowser methodListPresenter selectedItem meta.
	self
		assert: methodListBrowser methodSourcePresenter text asString
		equals: 'foo ^''foo'''
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_methodSourceNotChanged [

	| maxMs |
	self destroy: projectsBrowser.
	maxMs := 1000.
	1 to: 25 do: [ :index |
		| presenter ms |
		presenter := JadeiteConsole currentConsole openBrowser
			             activePresenter.
		presenter
			updateAfterFindClassName: 'RowanAnsweringService'
			methodSelector: #allTestsIn:
			meta: false.
		ms := Time millisecondClockValue.
		[
		presenter methodListPresenter selectedItem isNil and: [
			Time millisecondClockValue - ms < maxMs ] ] whileTrue: [
			(Delay forMilliseconds: 5) wait ].
		presenter methodListPresenter selectedItem ifNil: [
			self error:
				'methd source not selected in under ' , maxMs printString
				, ' milliseconds'.
			^ presenter parentPresenter window close ].
		self deny: presenter methodSourcePresenter hasUnacceptedEdits.
		presenter parentPresenter window close ]
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_methodSourcechangeIndicator [
	"It's hard to test that a glyph is displayed but we can test 
	the state that changes when the indicator is turned on and off"

	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	self deny: self morphicMethodSourceHasUnacceptedEdits.
	self methodSourcePresenter text: 'foo  ^''instance side'''.
	self assert: self morphicMethodSourceHasUnacceptedEdits.
	self projectsPresenter editSaveMethod. 
	self deny: self morphicMethodSourceHasUnacceptedEdits.
	self methodSourcePresenter text: 'foo  ^''dontcare'''.
	self assert: self morphicMethodSourceHasUnacceptedEdits.	
	self projectsPresenter resetMethodSource. 
	self assert: self methodSourcePresenter text = 'foo  ^''instance side'''. 
	self deny: self morphicMethodSourceHasUnacceptedEdits.
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_saveMethodKeepsAlphabetizedList [
	| methodSelectorsList newMethodSelectorsList originalSource |
	self testsIssue: #issue770 withTitle: 'Ensure new method is alphabetized after compile'.
	self selectRowanSample1Test.
	methodSelectorsList := (self methodListPresenter list
				collect: [:methodService | methodService selector]) asArray.
	self assert: methodSelectorsList equals: #(#test1 #test2 #testError #testFailure).
	originalSource := 'fooble  | array | array := Array new. ^''foo'''.
	self projectsPresenter selectMethodSourceTab.
	self selectCategoryNamed: 'tests'.
	self methodSourcePresenter value: originalSource.
	self methodSourcePresenter view isModified: true.
	self projectsPresenter editSaveMethod.
	newMethodSelectorsList := (self methodListPresenter list
				collect: [:methodService | methodService selector]) asArray.
	self assert: newMethodSelectorsList equals: #(#fooble #test1 #test2 #testError #testFailure)
]

{ #category : 'tests' }
JadeiteForPharoAbstractBrowserTestCase >> test_sendersOfOptimizedSelector [
	"senders of optimized selectors were giving walkback"

	| existingMethodListPresenters |
	existingMethodListPresenters := JadeiteMethodListPresenter
		                                allInstances.
	methodListBrowser := self projectsPresenter browseSendersOf:
		                     #_isNumber.
	methodListBrowser := (JadeiteMethodListPresenter allInstances
		                      difference: existingMethodListPresenters)
		                     first.
	self assert: methodListBrowser methodListPresenter list notEmpty.
	self
		assert: methodListBrowser methodSourcePresenter selection
		equals: '_isNumber'
]

{ #category : 'support' }
JadeiteForPharoAbstractBrowserTestCase >> toolUsedForCommonTests [

	^ projectsBrowser
]
