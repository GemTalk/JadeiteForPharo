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
		  JadeiteConsoleSeaside.
		  JadeiteConsoleTableColumn } asOrderedCollection
]

{ #category : 'testing' }
JadeiteForPharoConsoleTestCase class >> runAsDataCurator [
	"If the test class is expected to pass while
	logged in with DataCurator, override this 
	method to return true. The test runner will
	run each test as both SystemUser and DataCurator."

	^ true
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

{ #category : 'support' }
JadeiteForPharoConsoleTestCase >> tearDown [ 

	super tearDown. 
	self class failureLog contents traceCr. 
]

{ #category : 'tests' }
JadeiteForPharoConsoleTestCase >> test_abortTransaction [
	"assumption RowanSample1 is always loaded in the test resource"

	| sampleProject |
	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'no projects unless rowan present' ].
	sampleProject := jadeiteShell projectListPresenter list collection
		                 detect: [ :projectService |
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
	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'no projects unless rowan present' ].
	jadeiteShell projectListPresenter selectIndex: 1.
	auditResults := self
		                waitForNewPresenter: JadeiteWorkspace
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
		                     waitForNewPresenter: JadeiteMethodListPresenter
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

	| projectsPresenter |
	projectsPresenter := self openBrowserOn: 'Object'.
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
JadeiteForPharoConsoleTestCase >> test_lastLoadProjectPath [

	| lastLoadPath |
	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'no projects unless rowan present' ].

	self
		testsJadeiteForPharoIssue: #issue417
		title:
		'WR: Fresh image, try to open load dialog from console, get pharo walkback'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/417'.

	lastLoadPath := JadePresenter lastLoadProjectPath.
	[
		JadePresenter lastLoadProjectPath:
			JadePresenter rowanProjectsHomeEnvVarString.
		self
			assert: (JadePresenter possiblySetLastLoadProjectPath: 'fnoodle')
			equals: JadePresenter rowanProjectsHomeEnvVarString.
		self
			assert: JadePresenter lastLoadProjectPath
			equals: JadePresenter rowanProjectsHomeEnvVarString.

		JadePresenter lastLoadProjectPath: nil.
		self
			assert: (JadePresenter possiblySetLastLoadProjectPath: 'fnoodle')
			equals: 'fnoodle'.
		self assert: JadePresenter lastLoadProjectPath equals: 'fnoodle' ]
		ensure: [ JadePresenter lastLoadProjectPath: lastLoadPath ]
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
		selectServiceNamed: 'Announcements'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'Announcements'.
	self deny: servicesProjectService isCurrent.
	self transcript setCurrentProject.
	self
		assert: servicesProjectService displayName
		equals: '*Announcements'.
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
		equals: 'Announcements'.
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
	self assert: PharoLightTheme isCurrent.
	PharoDarkTheme beCurrent.
	self assert: PharoDarkTheme isCurrent.
	PharoLightTheme beCurrent.
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
		selectServiceNamed: 'Announcements'
		in: self projectListPresenter.
	servicesProjectService := self projectListPresenter selectedItem.
	self
		assert: servicesProjectService displayName
		equals: 'Announcements'.
	self deny: servicesProjectService isCurrent.

	self console setCurrentProject.
	self
		assert: servicesProjectService displayName
		equals: '*Announcements'.
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
