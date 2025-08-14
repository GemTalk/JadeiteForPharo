Class {
	#name : 'JadeiteForPharoChangesTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoChangesTestCase >> test_windowTitle [

	| changesBrowser |
	self openProjectBrowser.
	self selectRowanAnsweringService.
	self methodSourcePresenter text: 'foo  ^''instance side'''.
	self projectsPresenter editSaveMethod.
	changesBrowser := self
		                  waitForNew: JadeiteChangesBrowser
		                  while: [ self projectsPresenter projectChanges ].
	[
	self assert:
		(changesBrowser shellName , '*for*' , session stoneName , ' @*[*]'
			 match: changesBrowser window title) ] ensure: [
		changesBrowser window close.
		self abortTransaction ]
]
