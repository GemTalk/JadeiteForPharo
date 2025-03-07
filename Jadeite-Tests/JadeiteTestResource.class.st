Class {
	#name : 'JadeiteTestResource',
	#superclass : 'TestResource',
	#instVars : [
		'projectsBrowser',
		'jadeiteShell',
		'progressBarState'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteTestResource class >> current [

	current ifNil: [ "opening the settings browser initializes the JadeitePreferences
		which is needed in JadeiteHeadlessTestResource"
		| window |
		window := SettingBrowser open.
		window close.
		current := self new.
		current progressBarState: JadeitePreferences showProgressBar. 
		JadeitePreferences showProgressBar: false.
		current session ifNil: [ ^ nil "notified earlier" ] ].
	current hasValidSession ifFalse: [ current := self new ].
	^ current
]

{ #category : 'as yet unclassified' }
JadeiteTestResource class >> isAvailable [
	^self current isAvailable
]

{ #category : 'as yet unclassified' }
JadeiteTestResource class >> sampleProject1Name [
	^'RowanSample1'
]

{ #category : 'as yet unclassified' }
JadeiteTestResource class >> sampleProject9Name [
	^'RowanSample9'
]

{ #category : 'as yet unclassified' }
JadeiteTestResource class >> signalInitializationError [
	"TestSuite>>run: in the SUnit pacakge sends this method
	to the class, but implements it on the instance. That appears
	to be a bug."

	self reset.
	^TestResult signalErrorWith: 'Resource ' , self name , ' could not be initialized'
]

{ #category : 'projects loading' }
JadeiteTestResource >> basicUnloadProjects: projectNames onCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService onCompletion: [
		self refreshGlobalSelections.
		completionBlock value ]
]

{ #category : 'support' }
JadeiteTestResource >> cloneRowanSample1 [

	| sample1Path root service |
	self disableInteractionsWhile: [
		sample1Path := self rowanSample1Path.
		root := self rowanProjectsHome.
		service := RowanProjectService new.
		service
			command: #newGitProject:root:useSsh:;
			commandArgs: (Array with: sample1Path with: root with: true).
		RowanServiceUpdater current
			issueCommand: service
			session: GciSession current
			onCompletion: [  ] ]
]

{ #category : 'support' }
JadeiteTestResource >> closeConnectionLaunchers [ 

	JadeiteConnectionLauncher allInstances do: [ :launcher |
		| profile |
		profile := launcher connectionProfile.
		profile isConnected ifTrue: [ profile disconnect ].
		self destroy: launcher ].
]

{ #category : 'support' }
JadeiteTestResource >> closeTranscript: aTranscript [
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"closing the transcript will logout the session. don't commit"
	[aTranscript view close] ensure: [TestMessageBox disableJadeiteTestMessageBox]
]

{ #category : 'support' }
JadeiteTestResource >> closeTranscripts [
	self transcript ifNotNil: [self closeTranscript: self transcript].
	JadeiteTranscript allInstances
		do: [:transcript | self closeTranscript: transcript	"hopeful none, but just in case"]
]

{ #category : 'support' }
JadeiteTestResource >> connectSignaling: sem [

	| profile |
	^ [
	  profile := JadeiteConnectionProfile connectionProfile.
	  profile isConnected ifTrue: [ profile disconnect ].
	  RowanTestServiceUpdater installTestUpdater.
	  profile connect ] ensure: [
		  | waitForConsoleSem |
		  waitForConsoleSem := Semaphore new.
		  [
		  [ JadeiteConsole currentConsole ] whileNil: [
			  (Delay forMilliseconds: 1) wait ].
		  waitForConsoleSem signal ] fork.
		  waitForConsoleSem waitTimeoutSeconds: 5.
		  sem signal ]
]

{ #category : 'projects creating' }
JadeiteTestResource >> createRowanSample1Project [
	"Don't get RowanSample1 project from disk.
	It's good not to rely on an external git project which can be 
	changed anytime (unless necessary for the test)"

	| testService |
	testService := RowanTestService new.
	testService command: #createRowanSample1Project.
	testService commandArgs: Array new.
	self
		issueCommand: testService
		onCompletion: []
]

{ #category : 'actions' }
JadeiteTestResource >> destroy: visualThing [
	visualThing ifNil:[^self]. 
	(Delay forMilliseconds: 200) wait.
	visualThing window close.
	(Delay forMilliseconds: 20) wait.
]

{ #category : 'support' }
JadeiteTestResource >> disableInteractionsWhile: block [
	"interactions like confirm: and notify: are enabled by 
	default on all service commands. Disable for the duration
	of this block"

	| answeringService wasEnabled |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #interactionHandlerActive;
		commandArgs: Array new.
	self issueCommand: answeringService onCompletion: [].
	wasEnabled := answeringService answer.
	answeringService
		command: #setEnableInteractionHandler:;
		commandArgs: (Array with: false).
	self issueCommand: answeringService onCompletion: [].
	[ block value ] ensure: [
		answeringService
			command: #setEnableInteractionHandler:;
			commandArgs: (Array with: wasEnabled).
		self issueCommand: answeringService onCompletion: [  ] ]
]

{ #category : 'projects loading' }
JadeiteTestResource >> ensureRowanSample1Loaded [

	self
		ensureSampleProjectLoaded: [ self unloadSampleProject1 ]
		path: self rowanSample1Path
]

{ #category : 'projects loading' }
JadeiteTestResource >> ensureRowanSample9Loaded [
	self todo:[self
		ensureSampleProjectLoaded: [ self unloadSampleProject9 ]
		path: self rowanSample9Path]
]

{ #category : 'projects loading' }
JadeiteTestResource >> ensureRowanSampleProjectsLoaded [

	self createRowanSample1Project
]

{ #category : 'projects loading' }
JadeiteTestResource >> ensureRowanSampleProjectsLoadedFromDisk [
	"make sure we have the correct server state in the browser"
	self ensureRowanSample1Loaded. 
	self ensureRowanSample9Loaded
]

{ #category : 'projects loading' }
JadeiteTestResource >> ensureSampleProjectLoaded: unloadBlock path: projectPath [

	self todo:[self switchTransactionModeTo: #autoBegin. "Initializing the resource will do a commit. Make sure we can commit."].
	self transcript projectListPresenter refresh. "make sure we have the correct server state in the browser"
	self rowanSample1Project ifNotNil: [ :projectService | 
		projectService isDirty ifFalse: [ ^ self ] ].
	self disableInteractionsWhile: [ 
		unloadBlock value.
		self
			loadProjectFromFile: projectPath
			projectsHome: '$ROWAN_PROJECTS_HOME'
			customConditionalAttributes: #( 'tests' )
			componentNames: #( 'Core' 'Tests' ) ]
]

{ #category : 'support' }
JadeiteTestResource >> forceReconnect [

	| sem |
	sem := Semaphore new.
	[ self connectSignaling: sem ] fork.
	(sem waitTimeoutSeconds: 5) ifTrue: [
		Error signal: 'connection failed to complete' ]
]

{ #category : 'accessing' }
JadeiteTestResource >> gciSession [

	^self session
]

{ #category : 'support' }
JadeiteTestResource >> hasValidSession [
	| session |
	session := GciSession current.
	session ifNil: [^false].
	^session isValidSession
]

{ #category : 'testing' }
JadeiteTestResource >> isAvailable [
	^self session notNil
]

{ #category : 'support' }
JadeiteTestResource >> issueCommand: service onCompletion: completionBlock [

	^ RowanServiceUpdater current
		  issueCommand: service
		  session: self session
		  onCompletion: completionBlock
]

{ #category : 'support' }
JadeiteTestResource >> jadeiteShell [
	^jadeiteShell
]

{ #category : 'support' }
JadeiteTestResource >> loadProjectFromFile: fileString projectsHome: projectsHomePath customConditionalAttributes: attributes componentNames: componentNames [

	| projectService |
	projectService := RowanProjectService new.
	projectService
		command:
			#loadProjectFromFile:projectsHome:customConditionalAttributes:componentNames:;
		commandArgs: (Array
				 with: fileString
				 with: projectsHomePath
				 with: attributes
				 with: componentNames).
	RowanServiceUpdater current
		issueCommand: projectService
		session: self session
		onCompletion: [ ]
]

{ #category : 'support' }
JadeiteTestResource >> loginAs: userName [
	jadeiteShell := JadeiteLoginShell show.
	jadeiteShell userIDPresenter value: userName.
	jadeiteShell loginWithoutErrorHandling
]

{ #category : 'support' }
JadeiteTestResource >> loginWithRetry: loginShell [
	| loginError |
	loginError := true.
	[loginError] whileTrue: 
			[
			[loginShell loginWithoutErrorHandling.
			loginError := false] on: Error
					do: [:ex | (Delay forMilliseconds: 100) wait]]
]

{ #category : 'support' }
JadeiteTestResource >> logout [
	"hopeful none, but just in case"
	self closeTranscripts.
	JadeiteLoginShell allInstances do: 
			[:shell |
			shell view close.
			(Delay forMilliseconds: 100) wait	"should save to the remote 'C:\Users\ewinger\AppData\Roaming\JadeDefaultConnection.gss' file"]
]

{ #category : 'support' }
JadeiteTestResource >> openProjectsBrowser [
	((projectsBrowser isKindOf: JadeiteBrowser) not or: [projectsBrowser window isOpen not])
		ifTrue: [projectsBrowser := self openWindow: [self transcript openBrowser]].
	^projectsBrowser
]

{ #category : 'support' }
JadeiteTestResource >> openWindow: aBlock [
	"evaluate a block which is expected to return an object that responds to #view.
	Wait until the view affirms it is open before continuing"

	| presenter count |
	presenter := aBlock value.
	count := 0.
	[presenter window isOpen] whileFalse: 
			[(Delay forMilliseconds: 50) wait.
			count := count + 1.
			count > 10 ifTrue: [^presenter]].
	^presenter
]

{ #category : 'accessing' }
JadeiteTestResource >> progressBarState [

	^ progressBarState
]

{ #category : 'accessing' }
JadeiteTestResource >> progressBarState: anObject [

	progressBarState := anObject
]

{ #category : 'support' }
JadeiteTestResource >> projectsBrowser: anObject [
	projectsBrowser := anObject
]

{ #category : 'support' }
JadeiteTestResource >> projectsPresenter [

	^ projectsBrowser tabs currentCard activePresenter
]

{ #category : 'updates' }
JadeiteTestResource >> refreshGlobalSelections [
	"refresh selections in all browsers."

	| browserService |
	browserService := RowanBrowserService new
		                  command: #findRemovedServices:;
		                  commandArgs:
			                  (Array with:
					                   RowanServiceUpdater current activeServices
						                   asSet asArray).
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: [
		self updateServices: RowanServiceUpdater current selectedServices ]
]

{ #category : 'support' }
JadeiteTestResource >> refreshProjectNamed: projectName [

	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #update;
		commandArgs: nil.
	RowanServiceUpdater current
		issueCommand: projectService
		session: self session
		onCompletion: nil
]

{ #category : 'support' }
JadeiteTestResource >> reloadProjectNamed: projectName [

	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #reloadProject;
		commandArgs: nil.
	RowanServiceUpdater current
		issueCommand: projectService
		session: self session
		onCompletion: nil
]

{ #category : 'projects' }
JadeiteTestResource >> rowanProjectsHome [
	^JadePresenter rowanProjectsHomeEnvVarString
]

{ #category : 'projects' }
JadeiteTestResource >> rowanSample1Path [
	^JadePresenter rowanSample1Path
]

{ #category : 'projects' }
JadeiteTestResource >> rowanSample1Project [

	^ self rowanSampleProjectNamed: self sampleProject1Name 
]

{ #category : 'projects' }
JadeiteTestResource >> rowanSample9Path [
	^JadePresenter rowanSample9Path
]

{ #category : 'projects' }
JadeiteTestResource >> rowanSample9Project [

	^ self rowanSampleProjectNamed: self sampleProject9Name
]

{ #category : 'projects' }
JadeiteTestResource >> rowanSampleProjectNamed: projectName [

	^ self transcript projectListPresenter list items
		  detect: [ :projectService | projectService name = projectName ]
		  ifNone: [  ]
]

{ #category : 'projects' }
JadeiteTestResource >> sampleProject1Name [
	^self class sampleProject1Name
]

{ #category : 'projects' }
JadeiteTestResource >> sampleProject9Name [
	^self class sampleProject9Name
]

{ #category : 'support' }
JadeiteTestResource >> session [

	^GciSession current
]

{ #category : 'support' }
JadeiteTestResource >> setUp [

	super setUp.
	GciSession current ifNil: [
		MessageBox notify: 'GciSession current is nil. Login again.'.
		Processor activeProcess terminate "There's not a good way to safely return without many subsequent errors. Just kill the test process." ].
	self unloadSampleProject1.
	self ensureRowanSampleProjectsLoaded
]

{ #category : 'support' }
JadeiteTestResource >> switchTransactionModeTo: aSymbol [
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.	"confirm transaction mode switch"
	[self transcript transactionMode: aSymbol] ensure: [TestMessageBox disableJadeiteTestMessageBox]
]

{ #category : 'support' }
JadeiteTestResource >> tearDown [

	super tearDown.
	JadeitePreferences showProgressBar: progressBarState.
	GciSession current isValidSession ifFalse: [ ^ self ].
	self transcript ifNotNil: [ :console |
		console
			basicUnloadProjects: (Array with: self sampleProject1Name)
			onCompletion: [  ] ]
]

{ #category : 'support' }
JadeiteTestResource >> transcript [
	^self transcriptForCurrentSession
]

{ #category : 'support' }
JadeiteTestResource >> transcriptForCurrentSession [
	| console |
	console := JadeiteConsole currentConsole.
	console
		ifNil: 
			["somehow we have a transcript disconnected from the current session or no session at all. 
				This might have happened when a test failed in a bad way. Reestablish
				a valid session and transcript"
			self todo:[JadeiteConsole allInstances do: 
					[:aTranscript |
					aTranscript gciSession ifNotNil: [:sess | sess logout].
					self closeTranscript: aTranscript]].
			GciSession current ifNotNil: [:sess | sess logout]].
	^console
]

{ #category : 'projects loading' }
JadeiteTestResource >> unloadSampleProject1 [

	self unloadSampleProject: self rowanSample1Project
]

{ #category : 'projects loading' }
JadeiteTestResource >> unloadSampleProject9 [

	self unloadSampleProject: self rowanSample9Project
]

{ #category : 'projects loading' }
JadeiteTestResource >> unloadSampleProject: sampleProject [

	sampleProject ifNil: [ ^ self ].
	self
		basicUnloadProjects: (Array with: sampleProject name)
		onCompletion: [  ]
]

{ #category : 'updates' }
JadeiteTestResource >> updateServices: services [

	RowanServiceUpdater current
		updateServices: services asSet asArray
		session: self gciSession
		onCompletion: [ ]
]
