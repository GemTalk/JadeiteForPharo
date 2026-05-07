Class {
	#name : 'JadeiteForPharoMethodListTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> methodListPresenter [

	^ methodListBrowser methodListPresenter
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> methodSourcePresenter [

	^ methodListBrowser methodSourcePresenter
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> openMethodListBrowserOfImplementorsOf: aString [
	"just calling this method #browserImplementorsOf: would confuse it with production methods"

	self waitForMethodListBrowserWhile: [
		[ jadeiteShell browseImplementorsOf ]
			on: ProvideAnswerNotification
			do: [ :notification | notification resume: aString ] ]
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> openMethodListBrowserOfReferencesTo: className [

	self waitForMethodListBrowserWhile: [
		[ jadeiteShell browseClassReferences: className ]
			on: ProvideAnswerNotification
			do: [ :notification | notification resume: className ] ]
]

{ #category : 'as yet unclassified' }
JadeiteForPharoMethodListTestCase >> sampleMethodSource [
	^'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'. 
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> saveSourcesFor_test_sourcesSync: oldSource [

	self
		saveClass: 'TestingMethodSource'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'Rowan-Services-Tests'
		dictionaryName: 'RowanSample1Dictionary'
		classCategory: 'Rowan-Sample-Test'.
	self
		saveMethod: oldSource
		in: 'TestingMethodSource'
		category: 'test_created'
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> tearDown [

	super tearDown.
	JadeiteConnectionProfile connectionProfile disconnect
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseClassReferenceCaptionTitle [

	self openMethodListBrowserOfReferencesTo: 'AbstractCharacter'.
	self assert: ('* Class References to AbstractCharacter*' match:
			 methodListBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseClassReferences [

	| methodService originalMethodListBrowser |
	self openMethodListBrowserOfImplementorsOf: 'size'.
	methodService := methodListBrowser methodListPresenter items
		                 detect: [ :service | service className = 'Bag' ]
		                 ifNone: [  ].
	methodListBrowser methodListPresenter unselectAll. "Apparently you have to deselect all items before a single selection can be made"
	methodListBrowser methodListPresenter selectItem: methodService.
	originalMethodListBrowser := methodListBrowser.
	[
	self waitForMethodListBrowserWhile: [
		originalMethodListBrowser browseClassReferences ].
	methodListBrowser methodListPresenter items do: [ :service |
		methodListBrowser methodListPresenter selectItem: service.
		self waitWhile: [ methodListBrowser methodSourcePresenter text ~= service source ].
		self assert:
			('*Bag*' match: methodListBrowser methodSourcePresenter text) ] ]
		ensure: [ self destroy: originalMethodListBrowser ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseHierarchyImplementors [

	| methodService |
	self setupProjectBrowser.
	projectsBrowser findClassNamed: 'ReadStreamPortable'.
	self
		selectServiceNamed: 'size'
		in: self projectsPresenter methodListPresenter.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter browseHierarchyImplementors ].
	self assert:
		('4 Hierarchy Implementors of ''size'' in ReadStreamPortable for*'
			 match: methodListBrowser owner title).
	methodService := methodListBrowser methodListPresenter items
		                 detect: [ :service | service className = 'Object' ]
		                 ifNone: [  ].
	self denyIsNil: methodService.
	self assert: methodService selector equals: #size.
	methodService := methodListBrowser methodListPresenter items
		                 detect: [ :service |
		                 service className = 'PPStream' ]
		                 ifNone: [  ].
	self denyIsNil: methodService.
	self assert: methodService selector equals: #size.
	methodService := methodListBrowser methodListPresenter items
		                 detect: [ :service |
		                 service className = 'ReadByteStreamPortable' ]
		                 ifNone: [  ].
	self denyIsNil: methodService.
	self assert: methodService selector equals: #size.
	methodService := methodListBrowser methodListPresenter items
		                 detect: [ :service |
		                 service className = 'ReadStreamPortable' ]
		                 ifNone: [  ].
	self denyIsNil: methodService.
	self assert: methodService selector equals: #size
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseHierarchySenders [

	| hierarchyClassNames dataSource |
	self setupProjectBrowser.
	projectsBrowser findClassNamed: 'ReadStreamPortable'.
	self
		selectServiceNamed: 'size'
		in: self projectsPresenter methodListPresenter.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter browseHierarchySenders ].
	self assert:
		('* Hierarchy Senders of ''size'' in ReadStreamPortable for*'
			 match: methodListBrowser owner title).
	self selectHierarchyTab.
	self projectsPresenter expandFullHierarchy.
	dataSource := self projectsPresenter classHierarchyPresenter adapter
		              widget dataSource.
	dataSource expandAll. 
	hierarchyClassNames := dataSource allShownItems collect: [ :ea |
		                       ea data name ]. "got to be an easier way to get the tree's objects"
	methodListBrowser methodListPresenter items do: [ :methodService |
		self assert: (hierarchyClassNames includes: methodService className) ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseImplementors [

	| methodService |
	self openMethodListBrowserOfImplementorsOf: 'answer'.
	methodService := methodListBrowser methodListPresenter items
		                 detect: [ :service |
		                 service className = 'RowanAnsweringService' ]
		                 ifNone: [  ].
	self denyIsNil: methodService.
	self assert: methodService selector equals: #answer
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseImplementorsOf [

	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #size ].
	methodListBrowser methodListPresenter items do: [ :methodService |
		methodListBrowser methodListPresenter selectItem: methodService.
		self assert: methodService selector equals: #size ].
	self assert: ('* Implementors of ''size'' for *' match:
			 methodListBrowser owner title)
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseInExistingBrowser [
	"If no existing browser is found, open a new one"

	self
		testsIssue: #issue827
		withTitle:
		'Would be nice to be able to request that all browse menu items be routed to an existing project browser'. "dolphin issue"
	self
		testsJadeiteForPharoIssue: #issue267
		title:
		'could use "Browse in existing package browser" from method browsers'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/267'.
	self setupProjectBrowser.
	self selectRowanSample1Test.
	self projectsPresenter selectMethodNamed: #test1.
	self denyIsNil: projectsBrowser.
	self openMethodListBrowserOfImplementorsOf: 'testError'.

	self assert: methodListBrowser window isTopWindow.
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
		assert: self projectsPresenter classListPresenter selectedItem name
		equals: 'SUnitTest'.
	self
		assert:
		self projectsPresenter methodListPresenter selectedItem selector
		equals: #testError.
	projectsBrowser tabs selectPageIndex: 1.
	self
		assert: self projectsPresenter classListPresenter selectedItem name
		equals: 'RowanSample1Test'.
	self
		assert:
		self projectsPresenter methodListPresenter selectedItem selector
		equals: #test1
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseInExistingBrowserOpensNewBrowser [
	"If no existing browser is found, open a new one"

	| openBrowsers |
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
	openBrowsers := JadeiteBrowser browserClass allInstances select: [
		                :browser | browser window isOpen ].
	self assert: openBrowsers isEmpty.

	self openMethodListBrowserOfImplementorsOf: 'testError'.

	self assert: methodListBrowser window isTopWindow.
	methodListBrowser methodListPresenter unselectAll.
	methodListBrowser methodListPresenter selectIndex: 2.
	self
		assert: methodListBrowser methodListPresenter selectedItem className
		equals: 'SUnitTest'.

	methodListBrowser browseMethodClassInExistingBrowser.

	projectsBrowser := JadeiteBrowser browserClass allInstances detect: [
		                   :browser | browser window isOpen ].
	self assert: projectsBrowser window isTopWindow.
	self assert: projectsBrowser tabs pages size equals: 1.
	self
		assert: self classListPresenter selectedItem name
		equals: 'SUnitTest'.
	self
		assert: self methodListPresenter selectedItem selector
		equals: #testError
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseInstVarReaders [

	self setupProjectBrowser.
	self
		saveClass: 'TestInstVarReaders'
		superclass: 'Object'
		instVars: #( 'testbrowseInstVarReaders' )
		package: 'RowanSample1-Core'.
	self
		saveMethod: 'testbrowseInstVarReaders  ^testbrowseInstVarReaders'
		in: 'TestInstVarReaders'
		category: 'accessing'.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			browseInstVarReaders: 'testbrowseInstVarReaders'
			in: 'TestInstVarReaders'
			session: session ].
	self
		assert: self projectsPresenter methodListPresenter list size
		equals: 1.
	self
		assert:
		self projectsPresenter methodListPresenter list first selector
		equals: #testbrowseInstVarReaders
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseInstVarWriters [

	self setupProjectBrowser.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			browseInstVarWriters: 'autoCommit'
			in: 'RowanAutoCommitService'
			session: session ].
	self methodListPresenter list do: [ :methodService |
		self assert: ('*autoCommit :=*' match: methodService source) ]. 
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseSelectedMethods [

	| methodCount firstMethodListBrowser |
	self openMethodListBrowserOfImplementorsOf: 'size'.
	firstMethodListBrowser := methodListBrowser.
	methodCount := methodListBrowser methodListPresenter items size.
	methodListBrowser methodListPresenter selectAll.
	self waitForMethodListBrowserWhile: [
		methodListBrowser browseSelectedMethods ].
	[
	self
		assert: methodListBrowser methodListPresenter items size
		equals: methodCount.
	methodListBrowser methodListPresenter items do: [ :methodService |
		self assert: methodService selector equals: 'size' ] ] ensure: [
		self destroy: firstMethodListBrowser ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseSendersFoo [

	self
		testsIssue: #issue500
		withTitle:
		'(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	self waitForMethodListBrowserWhile: [
		jadeiteShell browseSendersOf: #foo ].
	methodListBrowser methodListPresenter items do: [ :methodService |
		methodListBrowser methodListPresenter selectItem: methodService.
		self waitWhile: [ methodListBrowser methodSourcePresenter text ~= methodService source ].
		self assert:
			('foo*' match: methodListBrowser methodSourcePresenter selection) "use match because we might pickup a '.'" ].
	self assert:
		('* Senders of ''foo'' for *' match: methodListBrowser owner title)
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_canDiscardSelectionEdits [

	| hitException |
	self
		testsIssue: #issue162
		withTitle: 'Unsaved changes warning rather alarming'. "https://github.com/GemTalk/JadeiteForPharo/issues/162"

	self waitForMethodListBrowserWhile: [
		jadeiteShell browseSendersOf: #foo ].
	self methodListPresenter adapter selectIndex: 1.
	self methodSourcePresenter text: 'foo  ^''I am changed'''.
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
		assert: self methodListPresenter selection selectedIndex
		equals: 2.
	self methodSourcePresenter hasUnacceptedEdits: false
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_findReplaceButtonsEnabled [

	| findService |
	self
		testsJadeiteForPharoIssue: #issue285
		title:
		'Find & Replace dialog doesn''t work well when invoked with no selection'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/285'.

	self openMethodListBrowserOfImplementorsOf: 'size'.
	self methodListPresenter selectIndex: 1.
	findService := self methodSourcePresenter adapter widget textArea
		               findReplaceService openDialog.
	[
	self assert: (findService isKindOf: SpRubFindReplaceService).
	self assert: findService dialog findButton isEnabled.
	self assert: findService dialog replaceButton isEnabled.
	self assert: findService dialog replaceAllButton isEnabled ] ensure: [
		findService dialog window close ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_methodCompileError [

	self openMethodListBrowserOfImplementorsOf: 'answer'.
	self methodListPresenter selectIndex: 1.
	self waitWhile: [ (self methodSourcePresenter text ifNil: [ '' ]) isEmpty ].
	self methodSourcePresenter value: self compileErrorMethodText.
	methodListBrowser editSaveMethod.
	self
		assert: self methodSourcePresenter text
		equals: self compileErrorMethodTextShowingCompileError.
	self
		assert: methodListBrowser statusBarText message 
		equals: 'CompileError - expected a right bracket (])'.
	self methodSourcePresenter hasUnacceptedEdits: false
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_methodListSourceDoesNotDisappear [

	self
		testsIssue: #issue863
		withTitle:
		'(Oscar 3.1.0 and 3.1.1) Under certain conditions selected methods browser loses method source and errors out'.
	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #compileClass: ].
	self
		assert: methodListBrowser methodListPresenter list size
		equals: 1. "right now, implementors size = 1. If that changes, revisit test"
	self waitWhile: [
		methodListBrowser methodSourcePresenter text
			~= methodListBrowser methodListPresenter selectedItem source ].
	self
		assert: methodListBrowser methodSourcePresenter text
		equals: methodListBrowser methodListPresenter selectedItem source.
	self openProjectBrowser.
	projectsBrowser findClassNamed: 'RowanBrowserService'.
	self waitWhile: [
		methodListBrowser methodSourcePresenter text
			~= methodListBrowser methodListPresenter selectedItem source ].
	self
		assert: methodListBrowser methodSourcePresenter text
		equals: methodListBrowser methodListPresenter selectedItem source.
	self
		assert: methodListBrowser methodListPresenter selectedItem selector
		equals: #compileClass:
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_methodReadsWritesSameInstvar [
	"doing inst var references to an inst var that both reads and writes
	in the same method showed the method twice in method list"

	self setupProjectBrowser.
	self projectsPresenter
		updateAfterFindClassName: 'RowanService'
		methodSelector: #shouldUpdate
		meta: false.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			browseInstVarReaders: 'shouldUpdate'
			in: 'RowanService'
			session: session ].
	self denyIsNil: (methodListBrowser methodListPresenter items
			 detect: [ :ea |
			 ea selector = #servicePerform:withArguments:shouldUpdate: ]
			 ifNone: [  ]).
	self destroy: methodListBrowser.
	methodListBrowser := nil.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			browseInstVarWriters: 'shouldUpdate'
			in: 'RowanService'
			session: session ].
	self denyIsNil: (methodListBrowser methodListPresenter items
			 detect: [ :ea |
			 ea selector = #servicePerform:withArguments:shouldUpdate: ]
			 ifNone: [  ]).
	self destroy: methodListBrowser.
	methodListBrowser := nil.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter
			browseInstVarReferences: 'shouldUpdate'
			in: 'RowanService'
			session: session ].
	self methodListPresenter items do: [ :methodService |
		| methodServices |
		[
		methodServices := methodListBrowser methodListPresenter items
			                  select: [ :ea |
			                  ea selector
			                  = #servicePerform:withArguments:shouldUpdate: ].
		methodServices isEmpty ] whileTrue: [
			(Delay forMilliseconds: 10) wait ].
		self assert: methodServices size equals: 1 ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_multiSelection [
	"source not updated on multi-select"

	| first second third |
	self openMethodListBrowserOfImplementorsOf: 'size'.
	first := self methodListPresenter list at: 1.
	second := self methodListPresenter list at: 2.
	third := self methodListPresenter list at: 3.
	self methodListPresenter selectIndex: 1.
	self assert: self methodListPresenter selectedItem equals: first.
	self assert: self methodListPresenter selectedItems size equals: 1.
	self waitWhile: [ self methodSourcePresenter text ~= first source ].
	self assert: self methodSourcePresenter text equals: first source.
	self methodListPresenter selectIndexes: #( 2 1 ).
	self assert: self methodListPresenter selectedItem equals: second.
	self assert: self methodListPresenter selectedItems size equals: 2.
	self waitWhile: [ self methodSourcePresenter text ~= second source ].
	self assert: self methodSourcePresenter text equals: second source.
	self methodListPresenter selectIndexes: #( 3 2 1 ).
	self assert: self methodListPresenter selectedItem equals: third.
	self assert: self methodListPresenter selectedItems size equals: 3.
	self waitWhile: [ self methodSourcePresenter text ~= third source ].
	self assert: self methodSourcePresenter text equals: third source
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_newMethodCompile [

	| newCompiledMethodBrowser originalText |
	self
		testsJadeiteForPharoIssue: #issue168
		title:
			'After using method browser to create a new method with a new selector, cannot revert to original method in that browser
'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/168'.

	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #answer ].
	self waitWhile: [ (self methodSourcePresenter text ifNil: [ '' ]) isEmpty ].
	originalText := self methodSourcePresenter text replaceCrWithLf.
	self methodSourcePresenter text: 'answer3
^#answer3'.
	newCompiledMethodBrowser := self
		                            waitForNewPresenter: JadeiteMethodListPresenter
		                            while: [
		                            methodListBrowser editSaveMethod ].
	[
	self methodSourcePresenter hasUnacceptedEdits: false.
	self
		assert: newCompiledMethodBrowser methodListPresenter items size
		equals: 1.
	self
		assert:
		newCompiledMethodBrowser methodListPresenter items first selector
		equals: #answer3.
	self waitWhile: [
		newCompiledMethodBrowser methodSourcePresenter text
			~= ('answer3
^#answer3' replaceCrWithLf) ].
	self
		assert: newCompiledMethodBrowser methodSourcePresenter text
		equals: 'answer3
^#answer3' replaceCrWithLf.
	self assert: self methodSourcePresenter text equals: originalText ]
		ensure: [ newCompiledMethodBrowser window close ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_newMethodCompileWithWarnings [

	| newCompiledMethodBrowser newMethodSource originalText |
	self
		testsJadeiteForPharoIssue: #issue168
		title:
			'After using method browser to create a new method with a new selector, cannot revert to original method in that browser
'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/168'.

	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #answer ].
	self waitWhile: [ (self methodSourcePresenter text ifNil: [ '' ]) isEmpty ].
	originalText := self methodSourcePresenter text replaceCrWithLf.
	newMethodSource := 'answer3
| abc | "create compiler warning for unused temp"
^#answer3'.
	self methodSourcePresenter text: newMethodSource.
	newCompiledMethodBrowser := self
		                            waitForNewPresenter: JadeiteMethodListPresenter
		                            while: [
		                            methodListBrowser editSaveMethod ].
	[
	self methodSourcePresenter hasUnacceptedEdits: false.
	self
		assert: newCompiledMethodBrowser methodListPresenter items size
		equals: 1.
	self
		assert:
		newCompiledMethodBrowser methodListPresenter items first selector
		equals: #answer3.
	self waitWhile: [
		newCompiledMethodBrowser methodSourcePresenter text
			~= newMethodSource replaceCrWithLf ].
	self
		assert: newCompiledMethodBrowser methodSourcePresenter text
		equals: newMethodSource replaceCrWithLf.
	self assert: ('WARNING: unused method temp ''abc''*' match:
			 newCompiledMethodBrowser statusBarText message).
	self assert: self methodSourcePresenter text equals: originalText.
	self assert: methodListBrowser statusBarText message isEmpty ]
		ensure: [ newCompiledMethodBrowser window close ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_reset [

	self openMethodListBrowserOfImplementorsOf: 'answer'.
	self waitWhile: [ (methodListBrowser methodSourcePresenter text ifNil: [ '' ]) isEmpty ].
	self assertTextPaneResetFor: methodListBrowser methodSourcePresenter
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_resetMethodDetails [

	| methodService sem |
	self openMethodListBrowserOfImplementorsOf: 'includes:'.
	self waitWhile: [ self methodSourcePresenter text ~= self methodListPresenter selectedItem source ].
	self
		assert: self methodSourcePresenter text
		equals: self methodListPresenter selectedItem source.
	methodService := methodListBrowser methodListPresenter selectedItem.

	self methodSourcePresenter hasUnacceptedEdits: true.
	sem := Semaphore new.
	self uiManager defer: [ "setCompileWarningColor is now deferred to the morphic thread"
			methodListBrowser setCompileWarningColor.
			sem signal ].
	WorldMorph doOneCycle. "allow deferred morphic blocks to run "
	sem wait.
	methodService source: 'I am changed!'.
	self assert:
		self methodSourcePresenter adapter widget hasUnacceptedEdits.
	self assertIsNil: methodListBrowser statusBarText message.
	self
		assert: methodListBrowser statusBarText adapter widget color
		equals: Color yellow.
	methodListBrowser resetVisibleMethodDetails.
	self assert: self methodSourcePresenter text equals: 'I am changed!'.
	self deny: self methodSourcePresenter hasUnacceptedEdits.
	self
		assert: methodListBrowser statusBarText message
		equals: String new.
	self
		assert: methodListBrowser statusBarText adapter widget color
		equals: Color transparent
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_sourcesSync [

	| oldSource newSource |
	self setupProjectBrowser.
	oldSource := 'didSourceUpdate  | tempVar | "test created method" self doSomething'.
	self saveSourcesFor_test_sourcesSync: oldSource.
	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #didSourceUpdate ].
	self waitWhile: [ methodListBrowser methodSourcePresenter text ~= oldSource ].
	self
		assert: methodListBrowser methodSourcePresenter text
		equals: oldSource.
	self
		assert: methodListBrowser methodListPresenter list size
		equals: 1.
	JadeitePreferences isRowanAvailable
		ifFalse: [
			self
				selectServiceNamed: 'RowanSample1Dictionary'
				in: self dictionaryListPresenter.
			self selectClassCategoryNamed: 'Rowan-Sample-Test' ]
		ifTrue: [
			self
				selectServiceNamed: 'RowanClientServices'
				in: self projectListPresenter.
			self
				selectServiceNamed: 'Rowan-Services-Tests'
				in: self packageListPresenter ].
	self
		selectServiceNamed: 'TestingMethodSource'
		in: self classListPresenter.
	self
		selectServiceNamed: 'didSourceUpdate'
		in: self projectsPresenter methodListPresenter.
	self waitWhile: [
		methodListBrowser methodSourcePresenter text
			~= methodListBrowser methodListPresenter selectedItem source ].
	self
		assert:
		methodListBrowser methodSourcePresenter text
		equals: methodListBrowser methodListPresenter selectedItem source.
	newSource := 'didSourceUpdate  | tempVar | "test created method" self doSomethingNew '.
	self
		saveMethod: newSource
		in: 'TestingMethodSource'
		category: 'test_created'.
	self
		assert: methodListBrowser methodListPresenter selectedItem selector
		equals: #didSourceUpdate.
	self waitWhile: [ methodListBrowser methodSourcePresenter text ~= newSource ].
	self
		assert: methodListBrowser methodSourcePresenter text
		equals: newSource.
	self waitWhile: [ self projectsPresenter methodSourcePresenter text ~= newSource ].
	self
		assert: self projectsPresenter methodSourcePresenter text
		equals: newSource
]

{ #category : 'as yet unclassified' }
JadeiteForPharoMethodListTestCase >> test_unsavedChangesNotOverwritten [

	| rowanSample1ClassService rowanSample1TestClassService widget |
	self
		testsIssue: #issue386
		withTitle:
		'(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	self
		testsJadeiteForPharoIssue: #issue268
		title:
		'clicking on method in package browser while editing the method in a method browser, unconditionally blows away the unfinished method edits'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/268'.

	self setupProjectBrowser.
	projectsBrowser
		updateAfterFindClassName: 'RowanSample1'
		methodSelector: nil
		meta: false.
	rowanSample1ClassService := self
		                            saveMethod: self sampleMethodSource
		                            in: 'RowanSample1'
		                            category: 'other'.
	rowanSample1TestClassService := self
		                                saveMethod: self sampleMethodSource
		                                in: 'RowanSample1Test'
		                                category: 'other'.
	self updateService:
		projectsBrowser activePresenter classListPresenter selectedItem.
	methodListBrowser := self projectsPresenter browseImplementorsOf:
		                     #sampleMethod.
	self
		assert:
		methodListBrowser methodListPresenter selection selectedIndex
		equals: 1.
	self
		assert: methodListBrowser methodListPresenter list size
		equals: 2.
	self waitWhile: [ (methodListBrowser methodSourcePresenter text ifNil: [ '' ]) isEmpty ].
	methodListBrowser methodSourcePresenter text: 'new text'.
	widget := methodListBrowser methodSourcePresenter adapter widget.
	self assert: widget hasUnacceptedEdits.
	projectsBrowser
		updateAfterFindClassName: 'RowanSample1'
		methodSelector: #sampleMethod
		meta: false.

	self
		assert:
			projectsBrowser activePresenter methodListPresenter selectedItem
				selector
		equals: 'sampleMethod'.
	self
		assert:
		methodListBrowser methodListPresenter selection selectedIndex
		equals: 1.
	self assert: widget hasUnacceptedEdits.
	self
		assert: methodListBrowser methodSourcePresenter text
		equals: 'new text'.
	widget hasUnacceptedEdits: false.
	JadeiteConnectionProfile connectionProfile disconnect "get rid of methods"
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> toolUsedForCommonTests [

	^ methodListBrowser ifNil: [
		  RowanServiceUpdater current critical: [
			  self openMethodListBrowserOfReferencesTo: 'AbstractCharacter' ].
		  methodListBrowser ]
]
