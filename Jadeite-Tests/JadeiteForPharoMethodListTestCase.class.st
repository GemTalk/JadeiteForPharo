Class {
	#name : 'JadeiteForPharoMethodListTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'methodListBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> openMethodListBrowserOfImplementorsOf: aString [
	"just calling this method #browserImplementorsOf: would confuse it with production methods"

	self waitForMethodListBrowserWhile: [
		[ jadeiteShell browseImplementorsOf ]
			on: ProvideAnswerNotification
			do: [ :notification | notification resume: aString ] ]
]

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> tearDown [

	super tearDown.
	self destroy: methodListBrowser
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

{ #category : 'as yet unclassified' }
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
	self assert: self methodListPresenter list size equals: 1.
	self assert: self methodListPresenter list first selector
		= #testbrowseInstVarReaders
]

{ #category : 'as yet unclassified' }
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

{ #category : 'support' }
JadeiteForPharoMethodListTestCase >> waitForMethodListBrowserWhile: aBlock [
	"would really like a more determinate way of getting the write method list"

	| existingMethodLists newMethodLists |
	RsrGarbageCollector maximumReclamation.
	existingMethodLists := JadeiteMethodListPresenter allInstances.
	aBlock fork.
	[
	(newMethodLists := JadeiteMethodListPresenter allInstances
		                   asOrderedCollection) size
	> existingMethodLists size ] whileFalse: [
		(Delay forMilliseconds: 1) wait ].
	newMethodLists removeAll: existingMethodLists.
	methodListBrowser := newMethodLists first
]
