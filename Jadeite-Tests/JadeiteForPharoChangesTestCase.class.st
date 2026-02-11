Class {
	#name : 'JadeiteForPharoChangesTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'changesBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'private' }
JadeiteForPharoChangesTestCase >> performTest [

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'Rowan is available. Test not run' ].
	^ super performTest
]

{ #category : 'running' }
JadeiteForPharoChangesTestCase >> runCase [

	JadeitePreferences isRowanAvailable ifFalse: [ ^ self ].
	^ super runCase
]

{ #category : 'running' }
JadeiteForPharoChangesTestCase >> setUp [

	super setUp.
	self openProjectBrowser.
	self selectRowanAnsweringService.
	self methodSourcePresenter text: 'foo  ^''instance side'''.
	self projectsPresenter editSaveMethod.
	changesBrowser := self
		                  waitForNewPresenter: JadeiteChangesBrowser
		                  while: [ self projectsPresenter projectChanges ]
]

{ #category : 'running' }
JadeiteForPharoChangesTestCase >> tearDown [

	super tearDown.
	changesBrowser ifNotNil: [ changesBrowser window close ].
	self abortTransaction
]

{ #category : 'tests' }
JadeiteForPharoChangesTestCase >> test_selectedMethodName [

	self assert:
		changesBrowser operationsListPresenter selections isEmpty.
	self assertIsNil: changesBrowser selectedMethodName
]

{ #category : 'tests' }
JadeiteForPharoChangesTestCase >> test_windowTitle [

	self assert:
		(changesBrowser shellName , '*for*' , session stoneName , ' @*[*]'
			 match: changesBrowser window title)
]

{ #category : 'tests' }
JadeiteForPharoChangesTestCase >> toolUsedForCommonTests [
	"if a test specifies a tool, then use it for common tests"

	^ nil
]
