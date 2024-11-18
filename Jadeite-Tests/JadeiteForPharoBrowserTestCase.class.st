Class {
	#name : 'JadeiteForPharoBrowserTestCase',
	#superclass : 'JadeiteForPharoBrowserAbstractTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
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
JadeiteForPharoBrowserTestCase >> methodMenuItemNamed: aString [

	self methodListPresenter contextMenu menuGroups do: [ :group |
		group menuItems do: [ :item |
			item name = aString ifTrue: [ ^ item ] ] ].
	^ nil
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> morphicMethodSourceHasUnacceptedEdits [

	^self methodSourcePresenter withAdapterDo: [ :adapter | adapter widgetDo:[:widget | widget hasUnacceptedEdits ] ]
]

{ #category : 'not working tests' }
JadeiteForPharoBrowserTestCase >> moveMethodToCategory [
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
JadeiteForPharoBrowserTestCase >> openSecondBrowser [

	secondBrowser := self testResourceClass current openWindow: [
		                 self transcript openBrowser ].
	secondBrowser caption: 'second browser'.
	secondPresenter := secondBrowser currentCard.
	secondPresenter selectClassListTab.
	^ secondBrowser
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> projectBrowserTabs [

	^ projectsBrowser tabs pages
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> projectList [
	^self projectListPresenter list
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> selectRowanAnsweringService [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Core'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> setupMultipleReferencesToString [

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

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_abortOnVariablesTab [

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
JadeiteForPharoBrowserTestCase >> test_abuseMethodList [
	"This test doesn't appear to do much but it does exercise
	list selection aggressively. There have been occassions when
	selecting methods was progressively getting slower with no 
	explanation. This might catch one of those occasions for debugging."

	self
		testsJadeiteForPharoIssue: #issue44
		title:
		'While editing a method, can click on other methods, but method text pane not updated'.
	self selectRowanServicesPackage.
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter.
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
	self projectsPresenter basicAddVariableAccessors.
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
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_addAccessorsClassTab [

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
	self projectsPresenter selectClassListTab.
	self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #( 'format' ).
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
JadeiteForPharoBrowserTestCase >> test_addAccessorsVerifySource [

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
JadeiteForPharoBrowserTestCase >> test_addRemoveCategory [
	self selectRowanSample1Class.
	self deny: (self categoryListPresenter list includes: 'jadeite test').
	self projectsPresenter basicAddMethodCategory: 'jadeite test'.
	self assert: (self categoryListPresenter list includes: 'jadeite test').
	self assert: self categoryListPresenter selectedItem = 'jadeite test'.
	self projectsPresenter basicRemoveMethodCategories.
	self deny: (self categoryListPresenter list includes: 'jadeite test')
]

{ #category : 'tests' }
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
JadeiteForPharoBrowserTestCase >> test_browseClassMethodSourceNotDirty [
	"was seeing method source dirty when method selected.
	Seemed to happen more when browser first opened."

	self selectRowanSample1Test.
	secondBrowser := self projectsPresenter browseClass.
	self
		assert: secondBrowser activePresenter selectedClass name
		equals: 'RowanSample1Test'.
	self selectMethodNamed: 'test1'.
	self deny:
		secondBrowser activePresenter methodSourcePresenter
			hasUnacceptedEdits
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_browseLiteralReferences [

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
JadeiteForPharoBrowserTestCase >> test_browseMenuItemEnablement [
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
JadeiteForPharoBrowserTestCase >> test_categorySelection [

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
JadeiteForPharoBrowserTestCase >> test_categorySelectionNotSticky [
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
JadeiteForPharoBrowserTestCase >> test_categoryUpdates [

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
JadeiteForPharoBrowserTestCase >> test_classCommentReset [
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
JadeiteForPharoBrowserTestCase >> test_classCommentSave [
	"also tests that abort restores original comment from class service"

	| originalComment |
	self
		testsJadeiteForPharoIssue: #issue49
		title: 'Class Comment tab doesn''t work correctly'.
	self ensureRowanSampleProjectsLoadedFromDisk.
	self commitTransaction.
	self selectRowanSample1Class.
	self projectsPresenter selectClassCommentTab.
	originalComment := self projectsPresenter selectedClass comment.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: originalComment.
	self projectsPresenter classCommentPresenter text: 'test comment'.
	self projectsPresenter editSaveClassComment.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: self projectsPresenter selectedClass comment.
	[
	self abortTransaction.
	self selectRowanSample1Class.
	self
		assert: self projectsPresenter classCommentPresenter text asString
		equals: originalComment.
	self
		assert: self projectsPresenter selectedClass comment
		equals: originalComment ] ensure: [
		self testResourceClass current unloadSampleProject1.
		self commitTransaction.
		self ensureRowanSampleProjectsLoaded ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_classCopy [

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
		assert: methodListBrowser methodSourcePresenter codePane selection
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
		assert: methodListBrowser methodSourcePresenter codePane selection
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
JadeiteForPharoBrowserTestCase >> test_compileClassCompilerError [

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
	instVarNames:  invalid pound sign# abc )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_compileErrorDisplay [

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
		equals: (47 to: 82)
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_confirmDiscardMethodChanges [
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
JadeiteForPharoBrowserTestCase >> test_discardMethodChangesRevertsSource [
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
JadeiteForPharoBrowserTestCase >> test_instVarReaders [
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
	self projectsPresenter variableListPresenter selection: 'fooInstVar'.
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
JadeiteForPharoBrowserTestCase >> test_instVarWriters [
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
	self projectsPresenter variableListPresenter selection: 'fooInstVar'.
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
JadeiteForPharoBrowserTestCase >> test_methodListBrowserOverwritesMethods [
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
JadeiteForPharoBrowserTestCase >> test_methodSourceNotChanged [

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
			presenter parentPresenter window close.
			^ self error:
				  'methd source not selected in under ' , maxMs printString
				  , ' milliseconds' ].
		self deny: presenter methodSourcePresenter hasUnacceptedEdits.
		presenter parentPresenter window close ]
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
	self projectsPresenter editSaveMethod. 
	self deny: self morphicMethodSourceHasUnacceptedEdits.
	self methodSourcePresenter text: 'foo  ^''dontcare'''.
	self assert: self morphicMethodSourceHasUnacceptedEdits.	
	self projectsPresenter resetMethodSource. 
	self assert: self methodSourcePresenter text = 'foo  ^''instance side'''. 
	self deny: self morphicMethodSourceHasUnacceptedEdits.
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_projectLoadAddedInAlphabeticalOrder [

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
JadeiteForPharoBrowserTestCase >> test_projectOrderDoesNotChange [

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
JadeiteForPharoBrowserTestCase >> test_saveMethodKeepsAlphabetizedList [
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
JadeiteForPharoBrowserTestCase >> test_selectVariable [

	self selectRowanServicesPackage.
	self
		selectServiceNamed: 'RowanClassService'
		in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection:
		'instVarNames'.
	self methodListPresenter list do: [ :methodService |
		RowanServiceUpdater current
			updateService: methodService
			session: session
			onCompletion: [  ].
		self assert:
			(methodService source substrings includes: 'instVarNames') ].
	self projectsPresenter variableListPresenter selection: 'isNewClass'.
	self methodListPresenter list do: [ :methodService |
		RowanServiceUpdater current
			updateService: methodService
			session: session
			onCompletion: [  ].
		self assert:
			(methodService source substrings includes: 'isNewClass') ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_sendersOfOptimizedSelector [
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
