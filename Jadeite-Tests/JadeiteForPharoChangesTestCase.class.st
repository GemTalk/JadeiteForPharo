Class {
	#name : 'JadeiteForPharoChangesTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoChangesTestCase >> test_windowTitle [

	| changesBrowser |
	self
		selectServiceNamed: 'RowanClientServices'
		in: jadeiteShell projectListPresenter.
	changesBrowser := self
		                  waitForNew: JadeiteChangesBrowser
		                  while: [ jadeiteShell projectChanges ].
	changesBrowser ifNil: [ "no changes, we'll test it next time we have changes"
		^ self ].
	[
	self assert:
		(changesBrowser shellName , '*for*' , session stoneName , ' @*[*]'
			 match: changesBrowser window title) ] ensure: [
		changesBrowser window close ]
]
