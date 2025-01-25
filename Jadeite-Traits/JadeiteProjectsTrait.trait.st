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
JadeiteProjectsTrait >> auditProject [
	self auditProjectFor: self projectListPresenter selectedItem name
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
			                  ifNone: [  ].
		projectService ifNotNil: [
			self projectListPresenter selectItem: projectService ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicPostOpen [

	^ self postOpenBlock ifNotNil: [
		  [ self postOpenBlock cull: self ] ensure: [
			  self postOpenBlock: nil ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicReloadProject [

	| selections |
	selections := self projectListPresenter selections.
	self basicReloadProject: selections
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicReloadProject: selections [

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
	filePath := self fileoutFileSelection: service name.
	filePath ifNotNil: [
		service
			command: #exportTopazFormatTo:;
			commandArgs: (Array with: filePath).
		RowanServiceUpdater current
			issueCommand: service
			session: self gciSession
			onCompletion: [  ] ]
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
			projectServices do: [ :service | service command: #write ].
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
		choice := self
			          selectStringFromList: tags
			          title: 'Jadeite Checkout Git Tag'.
		choice ifNotNil: [
			self basicCheckoutTag: choice for: projectService ] ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitCommit [

	| projectName message |
	self canCommit ifFalse: [ ^ self ].
	projectName := self projectListPresenter selectedItem name.
	[message := UIManager default
		           jadeiteMultiLineRequest:
		           'Enter Git commit message. (Note - This will NOT do a GemStone commit)'
		           initialAnswer: '<enter commit comment here>'
		           answerHeight: 250.
	message ifNotNil: [
		message value isEmpty
			ifTrue: [
				MessageBox notify:
					'Commit message must not be empty. Commit to local repository NOT done.' ]
			ifFalse: [ self gitCommit: projectName message: message ] ]] fork
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
			self basicReloadProject: self projectListPresenter selections ]
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

	self
		installProjectFromPath: path
		projectsHome: projectsHomePath
		componentNames: #(  )
		attributes: #(  )
		resolveStrict: false
]

{ #category : 'actions' }
JadeiteProjectsTrait >> installProjectFromPath: path projectsHome: projectsHomePath componentNames: componentNames attributes: attributes resolveStrict: resolveStrict [

	| projectService |
	projectService := RowanProjectService new.
	projectService
		command:
			#installProjectFromFile:projectsHome:componentNames:attributes:resolveStrict:;
		commandArgs: (Array
				 with: 'file:' , path
				 with: projectsHomePath
				 with: componentNames
				 with: attributes
				 with: resolveStrict).
	self issueCommand: projectService onCompletion: [  ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> loadProject [
	"the gui is updated in RowanBrowserService>>projectsUpdate:browser:"

	| filePath |
	filePath := JadeiteServerFileSelectorDialog
		            showOnSession: self gciSession
		            defaultPath: JadePresenter rowanProjectsHomeEnvVarString
		            shellName: 'Jadeite Select Load Spec File'.
	filePath ifNil: [ ^ self ].
	^ self
		  installProjectFromPath: filePath
		  projectsHome: JadePresenter rowanProjectsHomeEnvVarString
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
					action: [ self reloadProject ] ];
			addItem: [ :item |
				item
					name: 'Unload';
					action: [ self unloadProject ];
					enabled: [ self projectListPresenter selectionOrNil notNil ] ];
			addItem: [ :item |
				item
					name: 'Refresh from Server';
					action: [ self refreshProjects ] ];
			addItem: [ :item |
				item
					name: 'Set Current';
					action: [ self setCurrentProject ];
					enabled: [ self projectListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Pull from Git';
					action: [ self pullFromGit ] ];
			addItem: [ :item |
				item
					name: 'Commit to Git ...';
					action: [ [ self gitCommit ] fork ];
					enabled: [ self allSelectedProjectsDirty ] ];
			addItem: [ :item |
				item
					name: 'Push to Git';
					action: [ self pushToGit ] ];
			addItem: [ :item |
				item
					name: 'Git Log';
					action: [ self gitProjectLog ] ] ].
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Changes';
					action: [ self projectChanges ] ];
			addItem: [ :item |
				item
					name: 'Write';
					action: [ self gitWriteProject ];
					enabled: [ self projectListPresenter selectionOrNil notNil ] ];
			addItem: [ :item |
				item
					name: 'Checkout Git Tag ...';
					action: [ self gitCheckoutTag ] ];
			addItem: [ :item |
				item
					name: 'Checkout Git Branch ...';
					action: [ self gitCheckoutBranch ] ] ].
	menu addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Audit';
					action: [ self auditProject ];
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

	| workspace |
	workspace := JadeiteWorkspaceApplication showOnSession:
		             self gciSession library.
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
			choice := self
				          selectStringFromList: branches
				          title: 'Jadeite Checkout Git Branch'.
			completionBlock value: choice ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsTrait >> openGitLogInWorkspaceUsing: queryService [

	| workspace |
	workspace := JadeiteWorkspaceApplication showOnSession:
		             self gciSession library.
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
					changesBrowser owner application: self application ] ]
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

	| browserService |
	browserService := RowanBrowserService new command: #updateProjects.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
]

{ #category : 'actions' }
JadeiteProjectsTrait >> reloadProject [

	| selections |
	selections := self projectListPresenter selections.
	(self confirmReloadProjects: selections) ifFalse: [ ^ self ].
	self basicReloadProject: selections
]

{ #category : 'menus' }
JadeiteProjectsTrait >> selectStringFromList: strings title: title [

	| dialogWindow |
	dialogWindow := ListDialogWindow new
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

	RowanProjectServiceClient allInstances do: [ :projectService |
		projectService isCurrent: false ].
	self projectListPresenter selectedItem setCurrent.
	WorldMorph doOneCycle
]

{ #category : 'actions' }
JadeiteProjectsTrait >> unloadProject [

	(MessageBox confirm: 'Really unload selected projects?') ifFalse: [
		^ self ].
	self
		basicUnloadProjects:
			(self projectListPresenter selections collect: [ :service |
				 service name ])
		onCompletion: nil
]

{ #category : 'actions' }
JadeiteProjectsTrait >> updateProjects [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #updateProjects;
		commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: [
			(self areProjectsInSync: browserService projects) ifFalse: [
				self projectListPresenter items:
					(self sortedFrom: browserService projects).
				self projectListUpdated ].
			self basicPostOpen ]
]
