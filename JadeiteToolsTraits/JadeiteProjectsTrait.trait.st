Trait {
	#name : 'JadeiteProjectsTrait',
	#category : 'JadeiteToolsTraits'
}

{ #category : 'testing' }
JadeiteProjectsTrait >> allSelectedProjectsDirty [
	^self basicAllSelectedProjectsDirty: self projectListPresenter
]

{ #category : 'testing' }
JadeiteProjectsTrait >> basicAllSelectedProjectsDirty: aProjectListPresenter [
	aProjectListPresenter selections isEmpty ifTrue: [^false].
	aProjectListPresenter selections
		detect: [:projectService | projectService isDirty not and: [projectService isDiskDirty not]]
		ifNone: [^true].
	^false
]

{ #category : 'commands' }
JadeiteProjectsTrait >> basicUnloadProjects: projectNames [
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService.
	self refreshGlobalSelections.
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

{ #category : 'messages' }
JadeiteProjectsTrait >> dirtyDiskConfirmation [
	^MessageBox
		confirm: 'The on-disk state of the git repository is dirty. This may be due to a previous project write without commit, or change to the repository outside Jadeite. It is recommended to check status on the git command line before committing. Proceed?' 
]

{ #category : 'commands' }
JadeiteProjectsTrait >> gitBasicWriteProject: projectServices [

	| ws repositoryRoots |
	ws := WriteStream on: String new.
	repositoryRoots := RowanAnsweringService new projectRepositoryRoots: projectServices
				session: self gciSession.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space;
				nextPut: $(;
				nextPutAll: (repositoryRoots at: service name);
				nextPut: $);
				space].
	projectServices do: [:service | service command: #write].
	self issueCommands: projectServices.
	MessageBox notify: 'Projects ' , ws contents , ' written to disk'
]

{ #category : 'commands' }
JadeiteProjectsTrait >> gitCommit [

	| projectName message |
	self refreshFromServer.
	self canCommit ifFalse: [ ^ self ].
	projectName := self projectListPresenter jaditeSelection name.
	message := UIManager default
		           multiLineRequest:
		           'Enter Git commit message. (Note - This will NOT do a GemStone commit)'
		           initialAnswer: '<enter commit comment here>'
		           answerHeight: 250.
	message ifNil:[^self]. 
	message value isEmpty
		ifTrue: [ 
			MessageBox notify:
				'Commit message must not be empty. Commit to local repository NOT done.' ]
		ifFalse: [ self gitCommit: projectName message: message ]
]

{ #category : 'commands' }
JadeiteProjectsTrait >> gitCommit: projectName message: message [

	| service |
	service := self projectListPresenter jaditeSelection.
	service
		command: #commitWithMessage:;
		commandArgs: (Array with: message value asString).
	BrowserUpdate current issueCommand: service session: self gciSession. 
	RowanBrowserService new
		reloadProjects: self projectListPresenter selections
		presenter: self.
	self reloadProject.
	MessageBox notify:
		'Project ' , projectName , ' committed to local repository!'
]

{ #category : 'commands' }
JadeiteProjectsTrait >> gitWriteProject [

	| projectService ws repositoryRoots |
	projectService := self projectListPresenter selectionIfNone: [
		                  ^ MessageBox notify: 'No project selected' ].
	ws := WriteStream on: String new.
	repositoryRoots := RowanAnsweringService new
		                   projectRepositoryRoots:
		                   (Array with: projectService)
		                   session: self gciSession.
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

{ #category : 'commands' }
JadeiteProjectsTrait >> installProjectFromPath: path projectsHome: projectsHomePath [

	self
		installProjectFromPath: path
		projectsHome: projectsHomePath
		componentNames: #(  )
		attributes: #(  )
		resolveStrict: false
]

{ #category : 'commands' }
JadeiteProjectsTrait >> installProjectFromPath: path projectsHome: projectsHomePath componentNames: componentNames attributes: attributes resolveStrict: resolveStrict [
	| projectService |
	projectService := RowanProjectService new.
	projectService
		command: #installProjectFromFile:projectsHome:componentNames:attributes:resolveStrict:;
		commandArgs: (Array
					with: 'file:' , path
					with: projectsHomePath
					with: componentNames
					with: attributes
					with: resolveStrict).
	self issueCommand: projectService
]

{ #category : 'commands' }
JadeiteProjectsTrait >> loadProject [

	| filePath |
	filePath := JadeiteServerFileSelectorDialog
		            showOnSession: self gciSession
		            defaultPath: JadePresenter rowanProjectsHomeEnvVarString.
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
	menu := SpMenuPresenter new.
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Load ...';
				action: [ self loadProject ] ].
		group addItem: [ :item |
			item
				name: 'Commit to Git ...';
				action: [ self gitCommit ];
				enabled: [ self allSelectedProjectsDirty ] ].
		group addItem: [ :item |
			item
				name: 'Write to Git ...';
				action: [ self gitWriteProject ];
				enabled: [ self projectListPresenter selectionOrNil notNil ] ].
		group addItem: [ :item |
			item
				name: 'Push to GitHub';
				action: [ self pushToGit ] ].
		group addItem: [ :item |
			item
				name: 'Changes';
				action: [ self projectChanges ] ].
		group addItem: [ :item |
			item
				name: 'Unload ...';
				action: [ self unloadProject ];
				enabled: [ self projectListPresenter selectionOrNil notNil ] ] ].
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Refresh from Disk';
				action: [ self reloadProject ] ] ].
	^ menu
]

{ #category : 'commands' }
JadeiteProjectsTrait >> projectChanges [

	| changesBrowser operations |
	self projectListPresenter selections isEmpty ifTrue: [ 
		^ MessageBox notify: 'No project selected' ].
	operations := self projectListPresenter selectedItem changesUsing:
		              self gciSession.
	changesBrowser := JadeiteChangesBrowser
		showOn: (RowanPatch new
				 operations: operations;
				 gciSession: self gciSession)
		name: self projectListPresenter selectedItem name
		application: self application.
	changesBrowser owner application: self application.
	^ changesBrowser
]

{ #category : 'commands' }
JadeiteProjectsTrait >> pushToGit [
	| projectService ws |
	projectService := self projectListPresenter jaditeSelection.
	ws := WriteStream on: String new.
	ws
		nextPutAll: projectService name;
		space.
	(MessageBox
		confirm: 'Push projects - ' , ws contents , '- from the local repository to the remote server?')
			ifFalse: [^self].
	projectService command: #pushToGit.
	BrowserUpdate current issueCommand: projectService session: self gciSession.
	MessageBox notify: 'Project ' , projectService name , ' pushed to remote repository!'
]

{ #category : 'commands' }
JadeiteProjectsTrait >> refreshGlobalSelections [
	"refresh selections in all browsers."

	| browserService |
	browserService := RowanBrowserService new
				command: #findRemovedServices:;
				commandArgs: (Array with: BrowserUpdate current activeServices asSet asArray).
	BrowserUpdate current issueCommands: (Array with: browserService) session: self gciSession.
	self updateServices: BrowserUpdate current selectedServices 
]

{ #category : 'commands' }
JadeiteProjectsTrait >> reloadProject [

	| selections |
	selections := self projectListPresenter selections.
	(self confirmReloadProjects: selections) ifFalse: [ ^ self ].

	RowanBrowserService new reloadProjects: selections presenter: self.
	BrowserUpdate current selectedServices do: [ :service | 
		service postReload ].
	self projectListPresenter update. 
]

{ #category : 'commands' }
JadeiteProjectsTrait >> unloadProject [

	(MessageBox confirm: 'Really unload selected projects?') ifFalse: [
		^ self ].
	self basicUnloadProjects:
		(self projectListPresenter selections collect: [ :service | service name ])
]

{ #category : 'updates' }
JadeiteProjectsTrait >> updateServices: services [

	services isEmpty ifTrue: [ ^ self ].
	services do: [ :service | 
		service
			command: #update;
			commandArgs: #(  ) ].
	BrowserUpdate current 
		issueCommands: services
		session: self gciSession
]
