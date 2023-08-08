Trait {
	#name : 'JadeiteClassTrait',
	#category : 'JadeiteToolsTraits'
}

{ #category : 'queries' }
JadeiteClassTrait >> basicBrowseClassReferences: className session: session [

	| service |
	service := RowanQueryService
		           command: #browseClassReferences:
		           withArgs: (Array with: className).
	BrowserUpdate current issueCommands: (Array with: service) session: session.
	^ service 
]

{ #category : 'queries' }
JadeiteClassTrait >> browseClassReferences [

	^ self browseClassReferences:
		  self selectedClassTab activePresenter selectedItem name
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

	| dialogWindow answeringService selection |
	answeringService := RowanAnsweringService new
		                    command: #allClassNames;
		                    commandArgs: Array new.
	BrowserUpdate current
		issueCommand: answeringService
		session: self gciSession.
	dialogWindow := ListDialogWindow new
		                getList: [ :rxMatcher | 
			                answeringService answer select: [ :substring | 
					                rxMatcher matchesPrefix: substring ] ];
		                displayBlock: [ :e | e ];
		                doubleClickOk;
		                title: 'Jadeite Find Class';
		                yourself.
	selection := dialogWindow chooseFromOwner: self currentWorld.
	selection ifNotNil: [ 
		| classService |
		classService := RowanClassService new name: selection.
		Cursor wait showWhile: [ 
			self activePresenter updateAfterFindClass: classService ] ]
]

{ #category : 'private' }
JadeiteClassTrait >> findPackage [

	| dialogWindow browserService selection packageServices |
	browserService := RowanBrowserService new
		                  command: #allPackages;
		                  commandArgs: Array new.
	BrowserUpdate current
		issueCommand: browserService
		session: self gciSession.
	packageServices := browserService projects
		                   inject: (SortedCollection sortBlock: [ :x :y | x name < y name ])
		                   into: [ :coll :projectService |
			                   coll addAll: projectService packages.
			                   coll ].
	dialogWindow := ListDialogWindow new
		                getList: [ :rxMatcher |
			                packageServices select: [ :packageService |
					                rxMatcher matchesPrefix: packageService name ] ];
		                displayBlock: [ :e | e name ];
		                doubleClickOk;
		                title: 'Jadeite Find Package';
		                yourself.
	selection := dialogWindow chooseFromOwner: self currentWorld.
	^ selection
]

{ #category : 'menus' }
JadeiteClassTrait >> initializeClassMenu [

	self classListPresenter contextMenu: self newClassMenu.
	self classHierarchyPresenter ifNotNil: [:presenter | presenter contextMenu: self newClassMenu]
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
	BrowserUpdate current issueCommand: self selectedClass session: self gciSession.
	self updateAfterFindClassInPackage: self selectedClass
]

{ #category : 'menus' }
JadeiteClassTrait >> newClassMenu [

	^ SpMenuPresenter new
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Browse References';
						  action: [ self browseClassReferences ];
						  enabled: [ self isClassSelected ] ];
				  addItem: [ :item |
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
		  yourself
]
