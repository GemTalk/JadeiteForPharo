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
		onCompletion: nil.
	self
		openAuditResultsInWorkspaceUsing: answeringService
		projectNamed: projectName
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
		session: self gciSession.
	projectService branch: (branchName copyWithout: $*).
]

{ #category : 'menus' }
JadeiteProjectsTrait >> basicCheckoutTag: choice for: projectService [

	projectService
		basicCheckoutTag: choice
		using: self gciSession
		onCompletion: [ :unused | self refreshFromServer ]
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicReloadProject [

	| selections |
	selections := self projectListPresenter selections.
	self basicReloadProject: selections
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicReloadProject: selections [

	RowanBrowserService new reloadProjects: selections presenter: self.
	RowanServiceUpdater current selectedServices do: [ :service |
		service postReload ].
	self projectListPresenter update
]

{ #category : 'actions' }
JadeiteProjectsTrait >> basicUnloadProjects: projectNames [

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService onCompletion: nil.
	self refreshGlobalSelections
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
JadeiteProjectsTrait >> doProjectsNeedRefresh: browserService [

	^ (self sortedProjectsFrom: browserService projects) asArray
	  = self projectListPresenter items asArray
]

{ #category : 'actions' }
JadeiteProjectsTrait >> fileoutProject [

	| service filePath |
	service := self projectListPresenter selectedItem.
	UIManager default defer: [
		filePath := self fileoutFileSelection: service name.
		filePath ifNotNil: [
			service
				command: #exportTopazFormatTo:;
				commandArgs: (Array with: filePath).
			RowanServiceUpdater current
				issueCommand: service
				session: self gciSession
				onCompletion: nil ] ]
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
					UIManager default defer: [
						MessageBox notify:
							'Projects ' , ws contents , ' written to disk' ] ] ]
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutBranch [
	
	| selectedProjectService |
	selectedProjectService := self projectListPresenter selectedItem.
	self gitCheckoutBranch: selectedProjectService.
	self refreshFromServer 
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutBranch: projectService [

	| choice |
	choice := self openGitBranchesDialogFor: projectService.
	choice ifNil: [ ^ self ].
	self basicCheckoutBranch: choice for: projectService
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutTag [

	| selectedProjectService |
	selectedProjectService := self projectListPresenter selectedItem.
	self gitCheckoutTag: selectedProjectService.
	self refreshFromServer 
]

{ #category : 'menus' }
JadeiteProjectsTrait >> gitCheckoutTag: projectService [

	| choice tags |
	tags := projectService gitTags: self gciSession.
	choice := self
		          selectStringFromList: tags
		          title: 'Jadeite Checkout Git Tag'.
	choice ifNil: [ ^ self ].
	self basicCheckoutTag: choice for: projectService
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitCommit [

	| projectName message |
	self canCommit ifFalse: [ ^ self ].

	projectName := self projectListPresenter selectedItem name.
	UIManager default defer: [
		message := UIManager default
			           jadeiteMultiLineRequest:
			           'Enter Git commit message. (Note - This will NOT do a GemStone commit)'
			           initialAnswer: '<enter commit comment here>'
			           answerHeight: 250.
		message ifNotNil: [
			message value isEmpty
				ifTrue: [
					MessageBox notify:
						'Commit message must not be empty. Commit to local repository NOT done.' ]
				ifFalse: [ self gitCommit: projectName message: message ] ] ]
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
		onCompletion: nil.
	RowanBrowserService new
		reloadProjects: self projectListPresenter selections
		presenter: self.
	self basicReloadProject.
	MessageBox notify:
		'Project ' , projectName , ' committed to local repository!'
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
		onCompletion: nil. 
	self openGitLogInWorkspaceUsing: queryService
]

{ #category : 'actions' }
JadeiteProjectsTrait >> gitWriteProject [

	| projectService ws repositoryRoots |
	projectService := self projectListPresenter selectionIfNone: [
		                  ^ MessageBox notify: 'No project selected' ].
	ws := WriteStream on: String new.
	repositoryRoots := RowanAnsweringService new
		                   projectRepositoryRoots:
		                   (Array with: projectService)
		                   session: self gciSession
		                   onCompletion: nil.
	ws
		nextPutAll: projectService name;
		space;
		nextPut: $(;
		nextPutAll: (repositoryRoots at: projectService name);
		nextPut: $);
		space.
	(MessageBox confirm:
		 'Write projects - ' , ws contents , 'to disk without committing?')
		ifFalse: [ ^ false ].
	^ self gitBasicWriteProject: (Array with: projectService)
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
	self issueCommand: projectService onCompletion: nil
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
				name: 'Load ...';
				action: [ self loadProject ] ].
		group addItem: [ :item |
			item
				name: 'Refresh from Disk';
				action: [ self reloadProject ] ].
		group addItem: [ :item |
			item
				name: 'Unload';
				action: [ self unloadProject ];
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
JadeiteProjectsTrait >> openGitBranchesDialogFor: projectService [

	| branches |
	branches := projectService gitBranches: self gciSession.
	^ self
		  selectStringFromList: branches
		  title: 'Jadeite Checkout Git Branch'
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

	| tags |
	tags := projectService gitTags: self gciSession.
	^ self selectStringFromList: tags title: 'Jadeite Checkout Git Tag'
]

{ #category : 'actions' }
JadeiteProjectsTrait >> projectChanges [

	| changesBrowser operations projectService |
	self projectListPresenter selections isEmpty ifTrue: [
		^ MessageBox notify: 'No project selected' ].
	projectService := self projectListPresenter selectedItem.
	projectService existsOnDisk ifFalse: [
		^ UIManager default inform:
			  ('Project <1s> does not exist on disk' expandMacrosWith:
				   projectService name) ].
	operations := projectService changesUsing: self gciSession.
	changesBrowser := JadeiteChangesBrowser
		                  showOn: (RowanPatch new
				                   operations: operations;
				                   gciSession: self gciSession)
		                  name: projectService name
		                  application: self application.
	changesBrowser owner application: self application.
	^ changesBrowser
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
	RowanServiceUpdater current issueCommands: projectServices session: self gciSession onCompletion: nil
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
		 , '- from the local repository to the remote server?') ifTrue: [
		projectService command: #pushToGit.
		RowanServiceUpdater current
			issueCommand: projectService
			session: self gciSession ].

	MessageBox notify:
		'Project ' , projectService name , ' pushed to remote repository!'
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
		onCompletion: nil.
	self updateServices: RowanServiceUpdater current selectedServices
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
JadeiteProjectsTrait >> unloadProject [

	(MessageBox confirm: 'Really unload selected projects?') ifFalse: [
		^ self ].
	self basicUnloadProjects:
		(self projectListPresenter selections collect: [ :service | service name ])
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
			(self doProjectsNeedRefresh: browserService) ifFalse: [
				self projectListPresenter items:
					(self sortedProjectsFrom: browserService projects) ].
			self postOpenBlock ifNotNil: [
				[ self postOpenBlock cull: self ] ensure: [
					self postOpenBlock: nil ] ] ]
]
