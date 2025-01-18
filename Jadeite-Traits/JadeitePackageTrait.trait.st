Trait {
	#name : 'JadeitePackageTrait',
	#traits : 'JadeiteUtilityTrait',
	#classTraits : 'JadeiteUtilityTrait classTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'actions' }
JadeitePackageTrait >> addPackage [

	| inst |
	inst := JadeiteAddPackageDialog
		        showOnSession: GciSession current
		        projectService: self projectListPresenter selectedItem.
	inst isOk ifFalse: [ ^ self ].
	self basicAddPackage: inst
]

{ #category : 'actions' }
JadeitePackageTrait >> basicAddPackage: inst [

	| componentName symbolDictionaryName packageName |
	packageName := inst presenter packageName.
	componentName := inst presenter componentName.
	symbolDictionaryName := inst presenter symbolDictionaryName.
	self
		basicAddPackageNamed: packageName
		symbolDictionary: symbolDictionaryName
		componentName: componentName
]

{ #category : 'actions' }
JadeitePackageTrait >> basicAddPackageNamed: packageName symbolDictionary: symbolDictionaryName componentName: componentName [

	| projectService |
	packageName ifNil: [
		^ MessageBox notify: 'Must enter a valid package name' ].
	packageName = String new ifTrue: [
		^ MessageBox notify: 'Must enter a valid package name' ].
	projectService := self projectListPresenter selectedItem.
	projectService
		command:
			#addNewPackageNamed:inSymbolDictionaryNamed:toComponentNamed:;
		commandArgs: (Array
				 with: packageName
				 with: symbolDictionaryName
				 with: componentName).
	self issueCommand: projectService onCompletion: [ :unused |
		self application triggerEvent: #packageAdded: with: packageName ]
]

{ #category : 'actions' }
JadeitePackageTrait >> fileoutPackage [

	| service filePath |
	service := self packageListPresenter selectedItem.
	filePath := self fileoutFileSelection: service name.
	filePath ifNotNil: [
		service
			command: #exportTopazFormatTo:;
			commandArgs: (Array with: filePath).
		RowanServiceUpdater current
			issueCommand: service
			session: self gciSession
			onCompletion: nil ]
]

{ #category : 'menus' }
JadeitePackageTrait >> initializePackageMenu [

	self packageListPresenter contextMenu: self newPackageMenu.
]

{ #category : 'menus' }
JadeitePackageTrait >> newPackageMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Add Package';
						  action: [ self addPackage ];
						  enabled: [ self isRowanProjectSelected ] ];
				  addItem: [ :item |
					  item
						  name: 'Remove Package';
						  action: [ self removePackage ];
						  enabled: [
							  [ self packageListPresenter selectedItem notNil ]
								  on: Error
								  do: [ :ex |
									  false "Spec2 lists are broken and can have the wrong selection" ] ] ];
				  addItem: [ :item |
					  item
						  name: 'File Out Package ...';
						  action: [ self fileoutPackage ];
						  enabled: [
							  [ self packageListPresenter selectedItem notNil ]
								  on: Error
								  do: [ :ex |
									  false "Spec2 lists are broken and can have the wrong selection" ] ] ];
				  addItem: [ :item |
					  item
						  name: 'Set Current';
						  action: [ self setPackageCurrent ];
						  enabled: [
							  [ self packageListPresenter selectedItem notNil ]
								  on: Error
								  do: [ :ex |
									  false "Spec2 lists are broken and can have the wrong selection" ] ] ] ];
		  yourself
]

{ #category : 'actions' }
JadeitePackageTrait >> removePackage [

	| projectService |
	(MessageBox confirm: 'Really remove package(s)?') ifFalse: [ ^ self ].
	projectService := self projectListPresenter selectedItem.
	projectService
		command: #removePackagesNamed:;
		commandArgs:
			(Array with: (Array with: self packageListPresenter selectedItem)).
	self issueCommand: projectService onCompletion: [  ]
]

{ #category : 'actions' }
JadeitePackageTrait >> setPackageCurrent [

	self packageListPresenter items do: [ :packageService |
		packageService isCurrent: false ].
	self packageListPresenter selectedItem setCurrent.
	WorldMorph doOneCycle
]
