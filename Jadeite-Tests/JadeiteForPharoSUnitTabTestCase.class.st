Class {
	#name : 'JadeiteForPharoSUnitTabTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'testing' }
JadeiteForPharoSUnitTabTestCase class >> runAsDataCurator [

	^ true
]

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
JadeiteForPharoSUnitTabTestCase >> selectTestNamed: aSelector [

	| methodService |
	methodService := self theTestCases items detect: [ :methodService |
		                 methodService selector = aSelector ].
	self theTestCasePresenter selectItem: methodService
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
JadeiteForPharoSUnitTabTestCase >> testNamed: selector [

	^ self theTestCases
		  detect: [ :methodService | methodService selector = selector ]
		  ifNone: [ ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_abortClearsSelection [
	"should be able to save a new test without a method being selected"

	self isDataCurator ifTrue: [ ^ self ].
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self deny: (self theTestSelectors includes: #test_foo).
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self waitUntil: [ self theTestSelectors includes: #test_foo ].
	self assert: (self theTestSelectors includes: #test_foo).
	self projectsPresenter application abortTransactionOnCompletion: [
			self waitUntil: [ (self theTestSelectors includes: #test_foo) not ].
			self deny: (self theTestSelectors includes: #test_foo).
			self assertIsNil: self theTestCasePresenter selectionOrNil.
			self assert: self methodSourcePresenter text equals: String new ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_allTestsDisplayed [

	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self theTestCasePresenter list notEmpty ].
	self assert:
		self classListPresenter selectedItem testMethodSelectors notEmpty.
	self classListPresenter selectedItem testMethodSelectors do: [ :sel |
			| methodService |
			methodService := self theTestCases
				                 detect: [ :svc | svc selector = sel ]
				                 ifNone: [ ].
			self denyIsNil: methodService.
			self assert: methodService selector equals: sel ]
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_deselectClass [

	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self theTestCasePresenter list notEmpty ].
	self theTestCasePresenter selectIndex: 1.
	self waitUntil: [
			self methodSourcePresenter text notNil and: [
				self methodSourcePresenter text notEmpty ] ].
	self
		assert: self methodSourcePresenter text
		equals: self theTestCasePresenter selectedItem source.
	self theTestCasePresenter unselectAll.
	self assert: self methodSourcePresenter text equals: String new.
	self deny: self methodSourcePresenter hasUnacceptedEdits
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_methodAcceptedWithoutTestSelected [
	"should be able to save a new test without a method being selected"

	self isDataCurator ifTrue: [ ^ self ].
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self deny: self theTestCasePresenter hasSelection.
	self deny: (self theTestSelectors includes: #test_foo).
	self deny: (self methods includes: #test_foo).
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self waitUntil: [ self theTestSelectors includes: #test_foo ].
	self assert: (self theTestSelectors includes: #test_foo).
	self assert: (self testNamed: #test_foo) category equals: 'tests'.
	self assert: (self methods includes: #test_foo)
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_methodSelectedAfterSave [

	self isDataCurator ifTrue: [ ^ self ].
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self deny: self theTestCasePresenter hasSelection.
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self waitUntil: [ self theTestSelectors includes: #test_foo ].
	self assert: (self theTestSelectors includes: #test_foo).
	self
		assert: self theTestCasePresenter selectedItem selector
		equals: #test_foo
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_runAllTests [

	| sunitTab semTimeout |
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self projectsPresenter isSUnitTabSelected ].
	sunitTab := self projectsPresenter sunitPage.
	self waitUntil: [
		sunitTab activePresenter testCaseListPresenter list notEmpty ].
	self deny:
		('* run, * passed, * failures, * errors, * seconds' match:
			 self projectsPresenter statusBarText message).
	sunitTab activePresenter runAll.
	semTimeout := sunitTab activePresenter testSemaphore
		              waitTimeoutSeconds: 2.
	WorldMorph doOneCycle.
	self deny: semTimeout.
	self assert:
		('* run, * passed, * failures, * errors, * seconds' match:
			 self projectsPresenter statusBarText message)
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_runSelectedTests [
	"assumes announcer tests pass. Big assumption."

	| sunitTab semTimeout |
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self projectsPresenter isSUnitTabSelected ].
	sunitTab := self projectsPresenter sunitPage.
	self waitUntil: [
		sunitTab activePresenter testCaseListPresenter list notEmpty ].
	sunitTab activePresenter testCaseListPresenter selectIndex: 1.
	self waitUntil: [
			sunitTab activePresenter methodSourcePresenter text notNil and: [
				sunitTab activePresenter methodSourcePresenter text notEmpty ] ].
	self deny:
		('1 run, 1 passed, 0 failures, 0 errors, * seconds' match:
			 self projectsPresenter statusBarText message).
	sunitTab activePresenter runSelected.
	semTimeout := sunitTab activePresenter testSemaphore
		              waitTimeoutSeconds: 2.
	WorldMorph doOneCycle.
	self deny: semTimeout.
	self assert:
		('1 run, 1 passed, 0 failures, 0 errors, * seconds' match:
			 self projectsPresenter statusBarText message)
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_saveMethodInSuperclass [

	self isDataCurator ifTrue: [ ^ self ].
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self theTestSelectors includes: #testAnnounceClass ].
	self selectTestNamed: #testAnnounceClass.
	self
		assert: self theTestCasePresenter selectedItem selector
		equals: #testAnnounceClass.
	self
		assert: self theTestCasePresenter selectedItem className
		equals: 'AnnouncerTest'.
	self waitUntil: [
		'testAnnounceClass*' match: self methodSourcePresenter text ].
	self methodSourcePresenter text: 'test_foo'.
	self sunitPresenter editSaveMethod.
	self waitUntil: [ self theTestSelectors includes: #test_foo ].
	self assert: (self theTestSelectors includes: #test_foo).
	self
		assert: self theTestCasePresenter selectedItem selector
		equals: #test_foo.
	self
		assert: self theTestCasePresenter selectedItem className
		equals: 'AnnouncerTest'
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_selectDifferentTestClass [

	| announcerTests weakAnnouncerTests |
	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self theTestSelectors notEmpty ].
	announcerTests := self theTestSelectors.
	self assert: announcerTests notEmpty.
	self
		selectServiceNamed: 'WeakAnnouncerTest'
		in: self classListPresenter.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [
			self theTestCasePresenter items
				ifEmpty: [ false ]
				ifNotEmpty: [ :coll | coll first className = 'WeakAnnouncerTest' ] ].
	weakAnnouncerTests := self theTestSelectors.
	self assert: weakAnnouncerTests notEmpty.
	self deny: announcerTests equals: weakAnnouncerTests
]

{ #category : 'tests' }
JadeiteForPharoSUnitTabTestCase >> test_selection [

	self projectsPresenter findClassNamed: 'AnnouncerTest'.
	self projectsPresenter selectSUnitTab.
	self waitUntil: [ self theTestCasePresenter list notEmpty ].
	self theTestCasePresenter selectIndex: 1.
	self waitUntil: [
			self methodSourcePresenter text notNil and: [
				self methodSourcePresenter text notEmpty ] ].
	self
		assert: self methodSourcePresenter text
		equals: self theTestCasePresenter selectedItem source
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> theTestCasePresenter [

	^ self projectsPresenter sunitPresenter testCaseListPresenter
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> theTestCases [

	^ self theTestCasePresenter list
]

{ #category : 'support' }
JadeiteForPharoSUnitTabTestCase >> theTestSelectors [

	^ self theTestCasePresenter items collect: [ :ea | ea selector ]
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
