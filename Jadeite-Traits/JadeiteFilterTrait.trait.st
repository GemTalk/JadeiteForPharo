Trait {
	#name : 'JadeiteFilterTrait',
	#category : 'Jadeite-Traits'
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
JadeiteFilterTrait >> basicRemoveMethodCategories [

	| minusExtensions service |
	minusExtensions := self categoryListPresenter selectedItems reject: [
		                   :jadeiteCategory | jadeiteCategory isComputed ].
	service := self selectedClass
		           command: #removeCategories:;
		           commandArgs:
			           (Array with:
					            (minusExtensions collect: [ :ea | ea categoryName ])).
	self issueCommand: service onCompletion: nil
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

	| service shell |
	instVarName ifNil: [ ^ nil ].
	service := RowanQueryService
		           command: #instVarReaders:in:
		           withArgs: (Array with: instVarName with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: nil.
	shell := self
		         openMethodListOn: service
		         selectingAnyMatch: instVarName
		         session: session.
	shell updateCaptionFromSearchString:
		'Instance Variable Readers For ' , instVarName asString printString.
	^ shell
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarWriters [

	self
		browseInstVarWriters: self variableListPresenter selectedItem
		in: self selectedClassName
		session: self gciSession
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseInstVarWriters: instVarName in: className session: session [

	| service shell |
	instVarName ifNil: [ ^ nil ].
	service := RowanQueryService
		           command: #instVarWriters:in:
		           withArgs: (Array with: instVarName with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: nil.
	shell := self
		         openMethodListOn: service
		         selectingAnyMatch: instVarName
		         session: session.
	shell updateCaptionFromSearchString:
		'Instance Variable Writers For ' , instVarName asString printString
]

{ #category : 'actions' }
JadeiteFilterTrait >> browseSelectedCategoryMethods [
	"convenience menu item to display random methods in selected categories in a browser"

	| browser |
	self categoryListPresenter selectedItem ifNil: [
		^ MessageBox notify: 'No category selected' ].
	self methodListPresenter list isEmpty ifTrue: [
		^ MessageBox notify: 'No methods in category' ].
	self methodListPresenter list last serviceCompletionBlock: [
		browser := (JadeiteMethodListApplication showOnSession:
			            self gciSession library) methods:
			           self methodListPresenter list.
		browser caption: 'Selected Methods in Categories - '
			, (self categoryListPresenter selectedItems collect: [ :ea |
					 ea categoryName ]) asArray printString ].
	self updateServices: self methodListPresenter list asArray
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
	service := self selectedClass.
	UIManager default defer: [
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
				onCompletion: nil ] ]
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

{ #category : 'testing' }
JadeiteFilterTrait >> isVariableSelected [

	^self variableListPresenter selections size = 1
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
					  name: 'File out categories ...';
					  action: [ self fileoutCategories ];
					  enabled: [
						  self isClassSelected and: [ self isCategorySelected ] ] ] ];
		  yourself
]

{ #category : 'menus' }
JadeiteFilterTrait >> newVariableMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Add Accessors';
						  action: [ self addVariableAccessors ];
						  enabled: [ self isVariableSelected ] ] ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Browse Inst Var Readers';
						  action: [ self browseInstVarReaders ];
						  enabled: [ self isVariableSelected ] ];
				  addItem: [ :item |
					  item
						  name: 'Browse Inst Var Writers';
						  action: [ self browseInstVarWriters ];
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
