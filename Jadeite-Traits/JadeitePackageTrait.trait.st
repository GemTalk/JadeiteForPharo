Trait {
	#name : 'JadeitePackageTrait',
	#category : 'Jadeite-Traits'
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
	self issueCommand: projectService onCompletion: nil
]
