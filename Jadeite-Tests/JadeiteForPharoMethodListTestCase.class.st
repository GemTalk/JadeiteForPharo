Class {
	#name : 'JadeiteForPharoMethodListTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
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
JadeiteForPharoMethodListTestCase >> openMethodListBrowserOfReferencesTo: className [

	self waitForMethodListBrowserWhile: [
		[ jadeiteShell browseClassReferences: className ]
			on: ProvideAnswerNotification
			do: [ :notification | notification resume: className ] ]
]

{ #category : 'as yet unclassified' }
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
	self selectServiceNamed: 'size' in: self methodListPresenter.
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
	self selectServiceNamed: 'size' in: self methodListPresenter.
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
