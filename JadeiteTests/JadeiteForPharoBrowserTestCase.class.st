Class {
	#name : 'JadeiteForPharoBrowserTestCase',
	#superclass : 'JadeiteForPharoBrowserAbstractTestCase',
	#category : 'JadeiteTests'
}

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
