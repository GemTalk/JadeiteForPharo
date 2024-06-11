Class {
	#name : 'JadeiteProjectBrowserAbstractTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'secondBrowser',
		'methodListBrowser',
		'secondPresenter',
		'transcriptWritesWereEnabled'
	],
	#category : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> assertClassDefinitionPaneMatches: matchString [
	self assert: ('*', matchString, '*' match: self projectsPresenter classDefinitionPresenter value)
		description: 'Class definition pane did not match expected'
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> assertLinearAncestry: family in: presenter [
	"given a collection of class names in order from root to leaf,
	test that each subsequent element of the collection is a child
	of the previous element."

	1 to: family size - 1
		do: 
			[:index |
			| parentNode childNode parentName childName |
			parentName := family at: index.
			childName := family at: index + 1.
			parentNode := presenter model asBag detect: [:classService | classService name = parentName]
						ifNone: [].
			childNode := presenter model asBag detect: [:classService | classService name = childName]
						ifNone: [].
			self assert: ((presenter model childrenOf: parentNode) includes: childNode)]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> disableTranscriptWrites [
	(transcriptWritesWereEnabled := transcript isTranscriptInstalled)
		ifTrue: [transcript flipTranscript]	"turn off gemstone transcript writes for performance"
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> findClassNamed: selection [

	| classService browser |
	UIManager default defer: [
		browser := self openBrowser.
		classService := RowanClassService new name: selection.
		browser activePresenter
			updateAfterFindClass: classService
			onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> isAbstract [

	^self == JadeiteProjectBrowserAbstractTestCase
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> issue170methodCreation [
	| source |
	self methodSourcePresenter value: (source := 'another  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'interesting  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'test  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'try  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> primaryTestWindow [
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^projectsBrowser
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> projectNamed: aString [
	^self projectsPresenter projectListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> reloadProjectNamed: projectName [
	| projectService |
	projectService := RowanProjectService new name: projectName.
	RowanBrowserService new reloadProjects: (Array with: projectService)
		presenter: self projectsPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> saveMethodWithUniqueString [

	| source |
	source := 'gloop
	"I be unique"
	^self gloop'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> selectLowerTabsThenDo: aBlock [
	#('sunit' 'classDefinition' 'classDocumentation' 'methodSource' 'comparisonTab') do: 
			[:tabName |
			| tab |
			tab := self projectsPresenter selectSourceTabNamed: tabName.
			aBlock value: tab]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> selectSUnitTab [
	self projectsPresenter sunitPresenter ensureVisible
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> setUp [
	super setUp.
	self setupProjectBrowser
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserAbstractTestCase >> tearDown [
	super tearDown.
	session isValidSession
		ifTrue: [transcriptWritesWereEnabled == true ifTrue: [transcript flipTranscript]].
	methodListBrowser
		ifNotNil: 
			[self destroy: methodListBrowser.
			methodListBrowser := nil].
	secondBrowser
		ifNotNil: 
			[self destroy: secondBrowser.
			secondBrowser := nil]
]
