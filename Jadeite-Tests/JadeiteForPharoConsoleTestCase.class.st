Class {
	#name : 'JadeiteForPharoConsoleTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoConsoleTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor"

	^ {
		  JadeiteConsoleApplication.
		  JadeiteConsole.
		  JadeiteConsoleWithoutRowan.
		  JadeiteConsoleTableColumn } asOrderedCollection
]

{ #category : 'support' }
JadeiteForPharoConsoleTestCase >> console [
	"transcript is from the JfD days"

	^ transcript
]

{ #category : 'support' }
JadeiteForPharoConsoleTestCase >> projectListPresenter [

	^ self console projectListPresenter
]

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
JadeiteForPharoConsoleTestCase >> test_fileIn [

	| classes newClass fileName path |
	self console unsetCurrentProject.

	self openProjectBrowser.
	self
		selectServiceNamed: 'UnPackaged'
		in: self projectsPresenter projectListPresenter.
	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	self projectsPresenter setCurrentProject.
	self projectsPresenter setCurrentPackage.
	self projectsPresenter packageListPresenter unselectAll.

	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self assertIsNil: newClass.

	self
		saveClass: 'TestingFileIn'
		superclass: 'Object'
		instVars: #(  )
		package: 'UnPackaged-RowanClientServices'.

	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self denyIsNil: newClass.
	self projectsPresenter selectClassNamed: 'TestingFileIn'.
	fileName := 'test_fileIn.txt'.
	path := (FileSystem disk workingDirectoryPath / fileName)
		        asFileReference pathString.

	self projectsPresenter fileOutClassOnPath: path.

	self abortTransaction.

	self projectsPresenter packageListPresenter unselectAll.
	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self assertIsNil: newClass.

	self console basicFileInServerFile: path.

	self
		selectServiceNamed: 'UnPackaged-RowanClientServices'
		in: self projectsPresenter packageListPresenter.
	classes := self projectsPresenter classListPresenter list.
	newClass := classes
		            detect: [ :classService |
		            classService name = 'TestingFileIn' ]
		            ifNone: [  ].
	self denyIsNil: newClass.
	
	self abortTransaction.
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

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_setCurrentProject [

	| servicesProjectService rowanProjectService |
	self console unsetCurrentProject.
	self assert: self projectListPresenter list notEmpty.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.
	self transcript setCurrentProject.
	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.

	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	rowanProjectService := self projectListPresenter selectedItem.
	self assert: rowanProjectService displayName equals: 'Rowan'.
	self deny: rowanProjectService isCurrent.
	self console setCurrentProject.
	self assert: rowanProjectService displayName equals: '*Rowan'.
	self assert: rowanProjectService isCurrent.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.

	self console unsetCurrentProject.
	self assert: rowanProjectService displayName equals: 'Rowan'.
	self deny: rowanProjectService isCurrent
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_unsetCurrentProject [

	| servicesProjectService |
	self console unsetCurrentProject.
	self projectListPresenter items do: [ :projectService |
		self deny: (projectService displayName includes: $*).
		self deny: projectService isCurrent ].
	self
		selectServiceNamed: 'RowanClientServices'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'RowanClientServices'.
	self deny: servicesProjectService isCurrent.

	self console setCurrentProject.
	self
		assert: servicesProjectService displayName
		equals: '*RowanClientServices'.
	self assert: servicesProjectService isCurrent.

	self console unsetCurrentProject.
	self projectListPresenter items do: [ :projectService |
		self deny: (projectService displayName includes: $*).
		self deny: projectService isCurrent ]
]

{ #category : 'support' }
JadeiteForPharoConsoleTestCase >> toolUsedForCommonTests [

	^ jadeiteShell
]
