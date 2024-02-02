Class {
	#name : 'RowanSystemBrowserPresenter',
	#superclass : 'JadeAutoSystemBrowserPresenter',
	#category : 'Jadeite-Browser'
}

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> addPackageDictionaryInfoTo: aStream [
	aStream
		nextPutAll: 'dictionaryList';
		lf.
	dictionaryListPresenter selections do: 
			[:each |
			aStream
				nextPutAll: each key;
				tab].
	aStream lf
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> browseClassReferencesOf: className [
	
	| string |
	string := 'browseClassReferences' , Character tab asString , self behaviorIdentifier , Character lf asString.
	(string := self updateCommand: string) = 'browseClassReferences' ifFalse: [self error: 'Unrecognized response'].
	self browseMethodsAndSelect: className.
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> categoriesMenuStrings [

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
RowanSystemBrowserPresenter >> classService [
	^RowanClassService new
		name: self selectedClassNameWithoutVersion;
		yourself
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> createSchematicWiringForPackageDictionaryTabs [

	
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> getViews [
	classHierarchyTabs := self view viewNamed: 'classHierarchyTabs'.
	classListHierarchyTabs := self view viewNamed: 'instanceClassTabs'.
	methodFilterTabs := self view viewNamed: 'methodFilterTabs'.
	textAreaTabs := self view viewNamed: 'textAreaTabs'.
	self registerTabPresentersForUpdates
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> labelOfClass: oldName changedTo: newName [

	| stream |
	oldName = self selectedClassNameWithoutVersion.
	self browseClassReferencesOf: oldName.  "Jadeite gets in trouble deep in server code if the class isn't a class"
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
RowanSystemBrowserPresenter >> methodListSelection [
	^RowanMethodService new
				selector: self selectedMethodName asSymbol;
				className: classListPresenter selection;
				meta: self isClassSideSelected.
	
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> onViewClosed [
	super onViewClosed.
	subPresenters do: [:presenter | RowanServiceUpdater current removeEventsTriggeredFor: presenter]
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> registerTabPresentersForUpdates [
	RowanServiceUpdater current register: self methodFilterListPresenter selector: #methodFilterUpdate:
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> resetClassDefinitionPresenter [
	classDefinitionPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false;
		yourself
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateAfterFindClass: anArray isMeta: aBoolean selector: aString [

	super updateAfterFindClass: anArray isMeta: aBoolean selector: aString.
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateClassHierarchyFrom: update [
	| list paths treeModel x y currentSelection newSelection flags |
	list := update classes.
	newSelection := update selections reverse.
	flags := #().
	classHierarchyPresenter ensureVisible.
	list := list collect: [:each | each reverse].
	paths := Set new.
	list do: 
			[:eachClass |
			| string |
			string := ''.
			eachClass do: 
					[:each |
					string := string , each.
					paths add: string.
					string := string , Character tab asString]].
	paths := paths asSortedCollection asArray.
	treeModel := TreeModel new
				searchPolicy: SearchPolicy equality;
				reset;
				yourself.
	paths do: 
			[:each |
			| path parent |
			path := each subStrings: Character tab.
			parent := path copyFrom: 1 to: path size - 1.
			parent isEmpty ifTrue: [parent := nil].
			treeModel add: path asChildOf: parent].
	x := (treeModel asBag collect: [:each | each printString]) asSortedCollection asArray.
	y := (classHierarchyPresenter model asBag collect: [:each | each printString]) asSortedCollection
				asArray.
	x = y
		ifFalse: 
			[classHierarchyPresenter
				model: treeModel;
				yourself].
	currentSelection := classHierarchyPresenter selectionIfNone: [#()].
	(currentSelection isEmpty and: [newSelection isEmpty and: [classListPresenter selections size = 1]])
		ifTrue: 
			[x := classListPresenter selection.
			newSelection := classHierarchyPresenter model asBag asArray detect: [:each | each last = x]
						ifNone: [nil]].
	(newSelection notEmpty and: [currentSelection ~= newSelection])
		ifTrue: 
			[classHierarchyPresenter
				selection: newSelection;
				expand: newSelection;
				yourself].
	self selectedClassName: (newSelection notEmpty ifTrue: [newSelection last] ifFalse: ['']).
	classListPresenter selectionOrNil: nil.
	selectedClassesAreTestCases := (flags at: 1) = 'true'.
	sunitPresenter
		testClassService: (selectedClassesAreTestCases ifTrue: [selectedClassName] ifFalse: [''])
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateCommand: aString onSuccessDo: aBlock [
	| responseType |
	responseType := super updateCommand: aString onSuccessDo: aBlock.
	ignoreNextSetFocusEvent := true.	"Need to stop runaway set focus events somehow. There's a better fix somewhere"
	^responseType
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateFromCommand: update [
	| index newClassDefinition |
	selectedClassOop := update oop.
	newClassDefinition := update template.
	classCommentPresenter value: update comment.
	classDefinitionPresenter view isModified
		ifTrue: 
			[newClassDefinition = classDefinition ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Class has unsaved changes!')
				ifTrue: [classDefinitionPresenter value copyToClipboard]].
	classDefinition := newClassDefinition.
	0 < (classDefinition indexOfSubCollection: 'MyNewClass')
		ifTrue: 
			["Template is based on Stream class, but we don't want to use 'Globals' in template"
			index := classDefinition indexOfSubCollection: ': Globals'.
			(0 < index and: [(classDefinition copyFrom: index - 2 to: index + 1) ~= 'User'])
				ifTrue: 
					[classDefinition := (classDefinition copyFrom: 1 to: index + 1)
								, (dictionaryListPresenter selectionIfNone: ['UserGlobals' -> false]) key
									, (classDefinition copyFrom: index + 9 to: classDefinition size).
					index := classDefinition indexOfSubCollection: 'User Classes'.
					0 < index
						ifTrue: 
							[classDefinition := (classDefinition copyFrom: 1 to: index - 1) , 'User Classes'
										, (classDefinition copyFrom: index + 12 to: classDefinition size)]]].
	classDefinitionPresenter value: classDefinition.
	classDefinitionPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false;
		yourself
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateMethodFilter [

	| listPresenter pieces type tabs tab filters selections |
	listPresenter := self methodFilterListPresenter.
	pieces := readStream nextLine subStrings: Character tab.
	pieces isEmpty ifTrue:[^self].
	type := pieces at: 1.
	1 < pieces size ifTrue: [environment := (pieces at: 2) asNumber].
	(tabs := methodFilterTabs cards) isEmpty ifTrue: [^self].
	tab := tabs detect: [:each | each name = type].
	tab ensureVisible.
	filters := readStream nextLineAsList reverse.
	filters = listPresenter list ifFalse: [
		listPresenter list: (ListModel withAll: filters).
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
RowanSystemBrowserPresenter >> updateMethodFilterFrom: update [

	| listPresenter type tabs tab filters selections |
	listPresenter := self methodFilterListPresenter.
	type := update type. 
	(tabs := methodFilterTabs cards) isEmpty ifTrue: [^self].
	tab := tabs detect: [:each | each name = type].
	tab ensureVisible.
	filters :=update methodFilters reverse.
	filters = listPresenter list ifFalse: [
		listPresenter list: filters.
	].
	selections := update selections. 
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
RowanSystemBrowserPresenter >> updateMethodFrom: update [
	| gsMethod isReadOnly listModel methodSourceLabel newSource warnings x |
	methodSourcePresenter view cancelCallTip.
	gsMethod := update gsMethod session: gciSession.
	isReadOnly := gsMethod isReadOnly.	"current user has write permission for the class"
	newSource := gsMethod source.
	methodSourcePresenter view isModified
		ifTrue: 
			[newSource = methodSource ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Method has unsaved changes!')
				ifTrue: [methodSourcePresenter value copyToClipboard]].
	methodSource := newSource.
	methodSourcePresenter value: methodSource.
	unimplementedSelectors := gsMethod unimplementedSelectors.
	stepPoints := gsMethod stepPoints.
	breakPoints := gsMethod breakPoints.
	self updateMethodStepPoints.
	methodSourcePresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false;
		isReadOnly: isReadOnly;
		yourself.
	(overrideListPresenter list notEmpty
		and: [overrideListPresenter selectionOrNil ~= overrideListPresenter list last])
			ifTrue: 
				[methodSourcePresenter view
					backcolor: nil;
					isReadOnly: true;
					yourself].
	((methodCategory := gsMethod category) notEmpty and: [self isCategoryTabSelected])
		ifTrue: 
			[| fullList selections index newName |
			fullList := categoryListPresenter list.
			selections := categoryListPresenter selections.
			0 < (index := fullList indexOf: methodCategory)
				ifTrue: 
					[fullList at: index put: (newName := ' ' , methodCategory).
					categoryListPresenter list: fullList.
					0 < (index := selections indexOf: methodCategory)
						ifTrue: 
							[selections at: index put: newName.
							categoryListPresenter selections: selections].
					categoryListPresenter view invalidate]].
	listModel := (textAreaTabs subViews detect: [:each | each class == TabViewXP]) model.
	originalSourceLabel
		ifNil: [originalSourceLabel := listModel detect: [:each | each text = 'Original Source']].
	methodSourceLabel := listModel detect: [:each | each text = 'Method Source'].
	(x := gsMethod originalSource) isEmpty
		ifTrue: [listModel remove: originalSourceLabel ifAbsent: []]
		ifFalse: 
			[(listModel includes: originalSourceLabel)
				ifFalse: [listModel add: originalSourceLabel before: methodSourceLabel].
			originalSourcePresenter value: x].
	(warnings := gsMethod warnings) notEmpty
		ifTrue: [MessageBox warning: warnings caption: 'Jade Compile Warning']
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateMethodReferences: displayArrays [

	| services className |
	className := classListPresenter selection.
	services := displayArrays collect: [ :displayArray |
		            RowanMethodService new
			            selector: displayArray first asSymbol;
			            className: className asSymbol ].
	services do: [ :service |
		service meta: self isClassSideSelected.
		service command: #allReferences ].
	RowanServiceUpdater current
		issueCommands: services
		session: self gciSession
		onCompletion: nil.
	^ services
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateMethodSource [
	self updateAndSelect: methodSourcePresenter .
	

]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateMethodsFrom: update [
	| fullList selections |
	fullList := update methods collect: 
					[:methodUpdate |
					Array
						with: methodUpdate selector
						with: methodUpdate isOverride
						with: methodUpdate isTestClass
						with: 'F'	"monticello related, ignore"].
	fullList = methodListPresenter list ifFalse: [methodListPresenter list: fullList].
	selections := update selections.
	selections := methodListPresenter list select: [:eachArray | selections includes: eachArray first].
	selections = methodListPresenter selections ifFalse: [methodListPresenter selections: selections].
	selections notEmpty
		ifTrue: [methodListPresenter view ensureSelectionVisible]
		ifFalse: [fullList notEmpty ifTrue: [methodListPresenter view ensureVisible: 1]]
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateOverrideListFrom: update [

	| list selection |
	list := update inheritedClasses.		
	list = overrideListPresenter list ifFalse: [
		overrideListPresenter list: list.
	].
	selection := update inheritedClass.
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
RowanSystemBrowserPresenter >> updatePresenters [
	
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
			ensure: [inUpdate := false].
	self resetClassDefinitionPresenter
]

{ #category : 'as yet unclassified' }
RowanSystemBrowserPresenter >> updateSelectionsForUpdate: update [

	update updateDictionarySelectionsFor: dictionaryListPresenter.
	update updateClassCategorySelectionsFor: classCategoryPresenter.
	update updateClassSelectionFor: classListPresenter.
	update updateClassHierarchySelectionFor: classHierarchyPresenter.
	update updateSuperclassSelectionFor: superclassListPresenter.
	update updateMethodFilterSelectionFor: self methodFilterListPresenter.
	update updateMethodSelectionFor: self methodListPresenter.
	
]
