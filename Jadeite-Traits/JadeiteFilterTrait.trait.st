Trait {
	#name : 'JadeiteFilterTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'actions' }
JadeiteFilterTrait >> addMethodCategory [

	| string |
	(string := Prompter prompt: 'New method category?') isNil ifTrue: [ 
		^ self ].
	string trimBoth isEmpty ifTrue: [ 
		^ MessageBox notify: 'Category name must not be blank' ].
	self basicAddMethodCategory: string
]

{ #category : 'actions' }
JadeiteFilterTrait >> basicRemoveInstVarNamed: instVars [

	| refs |
	refs := self instVarReferences: instVars.
	refs notEmpty
		ifTrue: [
			| shell |
			(shell := JadeiteMethodListApplication showOnSession:
				          self gciSession library)
				methods: refs
				selectingAnyMatch: instVars.
			shell updateCaptionFromSearchString:
				'Instance Variable References for ' , '''' , instVars printString
				, ''''.
			UIManager default alert:
				'Selected instance var has references. Instance variable not removed.' ]
		ifFalse: [
			self selectedClass
				command: #removeInstVars:;
				commandArgs: (Array with: instVars).
			RowanServiceUpdater current
				issueCommand: self selectedClass
				session: self gciSession
				onCompletion: [ "pretty up display"
					RowanServiceUpdater current critical: [
						| index |
						index := self classListPresenter selection selectedIndex.
						self packageListPresenter selectItem:
							self packageListPresenter selectedItem.
						self classListPresenter selection selectIndex: index.
						self selectClassDefinitionTab.
						self selectVariableTab ] ] ]
]

{ #category : 'actions' }
JadeiteFilterTrait >> basicRemoveMethodCategories [

	| minusExtensions service |
	minusExtensions := self categoryListPresenter selectedItems reject: [
		                   :jadeiteCategory | jadeiteCategory isComputed ].
	service := self selectedClass
		           command: #removeCategories:;
		           commandArgs:
			           (Array with:
					            (minusExtensions collect: [ :ea | ea categoryName ])).
	self issueCommand: service onCompletion: [  ]
]

{ #category : 'actions' }
JadeiteFilterTrait >> basicRenameCategoryFrom: old to: new [

	| service |
	new isEmpty ifTrue: [
		^ MessageBox notify: 'New category name cannot be blank' ].
	service := self selectedClass
		           command: #renameCategoryFrom:to:;
		           commandArgs: (Array with: old with: new).
	self issueCommand: service onCompletion: [ 
		self categoryListPresenter unselectAll.
		self categoryListPresenter selectItem: new ]
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarReaders [

	^ self
		  browseInstVarReaders: self variableListPresenter selectedItem
		  in: self selectedClassName
		  session: self gciSession
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarReaders: instVarName in: className session: session [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"

	| service shell |
	instVarName ifNil: [ ^ nil ].
	service := RowanQueryService
		           command: #instVarReaders:in:
		           withArgs: (Array with: instVarName with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self
				         openMethodListOn: service
				         selectingAnyMatch: instVarName
				         session: session.
			shell updateCaptionFromSearchString:
				'Instance Variable Readers For '
				, instVarName asString printString ].
	^ shell
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarReferences [

	^ self
		  browseInstVarReferences: self variableListPresenter selectedItem
		  in: self selectedClassName
		  session: self gciSession
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarReferences: instVarName in: className session: session [

	| shell refs |
	instVarName ifNil: [ ^ nil ].
	refs := self instVarReferences: (Array with: instVarName).
	(shell := JadeiteMethodListApplication showOnSession:
		          self gciSession library)
		methods: refs
		selectingAnyMatch: instVarName.
	shell updateCaptionFromSearchString:
		'Instance Variable References For '
		, instVarName asString printString.
	^ shell
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarWriters [

	^ self
		  browseInstVarWriters: self variableListPresenter selectedItem
		  in: self selectedClassName
		  session: self gciSession
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarWriters: instVarName in: className session: session [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"

	| service shell |
	instVarName ifNil: [ ^ nil ].
	service := RowanQueryService
		           command: #instVarWriters:in:
		           withArgs: (Array with: instVarName with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self
				         openMethodListOn: service
				         selectingAnyMatch: instVarName
				         session: session.
			shell updateCaptionFromSearchString:
				'Instance Variable Writers For '
				, instVarName asString printString ].
	^ shell
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseSelectedCategoryMethods [
	"convenience menu item to display random methods in selected categories in a browser"

	| browser |
	self categoryListPresenter selectedItem ifNil: [
		^ MessageBox notify: 'No category selected' ].
	self methodListPresenter list isEmpty ifTrue: [
		^ MessageBox notify: 'No methods in category' ].
	self
		updateServices: self methodListPresenter list asArray
		onCompletion: [
			browser := (JadeiteMethodListApplication showOnSession:
				            self gciSession library) methods:
				           self methodListPresenter list.
			browser caption: 'Selected Methods in Categories - '
				, (self categoryListPresenter selectedItems collect: [ :ea |
						 ea categoryName ]) asArray printString ]
]

{ #category : 'messages' }
JadeiteFilterTrait >> confirmCategoryRemoval: selections [
	| ws verbiage |
	ws := WriteStream on: String new.
	verbiage := self categoryListPresenter selections size = 1 ifTrue: ['category'] ifFalse: ['categories'].
	ws
		nextPutAll: 'Really delete method ';
		nextPutAll: verbiage;
		space.
	selections do: 
			[:category |
			ws
				nextPutAll: category categoryName;
				space].
	ws
		nextPutAll: 'and ';
		nextPutAll: self methodListPresenter list size printString;
		nextPutAll: ' methods?'.
	^(MessageBox confirm: ws contents) == true
]

{ #category : 'actions' }
JadeiteFilterTrait >> fileoutCategories [
	"append .gs to the file so it matches what rowan does for packages & projects"

	| service filePath categoryStrings |
	RowanServiceUpdater current critical: [
		service := self selectedClass.
		filePath := self fileoutFileSelection:
			            service name , '_categories.gs'.
		filePath ifNotNil: [
			categoryStrings := self categoryListPresenter selections collect: [
				                   :category | category categoryName ].
			service
				command: #fileoutCategories:on:;
				commandArgs: (Array with: categoryStrings with: filePath).
			RowanServiceUpdater current
				issueCommand: service
				session: self gciSession
				onCompletion: [  ] ] ]
]

{ #category : 'menus' }
JadeiteFilterTrait >> initializeCategoryListMenu [

	self categoryListPresenter  contextMenu: self newCategoryMenu
]

{ #category : 'menus' }
JadeiteFilterTrait >> initializePackageMethodListMenu [

	self packageMethodListPresenter contextMenu: SpMenuPresenter new
]

{ #category : 'menus' }
JadeiteFilterTrait >> initializeVariableListMenu [

	self variableListPresenter contextMenu: self newVariableMenu
]

{ #category : 'accessing' }
JadeiteFilterTrait >> instVarReferences: instVars [

	| service refs |
	refs := OrderedCollection new.
	RowanServiceUpdater current critical: [
		instVars do: [ :instVar |
			service := RowanQueryService
				           command: #instVarReaders:in:
				           withArgs:
				           (Array with: instVar with: self selectedClass name).
			RowanServiceUpdater current
				issueCommand: service
				session: self gciSession
				onCompletion: [ refs addAll: service queryResults ].
			service
				command: #instVarWriters:in:;
				commandArgs: (Array with: instVar with: self selectedClass name).
			RowanServiceUpdater current
				issueCommand: service
				session: self gciSession
				onCompletion: [ refs addAll: service queryResults ] ] ].
	refs := refs asSet asSortedCollection: [ :x :y |
		        x className <= y className ].
	^ refs
]

{ #category : 'testing' }
JadeiteFilterTrait >> isOneVariableSelected [

	^ self variableListPresenter selections size = 1
]

{ #category : 'testing' }
JadeiteFilterTrait >> isVariableSelected [

	^ self variableListPresenter selections notEmpty
]

{ #category : 'menus' }
JadeiteFilterTrait >> newCategoryMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Add';
						  action: [ self addMethodCategory ];
						  enabled: [ self isClassSelected ] ];
				  addItem: [ :item |
					  item
						  name: 'Rename';
						  action: [ self renameMethodCategory ];
						  enabled: [ self categoryListPresenter selections size = 1 ] ];
				  addItem: [ :item |
					  item
						  name: 'Remove';
						  action: [ self removeMethodCategories ];
						  enabled: [ self categoryListPresenter selections size = 1 ] ] ];
		  addGroup: [ :group |
			  group addItem: [ :item |
				  item
					  name: 'Browse category methods';
					  action: [ self browseSelectedCategoryMethods ];
					  enabled: [
						  self isClassSelected and: [ self isCategorySelected ] ] ] ];
		  addGroup: [ :group |
			  group addItem: [ :item |
				  item
					  name: 'File out selected categories ...';
					  action: [ self fileoutCategories ];
					  enabled: [
						  self isClassSelected and: [ self isCategorySelected ] ] ] ];
		  yourself
]

{ #category : 'menus' }
JadeiteFilterTrait >> newVariableMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Add Accessors';
						  action: [ self addVariableAccessors ];
						  enabled: [ self isVariableSelected ] ];
				  addItem: [ :item |
					  item
						  name: 'Add All Missing Accessors';
						  action: [ self addMissingAccessors ];
						  enabled: [ self selectedClass notNil ] ] ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Browse Inst Var References';
						  action: [ self browseInstVarReferences ];
						  enabled: [ self isOneVariableSelected ] ];
				  addItem: [ :item |
					  item
						  name: 'Browse Inst Var Readers';
						  action: [ self browseInstVarReaders ];
						  enabled: [ self isOneVariableSelected ] ];
				  addItem: [ :item |
					  item
						  name: 'Browse Inst Var Writers';
						  action: [ self browseInstVarWriters ];
						  enabled: [ self isOneVariableSelected ] ] ];
		  addGroup: [ :group |
			  group addItem: [ :item |
				  item
					  name: 'Remove Inst Vars ...';
					  action: [ self removeInstVars ];
					  enabled: [ self isVariableSelected ] ] ];
		  yourself
]

{ #category : 'actions' }
JadeiteFilterTrait >> openMethodListOn: service selectingAnyMatch: string session: session [
	^JadeiteMethodListBrowser
		openOn: service
		selectingAnyMatch: string
		session: session
]

{ #category : 'actions' }
JadeiteFilterTrait >> removeInstVars [

	| instVars shouldRemove ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'Really remove instance variable'.
	instVars := self variableListPresenter selectedItems
		            asSortedCollection.
	instVars size > 1 ifTrue: [ ws nextPut: $s ].
	ws
		space;
		nextPut: $-;
		space.
	instVars do: [ :instVar |
		ws
			nextPutAll: instVar;
			space ].
	ws nextPut: $?.
	shouldRemove := UIManager default confirm: ws contents.
	shouldRemove ifFalse: [ ^ self ].
	self basicRemoveInstVarNamed: instVars asOrderedCollection
]

{ #category : 'actions' }
JadeiteFilterTrait >> removeMethodCategories [

	| selections |
	selections := self categoryListPresenter selections.
	selections do: [ :jadeiteCategory |
		jadeiteCategory isComputed ifTrue: [
			^ MessageBox notify: 'Cannot rename computed category' ] ].
	selections isEmpty ifTrue: [
		^ MessageBox notify: 'No categories selected' ].
	(self confirmCategoryRemoval: selections) ifFalse: [ ^ self ].
	self basicRemoveMethodCategories
]

{ #category : 'actions' }
JadeiteFilterTrait >> renameMethodCategory [

	| new current |
	current := self categoryListPresenter jaditeSelection.
	current isComputed ifTrue:[^MessageBox notify: 'Cannot rename computed category'].
	(new := Prompter
		        on: current
		        prompt: 'New method category?'
		        caption: 'Rename Category') isNil ifTrue: [ ^ self ].
	(self categoryListPresenter list includes: new) ifTrue: [ 
		^ MessageBox notify: 'category ' , new , ' already exists' ].
	self basicRenameCategoryFrom: current categoryName to: new
]
