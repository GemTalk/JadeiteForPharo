Trait {
	#name : 'JadeiteClassTrait',
	#category : 'Jadeite-Traits'
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
					enabled: [ self isClassSelected ] ] ]
]

{ #category : 'queries' }
JadeiteClassTrait >> basicBrowseClassReferences: className session: session [

	| service |
	service := RowanQueryService
		           command: #browseClassReferences:
		           withArgs: (Array with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: session
		onCompletion: nil.
	^ service
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClass [

	| browser |
	browser := self openBrowser.
	^ Cursor wait showWhile: [
		  browser activePresenter
			  updateAfterFindClass: self selectedClass
			  onCompletion: nil ]
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClassReferences [

	| presenter |
	presenter := self isClassHierarchyTabSelected
		             ifTrue: [ self classHierarchyPresenter ]
		             ifFalse: [ self classListPresenter ].
	^ self browseClassReferences: presenter selectedItem name
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClassReferences: className [

	| service shell |
	service := self
		           basicBrowseClassReferences: className
		           session: self gciSession.
	shell := self openMethodListOn: service selecting: className.
shell updateCaptionFromSearchString:
		'Class References to ' , className asString.

	^ shell
]

{ #category : 'private' }
JadeiteClassTrait >> findClass [

	| selection |
	selection := self openClassSelectionDialogFor: 'Class'.
	selection ifNotNil: [ self findClassNamed: selection ]
]

{ #category : 'private' }
JadeiteClassTrait >> findClassNamed: selection [

	| classService |
	classService := RowanClassService new name: selection.
	^ Cursor wait showWhile: [
		  self activePresenter
			  updateAfterFindClass: classService
			  onCompletion: nil ]
]

{ #category : 'private' }
JadeiteClassTrait >> findClassReferences [

	| selection |
	selection := self openClassSelectionDialogFor: 'Class References'.
	selection ifNotNil: [ self browseClassReferences: selection ]
]

{ #category : 'private' }
JadeiteClassTrait >> findPackage [

	| dialogWindow browserService selection packageServices |
	browserService := RowanBrowserService new
		                  command: #allPackages;
		                  commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: browserService
		session: self gciSession.
	packageServices := browserService projects
		                   inject:
		                   (SortedCollection sortBlock: [ :x :y |
			                    x name < y name ])
		                   into: [ :coll :projectService |
			                   coll addAll: projectService packages.
			                   coll ].
	dialogWindow := ListDialogWindow new
		                getList: [ :rxMatcher |
			                packageServices select: [ :packageService |
					                rxMatcher isString
						                ifTrue: [ rxMatcher , '*' match: packageService name ]
						                ifFalse: [ rxMatcher matchesPrefix: packageService name ] "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher" ] ];
		                displayBlock: [ :e | e name ];
		                doubleClickOk;
		                title: 'Jadeite Find Package';
		                yourself.
	selection := dialogWindow chooseFromOwner: self currentWorld.
	^ selection
]

{ #category : 'menus' }
JadeiteClassTrait >> initializeBrowseClassMenu [

	self classListPresenter contextMenu: self newBrowseClassMenu.
	self classHierarchyPresenter ifNotNil: [:presenter | presenter contextMenu: self newBrowseClassMenu]
]

{ #category : 'menus' }
JadeiteClassTrait >> initializeFullClassMenu [

	self classListPresenter contextMenu: self newFullClassMenu.
	self classHierarchyPresenter ifNotNil: [:presenter | presenter contextMenu: self newFullClassMenu]
]

{ #category : 'menus' }
JadeiteClassTrait >> isClassSelected [

	^ self selectedClassTab
		  ifNil: [ false ]
		  ifNotNil: [ :tab | tab activePresenter selectedItem notNil ]
]

{ #category : 'actions' }
JadeiteClassTrait >> moveClassToPackage [
	| packageService |
	packageService := self findPackage.
	packageService ifNil: [^self].
	self moveClassToPackageNamed: packageService name
]

{ #category : 'actions' }
JadeiteClassTrait >> moveClassToPackageNamed: packageName [
	self selectedClass ifNil: [^self].
	self selectedClass
		command: #moveToPackageNamed:;
		commandArgs: (Array with: packageName).
	RowanServiceUpdater current issueCommand: self selectedClass session: self gciSession.
	self updateAfterFindClassInPackage: self selectedClass
]

{ #category : 'menus' }
JadeiteClassTrait >> newBrowseClassMenu [

	^ JadeiteMenuPresenter new addGroup: [ :group |
		  group
			  addItem: [ :item |
				  item
					  name: 'Browse Class';
					  action: [ self browseClass ] ];
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
JadeiteClassTrait >> openClassSelectionDialogFor: searchName [ 

	| dialogWindow answeringService sem |
	sem := Semaphore new. 
	[answeringService := RowanAnsweringService new
		                    command: #allClassNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: nil. sem signal] schedule. 
	sem wait. 
	dialogWindow := ListDialogWindow new
		                getList: [ :rxMatcher |
			                answeringService answer select: [ :substring |
					                rxMatcher isString
						                ifTrue: [ rxMatcher , '*' match: substring ]
						                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
							                rxMatcher matchesPrefix: substring ] ] ];
		                displayBlock: [ :e | e ];
		                doubleClickOk;
		                title: 'Jadeite Regex Find ' , searchName;
		                yourself.
	^dialogWindow chooseFromOwner: self currentWorld.
	
]
