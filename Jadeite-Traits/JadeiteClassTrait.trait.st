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
			group addItem: [ :item |
				item
					name: 'Move to Package ...';
					action: [ self moveClassToPackage ];
					enabled: [ self isClassSelected ] ] ];
		addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'File Out Class ...';
					action: [ self fileoutClass ];
					enabled: [ self isClassSelected ] ] ]
]

{ #category : 'queries' }
JadeiteClassTrait >> basicBrowseClassReferences: className session: session completionBlock: completionBlock [

	| service |
	service := RowanQueryService
		           command: #browseClassReferences:
		           withArgs: (Array with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: session
		onCompletion: completionBlock.
	^ service
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClass [

	| browser |
	browser := self openBrowser.
	Cursor wait showWhile: [
		  browser activePresenter
			  updateAfterFindClass: self selectedClass
			  onCompletion: nil ].
	^browser
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClassReferences [

	| presenter |
	presenter := self activePresenter isClassHierarchyTabSelected
		             ifTrue: [ self classHierarchyPresenter ]
		             ifFalse: [ self classListPresenter ].
	^ self browseClassReferences: presenter selectedItem className
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClassReferences: className [

	| shell |
	self
		basicBrowseClassReferences: className
		session: self gciSession
		completionBlock: [ :service |
			shell := self openMethodListOn: service selecting: className.
			shell updateCaptionFromSearchString:
				service queryResults size printString , ' Class References to '
				, className asString ]
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
			onCompletion: nil ]
]

{ #category : 'private' }
JadeiteClassTrait >> findClass [

	| selection answeringService |
	answeringService := RowanAnsweringService new
		                    command: #allClassNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			| classService |
			selection := self openClassSelectionDialogOn:
				             answeringService answer.
			selection ifNotNil: [
				classService := RowanClassService new
					                name: selection;
					                meta: false.
				self
					updateService: classService
					onCompletion: [ self findClassService: classService ] ] ]
]

{ #category : 'private' }
JadeiteClassTrait >> findClassNamed: selection [

	| classService |
	classService := RowanClassService new
		                name: selection;
		                meta: false.
	self
		updateService: classService
		onCompletion: [ self findClassService: classService ]
]

{ #category : 'private' }
JadeiteClassTrait >> findClassReferences [

	| selection answeringService |
	answeringService := RowanAnsweringService new
		                    command: #allClassNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			selection := self openClassSelectionDialogOn:
				             answeringService answer.
			selection ifNotNil: [ self browseClassReferences: selection ] ]
]

{ #category : 'private' }
JadeiteClassTrait >> findClassService: classService [

	classService ifNil: [ ^ self ].

	self activePresenter
		updateAfterFindClass: classService
		onCompletion: nil
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
			packageServices := browserService projects
				                   inject:
				                   (SortedCollection sortBlock: [ :x :y |
					                    x name < y name ])
				                   into: [ :coll :projectService |
					                   coll addAll: projectService packages.
					                   coll ].
			dialogWindow := ListDialogWindow new
				                getList: [ :rxMatcher |
					                packageServices select: [ :thePackageService |
							                rxMatcher isString
								                ifTrue: [
									                rxMatcher , '*' match: thePackageService name ]
								                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
									                rxMatcher matchesPrefix:
											                thePackageService name ] ] ];
				                displayBlock: [ :e | e name ];
				                doubleClickOk;
				                title: 'Jadeite Find Package';
				                yourself.
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
		session: self gciSession onCompletion: [self updateAfterFindClass: self selectedClass]
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
JadeiteClassTrait >> openClassSelectionDialogOn: classNames [

	| dialogWindow |
	dialogWindow := ListDialogWindow new
		                getList: [ :rxMatcher |
			                classNames select: [ :substring |
					                rxMatcher isString
						                ifTrue: [ rxMatcher , '*' match: substring ]
						                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
							                rxMatcher matchesPrefix: substring ] ] ];
		                displayBlock: [ :e | e ];
		                doubleClickOk;
		                title: 'Jadeite Regex Find ' , 'Class';
		                yourself.
	^ dialogWindow chooseFromOwner: self currentWorld
]
