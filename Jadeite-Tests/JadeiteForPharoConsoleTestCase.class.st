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

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_openHelp [
	"open the Jadeite Help File and make sure it's contents match the .md file prescribed"

	| helpPresenter helpFileName fileReference |
	helpPresenter := jadeiteShell openJadeiteHelpFile presenter.
	helpFileName := helpPresenter defaultHelpMarkdownFile.
	fileReference := FileSystem workingDirectory resolveString:
		                 helpFileName.
	self assert: fileReference exists.
	self
		assert: helpPresenter contentsPresenter text asString
		equals: (helpPresenter contentsPresenter documentFromString: fileReference contents) text asString.
	self destroy: helpPresenter
]
