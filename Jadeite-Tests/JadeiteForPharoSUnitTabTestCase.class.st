Class {
	#name : 'JadeiteForPharoSUnitTabTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> methodNamed: selector [

	^ self methodListPresenter list
		  detect: [ :methodService | methodService selector = selector ]
		  ifNone: [ ]
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> methodSourcePresenter [

	^ self projectsPresenter sunitPresenter methodSourcePresenter
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> methods [
	"for testing what's in the method list as we change the tests in the sunit tab"

	^ self methodListPresenter list collect: [ :methodService |
		  methodService selector ]
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> setUp [

	self
		testsJadeiteForPharoIssue: #issue48
		title:
		'Running and debugging SUnit tests from the Projects Browser '.
	super setUp.
	self setupProjectBrowser
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> sunitPresenter [

	^ self projectsPresenter sunitPresenter
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> testCasePresenter [

	^ self projectsPresenter sunitPresenter testCaseListPresenter
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> testNamed: selector [

	^ self theTestCases
		  detect: [ :methodService | methodService selector = selector ]
		  ifNone: [ ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_abortClearsSelection [
	"should be able to save a new test without a method being selected"

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'rowan available only test for now' ].
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	self
		selectServiceNamed: 'Rowan-Services-Tests'
		in: self packageListPresenter.
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self projectsPresenter selectSUnitTab.
	self deny: (self theTestSelectors includes: #test_foo).
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self assert: (self theTestSelectors includes: #test_foo).
	self projectsPresenter application abortTransactionOnCompletion: [
			self waitUntil: [ (self theTestSelectors includes: #test_foo) not ].
			self deny: (self theTestSelectors includes: #test_foo).
			self deny: self testCasePresenter hasSelection.
			self assert: self methodSourcePresenter text equals: String new ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_methodAcceptedWithoutTestSelected [
	"should be able to save a new test without a method being selected"

	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	self deny: self testCasePresenter hasSelection.
	self deny: (self theTestSelectors includes: #test_foo).
	self deny: (self methods includes: #test_foo).
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self assert: (self theTestSelectors includes: #test_foo).
	self assert: (self testNamed: #test_foo) category equals: 'tests'.
	self assert: (self methods includes: #test_foo)
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_methodSelectedAfterSave [

	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	self deny: self testCasePresenter hasSelection.
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self assert: (self theTestSelectors includes: #test_foo).
	self
		assert: self testCasePresenter selectedItem selector
		equals: #test_foo
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_selection [

	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self testCasePresenter list notEmpty ].
	self testCasePresenter selectIndex: 1.
	self waitUntil: [
			self methodSourcePresenter text notNil and: [
				self methodSourcePresenter text notEmpty ] ].
	self
		assert: self methodSourcePresenter text
		equals: self testCasePresenter selectedItem source
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_testsDisplayed [
	"should be able to save a new test without a method being selected"

	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self testCasePresenter list notEmpty ].
	#( test1 test2 testError testFailure ) do: [ :sel |
			| methodService |
			methodService := self theTestCases
				                 detect: [ :svc | svc selector = sel ]
				                 ifNone: [ ].
			self denyIsNil: methodService.
			self assert: methodService selector equals: sel ]
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> theTestCases [

	^ self testCasePresenter list
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> theTestSelectors [

	^ self testCasePresenter list collect: [ :ea | ea selector ]
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> waitUntil: aBlock [

	| sem expired |
	sem := Semaphore new.
	[
		aBlock whileFalse: [
				(Delay forMilliseconds: 10) wait.
				WorldMorph doOneCycle ].
		sem signal ] fork.
	expired := sem waitTimeoutSeconds: 5.
	self deny: expired
]
