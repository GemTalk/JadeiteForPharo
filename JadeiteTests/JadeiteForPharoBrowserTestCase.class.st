Class {
	#name : 'JadeiteForPharoBrowserTestCase',
	#superclass : 'JadeiteForPharoBrowserAbstractTestCase',
	#category : 'JadeiteTests'
}

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> morphicMethodSourceHasUnacceptedEdits [

	^self methodSourcePresenter withAdapterDo: [ :adapter | adapter widgetDo:[:widget | widget hasUnacceptedEdits ] ]
]

{ #category : 'support' }
JadeiteForPharoBrowserTestCase >> projectList [
	^self projectListPresenter list
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
		self projectsPresenter basicRemoveClass:
			self projectsPresenter selectedClass ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_loadProjectAddedInAlphabeticalOrder [

	| projects |
	self
		testsJadeiteForPharoIssue: #issue21
		withTitle:
		'loading a new project externally and then aborting ends up with new project at bottom of console'.
	JadeiteApplication abortTransactionInSession: session.
	[
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
		equals: projects asSortedCollection asOrderedCollection ] ensure: [
		JadeiteTestResource current
			tearDown;
			"reset the world after abort. Need to improve this. "setUp ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserTestCase >> test_methodListBrowserOverwritesMethods [

	| methodList classMethod instanceMethod|
	self
		testsJadeiteForPharoIssue: #issue10
		withTitle:
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
	methodList := methodListBrowser methodListPresenter list asOrderedCollection.
	self assert: methodList size equals: 2.
	methodList do: [ :methodService |
		self assert: methodService className equals: 'RowanSample1' ].
	classMethod := methodList detect: [ :methodService | methodService meta ]. 
	instanceMethod := methodList detect: [ :methodService | methodService meta not ].
	self deny: classMethod equals: instanceMethod. 
	self assert: classMethod displayClassName equals: 'RowanSample1 class'. 
	self assert: instanceMethod displayClassName equals: 'RowanSample1'.
	methodListBrowser methodListPresenter selectItem: instanceMethod. 
	self assert: methodListBrowser methodSourcePresenter text asString equals: 'foo ^''foo'''.
	self
		saveMethod: 'foo  ^''the class side'''
		in: 'RowanSample1'
		category: 'dontcare'
		meta: true. "this should not write over the method list source pane"
	self deny: methodListBrowser methodListPresenter selectedItem meta. 
	self assert: methodListBrowser methodSourcePresenter text asString equals: 'foo ^''foo'''.
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
	self 
		saveMethod: 'foo  ^''instance side'''
		in: 'RowanSample1'
		category: 'dontcare'
		meta: false.
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
