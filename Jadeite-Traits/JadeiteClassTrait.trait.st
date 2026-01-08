Trait {
	#name : 'JadeiteClassTrait',
	#traits : 'JadeiteUtilityTrait',
	#classTraits : 'JadeiteUtilityTrait classTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'menus' }
JadeiteClassTrait >> addModifyClassMenuItemsTo: menu [

	menu
		addGroup: [ :group |
				group addItem: [ :item |
							item
								name: 'Remove ...';
								action: [ self removeClass ];
								enabled: [ self isClassSelected ] ] ];
		addGroup: [ :group |
				JadeitePreferences isRowanLoaded ifTrue: [
						group
							addItem: [ :item |
									item
										name: 'Move to Package ...';
										action: [ self moveClassToPackage ];
										enabled: [ self isClassSelected ] ];
							addItem: [ :item |
									item
										name: 'Move to Current Package';
										action: [ self moveClassToCurrentPackage ];
										enabled: [
											self isClassSelected and: [ self currentPackage notNil ] ] ] ].
				group addItem: [ :item |
						item
							name: 'Copy ...';
							action: [ self copyClass ];
							enabled: [ self isClassSelected ] ].
				JadeitePreferences isRowanAvailable ifTrue: [
						group addItem: [ :item |
								item
									name: 'Rename ...';
									action: [ self renameClass ];
									enabled: [ self isClassSelected ] ] ] ];
		addGroup: [ :group |
				group addItem: [ :item |
						item
							name: 'File Out Class ...';
							action: [ self fileoutClass ];
							enabled: [ self isClassSelected ] ] ]
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClass [

	| browser |
	browser := self openBrowser.
	browser activePresenter
		updateAfterFindClass: self selectedClass
		methodService: nil
		onCompletion: [  ].
	^ browser
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClassReferences [

	| presenter |
	presenter := self activePresenter isClassHierarchyTabSelected
		             ifTrue: [ self classHierarchyPresenter ]
		             ifFalse: [ self classListPresenter ].
	^ self browseClassReferences: presenter selectedItem className
]

{ #category : 'menus' }
JadeiteClassTrait >> fileoutClass [
	"append .gs to the file so it matches what rowan does for packages & projects"

	| service filePath |
	service := self selectedClass.

	filePath := self fileoutFileSelection: service name , '.gs'.
	filePath ifNotNil: [
		service
			command: #fileoutClassOn:;
			commandArgs: (Array with: filePath).
		RowanServiceUpdater current
			issueCommand: service
			session: self gciSession
			onCompletion: [  ] ]
]

{ #category : 'private' }
JadeiteClassTrait >> findPackageAndMoveToPackage [

	| dialogWindow browserService packageService packageServices |
	browserService := RowanBrowserService new
		                  command: #allPackages;
		                  commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession
		onCompletion: [
			packageServices := self packageListForSearchDialog: browserService.
			dialogWindow := self packageSearchDialogFor: packageServices.
			packageService := dialogWindow chooseFromOwner: self currentWorld.
			packageService ifNotNil: [
				self moveClassToPackageNamed: packageService name ] ]
]

{ #category : 'menus' }
JadeiteClassTrait >> initializeBrowseClassMenu [

	self classListPresenter contextMenu: self newBrowseClassMenu.
	self classHierarchyPresenter ifNotNil: [:presenter | presenter contextMenu: self newBrowseClassMenu]
]

{ #category : 'menus' }
JadeiteClassTrait >> initializeFullClassMenu [

	self classListPresenter contextMenu: self newFullClassMenu.
	self classHierarchyPresenter ifNotNil: [ :presenter |
		presenter contextMenu: self newHierarchyClassMenu ]
]

{ #category : 'menus' }
JadeiteClassTrait >> isClassSelected [

	^ self selectedClassTab
		  ifNil: [ false ]
		  ifNotNil: [ :tab | tab activePresenter selectedItem notNil ]
]

{ #category : 'actions' }
JadeiteClassTrait >> moveClassToCurrentPackage [

	self currentPackage ifNotNil: [
		self moveClassToPackageNamed: self currentPackage name ]
]

{ #category : 'actions' }
JadeiteClassTrait >> moveClassToPackage [

	self findPackageAndMoveToPackage
]

{ #category : 'actions' }
JadeiteClassTrait >> moveClassToPackageNamed: packageName [

	self selectedClass ifNil: [ ^ self ].
	self selectedClass
		command: #moveToPackageNamed:;
		commandArgs: (Array with: packageName).
	RowanServiceUpdater current
		issueCommand: self selectedClass
		session: self gciSession
		onCompletion: [
			self
				updateAfterFindClass: self selectedClass
				methodService: nil
				onCompletion: [  ] ]
]

{ #category : 'menus' }
JadeiteClassTrait >> newBrowseClassMenu [

	^ JadeiteMenuPresenter new addGroup: [ :group |
		  group
			  addItem: [ :item |
				  item
					  name: 'Browse Class';
					  action: [ self browseClass ];
					  enabled: [ self isClassSelected ] ];
			  addItem: [ :item |
				  item
					  name: 'Browse References';
					  action: [ self browseClassReferences ];
					  enabled: [ self isClassSelected ] ] ]
]

{ #category : 'menus' }
JadeiteClassTrait >> newFullClassMenu [

	| menu |
	menu := self newBrowseClassMenu.
	self addModifyClassMenuItemsTo: menu.
	^ menu
]

{ #category : 'private' }
JadeiteClassTrait >> packageListForSearchDialog: browserService [

	| packageServices |
	packageServices := browserService projects
		                   inject:
		                   (SortedCollection sortBlock: [ :x :y |
			                    x name < y name ])
		                   into: [ :coll :projectService |
			                   coll addAll: projectService packages.
			                   coll ].
	packageServices := packageServices asOrderedCollection.
	self currentPackage ifNotNil: [ :pkg | packageServices addFirst: pkg ].
	^ packageServices
]

{ #category : 'private' }
JadeiteClassTrait >> packageSearchDialogFor: packageServices [

	^ JadeiteSearchDialogWindow new
		  getList: [ :rxMatcher |
			  packageServices select: [ :thePackageService |
					  rxMatcher isString
						  ifTrue: [ rxMatcher , '*' match: thePackageService name ]
						  ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
							  rxMatcher matchesPrefix: thePackageService name ] ] ];
		  displayBlock: [ :e | e displayName ];
		  doubleClickOk;
		  title: 'Jadeite Find Package';
		  yourself
]
