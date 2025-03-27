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

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> saveSourcesFor_test_sourcesSync: oldSource [

	self
		saveClass: 'TestingMethodSource'
		superclass: 'Object'
		instVars: #( 'inst1' )
		package: 'Rowan-Services-Tests'.
	self
		saveMethod: oldSource
		in: 'TestingMethodSource'
		category: 'test_created'
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
		self assert:
			('*Bag*' match: methodListBrowser methodSourcePresenter text) ] ]
		ensure: [ self destroy: originalMethodListBrowser ]
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_browseHierarchyImplementors [

	| methodService |
	self setupProjectBrowser.
	self
		selectServiceNamed: 'gemstoneBaseImage'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Filein2Streams'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'ReadStreamPortable'
		in: self classListPresenter.
	self selectServiceNamed: 'size' in: self projectsPresenter methodListPresenter.
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

	| hierarchyClassNames |
	self setupProjectBrowser.
	self
		selectServiceNamed: 'gemstoneBaseImage'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Filein2Streams'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'ReadStreamPortable'
		in: self classListPresenter.
	self selectServiceNamed: 'size' in: self projectsPresenter methodListPresenter.
	self waitForMethodListBrowserWhile: [
		self projectsPresenter browseHierarchySenders ].
	self assert:
		('* Hierarchy Senders of ''size'' in ReadStreamPortable for*'
			 match: methodListBrowser owner title).
	self selectHierarchyTab.
	self projectsPresenter expandFullHierarchy.
	hierarchyClassNames := self projectsPresenter classHierarchyPresenter
		                       adapter widget dataSource allShownItems
		                       collect: [ :ea | ea data name ]. "got to be an easier way to get the tree's objects"
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
		self assert: ('foo*' match:
				 methodListBrowser methodSourcePresenter documentPresenter
					 selection) "use match because we might pickup a '.'" ].
	self assert: ('* Senders of ''foo'' for *' match: methodListBrowser owner title)
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
		equals: 2
]

{ #category : 'tests' }
JadeiteForPharoMethodListTestCase >> test_methodCompileError [

	self openMethodListBrowserOfImplementorsOf: 'answer'.
	self methodListPresenter selectIndex: 1.
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
	self
		assert:
		methodListBrowser methodSourcePresenter documentPresenter text
		equals: methodListBrowser methodListPresenter selectedItem source.
	self openProjectBrowser.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Core'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'RowanBrowserService'
		in: self classListPresenter. "this would have cleared the method source"
	self assert: methodListBrowser methodSourcePresenter documentPresenter text 
		= methodListBrowser methodListPresenter selectedItem source.
	self assert:
		methodListBrowser methodListPresenter selectedItem selector
		= #compileClass:
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
JadeiteForPharoMethodListTestCase >> test_sourcesSync [

	| oldSource newSource |
	self setupProjectBrowser.
	oldSource := 'didSourceUpdate  | tempVar | "test created method" self doSomething'.
	self saveSourcesFor_test_sourcesSync: oldSource.
	self waitForMethodListBrowserWhile: [
		jadeiteShell browseImplementorsOf: #didSourceUpdate ].
	self
		assert:
		methodListBrowser methodSourcePresenter documentPresenter text
		equals: oldSource.
	self
		assert: methodListBrowser methodListPresenter list size
		equals: 1.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'TestingMethodSource'
		in: self classListPresenter.
	self
		selectServiceNamed: 'didSourceUpdate'
		in: self projectsPresenter methodListPresenter.
	self
		assert:
		methodListBrowser methodSourcePresenter documentPresenter text
		equals: methodListBrowser methodListPresenter selectedItem source.
	newSource := 'didSourceUpdate  | tempVar | "test created method" self doSomethingNew '.
	self
		saveMethod: newSource
		in: 'TestingMethodSource'
		category: 'test_created'.
	self
		assert: methodListBrowser methodListPresenter selectedItem selector
		equals: #didSourceUpdate.
	self
		assert:
		methodListBrowser methodSourcePresenter documentPresenter text
		equals: newSource.
	self
		assert:
		self projectsPresenter methodSourcePresenter documentPresenter text
		equals: newSource
]
