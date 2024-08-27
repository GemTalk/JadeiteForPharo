Class {
	#name : 'JadeiteAbstractTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'session',
		'transcript',
		'projectsBrowser',
		'jadeiteShell',
		'user'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase class >> isAbstract [
	^self == JadeiteAbstractTestCase
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase class >> resources [
	^IdentitySet with: self testResourceClass
]

{ #category : 'accessing' }
JadeiteAbstractTestCase class >> testResourceClass [

	^JadeiteTestResource
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> abortTransaction [
	transcript abortTransaction
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> addPackageNamed: packageName [

	self projectsPresenter 
		basicAddPackageNamed: packageName
		symbolDictionary: 'UserGlobals'
		componentName: 'Core'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> anotherNumberMethodSource [
	^'anotherNumber

		^3'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> answerNoToDialogDuring: block [
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	block ensure: [TestMessageBox disableJadeiteTestMessageBox]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> answerYesToDialogDuring: block [
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	block ensure: [TestMessageBox disableJadeiteTestMessageBox]
]

{ #category : 'asserting' }
JadeiteAbstractTestCase >> assert: actualObject isKindOf: expectedType [
	(actualObject isKindOf: expectedType)
		ifFalse: 
			[self fail: ((WriteStream on: String new)
						nextPutAll: 'Expected a ';
						print: expectedType;
						nextPutAll: ' Actual: ';
						print: actualObject class;
						nextPutAll: '.';
						contents)]
]

{ #category : 'asserting' }
JadeiteAbstractTestCase >> assertIsNil: anArgument [

	self assert: anArgument value equals: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> assertMethodInList: selector [
	self assertMethodInList: selector presenter: self methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> assertMethodInList: selector presenter: methodListPresenter [
	self
		denyIsNil: (methodListPresenter list detect: [:projectService | projectService selector = selector]
				ifNone: [])
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> assertProjectInList: name [
	self denyIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = name]
				ifNone: [])
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> auditAll [
	self assert: (session
				executeString: '| auditResults | 
								auditResults := Rowan projectTools audit auditAll. 
								auditResults isEmpty')
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> categoryListPresenter [
	^self projectsPresenter categoryListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> classHierarchyPresenter [
	^self projectsPresenter classHierarchyPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> classListPresenter [
	^self projectsPresenter classListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> cleanupExistingWindows [
	JadeiteWorkspace allInstances do: [:ws | self cleanupTextPaneForClose: ws].	"otherwise the test will hang"
	JadeiteTranscript allInstances do: [:text | self cleanupTextPaneForClose: text].
	JadeiteBrowserPresenter allInstances do: 
			[:presenter |
			presenter methodSourcePresenter view isModified: false.
			presenter classDefinitionPresenter view isModified: false]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> cleanupTextPaneForClose: ws [
	^ws codePane documentPresenter view isModified
		ifTrue: 
			[ws codePane documentPresenter view isModified: false.
			ws codePane documentPresenter value: nil]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> clearBreakAt: anInteger [
	self projectsPresenter clearBreakPointAt: anInteger in: self projectsPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> cloneRowanSample1 [

	self testResourceClass current cloneRowanSample1
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> closeBrowser: theBrowser [
	| count maxTries |
	count := 0.
	maxTries := 10.
	theBrowser
		ifNotNil: 
			[theBrowser window close.
			[theBrowser window isOpen not and: [count > maxTries]] whileFalse: 
					[(Delay forMilliseconds: 10) wait.
					count := count + 1]].
	self assert: count > maxTries description: theBrowser printString , ' did not close quickly enough'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> closeExistingInspectors [
	"not so elegant way of making sure the test gets the right inspector. Close others first"

	JadeNavigationInspector allInstances do: 
			[:oldInspector |
			oldInspector view class = DeafObject
				ifTrue: [oldInspector become: String new]
				ifFalse: [oldInspector view close]].
	JadeInspector allInstances do: 
			[:oldInspector |
			oldInspector view class = DeafObject
				ifTrue: [oldInspector become: String new]
				ifFalse: [oldInspector view close]].
	JadeiteInspector allInstances do: 
			[:oldInspector |
			oldInspector view class = DeafObject
				ifTrue: [oldInspector become: String new]
				ifFalse: [oldInspector view close]]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> closeTranscriptAndLogout [
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"closing the transcript will logout the session. don't commit"
	[transcript view close] ensure: [TestMessageBox disableJadeiteTestMessageBox]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> commitTransaction [
	^transcript commitTransaction
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> createDebuggerTestMethod [

	| source |
	source := 'testMethod

	^10023614059'.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> createNewTestProjectNamed: projectName [

	| testService |
	testService := RowanTestService
		               command: #createNewTestProjectNamed:
		               withArgs: (Array with: projectName).
	self issueCommand: testService onCompletion: nil
]

{ #category : 'asserting' }
JadeiteAbstractTestCase >> denyIsNil: anArgument [

	self deny: anArgument value equals: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> denyMethodInList: selector [
	self denyMethodInList: selector presenter: self methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> denyMethodInList: selector presenter: methodListPresenter [
	self
		assertIsNil: (methodListPresenter list detect: [:projectService | projectService selector = selector]
				ifNone: [])
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> denyProjectInList: name [
	self assertIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = name]
				ifNone: [])
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> deselectProjects [

	self projectListPresenter selectionByIndex: 0
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> destroy: visualThing [
	visualThing ifNil:[^self]. 
	(Delay forMilliseconds: 200) wait.
	visualThing window close.
	(Delay forMilliseconds: 20) wait.
	
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> dictionaryPresenter [
	"dictionary list in projects browser"

	^self projectsPresenter dictionaryPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> disableBreakpoints [
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: false session: session
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> disableInteractionsWhile: block [

	^ self testResourceClass current disableInteractionsWhile: block
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> enableBreakpoints [
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: true session: session
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> ensureOneTab [
	projectsBrowser ifNil: [^self].
	[projectsBrowser cards size = 1] whileFalse: [projectsBrowser closeCard]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> ensureRowanSampleProjectsLoaded [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: (Array
				 with: self testResourceClass sampleProject1Name
				 with: self testResourceClass sampleProject9Name)).
	self issueCommand: browserService onCompletion: [
		JadeiteApplication
			commitTransactionInSession: session
			onCompletion: [
			self testResourceClass current createRowanSample1Project ] ]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> ensureRowanSampleProjectsLoadedFromDisk [

	self testResourceClass current unloadSampleProject1.
	self testResourceClass current unloadSampleProject9.
	session commit.
	self testResourceClass current
		ensureRowanSampleProjectsLoadedFromDisk
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> ensureTestIsSetUpAfterLogout [
	projectsBrowser := nil.
	GciSession current: nil.
	self loginWithRetry: (JadeiteLoginShell allInstances detect: [:shell | shell isOpen]).	"should only be one open"
	self resources do: 
			[:resource |
			resource current
				tearDown;
				setUp].
	self setUp
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> executeStringInOtherSession: string [
	| executionString |
	executionString := '(UserGlobals at: #otherSession) '.
	executionString := executionString , string.
	^session executeString: executionString
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> fail: aString [
	TestMessageBox disableJadeiteTestMessageBox.
	^super fail: aString
	
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> haltTestForHardToCatchErrors: reason [
	| proc |
	"Running test will not stop on assert. Need to do a hard halt to determine how a test can login as the wrong user"
	proc := Processor activeProcess.
	proc halt: proc topFrame sender cause: reason
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> interestingLoopMethodSource [
	^'interestingLoop

	| contents result |
	result := String new. 
	contents := { 23 . 55 . 45 . 999 }.
	contents select: [:n |
		| temp |
		temp := self test + n. 
		(temp / self anotherNumber) > 5
			ifTrue:[result add: ''found'']
			ifFalse: [result add: ''not found''].
		result add: '' - ''.
		n = 2.
	].
	^result'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> isSampleProject1Loaded [
	^(transcript projectListPresenter projectListPresenter list
		detect: [:projectService | projectService name = self sampleProject1Name]
		ifNone: []) notNil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> issueCommand: service onCompletion: completionBlock [

	RowanServiceUpdater current
		issueCommands: (Array with: service)
		session: session
		onCompletion: completionBlock
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> itemNamed: menuName in: menuBar [
	^menuBar items detect: [:item | '*' , menuName , '*' match: item text]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> jadeitePrefsFilePath [
	^SessionManager current imageBase , 'Jadeite.prefs'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> loadRowanSample1InProjectList [

	| sample1Path root selections |
	sample1Path := self rowanSample1Path.
	root := self rowanProjectsHome.
	self transcriptTab basicLoadV2Project: sample1Path projectsHome: root.
	self transcriptTab refresh.
	self
		selectServicesNamed: (Array with: self sampleProject1Name)
		in: self transcriptTab projectListPresenter.
	selections := self transcriptTab projectListPresenter selections.
	RowanBrowserService new
		reloadProjects: selections
		presenter: self transcriptTab
		onCompletion: nil.
	self transcriptTab refresh
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> loginOtherSession [
	 session
		executeString: 'UserGlobals at: #otherSession put: (GsExternalSession gemNRS: ''' , session gemNRS
				, ''' stoneNRS: ''' , session stoneName
				, ''' username: ''SystemUser'' password: ''swordfish'') login'.

]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> loginWithRetry: loginShell [
	| loginError maxTries count |
	loginError := true.
	maxTries := 25.
	count := 0.
	[loginError] whileTrue: 
			[
			[loginShell loginWithoutErrorHandling.
			session := GciSession current.
			loginError := false]
					on: Error
					do: 
						[:ex |
						count := count + 1.
						self assert: count < maxTries.
						(Delay forMilliseconds: 100) wait]]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> logoutOtherSession [
	^session executeString: '
				(UserGlobals at: #otherSession) ifNotNil: [:sess | sess logout]'
]

{ #category : 'support' }
JadeiteAbstractTestCase >> logoutThenLoginAs: theUser forceClose: aBoolean [

	self testResourceClass current
		logoutThenLoginAs: theUser
		forceClose: aBoolean.
	jadeiteShell := JadeiteConsole currentConsole "needed?"
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> methodListPresenter [
	^self projectsPresenter methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> methodSourceForTest [
	^'test
		^3'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> methodSourcePresenter [
	^self projectsPresenter methodSourcePresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> noBreakIn: aMenu [
	self
		assertIsNil: (aMenu items detect: 
					[:command |
					('*Break*' match: command text)
						and: [(command text = 'Browse Breakpoints') not and: [(command text = 'Clear Method Breakpoints') not]]]
				ifNone: [])
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> nonSystemSessionCount [
	^session
		executeString: '
(System currentSessions select:[:i |
	| username |
	username := ((System descriptionOfSession: i) at: 1) userId. 
	((username ~= ''GcUser'') and:[username ~=''SymbolUser''])]) size'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> openProjectBrowser [
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [JadeiteBrowser showOnSession: session]]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> openWindow: aBlock [
	"evaluate a block which is expected to return an object that responds to #view.
	Wait until the view affirms it is open before continuing"

	| presenter count |
	presenter := aBlock value.
	count := 0.
	[presenter view isOpen] whileFalse: 
			[(Delay forMilliseconds: 50) wait.
			count := count + 1.
			count > 10 ifTrue: [^presenter]].
	^presenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> packageListPresenter [
	^self projectsPresenter packageListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> primaryTestWindow [
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^projectsBrowser
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> projectListPresenter [
	^self projectsPresenter projectListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> projectsPresenter [
	^projectsBrowser tabs currentCard activePresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> queryCommand: commandSymbol inPresenter: presenter view: view [
	| commandQuery |
	commandQuery := CommandQuery new commandDescription: (CommandDescription new command: commandSymbol)
				source: view.
	presenter queryCommand: commandQuery.
	^commandQuery
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> reloadProjectNamed: projectName [

	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #reloadProject;
		commandArgs: nil.
	RowanServiceUpdater current
		issueCommand: projectService
		session: session
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> removePreferencesFile [
	| path prefsExist |
	path := self jadeitePrefsFilePath.
	prefsExist := File exists: path.
	prefsExist
		ifTrue: 
			[self savePrefsBackup.
			(File open: path) delete].
	self deny: (File exists: path).
	^prefsExist
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> restoreBackupPrefsFile: prefsExisted [
	| backupStream fileStream backupPath |
	prefsExisted
		ifFalse: 
			[(File open: SessionManager current imageBase , 'Jadeite.prefs')
				close;
				delete].
	backupPath := SessionManager current imageBase , 'Jadeite.prefs.testbkp'.
	(File exists: backupPath) ifFalse: [^self].
	backupStream := FileStream read: SessionManager current imageBase , 'Jadeite.prefs.testbkp'.
	fileStream := FileStream write: SessionManager current imageBase , 'Jadeite.prefs'.
	[fileStream nextPutAll: backupStream contents] ensure: 
			[backupStream close.
			(File open: backupPath) delete.
			fileStream close]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> routeCommand: command toWindow: windowLikeThing [
	"Private - see CommandDescription class comment for explanation of how it fits in the Dolphin MVP architecture.
	Route the command description through the command policy to see if it finds the right home"

	| commandDescription id |
	commandDescription := CommandDescription registry keys detect: [:key | key command = command].
	id := CommandDescription registry at: commandDescription.
	self routeCommandWithId: id inVisual: windowLikeThing
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> routeCommandWithId: id inVisual: windowLikeThing [
	"Private - see CommandDescription class comment for explanation of how it fits in the Dolphin MVP architecture.
	Route the command description through the command policy to see if it finds the right home"

	| commandDescription |
	commandDescription := CommandDescription withId: id ifAbsent: [].
	windowLikeThing commandPolicy route: commandDescription
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> rowanProjectsHome [
	^JadePresenter rowanProjectsHomeEnvVarString
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> rowanSample1Path [
	^JadePresenter rowanSample1Path
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> sampleClassName [
	^'RowanSample1'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> sampleProject1Name [

	^ self testResourceClass sampleProject1Name
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveClass: className superclass: superName instVars: instVars package: aString [
	self projectsPresenter classDefinitionPresenter
		value: superName, ' rwSubclass: ', className printString, '
	instVarNames: ' , instVars printString
				, '
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ', aString printString, '
	options: #()'.
	^self projectsPresenter editSaveClass
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveClass: className withInstVars: instVars package: aString [
	self saveClass: className superclass: 'Object' instVars: instVars package: aString
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveClassMethod: source in: className category: category [

	| classService |
	classService := RowanClassService named: className.
	classService meta: true.
	classService
		saveMethod: source
		category: category
		session: session
		onCompletion: nil.
	^ classService
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveInterestingLoopMethod [

	| source |
	source := self methodSourceForTest.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil.
	source := self anotherNumberMethodSource.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil.
	source := self interestingLoopMethodSource.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveIssue166Method [

	| source |
	source := 'issue166

	"RowanSample1 new issue166"

	[RowanSample1 new halt; foo] value.
	^self'.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveIssue169Method [

	| source |
	source := 'issue169

	"RowanSample1 new issue169"

	| image string|
	self halt. 
	image := Rowan image.
	string := String new. 
	Transcript cr. 
	^self'.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveIssue216Method [

	| source |
	source := 'issue216

	"RowanSample1 new issue216"

	self halt. 
	RowanClassService new classFromName.
	^self'.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveMethod: source in: className [
	^self
		saveMethod: source
		in: className
		category: 'dontCare'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveMethod: source in: className category: category [
	^self saveMethod: source in: className category: category meta: false
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveMethod: source in: className category: category meta: meta [

	| classService |
	classService := RowanClassService named: className.
	classService meta: meta.
	classService
		saveMethod: source
		category: category
		session: session
		onCompletion: [].
	^ classService
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> savePrefsBackup [
	| backupStream fileStream |
	backupStream := FileStream write: SessionManager current imageBase , 'Jadeite.prefs.testbkp'.
	fileStream := FileStream read: SessionManager current imageBase , 'Jadeite.prefs'.
	[backupStream nextPutAll: fileStream contents] ensure: 
			[backupStream close.
			fileStream close]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveSampleMethod [

	| source |
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter
		editSaveMethod: self classListPresenter selection
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> saveTestClassWithInstVars: instVars package: aString [
	self
		saveClass: 'TestClass'
		withInstVars: instVars
		package: aString
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectCategoriesNamed: categories [

	self categoryListPresenter selections: Array new.
	categories do: [ :category |
		| categoryString |
		categoryString := self projectsPresenter categoryNames
			                  detect: [ :listCategory |
			                  categories includes: listCategory ]
			                  ifNone: [
			                  self error:
				                  'Category ''' , category , ''' not found' ].
		self categoryListPresenter selections:
			(self categoryListPresenter selections asOrderedCollection
				 add: categoryString;
				 yourself) ]
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectCategoryNamed: category [
	self selectCategoriesNamed: (Array with: category)
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectClassInHierarchyNamed: className [
	self selectTreeServicesNamed: (Array with: className) in: self classHierarchyPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectClassListTab [
	self projectsPresenter selectClassListTab.
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectClassRadioButtonIn: presenter [
	presenter setClassSide
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectClassSide [
	self selectClassRadioButtonIn: self projectsPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectClassTab [
	self selectClassRadioButtonIn: self projectsPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectClassTabIn: presenter [
	presenter selectClassListTab 
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectHierarchyTab [
	self selectHierarchyTabIn: self projectsPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectHierarchyTabIn: presenter [

	self todo: [ "Not sure yet why but selecting class does not seem to finish dependencies without higher priority"
		 ].
	[ presenter selectClassHierarchyTab ] forkAt:
		Processor activePriority + 1.
	(Delay forSeconds: 0.25) wait
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectInstanceRadioButtonIn: presenter [
	presenter setInstanceSide
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectInstanceSide [
	self selectInstanceRadioButtonIn: self projectsPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectMethodNamed: selector [
	^self selectMethodsNamed: (Array with: selector)
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectMethodNamedInProjectBrowser: selector [
	| methodServices |
	self projectsPresenter methodListPresenter resetSelection.
	methodServices := self projectsPresenter  methodListPresenter list detect: [:svc | svc selector = selector].
	self projectsPresenter  methodListPresenter selections: (Array with: methodServices).
	^methodServices
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectMethodsNamed: selectors [
	| methodServices |
	self methodListPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | self methodListPresenter list detect: [:svc | svc selector = selector]].
	self methodListPresenter selections: methodServices.
	^methodServices
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectMethodsNamed: selectors in: presenter [
	| methodServices |
	presenter resetSelection.
	methodServices := selectors
				collect: [:selector | presenter list detect: [:svc | svc selector = selector]].
	presenter selections: methodServices.
	^methodServices
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectNoneProject [
	self selectServiceNamed: RowanProjectService noneProject name in: self projectListPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectRowanSample1Class [
	"big assumption - RowanSample1 class will allways be in RowanSample1 project"

	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self selectServiceNamed: self sampleClassName in: self classListPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectRowanSample1Test [
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectRowanServicesPackage [
	self selectServiceNamed: 'RowanClientServices' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectRowanServicesTestsPackage [
	self selectServiceNamed: 'RowanClientServices' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectServiceNamed: aString in: presenter [
	self selectServicesNamed: (Array with: aString) in: presenter
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectServicesNamed: anArray in: presenter [

	presenter resetSelection.
	anArray isEmpty ifTrue: [ ^ self ].
	anArray do: [ :name |
		| service |
		service := presenter list
			           detect: [ :svc | svc name = name ]
			           ifNone: [
			           self error: 'List element ' , name , ' not found' ].
		presenter selectItems: (presenter selections asOrderedCollection
				 add: service;
				 yourself)]
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectTreeServicesNamed: anArray in: presenter [
	| bag |
	bag := presenter model asBag.
	presenter resetSelection.
	anArray do: 
			[:name |
			| service |
			service := bag detect: [:svc | svc name = name]
						ifNone: [self error: 'Tree element ' , name , ' not found'].
			presenter selections: (presenter selections asOrderedCollection
						add: service;
						yourself)]
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectVariableNamed: aSymbol [
	| variable |
	variable := self projectsPresenter variableListPresenter list detect: [:var | aSymbol = var]
				ifNone: [].
	self projectsPresenter variableListPresenter
		selectionByIndex: (self projectsPresenter variableListPresenter list indexOf: variable).
	self assert: self projectsPresenter variableListPresenter selection equals: aSymbol
]

{ #category : 'selection' }
JadeiteAbstractTestCase >> selectWithChangeEventMethodNamed: selector [
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event index methodService |
	methodService := self methodListPresenter list detect: [:service | service selector = selector].
	index := self methodListPresenter list indexOf: methodService.
	event := (SelectionChangingEvent forSource: self)
				oldSelections: self methodListPresenter selections;
				newSelections: (Array with: (self methodListPresenter list at: index));
				cause: #test;
				yourself.
	self methodListPresenter onSelectionChanging: event.
	event value ifFalse: [^self].
	self methodListPresenter selection: (self methodListPresenter list at: index)
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> serviceNamed: name in: presenter [
	| service |
	service := presenter list detect: [:service | service name = name] ifNone: [].
	^service
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> setBreakAt: anInteger [
	self projectsPresenter setBreakPointAt: anInteger in: self projectsPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> setRemoteAutoCommit: aBoolean onCompletion: completionBlock [

	| autoCommitService |
	autoCommitService := RowanAutoCommitService new
		                     command: #autoCommit:;
		                     commandArgs: (Array with: aBoolean).
	self issueCommand: autoCommitService onCompletion: completionBlock
]

{ #category : 'support' }
JadeiteAbstractTestCase >> setUp [

	super setUp.
	user ifNil: [ user := 'SystemUser' ].
	self logoutThenLoginAs: user forceClose: true.
	session := self testResourceClass current session.
	transcript := self testResourceClass current transcript.
	self setRemoteAutoCommit: false onCompletion: [
		self ensureRowanSampleProjectsLoaded.
		JadeiteLoginShell allInstances size > 1 ifTrue: [
			RsrGarbageCollector maximumReclamation ] ]
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> setupProjectBrowser [

	projectsBrowser := self testResourceClass current openProjectsBrowser.
	self ensureOneTab.
	self selectClassListTab.
	self selectInstanceSide.
	self projectsPresenter selectCategoryTab.
	self projectListPresenter resetSelection
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> setupSupclassComparisonMethods [
	self selectRowanSample1Class.
	self
		saveClass: 'RowanSubClass'
		superclass: 'RowanSample1'
		instVars: #()
		package: 'RowanSample1-Core'.
	self
		saveMethod: 'comparisonMethod  ^self subclassResponsibility'
		in: 'RowanSample1'
		category: 'test support'.
	self selectServiceNamed: 'RowanSubClass' in: self classListPresenter.
	self
		saveMethod: 'comparisonMethod  ^3 + 4'
		in: 'RowanSubClass'
		category: 'test support'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> stopOtherSessions [
	session
		executeString: '	

	| sessionsToStop |
sessionsToStop :=  System currentSessions select:[:i |
	| username |
	username := ((System descriptionOfSession: i) at: 1) userId. 
	((username ~= ''GcUser'') and:[(username ~=''SymbolUser'' and:[System session ~= i])])].
sessionsToStop do:[:i | System stopSession: i]'
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> switchTransactionModeTo: aSymbol [

	self todo: [
		self testResourceClass current switchTransactionModeTo: aSymbol ]
]

{ #category : 'support' }
JadeiteAbstractTestCase >> tearDown [

	super tearDown.
	projectsBrowser ifNotNil: [
		self projectsPresenter methodSourcePresenter adapter ifNotNil: [ :a |
			a widget hasUnacceptedEdits: false ] ].
	self destroy: projectsBrowser
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> testResourceClass [
	^ self class testResourceClass
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> testsIssue: aSymbol withTitle: anObject [
	"send this to help identify which tests test which issues"

	" a helpful parameter format is #issue<issueNumber>"

	"Issues currently reside in: 
		https://github.com/GemTalk/Jadeite/issues"

	
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> testsJadeiteForPharoIssue: aSymbol title: anObject [
	"send this to help identify which tests test which issues"

	" a helpful parameter format is #issue<issueNumber>"

	"Issues currently reside in: 
		https://github.com/GemTalk/Jadeite/issues"

	
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> testsRowanIssue: aSymbol withTitle: anObject [
	"send this to help identify which tests test which Rowan project issues"

	" a helpful parameter format is #issue<issueNumber>"

	"Issues currently reside in: 
		https://github.com/GemTalk/Rowan/issues"

	
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> transcript [
	^transcript
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> transcriptForCurrentSession [
	^JadeiteTranscript allInstances detect: [:tran | tran gciSession == GciSession current] ifNone: []
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> transcriptProjectList [
	^self transcriptTab projectListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> transcriptProjectNamed: string [
	^self transcriptProjectList list detect: [:projectService | projectService name = string] ifNone: []
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> transcriptTab [
	^transcript projectListPresenter 
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> unloadSampleProject1 [

	self testResourceClass current unloadSampleProject1
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> updateService: service [

	service command: #update.
	^ self issueCommand: service onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> variableListPresenter [
	^self projectsPresenter variableListPresenter.
]

{ #category : 'as yet unclassified' }
JadeiteAbstractTestCase >> verifyWindowClosed: presenter [
	| count maxTries |
	maxTries := 100.
	count := 0.
	[count < maxTries] whileTrue: 
			[presenter isOpen ifTrue: [count := count + 1] ifFalse: [^true].
			(Delay forMilliseconds: 10) wait].
	self deny: presenter isOpen
]
