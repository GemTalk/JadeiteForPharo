Class {
	#name : 'JadeiteForPharoSUnitBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'sunitBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> application [
	"Spec2 needs this to open a browser via preferences"
	^JadeiteConsoleApplication new gciSession: GciSession current 
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> assertPackageInList: name [
	self denyIsNil: (sunitBrowser packageListPresenter list
				detect: [:packageService | packageService name = name]
				ifNone: [])
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> denyPackageInList: name [
	self assertIsNil: (sunitBrowser packageListPresenter list
				detect: [:packageService | packageService name = name]
				ifNone: [])
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> gciSession [

	^GciSession current 
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> setUp [ 

	super setUp. 
	sunitBrowser := self openSUnitBrowser. 
	sunitBrowser identityHash traceCr. 
]

{ #category : 'support' }
JadeiteForPharoSUnitBrowserTestCase >> tearDown [ 

	super tearDown. 
	self destroy: sunitBrowser
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_abortNoSelections [

	self
		testsIssue: #issue383
		withTitle:
		'(3.0.53) the commit button on the SUnit browser is silent'.
	self transcript
		basicUnloadProjects: (Array with: self sampleProject1Name)
		onCompletion: [  ].
	self commitTransaction. "ensure that the sample package wasn't committed"
	self denyPackageInList: 'RowanSample1-Tests'.
	self testResourceClass current createRowanSample1Project.
	self assertPackageInList: 'RowanSample1-Tests'.
	sunitBrowser abortTransaction.
	self denyPackageInList: 'RowanSample1-Tests'
]

{ #category : 'as yet unclassified' }
JadeiteForPharoSUnitBrowserTestCase >> test_abortWithSelections [
	"don't lose selection on abort which removes another package"

	self
		testsIssue: #issue383
		withTitle:
		'(3.0.53) the commit button on the SUnit browser is silent'.
	self transcript
		basicUnloadProjects: (Array with: self sampleProject1Name)
		onCompletion: [  ].
	self commitTransaction. "ensure that the sample package wasn't committed"
	sunitBrowser
		selectPackageNamed: 'Rowan-Services-Tests'
		classNamed: 'RowanTestClassServiceTest'.
	sunitBrowser selectMethodNamed: #test_addCategory.
	sunitBrowser abortTransaction.
	self
		assert: sunitBrowser packageListPresenter selectedItem name
		equals: 'Rowan-Services-Tests'.
	self
		assert: sunitBrowser classListPresenter selectedItem name
		equals: 'RowanTestClassServiceTest'.
	self
		assert: sunitBrowser methodListPresenter selectedItems size
		equals: 1.
	self
		assert:
		sunitBrowser methodListPresenter selectedItems first selector
		equals: #test_addCategory
]

{ #category : 'tests' }
JadeiteForPharoSUnitBrowserTestCase >> test_missingPackages [

	"packages weren't showing up in an sunit browser due to a timing issue. 
	Not directly reproducible, but open and close the sunit browser a number of times
	and make sure packages are there. #openSUnitBrowser is a traits method so we can 
	just send it to self" 
	self destroy: sunitBrowser. "opened in setUp"
	25 timesRepeat: [ sunitBrowser := self openSUnitBrowser. 
		self assert: sunitBrowser packageListPresenter list notEmpty.
		self destroy: sunitBrowser
		]
	

]
