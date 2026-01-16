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
JadeiteForPharoConsoleTestCase >> test_abortTransaction [
	"assumption RowanSample1 is always loaded in the test resource"

	| sampleProject |
	sampleProject := jadeiteShell projectListPresenter list collection detect: [
		                 :projectService |
		                 projectService name = 'RowanSample1' ].
	self assert:
		(jadeiteShell projectListPresenter list includes: sampleProject).
	jadeiteShell abortTransaction.
	self deny:
		(jadeiteShell projectListPresenter list includes: sampleProject)
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_alwaysDiscard [
	"console should never return true to canDiscardEdits as there are no edits to make"

	self assert: jadeiteShell canDiscardEdits
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_auditProjects [

	| auditResults |
	jadeiteShell projectListPresenter selectIndex: 1.
	auditResults := self
		                waitForNew: JadeiteWorkspace
		                while: [ jadeiteShell auditProjects ].
	self assert: auditResults window isOpen.
	self assert: auditResults isKindOf: JadeiteWorkspace.
	self destroy: auditResults
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_basicSelect [
	"bug found just selecting projects - was trying to disconnect.
Just select everything and assert the selection index changed."

	| projectsPresenter |
	projectsPresenter := jadeiteShell projectListPresenter.
	1 to: projectsPresenter items size do: [ :index |
			projectsPresenter unselectAll.
			projectsPresenter selectIndex: index.
			self
				assert: projectsPresenter selection selectedIndex
				equals: index ]
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_browseClassReferences [

	methodListBrowser := self
		                     waitForNew: JadeiteMethodListPresenter
		                     while: [
		                     jadeiteShell browseClassReferences:
			                     'RowanCommandResult' ].
	self assert: methodListBrowser isKindOf: JadeiteMethodListPresenter
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_browseProject [

	| projectsPresenter service |
	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip:
			  'Rowan not available. ' , thisContext methodClass name , '>>#'
			  , thisContext selector , ' not run' ].
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
JadeiteForPharoConsoleTestCase >> test_findClassUpdatesLabel [

	| projectsPresenter sem |
	RowanServiceUpdater uninstallTestUpdater.

	projectsPresenter := self
		                   waitForNew: JadeiteBrowser browserPresenterClass
		                   while: [ jadeiteShell findClassNamed: 'Object' ].
	projectsBrowser := projectsPresenter parentPresenter.
	sem := Semaphore new.
	[
	[
	projectsPresenter selectedClass
		ifNil: [ false ]
		ifNotNil: [ :classService | classService name = 'Object' ] ]
		whileFalse: [ (Delay forMilliseconds: 10) wait ].
	sem signal ] fork.

	sem waitTimeoutSeconds: 2.
	self assert: projectsPresenter selectedClass name equals: 'Object'.
	self
		assert: projectsPresenter parentPresenter
		isKindOf: JadeiteBrowser.
	self assert: projectsPresenter owner isKindOf: SpNotebookPresenter.
	self
		assert: projectsPresenter parentPresenter tabs selectedPage title
		equals: '1 Object'
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_jadeiteHelp [

	| helpBrowser |
	helpBrowser := jadeiteShell openJadeiteHelpFile.
	self assert: helpBrowser isOpen.
	self assert: helpBrowser presenter isKindOf: JadeiteHelpPresenter.
	self destroy: helpBrowser
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
	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip:
			  'Rowan not available. ' , thisContext methodClass name , '>>#'
			  , thisContext selector , ' not run' ].
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
JadeiteForPharoConsoleTestCase >> test_themeChanged [
	"not sure what to test here. I guess just switch
	themes and back and make sure there are no errors? "

	PharoLightTheme beCurrent. "should already be current as that's only what's supported"
	PharoLightTheme isCurrent ifFalse: [ self halt ].
	self assert: PharoLightTheme isCurrent.
	PharoDarkTheme beCurrent.
	PharoDarkTheme isCurrent ifFalse: [ self halt ].
	self assert: PharoDarkTheme isCurrent.
	PharoLightTheme beCurrent.
	PharoLightTheme isCurrent ifFalse: [ self halt ].
	self assert: PharoLightTheme isCurrent
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_transcriptReset [

	self console selectTranscriptTab.
	self assertTextPaneResetFor: self console transcriptPresenter
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_unsetCurrentProject [

	| servicesProjectService |
	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip:
			  'Rowan not available. ' , thisContext methodClass name , '>>#'
			  , thisContext selector , ' not run' ].
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

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_windowTitle [
	"we lost the connection information in the window title. 
	Test to catch if it happens again. "

	self assert:
		(jadeiteShell shellName , '*for*' , session stoneName , ' @*[*]'
			 match: jadeiteShell window title)
]

{ #category : 'support' }
JadeiteForPharoConsoleTestCase >> toolUsedForCommonTests [

	^ jadeiteShell
]
