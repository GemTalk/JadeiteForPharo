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
JadeiteForPharoBrowserTestCase >> morphicMethodSourceHasUnacceptedEdits [

	^self methodSourcePresenter withAdapterDo: [ :adapter | adapter widgetDo:[:widget | widget hasUnacceptedEdits ] ]
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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
		self projectsPresenter
			basicRemoveClass: self projectsPresenter selectedClass
			onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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
JadeiteForPharoBrowserTestCase >> test_confirmDiscardMethodChanges_investigate [
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
JadeiteForPharoBrowserTestCase >> test_selectVariable [
	self selectRowanServicesPackage.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'instVarNames'.
	self methodListPresenter list
		do: [:methodService | self assert: (methodService source substrings includes: 'instVarNames')].
	self projectsPresenter variableListPresenter selection: 'isNewClass'.
	self methodListPresenter list
		do: [:methodService | self assert: (methodService source substrings includes: 'isNewClass')]
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
