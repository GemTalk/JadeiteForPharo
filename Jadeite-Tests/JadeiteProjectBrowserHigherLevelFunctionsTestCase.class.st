Class {
	#name : 'JadeiteProjectBrowserHigherLevelFunctionsTestCase',
	#superclass : 'JadeiteProjectBrowserAbstractTestCase',
	#instVars : [
		'loadProjectDialog'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> selectLoadDirectoryNamed: aString [
	| presenter selection |
	presenter := (loadProjectDialog view viewNamed: 'Tabs') currentCard name = 'Project Spec Container'
				ifTrue: [loadProjectDialog fileSelectorPresenter]
				ifFalse: [loadProjectDialog projectHomePresenter].
	selection := presenter directoryContentsList list detect: [:assoc | assoc key = aString].
	presenter directoryContentsList selection: selection
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> selectLoadProjectDialogFirstDirectory [
	| presenter |
	presenter := (loadProjectDialog view viewNamed: 'Tabs') currentCard name = 'Project Spec Container'
				ifTrue: [loadProjectDialog fileSelectorPresenter]
				ifFalse: [loadProjectDialog projectHomePresenter].
	presenter directoryContentsList list do: 
			[:directoryOrFile |
			(directoryOrFile key ~= '.' and: [directoryOrFile value ~= '..'])
				ifTrue: 
					[directoryOrFile value
						ifTrue: 
							[presenter directoryContentsList selection: directoryOrFile.
							^self]]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> tearDown [
	super tearDown.
	loadProjectDialog ifNotNil: [self destroy: loadProjectDialog]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_addSystemTab [
	self deselectProjects.
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'. 
	self selectMethodNamed: #foo.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #foo.
	self projectsPresenter addSystemBrowser.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #foo.
	projectsBrowser closeCard.
	"make sure previous card selections didn't change"
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #foo
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_addSystemTabBrowserPosition [
	"browser should not move to default position when tab is opened" 
	| newPosition |
	self testsIssue: #issue735
		withTitle: 'In multi-monitor setupt, inconsistent locations for opening windows (3.0.93-7)'.
	self assert: projectsBrowser view position
		equals: transcript view position + JadePresenter defaultWindowOffset.
	newPosition := projectsBrowser view position + (100 @ 100).
	projectsBrowser view position: newPosition.
	self deny: projectsBrowser view position
		equals: transcript view position + JadePresenter defaultWindowOffset.
	self assert: projectsBrowser view position equals: newPosition.
	self projectsPresenter addSystemBrowser.
	self assert: projectsBrowser view position equals: newPosition.
	projectsBrowser closeCard.
	self assert: projectsBrowser view position equals: newPosition
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_addSystemTabClassSelection [
	self deselectProjects.
	self selectRowanSample1Class.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self deny: self classListPresenter selection meta.
	self projectsPresenter addSystemBrowser.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self deny: self classListPresenter selection meta.
	projectsBrowser closeCard.
	"make sure previous card selections didn't change"
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self deny: self classListPresenter selection meta
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_addSystemTabClassSelectionClassSide [
	self deselectProjects.
	self selectRowanSample1Class.
	self selectClassTab.
	self selectCategoriesNamed: (Array with: '*rowansample1-extensions').
	self selectMethodNamed: #bar.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter selection meta.
	self assert: self categoryListPresenter selection equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter selection selector equals: #bar.
	self projectsPresenter addSystemBrowser.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter selection meta.
	self assert: self categoryListPresenter selection equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter selection selector equals: #bar.
	projectsBrowser closeCard.

	"make sure previous card selections didn't change"
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter selection meta.
	self assert: self categoryListPresenter selection equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter selection selector equals: #bar
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_addSystemTabNoSelections [
	self deselectProjects.
	self assertIsNil: (self projectListPresenter selectionIfNone:[]).
	self assertIsNil: (self packageListPresenter selectionIfNone:[]).
	self assertIsNil: (self classListPresenter selectionIfNone:[]).
	self assertIsNil: (self categoryListPresenter selectionIfNone:[]).
	self assertIsNil: (self methodListPresenter selectionIfNone:[]).
	self projectsPresenter addSystemBrowser.
	self assertIsNil: (self projectListPresenter selectionIfNone:[]).
	self assertIsNil: (self packageListPresenter selectionIfNone:[]).
	self assertIsNil: (self classListPresenter selectionIfNone:[]).
	self assertIsNil: (self categoryListPresenter selectionIfNone:[]).
	self assertIsNil: (self methodListPresenter selectionIfNone:[]).
	projectsBrowser closeCard.
	"make sure previous card selections didn't change"
	self assertIsNil: (self projectListPresenter selectionIfNone:[]).
	self assertIsNil: (self packageListPresenter selectionIfNone:[]).
	self assertIsNil: (self classListPresenter selectionIfNone:[]).
	self assertIsNil: (self categoryListPresenter selectionIfNone:[]).
	self assertIsNil: (self methodListPresenter selectionIfNone:[]).
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_browseInExistingBrowser [

	self
		testsIssue: #issue827
		withTitle:
		'Would be nice to be able to request that all browse menu items be routed to an existing project browser'.
	projectsBrowser := nil.
	self testResourceClass current projectsBrowser: nil.
	JadeiteBrowser allInstances do: [ :browser | self destroy: browser ].
	self setupProjectBrowser.
	self assert: projectsBrowser cardsPresenter subPresenters size = 1.
	self selectRowanSample1Test.
	self selectMethodNamed: #testError.
	self assert:
		self projectsPresenter classListPresenter selection name
		= 'RowanSample1Test'.
	self assert:
		self projectsPresenter methodListPresenter selection selector
		= #testError.
	methodListBrowser := self projectsPresenter browseImplementors.
	self assert: methodListBrowser view isForeground.
	methodListBrowser primaryPresenter methodListPresenter
		methodListPresenter selectionByIndex: 3.
	self assert: methodListBrowser primaryPresenter methodListPresenter
			methodListPresenter selection className = 'SUnitTest'.
	methodListBrowser primaryPresenter methodListPresenter
		browseInExistingBrowser.
	self assert: projectsBrowser cardsPresenter subPresenters size = 2.
	self assert:
		self projectsPresenter classListPresenter selection name
		= 'SUnitTest'.
	self assert:
		self projectsPresenter methodListPresenter selection selector
		= #testError.
	self assert: projectsBrowser view isForeground.
	projectsBrowser cardsPresenter view cardLayout firstCard.
	self assert:
		self projectsPresenter classListPresenter selection name
		= 'RowanSample1Test'.
	self assert:
		self projectsPresenter methodListPresenter selection selector
		= #testError.
	self destroy: projectsBrowser. "Because we've added tabs, we want to start the next test with a fresh project browser"
	projectsBrowser := nil
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_browserPosition [
	self testsIssue: #issue735
		withTitle: 'In multi-monitor setupt, inconsistent locations for opening windows (3.0.93-7)'.
	projectsBrowser
		ifNotNil: 
			[self destroy: projectsBrowser.
			projectsBrowser := nil].
	self openProjectBrowser.
	self assert: projectsBrowser view position
		equals: transcript view position + JadePresenter defaultWindowOffset
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_createProject [
	"sanity test - do we open the right browser?"

	| createProjectsBrowser |
	createProjectsBrowser := self projectsPresenter createNewProject.
	[self assert: createProjectsBrowser isKindOf: JadeiteCreateProjectEditor]
		ensure: [self destroy: createProjectsBrowser]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_loadProjectDialogDiveIntoDoublePeriod [
	"should effectively be a pop"

	| path parentDirectory |
	JadeiteLoadProjectDialog previousProjectHomePath: nil.	"will reset to $ROWAN_PROJECTS_HOME"
	JadeiteLoadProjectDialog previousFilePath: nil.
	loadProjectDialog := JadeiteLoadProjectDialog showNonModalOnSession: session.
	path := loadProjectDialog pathText value.
	self selectLoadDirectoryNamed: '..'.
	loadProjectDialog fileSelectorPresenter dive.
	parentDirectory := session executeString: '(Path from: ''' , path , ''') parent pathString'.
	self assert: loadProjectDialog pathText value equals: parentDirectory
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_loadProjectDialogDiveIntoPeriod [
	| path |
	loadProjectDialog := JadeiteLoadProjectDialog showNonModalOnSession: session.
	path := loadProjectDialog pathText value.
	self selectLoadDirectoryNamed: '.'.
	loadProjectDialog fileSelectorPresenter dive.
	self assert: loadProjectDialog pathText value equals: path	"no change"
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_loadProjectDialogDiveNotRetainedOnCancel [
	JadeiteLoadProjectDialog previousProjectHomePath: nil.
	JadeiteLoadProjectDialog previousFilePath: nil.
	loadProjectDialog := JadeiteLoadProjectDialog showNonModalOnSession: session.
	self assert: JadeiteLoadProjectDialog previousProjectHomePath
		equals: JadePresenter expandedRowanProjectsHome.
	self assert: JadeiteLoadProjectDialog previousFilePath
		equals: JadePresenter expandedRowanProjectsHome.
	self selectLoadProjectDialogFirstDirectory.
	loadProjectDialog fileSelectorPresenter dive.
	loadProjectDialog cancel.
	self assert: JadeiteLoadProjectDialog previousProjectHomePath
		equals: JadePresenter expandedRowanProjectsHome.	"no change"
	self assert: JadeiteLoadProjectDialog previousFilePath
		equals: JadePresenter expandedRowanProjectsHome	"no change"
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_loadProjectDialogExpandEnvVariable [
	"$ROWAN_PROJECTS_HOME should be expanded when dialog is opened. "

	JadeiteLoadProjectDialog previousProjectHomePath: nil.	"reset the saved paths - should expand $ROWAN_PROJECTS_HOME on instantiation."
	JadeiteLoadProjectDialog previousFilePath: nil.
	loadProjectDialog := JadeiteLoadProjectDialog showNonModalOnSession: session.
	(loadProjectDialog view viewNamed: 'Tabs') nextCard.	"switch to Projects Home tab"
	self assert: loadProjectDialog projectHomePresenter pathText value
		equals: JadePresenter expandedRowanProjectsHome.
	self assert: JadeiteLoadProjectDialog previousProjectHomePath
		equals: JadePresenter expandedRowanProjectsHome.
	self assert: JadeiteLoadProjectDialog previousFilePath
		equals: JadePresenter expandedRowanProjectsHome
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_loadProjectDialogTabOrder [
	"ensure tab order doesn't get messed up if gui changes - Dolphin likes to reorder tabs without explanation in the gui editor"

	loadProjectDialog := JadeiteLoadProjectDialog showNonModalOnSession: session.
	self assert: (loadProjectDialog isKindOf: JadeiteLoadProjectDialog).
	self assert: loadProjectDialog isProjectSpecTabSelected.
	(loadProjectDialog view viewNamed: 'Tabs') nextCard.
	self assert: loadProjectDialog isProjectHomeTabSelected.
	(loadProjectDialog view viewNamed: 'Tabs') nextCard.
	self assert: loadProjectDialog isURLTabSelected.
	(loadProjectDialog view viewNamed: 'Tabs') nextCard.
	self assert: loadProjectDialog isAdvancedTabSelected
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_loadProjectFromURL [

	| projectNames answer loadedProjectName |
	self
		testsIssue: #issue939
		withTitle:
		'(3.2.10) need to be able to specify an http url in ''Load project spec'' dialog ...'.
	projectNames := self projectListPresenter list collect: [
		                :projectService | projectService name ].
	self deny: (projectNames includes: 'RowanSample9V3').
	loadProjectDialog := JadeiteLoadProjectDialog showNonModalOnSession:
		                     session.
	(loadProjectDialog view viewNamed: 'Tabs') nextCard.
	(loadProjectDialog view viewNamed: 'Tabs') nextCard.
	self assert: loadProjectDialog isURLTabSelected.
	loadProjectDialog urlText value:
		'https://raw.githubusercontent.com/dalehenrich/RowanSample9V3/spec_0061/rowan/specs/spec_0061.ston'.
	"simulate load for testing"
	loadProjectDialog lastSelectedTabName: loadProjectDialog selectedTab.
	answer := loadProjectDialog
		          apply;
		          answer.
	self assert: answer first = 'URL Container'.
	loadedProjectName := 'RowanSample9V3'.
	self projectsPresenter installProjectFromURL: answer last.
	self projectsPresenter selectProjectNamed: loadedProjectName.

	[
	projectNames := self projectListPresenter list collect: [
		                :projectService | projectService name ].
	self assert: (projectNames includes: loadedProjectName) ] ensure: [
		self projectsPresenter
			basicUnloadProjects: (Array with: loadedProjectName)
			onCompletion: nil ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_modifiedSystemTab [
	| cardLabel |
	self testsIssue: #issue584 withTitle: 'Would like changed method indicator on tab'.
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'.
	self selectMethodNamed: #foo.
	cardLabel := projectsBrowser cardsPresenter view currentCard arrangement.
	self assert: cardLabel text equals: '1 RowanSample1'.
	self methodSourcePresenter value: 'foo ^''foot'''.
	self methodSourcePresenter view isModified: true.
	self methodSourcePresenter trigger: #valueChanged.
	cardLabel := projectsBrowser cardsPresenter view currentCard arrangement.
	self assert: (cardLabel isKindOf: CardLabel).
	self assert: cardLabel iconBlock value isKindOf: Icon.
	self assert: cardLabel iconBlock value identifier equals: 'Changed.ico'.	" showing changed icon "
	self
		saveMethod: 'foo ^''foot'''
		in: 'RowanSample1'
		category: 'accessing'.
	self methodSourcePresenter view isModified: false.
	self methodSourcePresenter trigger: #valueChanged.
	cardLabel := projectsBrowser cardsPresenter view currentCard arrangement.
	self assert: cardLabel text equals: '1 RowanSample1'
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_moveTabsWithSUnitTabselected [
	self testsIssue: #issue556 withTitle: 'Funny orange boxes enabled for Sunit tab, but error'.
	projectsBrowser closeCard.
	projectsBrowser addSystemBrowser.
	self selectSUnitTab.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	projectsBrowser addSystemBrowser.
	self assert: projectsBrowser cardsPresenter view cards size equals: 2.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '2 Projects'.
	self selectRowanSample1Class.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '2 RowanSample1'.
	projectsBrowser moveCardLeft.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '2 RowanSample1'.
	self assert: projectsBrowser cardsPresenter view cards size equals: 2.
	projectsBrowser moveCardRight.
	self assert: projectsBrowser cardsPresenter view cards size equals: 2.
	projectsBrowser closeCard.
	self assert: projectsBrowser cardsPresenter view cards size equals: 1.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_projectDisplaysSync [
	"the projects browser and project list in the transcript should
	stay sync'ed automaticall"

	"project removal in projects browser"

	self disableInteractionsWhile: [
		self denyIsNil: (self projectNamed: 'RowanSample1').
		self
			assert: self transcriptTab
			isKindOf: JadeiteProjectListPresenter.
		self denyIsNil: (self transcriptProjectNamed: 'RowanSample1').
		self unloadSampleProject1.
		self assertIsNil: (self projectNamed: 'RowanSample1').
		self assertIsNil: (self transcriptProjectNamed: 'RowanSample1').
		"project addition in projects browser"
		self cloneRowanSample1.
		self ensureRowanSampleProjectsLoaded.

		[
		self denyIsNil: (self transcriptProjectNamed: 'RowanSample1').
		self denyIsNil: (self projectNamed: 'RowanSample1') ] ensure: [
			self unloadSampleProject1 ].
		self assertIsNil: (self projectNamed: 'RowanSample1').
		self assertIsNil: (self transcriptProjectNamed: 'RowanSample1').
		"project addition in project list"
		self loadRowanSample1InProjectList.
		self denyIsNil: (self transcriptProjectNamed: 'RowanSample1').
		self denyIsNil: (self projectNamed: 'RowanSample1').
		"project removal in project list"
		(self transcriptTab projectListPresenter list
			 detect: [ :projectService |
			 projectService name = self sampleProject1Name ]
			 ifNone: [  ]) notNil ifTrue: [
			self transcriptTab
				basicUnloadProjects: (Array with: self sampleProject1Name)
				onCompletion: nil ].

		[
		self assertIsNil: (self projectNamed: 'RowanSample1').
		self assertIsNil: (self transcriptProjectNamed: 'RowanSample1') ]
			ensure: [ self loadRowanSample1InProjectList ] ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_projectListToolTip [

	self rowanFixMe. "when issue & title made, insert"
	self testsIssue: #issue withTitle: ''.
	self projectListPresenter list do: [ :projectService |
		RowanServiceUpdater current
			updateService: projectService
			session: session
			onCompletion: nil.
		projectService isDirty ifTrue: [
			self assert: ('*Dirty in image*' match: projectService toolTip) ].
		projectService isDiskDirty ifTrue: [
			self assert: ('*Dirty on disk*' match: projectService toolTip) ].
		projectService isSkew ifTrue: [
			self assert: ('*Skew in sha*' match: projectService toolTip) ].
		projectService displayName = RowanService notRowanizedPackageName
			ifTrue: [
				self
					assert: projectService toolTip
					equals: 'Does not exist on disk' ].
		projectService existsOnDisk
			ifTrue: [
				projectService isDirty not & projectService isDiskDirty not
				& projectService isSkew not
				& (projectService existsOnDisk == false) not ifTrue: [
					self assert: projectService toolTip = 'Disk/image consistent' ] ]
			ifFalse: [
				self assert:
					('*Does not exist on disk*' match: projectService toolTip) ] ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_projectMenuEnablementUnloadReload [
	self testsIssue: #issue836 withTitle: 'Can''t reload (UnPackaged) project'.
	#(#unloadProjects #reloadProject) do: 
			[:command |
			| projectNames |
			self deselectProjects.
			self deny: (self projectsPresenter isProjectItemEnabled: command).
			projectNames := self projectListPresenter list collect: [:projectService | projectService name].
			projectNames do: 
					[:projectName | 
					self selectServiceNamed: projectName in: self projectListPresenter.
					(projectName = 'UnPackaged' or: [projectName = RowanService notRowanizedPackageName])
						ifTrue: [self deny: (self projectsPresenter isProjectItemEnabled: command)]
						ifFalse: [self assert: (self projectsPresenter isProjectItemEnabled: command)]]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_projectMenuGitCommitMenuItem [
	| gitCommitMenuItem query |
	self testsIssue: #issue317 withTitle: 'Commit when no changes results in walkback'.
	gitCommitMenuItem := self projectListPresenter view queryContextMenu items
				detect: [:menu | '*Commit to Git*' match: menu text]
				ifNone: [].
	self denyIsNil: gitCommitMenuItem.
	self assert: gitCommitMenuItem command equals: #gitCommit.
	self assert: (self projectsPresenter class canUnderstand: #gitCommit).
	query := CommandQuery commandDescription: gitCommitMenuItem source: self projectListPresenter view.
	self projectListPresenter list do: 
			[:projectService |
			self projectListPresenter selection: projectService.
			self projectsPresenter queryCommand: query.
			projectService isDirty ifTrue: [self assert: query isEnabled] ifFalse: [self deny: query isEnabled]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_queryCommandHandlesNilSession [
	| flipAutoCommitItem query previousAutoCommit |
	self testsIssue: #issue773
		withTitle: 'Answer no to "Unsaved Changes" on logout does not work as planned (3.1pr4)'.
	flipAutoCommitItem := MenuItem fromString: ' Fake Command//flipAutoCommit'.
	query := CommandQuery commandDescription: flipAutoCommitItem commandDescription source: nil.
	previousAutoCommit := session autoCommit.
	session autoCommit: true.
	
	[JadePresenterA new queryCommand: query.
	self assert: query isChecked.
	session := GciSession current.
	GciSession current: nil.
	
	[JadePresenterA new queryCommand: query.
	self deny: query isChecked]
			ensure: [GciSession current: session]]
			ensure: [session autoCommit: previousAutoCommit]
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_systemTabNamesDictionaryClass [
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectNoneProject.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 (NONE)'.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 UserGlobals'.
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 JadeServer'
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_systemTabNamesDictionaryClassHierarchy [
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectNoneProject.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 (NONE)'.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 UserGlobals'.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'JadeServer'.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 JadeServer'
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_systemTabNamesMultiplePackagesAndClassSelected [
	self testsIssue: #issue623
		withTitle: '(3.0.85) when multiple packages selected the browser tab not updated with class name'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter. 
	self selectServicesNamed: #('RowanSample1-Core' 'RowanSample1-Tests') in: self packageListPresenter. 
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 RowanSample1'.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter. 
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 RowanSample1Test'.	
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_systemTabNamesProjectClassHierarchy [
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1-Core'.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'RowanSample1'.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'
]

{ #category : 'as yet unclassified' }
JadeiteProjectBrowserHigherLevelFunctionsTestCase >> test_systemTabNamesProjectClassList [
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1-Core'.
	self selectServiceNamed: 'RowanSample1' in: self classListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'
]
