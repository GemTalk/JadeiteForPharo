"
Run a few sanity tests as DataCurator during every test run.

Test tests are mostly copies of other test class tests just run
under the DataCurator login. 
"
Class {
	#name : 'JadeiteDataCuratorTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> setUp [
	user := 'DataCurator'.
	super setUp.
	self setupProjectBrowser
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> tearDown [

	super tearDown.
	GciSession current userID: nil. "ensure we logout and back in"
	self assert: jadeiteShell userIDPresenter value equals: 'SystemUser'.
	self assert: GciSession current userID equals: 'SystemUser'.
	self assert: (GciSession current executeString: '3+4') equals: 7
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_addAccessorsClassTab [

	self
		testsIssue: #issue382
		withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #(  )
		package: 'RowanSample1-Core'.

	[
	self projectsPresenter selectClassTab.
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
JadeiteDataCuratorTestCase >> test_autoCommit [
	| methodListPresenter autoCommit methodListBrowser |
	self testsIssue: #issue421 withTitle: 'Need a way to know if you are in autocommit'.
	methodListBrowser := JadePresenter browseImplementorsOf: #size session: session.
	
	[methodListPresenter := methodListBrowser primaryPresenter.
	autoCommit := self projectsPresenter remoteAutoCommit.
	self assert: self projectsPresenter autoCommit equals: autoCommit.
	self assert: methodListPresenter autoCommit equals: autoCommit.
	self assert: transcript autoCommit equals: autoCommit.
	self projectsPresenter flipAutoCommit.
	self assert: self projectsPresenter remoteAutoCommit.
	self assert: self projectsPresenter autoCommit.
	self assert: methodListPresenter autoCommit.
	self assert: transcript autoCommit.
	methodListPresenter flipAutoCommit.
	self deny: (autoCommit := self projectsPresenter remoteAutoCommit).
	self deny: self projectsPresenter autoCommit.
	self deny: methodListPresenter autoCommit.
	self deny: transcript autoCommit.
	transcript flipAutoCommit.
	self assert: self projectsPresenter remoteAutoCommit.
	self assert: self projectsPresenter autoCommit.
	self assert: methodListPresenter autoCommit.
	self assert: transcript autoCommit]
			ensure: [self destroy: methodListBrowser]
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_basicInspection [
	| remoteObject inspector |
	self testsIssue: #issue687 withTitle: 'inspection as DataCurator broken'.
	remoteObject := session
				executeString: '''fnoodle'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: inspector model isKindOf: RowanInspectorService.
	self assert: inspector documentPresenter value equals: '''fnoodle''']
			ensure: [inspector view close].
	remoteObject := session
				executeString: 'UserGlobals'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: inspector model isKindOf: RowanInspectorService.
	self assert: ('*SymbolDictionary*' match: inspector documentPresenter value)]
			ensure: [inspector view close]
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_compileClass [

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
	[
	self assert: self projectsPresenter selectedClass name = 'TestClass' ]
		ensure: [
			self projectsPresenter
				basicRemoveClass: self projectsPresenter selectedClass
				onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_dictionaryNameIsString [
	"for consistency, service names should be strings"
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: (self dictionaryPresenter selection name isKindOf: String).
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_dictionarySelectionChangesTab [
	| browserTabs |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	browserTabs := projectsBrowser cardsPresenter view.
	self selectNoneProject.
	self assert: browserTabs currentCard arrangement text equals: '1 ' , RowanProjectService noneProject name.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: browserTabs currentCard arrangement text equals: '1 UserGlobals'.
	self projectListPresenter resetSelection.
	self assert: browserTabs currentCard arrangement text equals: '1 Projects'
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_dictionaryWithoutClassHasClassTemplate [
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter selectClassDefinitionTab.
	self assertIsNil: self projectsPresenter selectedClass.
	self rowanFixMe.
	self assert: self projectsPresenter classDefinitionPresenter value notEmpty	"not sure what this should be yet"
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_dontDuplicateBreakpoints [
	| breakpointBrowser |
	self testsIssue: #issue533
		withTitle: 'Breakpoint browser seems muddled: method browser with duplicate methods'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self assert: self methodListPresenter selection breakPoints size = 2.
	self assert: self methodListPresenter selection breakPoints = #(1 2) asOrderedCollection.
	
	[breakpointBrowser := self projectsPresenter browseBreakpointList.
	self assert: breakpointBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: breakpointBrowser primaryPresenter methodListPresenter selection selector = #test1.
	self assert: breakpointBrowser primaryPresenter methodListPresenter selection breakPoints
				= #(1 2) asOrderedCollection]
			ensure: 
				[breakpointBrowser view close.
				self projectsPresenter clearMethodBreakpoints]
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_dontOverrideExistingAccessorMethods [

	self
		testsIssue: #issue382
		withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'abc' )
		package: 'RowanSample1-Core'.

	[
	self saveMethod: 'abc  ^123' in: 'TestClass' category: 'accessing'.
	self
		saveMethod: 'abc: foo ^123'
		in: 'TestClass'
		category: 'accessing'.
	self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #( 'abc' ).
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no. "do not create accessors"
	[ self projectsPresenter addVariableAccessors ] ensure: [
		TestMessageBox disableJadeiteTestMessageBox ].
	self variableListPresenter selections: #(  ).
	self selectMethodNamed: #abc.
	self assert: self methodSourcePresenter value equals: 'abc  ^123'.
	self selectMethodNamed: #abc:.
	self assert: self methodSourcePresenter value equals: 'abc: foo ^123' ]
		ensure: [
			self projectsPresenter
				basicRemoveClass: self projectsPresenter selectedClass
				onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_loginOk [
	self assert: jadeiteShell userIDPresenter value equals: 'DataCurator'.
	self assert: GciSession current userID equals: 'DataCurator'.
	self assert: (GciSession current executeString: '3+4') equals: 7
]

{ #category : 'as yet unclassified' }
JadeiteDataCuratorTestCase >> test_transcriptWindowPosition [
	self testsIssue: #issue735
		withTitle: 'In multi-monitor setupt, inconsistent locations for opening windows (3.0.93-7)'.
	self assert: transcript view position
		equals: jadeiteShell view position + JadePresenter defaultWindowOffset
]
