Trait {
	#name : 'JadeiteProjectsTrait',
	#instVars : [
		'defaultSaveFilePath'
	],
	#traits : 'JadeiteUtilityTrait',
	#classTraits : 'JadeiteUtilityTrait classTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'testing' }
JadeiteProjectsTrait >> allSelectedProjectsDirty [
	^self basicAllSelectedProjectsDirty: self projectListPresenter
]

{ #category : 'actions' }
JadeiteProjectsTrait >> areProjectsInSync: projects [

	^ (self sortedFrom: projects) asArray
	  = self projectListPresenter items asArray
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> auditProjectFor: projectName [

	| answeringService |
	answeringService := RowanAnsweringService new
		                    command: #auditProjectNamed:;
		                    commandArgs: (Array with: projectName).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			self
				openAuditResultsInWorkspaceUsing: answeringService
				projectNamed: projectName ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> auditProjects [

	self projectListPresenter selectedItems do: [ :projectService |
		self auditProjectFor: projectService name ]
]

{ #category : 'testing' }
JadeiteProjectsTrait >> basicAllSelectedProjectsDirty: aProjectListPresenter [
	aProjectListPresenter selections isEmpty ifTrue: [^false].
	aProjectListPresenter selections
		detect: [:projectService | projectService isDirty not and: [projectService isDiskDirty not]]
		ifNone: [^true].
	^false
]

{ #category : 'menus' }
JadeiteProjectsTrait >> basicCheckoutBranch: branchName for: projectService [

	projectService
		command: #checkout:;
		commandArgs: (Array with: (branchName copyWithout: $*)).
	RowanServiceUpdater current
		issueCommand: projectService
		session: self gciSession
		onCompletion: [ projectService branch: (branchName copyWithout: $*) ]
]

{ #category : 'menus' }
JadeiteProjectsTrait >> basicCheckoutTag: choice for: projectService [

	projectService
		basicCheckoutTag: choice
		using: self gciSession
		onCompletion: [ :unused | self refreshFromServer ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicCreateProject: projectName [

	| browserService |
	browserService := RowanBrowserService new
		                  command: #newProjectNamed:;
		                  commandArgs: { projectName }.
	self issueCommand: browserService onCompletion: [
			| projectService |
			projectService := self projectListPresenter items
				                  detect: [ :service | service name = projectName ]
				                  ifNone: [ ].
			projectService ifNotNil: [
					self projectListPresenter unselectAll.
					self projectListPresenter selectItem: projectService ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicFileoutProject: service to: filePath [

	filePath ifNotNil: [
			service
				command: #exportTopazFormatTo:;
				commandArgs: (Array with: filePath).
			RowanServiceUpdater current
				issueCommand: service
				session: self gciSession
				onCompletion: [ ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicPostOpen [

	self updateCurrentProjectPackageInfo.
	^ self postOpenBlock ifNotNil: [
		  [ self postOpenBlock cull: self ] ensure: [
			  self postOpenBlock: [ ] ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicReloadProjects [

	| selections |
	selections := self projectListPresenter selections.
	self basicReloadProjects: selections
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicReloadProjects: selections [

	RowanBrowserService new
		reloadProjects: selections
		presenter: self
		onCompletion: [
			RowanServiceUpdater current selectedServices do: [ :service |
				service postReload ].
			self projectListPresenter update.
			MessageBox notify: 'Projects reloaded' ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicUnloadProjects: projectNames onCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self
		issueCommand: browserService
		onCompletion: [ self refreshGlobalSelections. completionBlock value ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> browseProject [

	| browser |
	self projectListPresenter selectedItem ifNil: [ ^ self ].
	browser := JadeiteBrowser new owner: self.
	browser postOpenBlock: [
		browser activePresenter selectProjectNamed:
			self projectListPresenter selectedItem name ].
	^self browserOpener basicOpenBrowser: browser
]

{ #category : 'testing' }
JadeiteProjectsTrait >> canCommit [
	| projectService |
	self projectListPresenter selections size > 1
		ifTrue: 
			[MessageBox notify: 'Only one project may be committed'.
			^false].
	projectService := self projectListPresenter selectionOrNil. 
	projectService
		ifNil: 
			[MessageBox notify: 'No project selected'.
			^false].
	^projectService sha = projectService diskSha
		ifTrue: [projectService isDiskDirty ifTrue: [self dirtyDiskConfirmation] ifFalse: [true]]
		ifFalse: [self mismatchedShasConfirmation]
]

{ #category : 'messages' }
JadeiteProjectsTrait >> confirmReloadProjects: selections [
	| ws |
	ws := String new writeStream.
	selections do: 
			[:projectService |
			ws
				cr;
				print: projectService name].
	ws
		nextPut: $?;
		cr.
	(MessageBox
		confirm: 'Really load project(s) ' , ws contents , 'This will destroy any changes you may have.')
			ifFalse: [^false].
	^true
]

{ #category : 'actions' }
JadeiteProjectsTrait >> copyProjectUrl [

	Clipboard
		clipboardText: self projectListPresenter selectedItem projectUrl
		informing: 'Text copied to clipboard'
]

{ #category : 'actions' }
JadeiteProjectsTrait >> createProject [

	| projectName |
	projectName := Prompter prompt: 'Enter new project name:'.
	projectName ifNil: [ ^ self ].
	self basicCreateProject: projectName
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> defaultSaveProjectName [

	^'myProject.tpz'
]

{ #category : 'messages' }
JadeiteProjectsTrait >> dirtyDiskConfirmation [

	| ws message |
	ws := WriteStream on: String new.
	message := 'The on-disk state of the git repository is dirty. This may be due to a previous project write without commit, or change to the repository outside Jadeite. It is recommended to check status on the git command line before committing. Proceed?'.
	^ MessageBox confirm: (message skinnyPrintOn: ws) contents
]

{ #category : 'actions' }
JadeiteProjectsTrait >> fileoutProject [

	| service filePath |
	service := self projectListPresenter selectedItem.
	filePath := self fileoutFileSelection: service name , '.gs'.
	self basicFileoutProject: service to: filePath
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitBasicWriteProject: projectServices [

	| ws answeringService |
	ws := WriteStream on: String new.
	answeringService := RowanAnsweringService new.
	answeringService
		projectRepositoryRoots: projectServices
		session: self gciSession
		onCompletion: [
			projectServices do: [ :service |
				ws
					nextPutAll: service name;
					space;
					nextPut: $(;
					nextPutAll: (answeringService answer at: service name);
					nextPut: $);
					space ].
			projectServices do: [ :service |
				service
					command: #write;
					commandArgs: Array new ].
			RowanServiceUpdater current
				issueCommands: projectServices
				session: self gciSession
				onCompletion: [
				MessageBox notify: 'Projects ' , ws contents , ' written to disk' ] ]
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutBranch [
	
	| selectedProjectService |
	selectedProjectService := self projectListPresenter selectedItem.
	self gitCheckoutBranch: selectedProjectService.
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutBranch: projectService [

	self
		openGitBranchesDialogFor: projectService
		onCompletion: [ :choice |
			choice ifNotNil: [
				self basicCheckoutBranch: choice for: projectService ] ]
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutTag [

	| selectedProjectService |
	selectedProjectService := self projectListPresenter selectedItem.
	self gitCheckoutTag: selectedProjectService
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutTag: projectService [

	| choice |
	projectService gitTags: self gciSession onCompletion: [ :tags |
		tags ifNotNil: [
			tags
				ifEmpty: [ UIManager default alert: 'Project does not have tags' ]
				ifNotEmpty: [
					choice := self
						          selectStringFromList: tags
						          title: 'Jadeite Checkout Git Tag'.
					choice ifNotNil: [
						self basicCheckoutTag: choice for: projectService ] ] ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitCommit [

	| projectName |
	self canCommit ifFalse: [ ^ self ].
	projectName := self projectListPresenter selectedItem name.
	UIManager default
		jadeiteMultiLineRequest:
		'Enter Git commit message. (Note - This will NOT do a GemStone commit)'
		initialAnswer: '<enter commit comment here>'
		answerHeight: 250
		onCompletion: [ :message |
			message value isEmpty
				ifTrue: [
					MessageBox notify:
						'Commit message must not be empty. Commit to local repository NOT done.' ]
				ifFalse: [ self gitCommit: projectName message: message ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitCommit: projectName message: message [

	| service |
	service := self projectListPresenter jaditeSelection.
	service
		command: #commitWithMessage:;
		commandArgs: (Array with: message value asString).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			MessageBox notify:
				'Project ' , projectName , ' committed to local repository!'.
			self basicReloadProjects: self projectListPresenter selections.
			self markProjectContentsNotDirty ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> gitProjectLog [

	| queryService |
	queryService := RowanQueryService
		                command: #projectLog:
		                withArgs: (Array with: self selectedProjectName).
	RowanServiceUpdater current
		issueCommand: queryService
		session: self gciSession
		onCompletion: [self openGitLogInWorkspaceUsing: queryService]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitWriteProject [

	| projectService ws |
	projectService := self projectListPresenter selectionIfNone: [
		                  ^ MessageBox notify: 'No project selected' ].
	ws := WriteStream on: String new.
	RowanAnsweringService new
		projectRepositoryRoots: (Array with: projectService)
		session: self gciSession
		onCompletion: [ :answeringService |
			ws
				nextPutAll: projectService name;
				space;
				nextPut: $(;
				nextPutAll: (answeringService answer at: projectService name);
				nextPut: $);
				space.
			(MessageBox confirm:
				 'Write projects - ' , ws contents , 'to disk without committing?')
				ifTrue: [ self gitBasicWriteProject: (Array with: projectService) ] ]
]

{ #category : 'menus' }
JadeiteProjectsTrait >> initializeProjectListMenu [

	self projectListPresenter contextMenu: self newProjectMenu
]

{ #category : 'actions' }
JadeiteProjectsTrait >> installProjectFromPath: path projectsHome: projectsHomePath [

	(ProvideAnswerNotification signal:
		 (Array with: path with: projectsHomePath)) ifNotNil: [ :array |
		^ array ].
	self
		installProjectFromPath: path
		projectsHome: projectsHomePath
		componentNames: nil
		attributes: nil
		resolveStrict: false
		alias: nil
]

{ #category : 'actions' }
JadeiteProjectsTrait >> installProjectFromPath: path projectsHome: projectsHomePath componentNames: componentNames attributes: attributes resolveStrict: resolveStrict alias: alias [

	| projectService |
	projectService := RowanProjectServiceClient new.
	projectService
		command:
			#installProjectFromFile:projectsHome:componentNames:attributes:resolveStrict:alias:;
		commandArgs: {
				('file:' , path).
				projectsHomePath.
				componentNames.
				attributes.
				resolveStrict.
				alias }.
	projectService compileErrorHandler: [ :ex |
		| ws |
		ws := WriteStream on: String new.
		ws
			nextPutAll: 'Compile Error during project load. Load cancelled.';
			cr;
			nextPutAll: ex messageText.
		UIManager default alert: ws contents ].
	self issueCommand: projectService onCompletion: [  ]
]

{ #category : 'testing' }
JadeiteProjectsTrait >> isWriteableProject [

	| projectService |
	projectService := self projectListPresenter selectionOrNil.
	^ projectService notNil and: [ projectService canBeWritten ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> loadProject [
	"the gui is updated in RowanBrowserService>>projectsUpdate:browser:"

	| filePath ws useRowanProjectsHome projectsHomePath |
	filePath := JadeiteServerFileSelectorDialog
		            showOnSession: self gciSession
		            defaultPath: JadePresenter homeEnvVarString
		            shellName: 'Jadeite Select Load Spec File'.
	filePath ifNil: [ ^ self ].
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'Loading this spec file will use ''';
		nextPutAll: JadePresenter rowanProjectsHomeEnvVarString;
		nextPutAll: ''' as projects home. Continue?';
		cr;
		nextPutAll:
			'(Pressing No will open a dialog to choose an alternate projects home path)'.
	useRowanProjectsHome := self uiManager confirm: ws contents.
	projectsHomePath := useRowanProjectsHome
		                    ifTrue: [
		                    JadePresenter rowanProjectsHomeEnvVarString ]
		                    ifFalse: [
				                    JadeiteServerFileSelectorDialog
					                    showOnSession: self gciSession
					                    defaultPath:
					                    JadePresenter rowanProjectsHomeEnvVarString
					                    shellName:
						                    'Jadeite Alternate Projects Home for load of '
						                    , filePath asFileReference basename ].
	projectsHomePath ifNil: [ ^ self ].
	^ self
		  installProjectFromPath: filePath
		  projectsHome: projectsHomePath
]

{ #category : 'actions' }
JadeiteProjectsTrait >> markProjectContentsNotDirty [

	"Let each presenter handle it's own dirty state management"
]

{ #category : 'messages' }
JadeiteProjectsTrait >> mismatchedShasConfirmation [

	| msg |
	msg := 'The most recently loaded sha differs from the sha of the git repository. It is not recommended to commit; if you are aware of the issues, you may continue to write and commit your image changes. Proceed?'.
	^ JadeiteConfirmDialogDefaultCancel new
		  title: 'Confirm Git Commit';
		  label: msg;
		  acceptLabel: 'Yes';
		  cancelLabel: 'No';
		  openModal
]

{ #category : 'menus' }
JadeiteProjectsTrait >> newProjectMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu addGroup: [ :group |
			group addItem: [ :item |
					item
						name: 'Browse';
						action: [ self browseProject ];
						enabled: [ self projectListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
			group
				addItem: [ :item |
						item
							name: 'New ...';
							action: [ self createProject ] ];
				addItem: [ :item |
						item
							name: 'Load ...';
							action: [ self loadProject ] ];
				addItem: [ :item |
						item
							name: 'Reload from Disk';
							action: [ self reloadProject ];
							enabled: [ self isWriteableProject ] ];
				addItem: [ :item |
						item
							name: 'Unload ...';
							action: [ self unloadProject ];
							enabled: [ self isWriteableProject ] ];
				addItem: [ :item |
						item
							name: 'Refresh from Server';
							action: [ self refreshProjects ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Set Current';
							action: [ self setCurrentProject ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Unset Current';
							action: [ self unsetCurrentProject ] ] ].
	menu addGroup: [ :group |
			group
				addItem: [ :item |
						item
							name: 'Pull from Git';
							action: [ self pullFromGit ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Commit to Git ...';
							action: [ [ self gitCommit ] fork ];
							enabled: [ self allSelectedProjectsDirty ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Push to Git';
							action: [ self pushToGit ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Git Log';
							action: [ self gitProjectLog ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
			group
				addItem: [ :item |
						item
							name: 'Changes';
							action: [ self projectChanges ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Write';
							action: [ self gitWriteProject ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Checkout Git Tag ...';
							action: [ self gitCheckoutTag ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Checkout Git Branch ...';
							action: [ self gitCheckoutBranch ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
			group
				addItem: [ :item |
						item
							name: 'Audit';
							action: [ self auditProjects ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'Copy Project URL';
							action: [ self copyProjectUrl ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ];
				addItem: [ :item |
						item
							name: 'File Out Project ...';
							action: [ self fileoutProject ];
							enabled: [ self projectListPresenter selectionOrNil notNil ] ] ].
	^ menu
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> openAuditResultsInWorkspaceUsing: answeringService projectNamed: projectName [

	| workspace workspacePresenter |
	workspacePresenter := JadeiteWorkspaceApplication showOnSession:
		             self gciSession library.
	workspace := workspacePresenter workspace. 
	workspace setCaption: 'Audit Report for project ' , projectName.
	workspace text: answeringService answer.
	workspace hasUnacceptedEdits: false.
	^ workspace
]

{ #category : 'menus' }
JadeiteProjectsTrait >> openGitBranchesDialogFor: projectService onCompletion: completionBlock [

	projectService
		gitBranches: self gciSession
		onCompletion: [ :branches |
			| choice |
			branches
				ifEmpty: [
				UIManager default alert: 'Project does not have branches' ]
				ifNotEmpty: [
					choice := self
						          selectStringFromList: branches
						          title: 'Jadeite Checkout Git Branch'.
					completionBlock value: choice ] ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> openGitLogInWorkspaceUsing: queryService [

	| workspace workspacePresenter |
	workspacePresenter := JadeiteWorkspaceApplication showOnSession:
		                      self gciSession library.
	workspace := workspacePresenter workspace.
	workspace setCaption:
		'Jadeite Git Log for ' , self selectedProjectName.
	workspace text: queryService answer.
	workspace hasUnacceptedEdits: false.
	^ workspace
]

{ #category : 'menus' }
JadeiteProjectsTrait >> openGitTagSelectionDialogFor: projectService [

	projectService gitTags: self gciSession onCompletion: [ :tags |
		^ self selectStringFromList: tags title: 'Jadeite Checkout Git Tag' ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> projectChanges [

	| changesBrowser projectService |
	self projectListPresenter selections isEmpty ifTrue: [
		^ MessageBox notify: 'No project selected' ].
	projectService := self projectListPresenter selectedItem.
	projectService existsOnDisk ifFalse: [
		^ UIManager default inform:
			  ('Project <1s> does not exist on disk' expandMacrosWith:
				   projectService name) ].
	projectService
		changesUsing: self gciSession
		onCompletion: [ :operations |
			operations isEmpty
				ifTrue: [ MessageBox notify: 'No changes!' ]
				ifFalse: [
					changesBrowser := JadeiteChangesBrowser
						                  showOn: (RowanPatch new
								                   operations: operations;
								                   gciSession: self gciSession)
						                  name: projectService name
						                  application: self application.
					changesBrowser owner application: self application.
					 ] ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> pullFromGit [

	| projectServices ws |
	projectServices := self projectListPresenter selections.
	ws := WriteStream on: String new.
	projectServices do: [ :service |
		ws
			nextPutAll: service name;
			space ].
	(MessageBox confirm:
		 'It is recommended that you commit changes before doing a pulling projects - '
		 , ws contents , ' -  from git. Really proceed?') ifFalse: [ ^ self ].
	projectServices do: [ :service | service command: #pullFromGit ].
	RowanServiceUpdater current
		issueCommands: projectServices
		session: self gciSession
		onCompletion: [  ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> pushToGit [

	| projectService ws |
	projectService := self projectListPresenter jaditeSelection.
	ws := WriteStream on: String new.
	ws
		nextPutAll: projectService name;
		space.
	(MessageBox confirm: 'Push projects - ' , ws contents
		 , '- from the local repository to the remote server?') ifFalse: [
		^ self ].
	projectService
		command: #pushToGit;
		commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: projectService
		session: self gciSession
		onCompletion: [
			MessageBox notify:
				'Project ' , projectService name , ' pushed to remote repository!' ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> refreshFromServer [

	| selection |
	selection := self projectListPresenter selectedItem.
	self updateProjectsOnCompletion: [  ].
	selection ifNotNil: [
		self projectListPresenter selectItem: selection ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> refreshGlobalSelections [
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

{ #category : 'actions' }
JadeiteProjectsTrait >> refreshProjects [

	self refreshProjectsOnCompletion: [  ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> refreshProjectsOnCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: completionBlock
]

{ #category : 'actions' }
JadeiteProjectsTrait >> reloadProject [

	| selections |
	selections := self projectListPresenter selections.
	(self confirmReloadProjects: selections) ifFalse: [ ^ self ].
	self basicReloadProjects: selections
]

{ #category : 'menus' }
JadeiteProjectsTrait >> selectStringFromList: strings title: title [

	| dialogWindow |
	dialogWindow := JadeiteSearchDialogWindow new
		                getList: [ :rxMatcher |
			                strings select: [ :substring |
					                rxMatcher isString
						                ifTrue: [ rxMatcher , '*' match: substring ]
						                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
							                rxMatcher matchesPrefix: substring ] ] ];
		                displayBlock: [ :e | e ];
		                doubleClickOk;
		                title: title;
		                yourself.
	^ dialogWindow chooseFromOwner: self currentWorld
]

{ #category : 'selections' }
JadeiteProjectsTrait >> selectedProjectName [
	^(self projectListPresenter selectionOrNil ifNil: [^nil]) name 
]

{ #category : 'actions' }
JadeiteProjectsTrait >> setCurrentProject [

	self projectListPresenter selectedItem setCurrentOnCompletion: [
			:projectService |
			self gciSession
				announceUpdatedCurrentProject: projectService
				package: nil ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> unloadProject [

	| projectsToBeRemoved ws |
	projectsToBeRemoved := Set new.
	self projectListPresenter selectedItems do: [ :projectService |
			projectsToBeRemoved add: projectService name.
			projectsToBeRemoved addAll:
				projectService requiredProjectNames asSet ].
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'This will unload the following projects. Continue?';
		cr.
	projectsToBeRemoved do: [ :projectName |
			ws
				nextPutAll: projectName;
				cr ].
	(self uiManager confirm: ws contents) ifFalse: [ ^ self ].
	self
		basicUnloadProjects:
			(self projectListPresenter selections collect: [ :service |
				 service name ])
		onCompletion: nil
]

{ #category : 'actions' }
JadeiteProjectsTrait >> unsetCurrentProject [

	RowanBrowserService new unsetCurrentProjectOnCompletion: [
		self gciSession announceUpdatedCurrentProject: nil package: nil ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> updateProjectsOnCompletion: completionBlock [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: [
			(self areProjectsInSync: browserService projects) ifFalse: [
				self projectListPresenter items:
					(self sortedFrom: browserService projects).
				self projectListUpdated ].
			self basicPostOpen.
			completionBlock value ]
]
