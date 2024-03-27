Class {
	#name : 'JadeSystemBrowserPresenter',
	#superclass : 'JadeBrowserPresenter',
	#instVars : [
		'ancestorListPresenter',
		'breakPoints',
		'categoryListPresenter',
		'classCategoryPresenter',
		'classCommentPresenter',
		'classDefinition',
		'classDefinitionPresenter',
		'classHierarchyPresenter',
		'classHierarchyTabs',
		'classListPresenter',
		'dictionaryListPresenter',
		'environment',
		'eventCount',
		'globalsPresenter',
		'globalsLabel',
		'historyList',
		'historyIndex',
		'ignoreNextSetFocusEvent',
		'inUpdate',
		'keystrokeTime',
		'methodCategory',
		'methodFilterTabs',
		'methodListPresenter',
		'methodSource',
		'methodSourcePresenter',
		'originalSourceLabel',
		'originalSourcePresenter',
		'overrideListPresenter',
		'packageDictionaryTabs',
		'packageInfoTab',
		'packageLabel',
		'packageListPresenter',
		'pragmaListPresenter',
		'readStream',
		'repositoryListPresenter',
		'selectedClassChanged',
		'selectedClassesAreTestCases',
		'selectedClassName',
		'selectedClassOop',
		'stepPoints',
		'sunitPresenter',
		'superclassListPresenter',
		'textAreaTabs',
		'unimplementedSelectors',
		'updateCount',
		'updateProcess',
		'variableListPresenter',
		'classListHierarchyTabs'
	],
	#category : 'Jadeite-Browser'
}

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> aboutToChange: aSelectionChangingEvent [
	aSelectionChangingEvent value ifTrue: [
		aSelectionChangingEvent value: self isOkayToChange.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> aboutToEditClassLabel: oldName accept: aValueHolder [

	aValueHolder value: true.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> addClassCategoryInfoTo: aStream [

	| category |
	category := (classCategoryPresenter selectionIfNone: [#() -> nil]) key.
	category isEmpty ifTrue: [category := #('')].
	category do: [:each | 
		aStream nextPutAll: each; nextPut: $-.
	].
	aStream lf.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> addClassHierarchyInfoTo: aStream [

	| selections |
	aStream nextPutAll: classHierarchyTabs currentCard name; lf.
	self isClassListTabSelected ifTrue: [
		(selections := classListPresenter selections) isEmpty ifTrue: [
			selections := Array with: self selectedClassNameWithoutVersion.
		].
	] ifFalse: [
		selections := Array with: (classHierarchyPresenter selectionIfNone: [Array with: self selectedClassNameWithoutVersion]) last.
	].
	selections do: [:each | aStream nextPutAll: each; tab].
	aStream lf.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> addMethodInfoTo: aStream [

	| string |
	selectedClassChanged ifTrue: [
		aStream 
			nextPutAll: classListHierarchyTabs currentCard name; lf;
			lf;	"superclassList selection"
			nextPutAll: 'categoryList'; tab;
			lf;	"method filter selections"
			lf; "overrideList selection"
			yourself.
		^self.
	].
	string := superclassListPresenter selectionIfNone: [''].
	aStream 
		nextPutAll: classListHierarchyTabs currentCard name; lf;		"instanceTab or classTab"
		nextPutAll: string; lf;								"selected superclass"
		nextPutAll: methodFilterTabs currentCard name; tab;		"categoryList or variableList or pragmaList"
		lf.
	self methodFilterListPresenter selections do: [:each | aStream nextPutAll: each trimBlanks; tab].
	aStream lf.
	methodListPresenter selections do: [:each | aStream nextPutAll: each first; tab].
	string := overrideListPresenter selectionIfNone: [''].
	(string includes: Character space) ifTrue: [string := string subStrings first].
	aStream 
		lf;
		nextPutAll: string; lf;
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> addMissingAccessors [

	| string |
	string := 'addMissingAccessors' , Character tab asString , self behaviorIdentifier , Character lf asString , self requestString.
	self updateCommand: string.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> addPackageDictionaryInfoTo: aStream [

	| tabName |
	tabName := packageDictionaryTabs currentCard name.
	aStream nextPutAll: tabName; lf.
	tabName = 'packageList' ifTrue: [
		packageListPresenter selections do: [:each | aStream nextPutAll: each key; tab].
	] ifFalse: [
		dictionaryListPresenter selections do: [:each | aStream nextPutAll: each key; tab].
	].
	aStream lf.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> addRepository [

	| string list selection stream |
	string := self gciSession serverPerform: #'mcRepositoryList'.
	list := (string subStrings: Character lf) reject: [:each | each isEmpty].
	list := list collect: [:each | (each subStrings: Character tab) at: 2].
	list := list asSortedCollection.
	selection := ChoicePrompter 
		choices: list 
		caption: 'Select Repository'.
	selection isNil ifTrue: [^self].
	stream := (WriteStream on: String new)
		nextPutAll: 'addRepository'; tab;
		nextPutAll: selection;
		yourself.
	packageListPresenter selections do: [:each | stream tab; nextPutAll: each key].
	stream lf.
	self updateCommand: stream contents , self requestString.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> behaviorIdentifier [

	^(WriteStream on: String new)
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: classListHierarchyTabs currentCard name;
		contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> breakAt: anInteger operation: aString [

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'break'; tab;
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: classListHierarchyTabs currentCard name; tab;
		nextPutAll: methodListPresenter selection first; tab;
		nextPutAll: anInteger printString; tab;
		nextPutAll: aString; tab;
		lf.
	self updateCommand: stream contents , self requestString.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> browseGlobalReferences [

	| string |
	string := 'browseGlobalReferences' , Character tab asString , (globalsPresenter selection at: 5) , Character lf asString.
	(string := self updateCommand: string) = 'browseGlobalReferences' ifFalse: [self error: 'unrecognized response'].
	self browseMethodsAndSelect: (globalsPresenter selection at: 1).

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> browseMethodPragmas [

	| commandString keyword keywords responseString |
	responseString:= self updateCommand: 'listMethodPragmas'.
	keywords := responseString subStrings: Character tab.
	(keyword := ChoicePrompter choices: keywords) ifNil: [^self].
	commandString := 'browseMethodsWithPragma' , Character tab asString , keyword , Character lf asString.
	responseString := self updateCommand: commandString.
	responseString = 'browseMethodsWithPragma' ifFalse: [self error: 'unexpected response'].
	self browseMethodsAndSelect: keyword.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> browseSelectedClass [

	| range string list assoc |
	range := methodSourcePresenter view selectionRange.
	string := methodSourcePresenter value copyFrom: range start to: range stop.
	list := self findClassList.
	assoc := list 
		detect: [:each | each key = string]
		ifNone: [^MessageBox warning: 'Class ' , string printString , ' not found!' caption: 'Jade'].
	parentPresenter parentPresenter addSystemBrowserForClass: assoc value.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> categoriesMenuStrings [

	false ifTrue: [
		self addMethodCategory; removeMethodCategories.
	].
	^#(
		'&Categories'
		'&Add Method Category//addMethodCategory'
		'&Remove Method Categories//removeMethodCategories'
	).

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> categoryListPresenter [

	^categoryListPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> classCategoryPresenter [

	^classCategoryPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> classHierarchyPresenter [

	^classHierarchyPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> classHierarchyTabs [
	"for tests" 
	^classHierarchyTabs
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> classListPresenter [

	^classListPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> clearPackageInfo [

	ancestorListPresenter list: #().
	repositoryListPresenter list: #().


]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> closeRequested: anAssociation [

	anAssociation value ifTrue: [
		anAssociation value: self isOkayToChange.
	].


]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> compareAncestor [

	| repository stream patch |
	repository := repositoryListPresenter hasSelection 
		ifTrue: [repositoryListPresenter selection]
		ifFalse: [repositoryListPresenter list first].
	stream := (WriteStream on: String new)
		nextPutAll: 'comparePackages'; tab;
		nextPutAll: packageListPresenter selections first key; tab;
		nextPutAll: (ancestorListPresenter selections first at: 2); tab;
		nextPutAll: (repository at: 2); tab;
		lf.
	(self updateCommand: stream contents) = 'comparePackages' ifFalse: [self error: 'Unexpected response!'].
	patch := MCPatch
		fromString: readStream upToEnd
		session: self gciSession.
	patch operations isEmpty ifTrue: [
		MessageBox notify: 'No changes!'.
		^self.
	].
	MCPatchBrowser showOn: patch.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> contextObject [
	^gciSession oopNil value
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> createSchematicWiringForMethodSource [

	methodSourcePresenter 	
		when: #'hoverStart:'				send: #'methodHoverStart:'	to: self;
		when: #'hoverEnd:'				send: #'methodHoverEnd:'		to: self;
		when: #'aboutToDisplayMenu:'		send: #'methodMenu:'		to: self;
		when: #'leftButtonDoubleClicked:'	send: #'methodDoubleClicked:'	to: self;
		when: #'focusLost'				send: #'cancelCallTip'			to: methodSourcePresenter view;
		yourself.
	
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> currentSelectionOrLine [

	View focus hasSelection ifFalse: [View focus selectCurrentLine].
	^View focus selection replaceCrLfWithLf.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> defaultFileExtension [

	^'gs'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> delayUpdate [
	"Sent by various key-press events. If someone is typing in a list, the list will update
	to the letters typed. If someone is typing several keys in in a row, we don't want to
	go to the server for every keystroke."

	keystrokeTime := Time millisecondClockValue + 500.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> deletePackage [
	"renamed from unloadPackage for semantical differences with Monticello"
	| packageName |
	packageName := packageListPresenter selections first key.
	(MessageBox confirm: 'Do you want to unload ''' , packageName , '''?' caption: 'Confirm Unload')
		ifFalse: [^self].
	self updateCommand: 'unloadPackage' , Character tab asString , packageName , Character lf asString
				, self requestString
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> dictionaryListPresenter [

	^dictionaryListPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> dictsMenuStrings [

	false ifTrue: [
		self browseDictionaryReferences; fileOutDictionary; findClass; insertDictionary; removeDictionary; setHomeDictionary; fileInCode.
	].
	^#(
		'&Dictionaries'
		'&Browse References//browseDictionaryReferences'
		'&File Out Dictionary//fileOutDictionary'
		'File In Code//fileInCode'
		'&Find Class/Ctrl+Shift+F/findClass'
		'&Insert Dictionary//insertDictionary'
		'&Remove Dictionary//removeDictionary'
		'&Set Home Dictionary//setHomeDictionary'
	).

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editCopy [

	View focus copySelection.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editCut [

	View focus cutSelection.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editFind [
	textAreaTabs currentCard setFocus; editFind.
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editFindNext [
	textAreaTabs currentCard setFocus; editFind.
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editMenuStrings [

	false ifTrue: [
		self editSave; editUndo; editRevert; editRedo; editCut; editCopy; editPaste; editSelectAll; editFind; editFindNext; editReplace; 
			jadeDisplay; jadeExecute; jadeInspect; browseSelectedClass.
	].
	^#(
		'&Edit'
		'&Save/Ctrl+S/editSave'
		'-'
		'&Undo/Ctrl+Z/editUndo'
		'&Redo/Ctrl+Y/editRedo'
		'&Revert//editRevert'
		'-'
		'&Reformat Source/Ctrl+Shift+O/reformatSource'
		'-'
		'&Cu&t/Ctrl+X/editCut'
		'&Copy/Ctrl+C/editCopy'
		'&Paste/Ctrl+V/editPaste'
		'-'
		'Select &All/Ctrl+A/editSelectAll'
		'-'
		'&Find/Ctrl+F/editFind'
		'Find &Next/F3/editFindNext'
		'&Replace/Ctrl+H/editReplace'
		'-'
		'Debug/Ctrl+B/jadeDebug'
		'Display/Ctrl+D/jadeDisplay'
		'Execute/Ctrl+E/jadeExecute'
		'Inspect/Ctrl+Q/jadeInspect'
		'Browse Class//browseSelectedClass'
	).

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editPaste [

	View focus 
		pasteClipboard;
		updateModel;
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editRedo [

	View focus redo.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editReplace [

	View focus findReplace.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editSaveClassA [

	"Removed the class migration dialog and just pass default answers.
	Rowan will then ignore them." 
	| stream answer |
	(selectedClassName includes: Character space) ifFalse: [^self].		"This is a check to see if an earlier version exists"
	"(dict := JadeMigrateClassDialog showModal) isNil ifTrue: [^self revertNewClass].  Commented out for Jadeite
	(dict allSatisfy: [:each | each not]) ifTrue: [^self]."
	(stream := WriteStream on: String new)
		nextPutAll: 'postSaveClass'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		yourself.
	true printOn: stream. 			stream tab.	"copyMethods"
	true printOn: stream. 			stream tab.	"recompileSubclasses"
	true printOn: stream. 			stream tab.	"migrateInstances"
	true printOn: stream. 	stream lf.				"removeFromClassHistory"
	(answer := self updateCommand: stream contents , self requestString) isNil ifTrue: [^self].
	[
		answer = 'compileError'.
	] whileTrue: [
		(JadeiteWorkspace showOnSession: self gciSession)
			caption: 'Jade Workspace - Compile errors found when compiling class';
			showText: readStream nextParagraph.
		answer := readStream nextLine.
	].
	answer = 'update' ifFalse: [self error: 'Unexpected token'].
	self updatePresenters.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editSelectAll [

	View focus selectAll.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> editUndo [

	View focus undo.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> fileOutDictionary [

	| dictionaryName path string file index |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	dictionaryName :=  dictionaryListPresenter selection key.
	path := FileSaveDialog new
		caption: 'File Out ' , dictionaryName;
		fileTypes: self fileTypes;
		defaultExtension: self defaultFileExtension;
		value: dictionaryName , '.gs';
		overwritePrompt;
		showModal.
	path isNil ifTrue: [^self].
	string := environment printString , ' fileOutDictionary' , Character tab asString , dictionaryName.
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: string.
	index := string indexOf: Character lf.
	file := FileStream write: path.
	[
		file nextPutAll: (string copyFrom: index + 1 to: string size).
	] ensure: [
		file close.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> fileOutMethod [

	| name path myReadStream writeStream |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	name := self selectedClassNameWithoutVersion.
	self isClassSideSelected ifTrue: [name := name , '-class'].
	name := name , '-' , self selectedMethodName.
	name := name copyReplaceAll: ':' with: '_'.
	myReadStream := ReadStream on: name.
	writeStream := WriteStream on: String new.
	[myReadStream atEnd not] whileTrue: [
		| each |
		each := myReadStream next.
		(each isAlphaNumeric or: [each == $_ or: [each == $-]]) ifTrue: [
			writeStream nextPut: each.
		] ifFalse: [
			writeStream
				nextPut: $-;
				print: each codePoint;
				nextPut: $-;
				yourself.
		].
	].
	name := writeStream contents.
	path := FileSaveDialog new
		caption: 'File Out Method';
		fileTypes: self fileTypes;
		defaultExtension: self defaultFileExtension;
		value: name;
		overwritePrompt;
		showModal.
	path ifNotNil: [:value | self fileOutMethodOnPath: value].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> fileOutMethodOnPath: aString [

	| header file newSource index |
	newSource := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' fileOutMethod' , Character tab asString , self behaviorIdentifier , Character tab asString , self selectedMethodName.
	index := newSource indexOf: Character lf.
	newSource := newSource copyFrom: index + 1 to: newSource size.
	header := self stuffToKeepFromPath: aString andAddTo: newSource.
	file := FileStream write: aString.
	[
		file nextPutAll: header; nextPutAll: newSource.
	] ensure: [
		file close.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> fileTypes [

	^Array
		with: #('GemStone Files (*.gs)' '*.gs')
		with: #('Smalltalk Files (*.st)' '*.st')
		with: FileDialog allFilesType.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> findClassList [
"
	Array with: className with: dictionaryName with: catetory with: packageName.
"
	| string list | 
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' findClass'.
	list := (string subStrings: Character lf) collect: [:each | each subStrings: Character tab].
	list := list copyFrom: 2 to: list size.
	list := list collect: [:each | each size < 3 ifTrue: [each , #('' '' '')] ifFalse: [each]].
	list := list collect: [:each | (each at: 1) -> each].
	^list

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> getSelectedMethod [
	| dataArray |

	dataArray := self methodListPresenter selectionOrNil.
	dataArray ifNil: [^nil].

	^dataArray first
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> getViews [

	packageDictionaryTabs 	:= self view viewNamed: 'packageDictionaryTabs'.
	classHierarchyTabs 		:= self view viewNamed: 'classHierarchyTabs'.
	classListHierarchyTabs		:= self view viewNamed: 'instanceClassTabs'.
	methodFilterTabs 		:= self view viewNamed: 'methodFilterTabs'.
	textAreaTabs			:= self view viewNamed: 'textAreaTabs'.
	packageInfoTab			:= self view viewNamed: 'packageInfo'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> globalsMenuStrings [

	false ifTrue: [
		self inspectGlobal; browseGlobalReferences; removeGlobals.
	].
	^#(
		'&Globals'
		'&Inspect//inspectGlobal'
		'&Browse References//browseGlobalReferences'
		'&Remove//removeGlobals'
	).

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> horizontalSplitter [

	^view 
		viewNamed: 'splitter' 
		ifNone: [self error: 'splitter is missing!?'].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> initialize [

	super initialize.
	environment := 0.
	historyIndex := 0.
	historyList := OrderedCollection new.
	ignoreNextSetFocusEvent := false.
	inUpdate := false.
	selectedClassName := ''.
	eventCount := 0.
	selectedClassChanged := false.
	selectedClassesAreTestCases := false.
	keystrokeTime := 0.
	updateCount := 0.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> insertDictionary [

	| newName currentName stream |
	(newName := Prompter prompt: 'New dictionary name?') isNil ifTrue: [^self].
	currentName := dictionaryListPresenter selections notEmpty
		ifTrue: [dictionaryListPresenter selections first key]
		ifFalse: [''].
	stream := (WriteStream on: String new)
		nextPutAll: 'addDictionary'; tab;
		nextPutAll: newName; tab;
		nextPutAll: currentName; tab;
		lf;
		nextPutAll: self requestString;
		yourself.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> inspectGlobal [

	| oopType |
	oopType := self gciSession oopTypeWithOop: (globalsPresenter selection at: 4) asNumber.
	(Smalltalk at: #'JadeInspector' ifAbsent: [^self]) showOn: oopType session: self gciSession.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isClassListTabSelected [
	classListHierarchyTabs currentCard ifNil: [ ^true ].
	^classListHierarchyTabs currentCard name = 'Class'.
	
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isClassSelectedInEditor [

	| range string |
	(range := methodSourcePresenter view selectionRange) isEmpty ifTrue: [^false].
	string := methodSourcePresenter value copyFrom: range start to: range stop.
	^(string allSatisfy: [:each | each isAlphaNumeric]) and: [string first isLetter and: [string first isUppercase]]

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isGlobalsTabSelected [

	^textAreaTabs currentCard name = 'globals'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isPackageListTabSelected [
	packageDictionaryTabs ifNil: [ ^false ]. 
	packageDictionaryTabs currentCard ifNil: [ ^false ].
	^packageDictionaryTabs currentCard name = 'Package'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isPragmasTabSelected [

	^methodFilterTabs currentCard name = 'pragmaList'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isTreeModel: treeModelA equivalentTo: treeModelB [

	| listA listB |
	listA := (treeModelA asBag collect: [:each | each key printString]) asSortedCollection asArray.
	listB := (treeModelB asBag collect: [:each | each key printString]) asSortedCollection asArray.
	^listA = listB.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> isVariablesTabSelected [	
	
	methodFilterTabs ifNil:[^true]. 
	^methodFilterTabs selectedPage title = 'Variable'

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> jadeDisplay [
	self jadeExecuteAndDisplay: true shouldDebug: false
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> jadeExecute [
	self jadeExecuteAndDisplay: false shouldDebug: false
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> labelOfClass: oldName changedTo: newName [

	| stream |
	oldName = self selectedClassNameWithoutVersion.
	stream := (WriteStream on: String new)
		nextPutAll: 'changeClassName'; tab;
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: newName; tab;
		lf; nextPutAll: self requestString;
		yourself.
	self selectedClassName: newName.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> labelOfClass: oldName editedTo: newName accept: aValueHolder [

	| stream string |
	oldName = self selectedClassNameWithoutVersion.
	stream := (WriteStream on: String new)
		nextPutAll: 'checkUniqueClassName'; tab;
		nextPutAll: oldName; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: newName; tab; lf;
		yourself.
	(string := self updateCommand: stream contents) notEmpty ifTrue: [
		MessageBox warning: string.
	] ifFalse: [
		aValueHolder value: true.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> layoutInfo [

	^OrderedCollection new
		add: self requestStringForUpdate;
		add: self horizontalSplitter position;
		add: environment;
		asArray.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> layoutInfo: anArray [
	environment := (anArray size < 3) ifTrue: [0] ifFalse: [anArray at: 3].
	view ensureVisible.
	anArray isNil ifTrue: [
		self updateAndSelect: nil.
		^self.
	].
	self 
		updateCommand: (anArray at: 1);
		updateMenuBar;
		yourself.
	methodListPresenter hasSelection ifTrue: [
		methodSourcePresenter ensureVisible.
	].
	[
		view layoutManager reposition: self horizontalSplitter to: (anArray at: 2).
		view layout.
	] postToInputQueue.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> loadLatestVersion [

	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'loadLatestVersion'.
	packageListPresenter selections do: [:each | stream tab; nextPutAll: each key].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodDoubleClicked: anObject [

	| range string |
	range := methodSourcePresenter view selectionRange.
	string := methodSourcePresenter value.
	string size = range stop ifTrue: [^self].
	(string at: range stop + 1) = $: ifFalse: [^self].
	range stop: range stop + 1.
	methodSourcePresenter view selectionRange: range.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodFilterListPresenter [

	| name |
	name := methodFilterTabs currentCard name.
	name = 'Category' ifTrue: [^categoryListPresenter].
	name = 'Variable' ifTrue: [^variableListPresenter].
	name = 'pragmaList' ifTrue: [^pragmaListPresenter].
	self error: 'Unrecognized method filter name'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodHoverEnd: anObject [

	methodSourcePresenter view cancelCallTip.
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodHoverStart: aPoint [

	| charIndex indicator |
	charIndex := methodSourcePresenter view charNearestPosition: aPoint.
	indicator := methodSourcePresenter view indicators
		detect: [:each | each range includes: charIndex]
		ifNone: [^self].
	methodSourcePresenter view 
		showCallTip: indicator tag
		at: charIndex.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodListPresenter [

	^methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodSourcePresenter [

	^methodSourcePresenter.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> methodsIdentifier [

	| stream |
	stream := (WriteStream on: String new)
		nextPutAll: self behaviorIdentifier;
		yourself.
	methodListPresenter selections do: [:each | stream tab; nextPutAll: each first].
	^stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragClassHierarchy: aSession [
	| className |
	className := classHierarchyPresenter selection last.
	^super onDragClass: aSession className: className
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragClassList: aSession [ 

	| list |
	list := classListPresenter selections collect: [:each | 
		(aSession newDragObject: each)
			format: #class data: each;
			yourself.
	].
	aSession 
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #move;
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragClassOrMethodOverPackageList: aSession [
	aSession
		supportedOperations: #(#move);
		operation: #move;
		yourself
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragClassesOverDictionary: aSession [ 

	(dictionaryListPresenter selections includes: aSession suggestedTarget) ifTrue: [^self].
	aSession
		supportedOperations: #(#'copy' #'move');
		operation: #'move';
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragCutClassHierarchy: aSession [ 

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragCutClassList: aSession [ 

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragCutMethod: aSession [ 

	"self halt."
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragMethodsOverClassHierarchy: aSession [

	aSession
		supportedOperations: #(#'copy' #'move');
		operation: #'copy';
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragMethodsOverClassList: aSession [

	aSession
		supportedOperations: #(#'copy' #'move');
		operation: #'copy';
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragOverClassCategory: aSession [ 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'class') ifFalse: [^self].
	aSession
		supportedOperations: #(#'move');
		operation: #'move';
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragOverClassHierarchy: aSession [ 

	aSession operation: nil.
	aSession dragObjects isEmpty 			ifTrue: [^self].
	aSession suggestedTarget isNil 			ifTrue: [^self].
	(aSession isFormatAvailable: #'class') 	ifTrue: [^self].
	(aSession isFormatAvailable: #'method')	ifTrue: [^self onDragMethodsOverClassHierarchy: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause.
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragOverClassList: aSession [ 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'class')			ifTrue: [^self].
	(aSession isFormatAvailable: #'method') 	ifTrue: [^self onDragMethodsOverClassList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragOverDictionary: aSession [ 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'class') 				ifTrue: [^self onDragClassesOverDictionary: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDragOverMethodCategory: aSession [ 
	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].

	(aSession isFormatAvailable: #'method') ifFalse: [^self].
	aSession
		supportedOperations: #(#'move');
		operation: #'move';
		yourself.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropClassesOnDictionary: aSession [ 

	| classNames stream |
	classNames := aSession dragObjects collect: [:each | each format: #'class'].
	stream := (WriteStream on: String new)
		nextPutAll: 'classesToDictionary'; tab;
		nextPutAll: aSession operation; tab;
		nextPutAll: aSession suggestedTarget key;
		lf.
	dictionaryListPresenter selections do: [:each | stream nextPutAll: each key; tab].
	stream lf.
	classNames do: [:each | stream nextPutAll: each; tab].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropMethodsOnClass: aString session: aSession [ 

	| selectors stream |
	selectors := aSession dragObjects collect: [:each | each format: #'method'].
	stream := (WriteStream on: String new)
		nextPutAll: 'methodClass'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		nextPutAll: aSession operation; tab;
		nextPutAll: aString;
		yourself.
	selectors do: [:each | stream tab; nextPutAll: each].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropMethodsOnClassHierarchy: aSession [
	self onDropMethodsOnClass: aSession suggestedTarget last session: aSession
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropMethodsOnClassList: aSession [
	self onDropMethodsOnClass: aSession suggestedTarget session: aSession
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropOnClassCategory: aSession [ 

	| classNames stream |
	classNames := aSession dragObjects collect: [:each | each format: #'class'].
	stream := (WriteStream on: String new)
		nextPutAll: 'classCategory'; tab;
		yourself.
	aSession suggestedTarget key do: [:each | stream nextPutAll: each; nextPut: $-].
	stream tab.
	classNames do: [:each | stream nextPutAll: each; space].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropOnClassHierarchy: aSession [ 

	(aSession isFormatAvailable: #'method') ifTrue: [^self onDropMethodsOnClassHierarchy: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropOnClassList: aSession [ 

	(aSession isFormatAvailable: #'method') ifTrue: [^self onDropMethodsOnClassList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropOnDictionary: aSession [ 

	(aSession isFormatAvailable: #'class') ifTrue: [^self onDropClassesOnDictionary: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onDropOnMethodCategory: aSession [ 

	| selectors stream |
	selectors := aSession dragObjects collect: [:each | each format: #'method'].
	stream := (WriteStream on: String new)
		nextPutAll: 'methodCategory'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		nextPutAll: aSession suggestedTarget trimBlanks;
		yourself.
	selectors do: [:each | stream tab; nextPutAll: each].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> onSetFocus: aView stack: aString [

	[
		| startTime activeView |
		startTime := TimeStamp current.
		(Delay forMilliseconds: 50) wait.
		aView ~~ (activeView := View active) ifTrue: [^self].		"If view changed then there is no point in updating it!"
		view = DeafObject current ifTrue: [^self].
		eventCount = gciSession eventCount ifTrue: [^self].
		super onSetFocus.
		[
			self updateAndSelect: nil.
		] on: Error do: [:ex | 
			SessionManager current logError: ex.
			ignoreNextSetFocusEvent := true.
			MessageBox 
				errorMsg: ex description
				caption: 'Jade Error'.
			Keyboard default isShiftDown ifTrue: [
				| stream |
				stream := WriteStream on: String new.
				ex printTraceOn: stream.
				(JadeiteWorkspace showOnSession: gciSession) showText: stream contents.
			].
		].
	] ensure: [
		updateProcess := nil.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> openSourceStyler [
	| textStyles |
	textStyles := methodSourcePresenter view editStyles textStyles.
	JadeiteTextStyles default textStyles: textStyles.
	classDefinitionPresenter view textStyles: textStyles.
	originalSourcePresenter view textStyles: textStyles.
	classCommentPresenter view textStyles: textStyles. 
	^textStyles
	
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> packageListPresenter [

	^packageListPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> parseContext [

	^nil
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> pkgDictChanged [

	| listModel | 
	listModel := (textAreaTabs subViews detect: [:each | each class == TabViewXP]) model.
	globalsLabel ifNil: [globalsLabel := listModel detect: [:each | each text = 'Globals']].
	packageLabel ifNil: [packageLabel := listModel detect: [:each | each text = 'Package']].
	self isPackageListTabSelected ifTrue: [
		(listModel includes: packageLabel) ifFalse: [listModel addFirst: packageLabel].
		packageInfoTab ensureVisible.
		listModel remove: globalsLabel ifAbsent: [].
		self updateAndSelect: packageInfoTab.
	] ifFalse: [
		(listModel includes: globalsLabel ) ifFalse: [listModel addFirst: globalsLabel].
		globalsPresenter ensureVisible.
		listModel remove: packageLabel ifAbsent: [].
		self updateAndSelect: globalsPresenter.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> promptForSelector [

	| string list stream |
	ignoreNextSetFocusEvent := true.
	(string := Prompter prompt: 'Enter selector:') isNil ifTrue: [^nil].
	((string includes: $:) and: [string includes: Character space]) ifTrue: [
		list := string subStrings: Character space.
		list := list select: [:each | each last = $:].
		stream := WriteStream on: String new.
		list do: [:each | stream nextPutAll: each].
		string := stream contents.
	].
	string := string reject: [:each | each = Character space].
	^string.
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> removeClass [

	| list stream result |
	list := self selectedClasses.
	stream := WriteStream on: String new.
	list do: [:each | stream nextPutAll: each; cr].
	result := MessageBox 
		confirm: stream contents 
		caption: 'Remove the following class(s)?'.
	result ifFalse: [^self].
	stream := WriteStream on: String new.
	stream nextPutAll: 'removeClasses'; lf.
	self addPackageDictionaryInfoTo: stream.
	list do: [:each | stream nextPutAll: each; tab].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.


]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> removeDictionary [

	| list stream result |
	list := dictionaryListPresenter selections collect: [:each | each key].
	stream := WriteStream on: String new.
	list do: [:each | stream nextPutAll: each; cr].
	result := MessageBox 
		confirm: stream contents 
		caption: 'Remove the following dictionary(s)?'.
	result ifFalse: [^self].
	stream := (WriteStream on: String new)
		nextPutAll: 'removeDictionaries'; tab;
		yourself.
	list do: [:each | 
		stream nextPutAll: each; tab.
	].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> removeGlobals [

	| stream |
	stream := (WriteStream on: String new)
		nextPutAll: 'removeGlobals'; lf;
		yourself.
	dictionaryListPresenter selections do: [:each | 
		stream nextPutAll: each key; tab.
	].
	stream lf.
	globalsPresenter selections do: [:each | 
		stream nextPutAll: each first; tab.
	].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> removePriorVersions [

	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'removePriorVersions'; lf.
	self addPackageDictionaryInfoTo: stream.
	self selectedClasses do: [:each | stream nextPutAll: each; tab].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> removeRepository [

	|stream |
	stream := (WriteStream on: String new)
		nextPutAll: 'removeRepository'; tab;
		nextPutAll: (repositoryListPresenter selection at: 2);
		yourself.
	packageListPresenter selections do: [:each | stream tab; nextPutAll: each key].
	stream lf.
	self updateCommand: stream contents , self requestString.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> requestString [

	| stream |
	stream := WriteStream on: String new.
	self
		addPackageDictionaryInfoTo: stream;
		addClassCategoryInfoTo: stream;
		addClassHierarchyInfoTo: stream;
		addMethodInfoTo: stream;
		yourself.
	^stream contents.
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> requestStringForUpdate [

	^'update' , Character lf asString , self requestString.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> resetColors [
	JadeiteTextStyles default resetColors
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> revertNewClass [

	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'revertClass'; lf.
	self addPackageDictionaryInfoTo: stream.
	stream nextPutAll: selectedClassName subStrings first.
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> selectClass: aString selector: methodString [
"
	Array with: className with: dictionaryName with: category with: packageName.
"
	| string list className isMeta array |
	updateProcess ifNotNil: [		"https://github.com/jgfoster/Jade/issues/109"
		updateProcess terminate.
		updateProcess := nil.
	].
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' findClass'.
	list := (string subStrings: Character lf) collect: [:each | each subStrings: Character tab].
	list := list copyFrom: 2 to: list size.
	list := list collect: [:each | each size < 3 ifTrue: [each , #('' '' '')] ifFalse: [each]].
	className := aString.
	(isMeta := className endsWith: ' class') ifTrue: [
		className := className copyFrom: 1 to: className size - 6.
	].
	array := list detect: [:each | each first subStrings first = className].
	self 
		updateAfterFindClass: array
		isMeta: isMeta 
		selector: methodString.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> selectedClassChanged: aBoolean [
		"We don't want the previous class' method filter to apply to new class"

	selectedClassChanged := aBoolean.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> selectedClassName [
	^self selectedClasses isEmpty ifTrue: [nil] ifFalse: [self selectedClasses first]
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> selectedClassName: aString [

	selectedClassName := aString.
	self updateTabLabel.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> selectedClassNameWithoutVersion [

	^(selectedClassName includes: Character space)
		ifTrue: [selectedClassName subStrings first]
		ifFalse: [selectedClassName].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> selectedClasses [

	| list |
	(list := classListPresenter selections) isEmpty ifTrue: [
		(list := classHierarchyPresenter selections) notEmpty ifTrue: [
			list := Array with: list last last.
		].
	].
	^list.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> setEnvironment0 [

	self setEnvironment: 0

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> setEnvironment1 [

	self setEnvironment: 1

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> setEnvironment2 [

	self setEnvironment: 2

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> setEnvironment: anInteger [

	environment := anInteger.
	self updateCommand: self requestStringForUpdate.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> setHomeDictionary [

	| string |
	string := 'setHomeDictionary' , Character tab asString , dictionaryListPresenter selection key , Character lf asString , self requestString.
	self updateCommand: string.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> setSearchPolicy [

	ancestorListPresenter 	view model searchPolicy: SearchPolicy equality.
	categoryListPresenter 	view model searchPolicy: SearchPolicy equality.
	classCategoryPresenter	view model searchPolicy: SearchPolicy equality.
	classHierarchyPresenter	view model searchPolicy: SearchPolicy equality.
	classListPresenter		view model searchPolicy: SearchPolicy equality.
	dictionaryListPresenter 	view model searchPolicy: SearchPolicy equality.
	globalsPresenter		view model searchPolicy: SearchPolicy equality.
	methodListPresenter		view model searchPolicy: SearchPolicy equality.
	overrideListPresenter	view model searchPolicy: SearchPolicy equality.
	packageListPresenter 	view model searchPolicy: SearchPolicy equality.
	pragmaListPresenter		view model searchPolicy: SearchPolicy equality.
	repositoryListPresenter	view model searchPolicy: SearchPolicy equality.
	superclassListPresenter	view model searchPolicy: SearchPolicy equality.
	variableListPresenter	 	view model searchPolicy: SearchPolicy equality.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> showPackageChanges [

	| repository stream patch |
	repository := repositoryListPresenter hasSelection 
		ifTrue: [repositoryListPresenter selection]
		ifFalse: [repositoryListPresenter list first].
	stream := (WriteStream on: String new)
		nextPutAll: 'changesInPackage'; tab;
		nextPutAll: packageListPresenter selections first key; tab;	"package name"
		nextPutAll: (repository at: 2); tab;		"repository name"
		lf.
	(self updateCommand: stream contents) = 'changesInPackage' ifFalse: [self error: 'Unexpected response!'].
	patch := MCPatch
		fromString: readStream upToEnd
		session: self gciSession.
	patch operations isEmpty ifTrue: [
		MessageBox notify: 'No changes!'.
		^self.
	].
	MCPatchBrowser showOn: patch.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> splitterPosition: aPoint [

	[
		| splitter |
		splitter := view viewNamed: 'splitter' ifNone: [self error: 'splitter is missing!?'].
		view layoutManager reposition: splitter to: aPoint.
		view layout.
	] postToInputQueue.


]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> statusBarServerRequestText: aString [

	self parentPresenter parentPresenter statusBarServerRequestText: aString.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> stepPointAt: aPoint [

	| charIndex |
	charIndex := methodSourcePresenter view charNearestPosition: aPoint.
	stepPoints size to: 1 by: -1 do: [:stepPoint | 
		| range |
		range := (stepPoints at: stepPoint) key.
		(range start <= charIndex and: [charIndex <= range stop]) ifTrue: [
			^stepPoint.
		].
	].
	^nil.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> stuffToKeepFromPath: pathString andAddTo: newSource [

	| file existingSource i j string existingHeader newHeader x |
	[
		file := FileStream
			read: pathString
			text: true.
	] on: Exception do: [:ex | ^''].
	existingSource := file contents.
	file close.
	string := 'doit' , Character lf asString.
	(i := existingSource indexOfSubCollection: string) <3 ifTrue: [^''].
	(j := newSource indexOfSubCollection: string) <3 ifTrue: [^''].
	(i == j and: [(existingSource copyFrom: 1 to: i) = (newSource copyFrom: 1 to: j)]) ifTrue: [^''].
	existingHeader := existingSource copyFrom: 1 to: i - 2.
	newHeader := newSource copyFrom: 1 to: j - 2.
	[
		0 < (i := existingHeader size - newHeader size) and: [
			x := existingHeader copyFrom: i + 1 to: existingHeader size.
			x = newHeader.
		].
	] whileTrue: [
		existingHeader = newHeader ifTrue: [^''].
		existingHeader := existingHeader copyFrom: 1 to: i - 1.
	].
	^(MessageBox confirm: 'Add the following header to the fileout?
' , existingHeader caption: 'Existing fileout has extra line(s) at the top') 
		ifTrue: [existingHeader , Character lf asString]
		ifFalse: [''].


]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> sunitPresenter [
	"Private - for testing"

	^sunitPresenter
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateAndSelect: aView [

	updateCount := updateCount + 1.
	keystrokeTime < Time millisecondClockValue ifTrue: [
		self updateAndSelectA: aView.
	] ifFalse: [
		[self updateAndSelectB: aView] fork.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateAndSelectA: aView [

	inUpdate ifTrue: [^self].
	self updateCommand: self requestStringForUpdate.
	self updateMenuBar.
	aView notNil ifTrue: [aView ensureVisible].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateAndSelectB: aView [

	| oldUpdateCount |
	oldUpdateCount := updateCount.
	(Delay forMilliseconds: keystrokeTime - Time millisecondClockValue) wait.
	oldUpdateCount = updateCount ifTrue: [
		self updateAndSelectA: aView.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateClassCategoryTree [

	| root treeModel cache listA listB existingSelection newSelection |

	root := #() -> '--Categories--'.
	treeModel := TreeModel new
		searchPolicy: SearchPolicy equality;
		reset;
		add: root asChildOf: nil;
		yourself.
	cache := Dictionary new
		at: root key put: root;
		yourself.
	readStream nextLineAsList asSortedCollection do: [:each | 
		| array |
		array := each subStrings: $-.
		1 to: array size do: [:i | 
			| childName parentName child parent |
			childName := array copyFrom: 1 to: i.
			parentName := array copyFrom: 1 to: i - 1.
			parent := cache at: parentName.
			(cache includesKey: childName) ifFalse: [
				cache 
					at: childName
					put: (child := childName -> each).
				treeModel 
					add: child
					asChildOf: parent.
			].
		].
	].
	listA := (treeModel asBag collect: [:each | each key printString]) asSortedCollection asArray.
	listB := (classCategoryPresenter model asBag collect: [:each | each key printString]) asSortedCollection asArray.
	listA = listB ifFalse: [
		classCategoryPresenter
			model: treeModel;
			yourself.
	].
	newSelection := readStream nextLine subStrings: $-.
	newSelection isEmpty ifTrue: [newSelection := root key].
	existingSelection := (classCategoryPresenter selectionIfNone: [nil -> nil]) key.
	newSelection = existingSelection ifFalse: [
		| items item |
		items := classCategoryPresenter model asBag asArray.
		0 to: newSelection size do: [:i | 
			| key |
			key := newSelection copyFrom: 1 to: i.
			item := items detect: [:each | each key = key] ifNone: [nil].
			classCategoryPresenter expand: item.
		].
		classCategoryPresenter selection: item.
	].
	classCategoryPresenter view ensureSelectionVisible.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateCommand: aString [

	^self 
		updateCommand: aString 
		onSuccessDo: [].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateCommand: aString onSuccessDo: aBlock [
	
	[
		| time1 time2 time3 string |
		time1 := Time millisecondsToRun: [
			string := self gciSession 
				serverPerform: #'systemBrowser:' 
				with: environment printString , ' ' , aString.
			eventCount := self gciSession eventCount.
		].
		time2 := Time millisecondsToRun: [
			| responseType |
			readStream := JadeServerReadStream on: string.
			time3 := readStream nextLine asNumber.
			aBlock value.
			(responseType := readStream nextLine) = 'update' ifFalse: [^responseType].
			self updatePresenters.
		].
		self statusBarServerRequestText:
			'server took ' , time3 printString , 'ms; ' , 
			'network took ' , (time1 - time3) printString , 'ms; ' , 
			'client took ' , time2 printString , 'ms; ' , 
			'total of ' , (time1 + time2) printString , 'ms'.
	] ensure: [
		selectedClassChanged := false.
	].
	^nil.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateDictionaryList [

	| fullList selections lines |
	dictionaryListPresenter ensureVisible.
	fullList := readStream nextLineAsList collect: [:each | (each copyFrom: 2 to: each size) -> (each first = $H)].
	dictionaryListPresenter list = fullList ifFalse: [
		dictionaryListPresenter list: (ListModel withAll: fullList).
	].
	selections := readStream nextLineAsList collect: [:x | dictionaryListPresenter list detect: [:y | x = y key]].
	dictionaryListPresenter selections = selections ifFalse: [
		dictionaryListPresenter selections: selections.
	].
	dictionaryListPresenter view ensureSelectionVisible.
	lines := readStream nextList.
	globalsPresenter list: (ListModel withAll: lines).

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateMethodFilter [

	| listPresenter pieces type tabs tab filters selections |
	listPresenter := self methodFilterListPresenter.
	pieces := readStream nextLine subStrings: Character tab.
	type := pieces at: 1.
	1 < pieces size ifTrue: [environment := (pieces at: 2) asNumber].
	(tabs := methodFilterTabs cards) isEmpty ifTrue: [^self].
	tab := tabs detect: [:each | each name = type].
	tab ensureVisible.
	filters := readStream nextLineAsList reverse.
	filters = listPresenter list ifFalse: [
		listPresenter list: filters.
	].
	selections := readStream nextLineAsList.
	selections := listPresenter list select: [:each | selections includes: each].
	selections = listPresenter selections ifFalse: [
		listPresenter selections: selections.
	].
	selections notEmpty ifTrue: [
		listPresenter view ensureSelectionVisible.
	] ifFalse: [
		filters notEmpty ifTrue: [
			listPresenter view ensureVisible: 1.
		].
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateMethodList [

	| fullList selections |
	fullList := (readStream nextParagraph subStrings: Character lf) collect: [:each | (each subStrings: Character tab) , #('' '' '' '' '')].
	fullList := fullList do: [:each | 	"JadeServer>>#'sbUpdateMethods' "
		each 
			at: 2 put: (each at: 2) = 'T';		"has a superclass implementation"
			at: 3 put: (each at: 3) = 'T';		"is in a TestCase class"
			at: 4 put: (each at: 4) = 'T';		"method replaced by GsPackagePolicy"
			yourself.
	].
	fullList = methodListPresenter list ifFalse: [
		methodListPresenter list: (ListModel withAll: fullList).
	].
	selections := readStream nextLineAsList.	"JadeServer>>#'sbUpdateMethodSelectionsIn:' "
	selections := methodListPresenter list select: [:eachArray | selections includes: eachArray first].
	selections = methodListPresenter selections ifFalse: [
		methodListPresenter selections: selections.
	].
	selections notEmpty ifTrue: [
		methodListPresenter view ensureSelectionVisible.
	] ifFalse: [
		fullList notEmpty ifTrue: [
			methodListPresenter view ensureVisible: 1.
		].
	].


]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateMethodStepPoints [
	| indicators |
	methodSourcePresenter view clearContainerIndicators.
	indicators := OrderedCollection new.
	1 to: stepPoints size
		do: 
			[:stepPoint |
			| range string styleName |
			range := (stepPoints at: stepPoint) key.
			(unimplementedSelectors at: range start ifAbsent: [nil])
				ifNotNil: 
					[:value |
					styleName := 10.
					string := 'No implementors of #' , value printString , ' (found at step point #'
								, stepPoint printString , ')']
				ifNil: 
					[styleName := (breakPoints includes: stepPoint) ifTrue: [#disabledBreakPoint] ifFalse: [#stepPoint].
					string := ((breakPoints includes: stepPoint) ifTrue: ['Break at '] ifFalse: ['']) , 'step point #'
								, stepPoint printString].
			indicators add: (ScintillaIndicator
						styleName: styleName
						range: range
						tag: string)].
	methodSourcePresenter view indicators: indicators
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateOverrideList [

	| list selection |
	list := readStream nextLineAsList.		"JadeServer>>#'sbUpdateMethod:' "
	list = overrideListPresenter list ifFalse: [
		overrideListPresenter list: list.
	].
	selection := readStream nextLine.
	selection isEmpty ifTrue: [selection := nil].
	selection notNil ifTrue: [
		selection := overrideListPresenter list
			detect: [:each | each = selection]
			ifNone: [nil].
	].
	selection = overrideListPresenter selectionOrNil ifFalse: [
		overrideListPresenter selectionOrNil: selection.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updatePackageDictionaryList [

	| next |
	self rowanFixMe. "project list is updated by STON only" 
	next := readStream nextLine.
	next = 'dictionaryList' ifTrue: [^self updateDictionaryList].
	next = 'packageList' ifTrue: [^self updatePackageList].
	next = 'projectList' ifTrue: [^self updatePackageList]. 
	self error: 'Unexpected token'.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updatePackageInfo [

	| list |
	list := readStream nextList collect: [:each | each , #('' '' '' '')].
	list = ancestorListPresenter list ifFalse: [
		ancestorListPresenter list: list.
	].
	list := readStream nextList collect: [:each | each , #('' '')].
	list = repositoryListPresenter list ifFalse: [
		repositoryListPresenter list: list.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updatePackageList [

	| dictionary fullList selections old new |

	packageListPresenter ensureVisible.
	dictionary := Dictionary new.
	readStream nextLineAsList do: [:each | dictionary at: each put: false].
	readStream nextLineAsList do: [:each | dictionary at: each put: true].
	fullList := dictionary associations asSortedCollection asArray.
	old := packageListPresenter list collect: [:each | each key].
	new := fullList collect: [:each | each key].
	old = new ifTrue: [
		packageListPresenter list do: [:each | 
			each value: (dictionary at: each key).
		].
		packageListPresenter view updateAll.
	] ifFalse: [
		packageListPresenter list: fullList.
	].
	selections :=  readStream nextLineAsList.
	selections := selections collect: [:x | packageListPresenter list detect: [:y | x = y key]].
	packageListPresenter selections = selections ifFalse: [
		packageListPresenter selections: selections.
	].
	selections size = 1 
		ifTrue: [self updatePackageInfo]
		ifFalse: [self clearPackageInfo].
	packageListPresenter view ensureSelectionVisible.

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updatePresenters [
	
	[inUpdate := true.
	self
		updatePackageDictionaryList;
		updateClassCategoryTree;
		updateClassListOrHierarchy;
		updateClassInfo;
		updateSuperclassList;
		updateMethodFilter;
		updateMethodList;
		updateOverrideList;
		updateSelector;
		updateTabLabel;
		yourself]
			ensure: [inUpdate := false]
]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> updateSuperclassList [

	| tabs tabName tab list selected |
	tabName := readStream nextLine.
	(tabs := classListHierarchyTabs cards) isEmpty ifTrue: [^self].
	tab := tabs 
		detect: [:each | each name = tabName]
		ifNone: [self error: 'None of ' , tabs printString , ' match ' , tabName printString].
	tab ensureVisible.
	list := readStream nextLineAsList reverse.
	list = superclassListPresenter list ifFalse: [
		superclassListPresenter list: (ListModel withAll: list).
	].
	(selected := readStream nextLine) notEmpty ifTrue: [
		selected := (selected subStrings: Character tab) first.
	].
	selected := superclassListPresenter list
		detect: [:each | each = selected]
		ifNone: [list notEmpty ifTrue: [list last] ifFalse: [nil]].
	(selected = superclassListPresenter selectionOrNil) ifFalse: [
		superclassListPresenter selection: selected.
	].

]

{ #category : 'as yet unclassified' }
JadeSystemBrowserPresenter >> variableListPresenter [

	^variableListPresenter
]
