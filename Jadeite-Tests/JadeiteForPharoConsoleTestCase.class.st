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
