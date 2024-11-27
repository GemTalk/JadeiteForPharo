Class {
	#name : 'JadeiteForPharoConsoleTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_basicSelect [
	"bug found just selecting projects - was trying to disconnect.
Just select everything and assert the selection index changed."

	| projectsPresenter |
	projectsPresenter := jadeiteShell projectListPresenter.
	1 to: projectsPresenter items size do: [ :index |
		projectsPresenter selectIndex: index.
		self assert: projectsPresenter selection selectedIndex equals: index ]
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_browseProject [

	| projectsPresenter service |
	RowanServiceUpdater uninstallTestUpdater.
	projectsPresenter := jadeiteShell projectListPresenter.
	service := projectsPresenter items detect: [ :projectService |
		           projectService name = 'Rowan' ].
	projectsPresenter selectItem: service.
	projectsBrowser := jadeiteShell browseProject.
	[ self projectsPresenter projectListPresenter selectedItem isNil ]
		whileTrue: [ (Delay forMilliseconds: 10) wait ].
	self assert: [
		self projectsPresenter projectListPresenter selectedItem name
		= 'Rowan' ]
]
