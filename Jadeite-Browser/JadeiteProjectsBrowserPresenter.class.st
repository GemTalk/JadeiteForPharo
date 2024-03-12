"
Use subclass JadeiteBrowserPresenter now which integrates the dictionary browser. 
In packages pane, show projects & packages. Remove class categories.

"
Class {
	#name : 'JadeiteProjectsBrowserPresenter',
	#superclass : 'RowanSystemBrowserPresenter',
	#instVars : [
		'projectListPresenter',
		'stonCritical',
		'projectInfoTab',
		'projectLabel',
		'projectDictionaryTabs',
		'comparisonPresenter',
		'comparisonTab',
		'definedClassPackageText',
		'definedMethodPackageText',
		'methodCategoryText',
		'statusBarText'
	],
	#category : 'Jadeite-Browser'
}

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> addNoneProject [ 

	"ignore in this browser"
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> addPackageDictionaryInfoTo: aStream [

	"Private - projects don't write themselves to string"
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> addSubclass [

	| classService answerService |
	classService := self selectedClass ifNil: [ ^ self ].
	classService
		command: #subclassCreationTemplate;
		commandArgs: Array new.
	answerService := (self issueCommand: classService onCompletion: nil)
		                 first.
	classDefinitionPresenter
		ensureVisible;
		value: answerService answer
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> allClasses [

	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #allClasses.
	self issueCommand: browserService onCompletion: nil.
	^ browserService allClasses ifNil: [ Array new ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> autoCommit: boolean [
	gciSession autoCommit contents: boolean
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> basicProjectTabLabel [
	| label |
	projectListPresenter selections isEmpty ifTrue: [^'Projects'].
	label := projectListPresenter selectedItem name.
	packageListPresenter list isEmpty ifTrue: [^label].
	packageListPresenter selections isEmpty ifTrue: [^label].
	(packageListPresenter selections size > 1 and: [self selectedClass isNil]) ifTrue: [^label].
	packageListPresenter selections size = 1 ifTrue: [label := packageListPresenter jaditeSelection name].
	^self selectedClass ifNil: [label] ifNotNil: [self selectedClass name]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> basicRemoveMethods [
	| service presenter |
	presenter := self isClassListTabSelected
				ifTrue: [classListPresenter]
				ifFalse: [classHierarchyPresenter].
	service := presenter selectionIfNone: [^self].
	service meta: self isClassSideSelected.
	self removeMethods: (Array with: service)
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> behaviorIdentifier [
	^self selectedClass behaviorIdentifier
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> browseHierarchyImplementors [
	^self browseHierarchyImplementorsOf: self selectedMethodName
		className: methodListPresenter selections first className
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> browseHierarchySenders [
	^self browseHierarchySendersOf: self selectedMethodName
		className: methodListPresenter selection className
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> browseSelectedClass [
	^self browseSelectedClassIn: methodSourcePresenter newTab: Keyboard default isCtrlDown
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> categoryListPresenter [
	^categoryListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> classCommentPresenter [
	"for test access" 
	^classCommentPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> classDefinitionPresenter [

	^classDefinitionPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> classHierarchyTabs [
	^classHierarchyTabs
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> cleanupComparisonBrowser [
	self todo:[comparisonPresenter
		beforeTitle: String new;
		afterTitle: String new;
		compare: String new with: String new]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> clearMethodBreakpoints [
	^JadePresenter clearMethodBreakpoints: methodListPresenter selections in: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> comparisonTab [
	^comparisonTab
		ifNil: 
			[comparisonTab := self textTabs
						detect: [:each | (each class canUnderstand: #text) ifTrue: [each text = 'Comparison'] ifFalse: [each = 'Comparison']]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> confirmOverwriteAccessor [
	| existing selectors |
	existing := OrderedCollection new.
	selectors := self selectedClass methods collect: [:methodService | methodService selector].
	self methodFilterListPresenter selections do: 
			[:variable |
			| setter |
			(selectors includes: variable asSymbol) ifTrue: [existing add: variable].
			setter := (variable , ':') asSymbol.
			(selectors includes: setter) ifTrue: [existing add: setter]].
	existing isEmpty
		ifFalse: 
			[^MessageBox
				confirm: 'These methods will be overridden - ' , existing asArray printString , ' Continue?'].
	^true
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> containedDictionaryLabel [
	| containedDictionary |
	containedDictionary := 'Go To Containing Dictionary'.
	self selectedClass
		ifNotNil: [:classService | containedDictionary := containedDictionary , ' (' , classService dictionaryName , ')'].
	^containedDictionary
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> containedPackageDictionaryLabel [
	| containedDictionary |
	containedDictionary := 'Go to Associated Dictionary'.
	packageListPresenter selection
		ifNotNil: 
			[:packageService |
			containedDictionary := containedDictionary , ' ('
						, (packageService dictionaryName ifNil: [String new]) , ')'].
	^containedDictionary
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> copyClass [
	| oldClassService newClassName validClassNameSelected |
	oldClassService := self selectedClass ifNil: [^MessageBox notify: 'Class must be selected'].
	validClassNameSelected := false.
	[validClassNameSelected] whileFalse: 
			[(newClassName := Prompter
						on: oldClassService name
						prompt: 'Copy ' , oldClassService name , ' to:'
						caption: 'Copy class') isNil
				ifTrue: [^self].
			validClassNameSelected := self symbolExists: newClassName.
			validClassNameSelected ifFalse: [MessageBox notify: 'Symbol exists. Please retry.']].
	self basicCopyClass: oldClassService to: newClassName
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> definedClassMenuItemLabel [
	| definedLabel |
	definedLabel := 'Go To Defining Package'.
	self selectedClass
		ifNotNil: 
			[:classService |
			classService definedPackageName ifNil: [self updateService: self selectedClass].
			classService definedPackageName = RowanService notRowanizedPackageName
				ifFalse: [definedLabel := definedLabel , ' (' , classService definedPackageName , ')']].
	^definedLabel
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> definedMethodMenuItemLabel [
	| definedLabel |
	definedLabel := 'Go To Defining Package'.
	methodListPresenter selection
		ifNotNil: 
			[:methodService |
			methodService definedPackage = RowanService notRowanizedPackageName
				ifFalse: [definedLabel := definedLabel , ' (' , methodService definedPackage , ')']].
	^definedLabel
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> displayMultipleCategories [
	"display a generic indication of multiple categories unless all selected methods
	are in the same category"

	| categories |
	categories := (methodListPresenter selections collect: [:methodService | methodService category])
				asSet.
	categories size = 1
		ifTrue: [methodCategoryText value: 'Category: ' , categories anyOne]
		ifFalse: [methodCategoryText value: 'Categories: (Multiple)']
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> editFind [
	| tab |
	tab := textAreaTabs currentCard.
	tab setFocus.
	(tab class canUnderstand: #editFind) ifTrue: [^tab editFind]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> editReplace [
	View focus == methodSourcePresenter view ifTrue: [View focus findReplace]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> filterTabChanged [
	self isClassSelected
		ifTrue: [self updateService: self selectedClass]
		ifFalse: 
			[self clearFilterLists.
			^self].
	self populateFilterList.
	self isCategoryTabSelected
		ifTrue: 
			[^methodListPresenter selectionOrNil
				ifNil: [self selectMethodSourceTab]
				ifNotNil: 
					[:methodService |
					self selectCategoryFrom: methodService.
					self selectMethodSourceTab]].
	methodListPresenter selectionOrNil ifNotNil: [self selectMethodSourceTab]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> findMethod [
	self selectedClass isNil ifTrue: [^self].
	^self class
		findMethodIn: gciSession
		class: self selectedClass
		presenter: self
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> findMethod: selector [
	"assume we have a populated method list"

	| methodService |
	methodService := methodListPresenter list detect: [:service | service selector = selector]
				ifNone: [^self].
	self isCategoryTabSelected
		ifTrue: [categoryListPresenter selection: methodService category]
		ifFalse: [variableListPresenter selection: nil].
	methodListPresenter selections: (Array with: methodService)
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> getViews [
	classHierarchyTabs := self view viewNamed: 'classHierarchyTabs'.
	classListHierarchyTabs := self view viewNamed: 'instanceClassTabs'.
	methodFilterTabs := self view viewNamed: 'methodFilterTabs'.
	textAreaTabs := self view viewNamed: 'textAreaTabs'.
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> getterMethodSourceFor: variable [
	| sourceStream |
	sourceStream := WriteStream on: String new.
	sourceStream
		nextPutAll: variable;
		lf;
		tab;
		nextPut: $^;
		nextPutAll: variable.
	^sourceStream
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> gotoClass [
	JadePresenter browseClassIn: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> gotoClassDefinedPackageViaButton [
	^self gotoClassDefinedPackage
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> gotoMethodDefinedPackage [
	"find will go to the defined package of the selected class"

	| selectedCategory selectedMethod className |
	selectedCategory := categoryListPresenter selectionIfNone: [].
	selectedMethod := methodListPresenter selectionIfNone: [^self].
	className := self selectedClass name.
	self selectClassListTab.
	self gotoProjectNamed: selectedMethod projectName.
	self gotoPackageNamed: selectedMethod definedPackage.
	self selectClassNamed: className.
	selectedCategory ifNotNil: [:category | categoryListPresenter selection: category].
	methodListPresenter selection: (methodListPresenter list
				detect: [:methodService | methodService selector = selectedMethod selector])	"It better be there".
	self updateMenuBar. "to refresh method menu"
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> gotoMethodDefinedPackageViaButton [
	^self gotoMethodDefinedPackage
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> gotoPackageNamed: packageName [
	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = packageName]
				ifNone: [^self].
	packageListPresenter selections: (Array with: packageService)
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> gotoProjectNamed: projectName [
	| projectService  |
	projectService := projectListPresenter list
				detect: [:service | service name = projectName]
				ifNone: 
					[^self].
	projectListPresenter selections: (Array with: projectService).
	
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> initialize [
	super initialize.
	stonCritical := Semaphore forMutualExclusion.
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> jadeDisplay [
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeDisplay
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> jadeExecute [
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeExecute
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> methodCategoryText [
	^methodCategoryText
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> methodListPresenter [
	^methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> methodListSelection [

	^methodListPresenter selectionOrNil
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> methodMenuBreak: aMenu [
	| selection |
	methodSourcePresenter view isModified ifTrue: [^self].
	selection := methodListPresenter selectionOrNil.
	selection ifNil: [^self].
	selection appendToSourceMenu: aMenu presenter: methodSourcePresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> methodSourcePresenter: anObject [
	methodSourcePresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> methodsMenuStrings [
	false
		ifTrue: 
			["This helps us find senders"
			self
				browseBreakpointList;
				browseImplementors;
				browseImplementorsOf;
				browseSenders;
				browseSendersOf;
				browseHierarchyImplementors;
				browseHierarchySenders;
				browseMethodsContaining;
				browseLiteralReferences;
				browseSelectedMethods;
				browseMethodHistory;
				clearMethodBreakpoints;
				removeMethods;
				runMethodTests;
				fileOutMethods;
				findMethod;
				runMethodTests;
				gotoMethodDefinedPackage;
				runAll;
				runSelected].
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) ...//removeMethods' '-' 'Run All Tests/Ctrl+Shift+A/runAll' 'Run Selected Test(s)/Ctrl+Shift+S/runMethodTests' 'Debug Selected &Test(s)/Ctrl+B/runMethodTests' '-' 'Go To Defining Package//gotoMethodDefinedPackage')
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> newBrowser [
	| classService selector |
	classService := self selectedClass.
	selector := methodListPresenter selectionOrNil ifNotNil: [:methodService | methodService selector].
	^self openProjectBrowserOn: classService selector: selector
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> onSetFocus: aView stack: aString [

	"no need for constant trips to the server"
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> onViewClosed [
	"the sunitPresenter doesn't seem to get it's events cleaned up on 
	a normal window exit. Help it out."
	super onViewClosed.
	RowanServiceUpdater current logComment: 'Closing Projects Browser {' , self identityHash printString, '}'.
	RowanServiceUpdater current removeEventsTriggeredFor: sunitPresenter methodListPresenter.
	RowanServiceUpdater current removeEventsTriggeredFor: self.
	JadePresenter transactionModeValueHolder removeEventsTriggeredFor: self. 
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> postOkToChangeEvent [
	| service |
	service := self isClassListTabSelected
				ifTrue: [classListPresenter selectionIfNone: [^self]]
				ifFalse: [classHierarchyPresenter selectionIfNone: [^self]].
	service ifNil:[^self]. 
	classDefinitionPresenter value: service template.
	self resetClassDefinitionPane.
	self sundryCleanup
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> projectListPresenter [
	^projectListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> refreshClassListOrHierarchy [
	| newSelection listSelection hierarchySelection |
	(textAreaTabs currentCard name = 'classDefinition' and: [self selectedClass isNil])
		ifTrue: [self resetClassTemplate].
	self isClassListTabSelected
		ifTrue: 
			[listSelection := classListPresenter selectionOrNil.
			hierarchySelection := classHierarchyPresenter selectionOrNil.
			listSelection = hierarchySelection
				ifTrue: 
					[self resetDefinedClassPackage.
					^self].
			hierarchySelection isNil ifTrue: [^self updateClasses].
			self updateClasses.
			newSelection := classListPresenter list detect: [:service | hierarchySelection name = service name]
						ifNone: 
							[self resetDefinedClassPackage.
							^classListPresenter resetSelection].
			classListPresenter selection: newSelection]
		ifFalse: 
			[| selectedFilters selectedMethods |
			selectedFilters := self selectedFilters.
			selectedMethods := methodListPresenter selections.
			self updateHierarchy.
			self isCategoryTabSelected
				ifTrue: [categoryListPresenter selections: selectedFilters]
				ifFalse: [variableListPresenter selections: selectedFilters].
			classHierarchyPresenter selections isEmpty
				ifFalse: 
					["No selection if in the refreshing after rename. Done later"
					self selectMethods: selectedMethods]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> registerClassData [
	"temporarily disabled"
]

{ #category : 'registration' }
JadeiteProjectsBrowserPresenter >> registerPresentersForUpdates [
	RowanServiceUpdater current register: classListPresenter selector: #removedClass:.
	RowanServiceUpdater current
		register: classListPresenter
		selector: #updatedClass:browser:
		browser: self.
	RowanServiceUpdater current
		register: classDefinitionPresenter
		selector: #updatedClassDefinition:browser:
		browser: self.
	RowanServiceUpdater current register: classListPresenter selector: #removed:.
	RowanServiceUpdater current register: packageListPresenter selector: #removed:.
	RowanServiceUpdater current register: packageListPresenter selector: #packageUpdate:.
	RowanServiceUpdater current
		register: categoryListPresenter
		selector: #filterUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: variableListPresenter
		selector: #filterUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #classHierarchyUpdate:browser:
		browser: self.
	RowanServiceUpdater current
		register: classListPresenter
		selector: #updatedClass:browser:
		browser: self.
	RowanServiceUpdater current register: classHierarchyPresenter selector: #removedClass:.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #updatedClass:browser:
		browser: self.
	RowanServiceUpdater current
		register: classHierarchyPresenter
		selector: #updatedClassInHierarchy:browser:
		browser: self.
	RowanServiceUpdater current register: classHierarchyPresenter selector: #removed:.
	RowanServiceUpdater current register: methodListPresenter selector: #removed:.
	RowanServiceUpdater current
		register: methodSourcePresenter
		selector: #methodSourceUpdate:browser:
		browser: self.
	RowanServiceUpdater current register: self selector: #autoCommitUpdate:
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> releasedReferencedServices: selectionChangingEvent [
	selectionChangingEvent window presenter selectionOrNil ifNotNil: [:service | service postUpdate]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> removeMethod [
	self removeMethodSelector: self selectedMethodName 
	
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> removeMethodSelector: selector [
	self removeMethodSelectors: (Array with: selector)
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> removeMethods: classServices [
	"This is hokey but used everywhere. Replace 
	it with #removeMethodSelector(s): sometime soon"

	classServices do: [ :classService |
		classService
			command: #removeMethods:;
			commandArgs: (Array with: methodListPresenter selections) ].
	RowanServiceUpdater current
		issueCommands: classServices
		session: self gciSession
		onCompletion: nil
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> renameClass [
	| oldClassService newClassName |
	oldClassService := self selectedClass ifNil: [^MessageBox notify: 'Class must be selected'].
	(MessageBox
		confirm: 'Rename class does NOT create a new version of the renamed class and instances are not migrated. Continue?')
			ifFalse: [^self].
	(newClassName := Prompter
				on: oldClassService name
				prompt: 'Rename ' , oldClassService name , ' to:'
				caption: 'Rename class') isNil
		ifTrue: [^self].
	self basicRenameClass: oldClassService to: newClassName
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> resetClassDefinitionPane [

	classDefinitionPresenter isModified: false
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> resetDefinedClassPackage [
definedClassPackageText ifNotNil:[
	definedClassPackageText text: String new].
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> resetSunitTestList [
	self todo:[self selectedClass ifNil: [sunitPresenter resetTestList]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> runAndMesureTime [
	| selections |
	self selectSUnitTab.
	sunitPresenter reset.
	selections := OrderedCollection new.
	methodListPresenter selections do: 
			[:methodService |
			| service |
			service := sunitPresenter methodListPresenter list
						detect: [:sunitService | sunitService selector = methodService selector]
						ifNone: [].
			service ifNotNil: [selections add: service]].
	sunitPresenter methodListPresenter selections: selections. 
	^sunitPresenter runAndMesureTime
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> runClassTests [

	| classService answeringService |
	classService := self selectedClass.
	classService
		command: #runClassTests:;
		commandArgs: (Array with: self selectedClass).
	answeringService := [
	                    self issueCommand: classService onCompletion: nil ]
		                    on: Error
		                    do: [ :ex |
			                    ex pass.
			                    ^ self ].
	answeringService first answer ifTrue: [
		| testResult |
		sunitPresenter reset.
		testResult := JadeTestResult new.
		testResult passed: (methodListPresenter list
				 select: [ :methodService |
				 'test*' match: methodService selector asString ]
				 thenCollect: [ :methodService | methodService selector ]).
		sunitPresenter updateResult: testResult.
		sunitPresenter ensureVisible ]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> runMethodTests [
	| sunitPresenterSelections testMethodServices | 
	testMethodServices := methodListPresenter selections select:[:methodService | methodService isTestMethod]. 
	(JadePresenter runMethodTests: testMethodServices in: self gciSession)
		ifTrue: 
			[| testResult |
			sunitPresenter reset.
			testResult := JadeTestResult new.
			testResult passed: (testMethodServices
								collect: [:methodService | methodService selector]).
			sunitPresenterSelections := self sunitPresenter methodListPresenter list select:[:methodService | testMethodServices includes: methodService]. 
			self sunitPresenter methodListPresenter selections: sunitPresenterSelections.
			sunitPresenter updateResult: testResult.
			sunitPresenter ensureVisible]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> savePackage [
	MessageBox notify: 'This feature is not yet available'
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectCategoryFrom: methodService [
	^categoryListPresenter selectionOrNil = methodService category
		ifFalse: [categoryListPresenter selection: methodService category]
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectCategoryNamed: category [
	^self selectCategoriesNamed: (Array with: category)
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectCommentTab [
	self selectSourceTabNamed: 'classDocumentation'
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectComparisonTab [
	self selectSourceTabNamed: 'comparisonTab'
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectGlobalsTab [
	| tab |
	tab := self view viewNamed: 'globalsTab' ifNone:[^nil].
	^tab ensureVisible
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectPackage: newPackageSelection [
	| methodSelection classSelection |
	methodSelection := methodListPresenter selectionOrNil.
	classSelection := classListPresenter selectionOrNil.
	packageListPresenter selection: newPackageSelection.
	packageListPresenter verticalAlignment desiredVisibleRow: packageListPresenter selection selectedIndex.
	classSelection ifNotNil: [self selectClassNamed: classSelection name].
	methodSelection ifNotNil: [self selectionMethod: methodSelection]
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectSUnitTab [
	self selectSourceTabNamed: 'sunit'
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectSourceTabNamed: tabName [
	| tab |
	tab := self view viewNamed: tabName.
	tab ensureVisible
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectVariableTab [
	methodFilterTabs selectPageIndex: 2
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectedClass [
	^self isClassListTabSelected
		ifTrue: [classListPresenter selectionIfNone: []]
		ifFalse: [classHierarchyPresenter selectionIfNone: []]
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectedClassName [
	^self selectedClass name
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectedClasses [
	^self isClassListTabSelected
		ifTrue: [classListPresenter selections]
		ifFalse: [classHierarchyPresenter selections]
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectedMethodCategory [
	^methodListPresenter selectionOrNil ifNotNil: [:methodService | methodService category]
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectedMethodNames [

	^methodListPresenter selections collect:[:methodService | methodService selector]

]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectedPackageNames [
	^packageListPresenter selections collect: [:packageService | packageService name]
]

{ #category : 'selections' }
JadeiteProjectsBrowserPresenter >> selectionMethod: methodSelection [
	| newMethodSelection |
	newMethodSelection := methodListPresenter list
				detect: [:svc | svc selector = methodSelection selector]
				ifNone: [].
	^newMethodSelection ifNotNil: [methodListPresenter selection: newMethodSelection]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> setDefaultProjectTablLabel [
	projectLabel ifNil: [projectLabel := self textTabs detect: [:each | each text = 'Project']]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> setDefaultProjectTablLabel: listModel [
	projectLabel ifNil: [projectLabel := listModel detect: [:each | each text = 'Project']]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> setMethodFilterFor: presenter [
	| filters |
	self isCategoryTabSelected
		ifTrue: [filters := categoryListPresenter selections]
		ifFalse: [filters := variableListPresenter selections].
	presenter model asBag do: [:service | service filters: filters]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> setTestClass: service [
	self todo:[sunitPresenter testClassService: (service isTestCase ifTrue: [service] ifFalse: [nil])]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> setterMethodSourceFor: variable [
	| sourceStream |
	sourceStream := WriteStream on: String new.
	sourceStream
		nextPutAll: variable , ': object';
		lf;
		tab;
		nextPutAll: variable , ' := object'.
	^sourceStream
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> setupPackageMenu [
	packageListPresenter view contextMenu: (Menu fromStrings: self pkgsMenuStrings)
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> showSuperClassComparison [
	| methodService |
	methodService := methodListPresenter jaditeSelection.
	methodService hasSupers
		ifTrue: 
			[comparisonPresenter
				beforeTitle: methodService classMethodDisplayString;
				afterTitle: methodService superDisplayString;
				compare: methodService source with: methodService comparisonSource]
		ifFalse: 
			[comparisonPresenter
				beforeTitle: methodService classMethodDisplayString;
				afterTitle: 'No super implementation';
				compare: methodService source with: String new]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> sundryCleanup [
	self statusBarText: String new.
	methodListPresenter selections notEmpty ifFalse: [self cleanupComparisonBrowser].
	self resetSunitTestList
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> sunitPresenter [
	"for testing"

	^sunitPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> targetCategory [
	self isVariablesTabSelected ifTrue: [^self selectedMethodCategory].
	categoryListPresenter hasSelection ifTrue: [^categoryListPresenter selectedItem].
	self methodListPresenter selectedItem ifNil: [ 
	^'as yet unclassified'].
	^self methodListPresenter selectedItem category
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> textAreaTabs [
	"for testing"
	^textAreaTabs
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> textTabs [
	^(textAreaTabs subViews detect: [:each | each class == TabViewXP]) model
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> unloadPackage [
	MessageBox notify: 'This feature is not yet available'
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateAndSelectA: aView [
	"is this override still needed?"
	self updateMenuBar.
	aView notNil ifTrue: [aView ensureVisible].

]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateCommand: aString onSuccessDo: aBlock [
	"Only use STON to update in our new browser"

	stonCritical critical: 
			[
			[| stonResults update |
			update := RowanServiceUpdater current initializeUpdates.
			stonResults := self gciSession serverPerform: #systemBrowserSTON:
						with: environment printString , ' ' , aString.
			update applyUpdatesFromReturnedServices: (STON fromString: stonResults).
			self updateSelectionsFor: update.
			self updateTabLabel.
			update applyUpdatesFromReturnedServices: #()]
					ensure: [selectedClassChanged := false]].
	^nil
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateMethodMenu: menu [
	| item |
	methodListPresenter selectionIfNone: [^self].
	(menu class canUnderstand: #items) ifFalse: [^self].
	item := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoMethodDefinedPackage]
				ifNone: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	menu removeItem: item.
	item description: self definedMethodMenuItemLabel.
	menu addItem: item
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateMethodReferences: services [

	services do: [ :service | service command: #allReferences ].
	self issueCommand: services onCompletion: nil.
	^ services
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateMultiMethodComparison [
	comparisonPresenter
		beforeTitle: (methodListPresenter selections at: 1) classMethodDisplayString;
		afterTitle: (methodListPresenter selections at: 2) classMethodDisplayString;
		compare: (methodListPresenter selections at: 1) source
			with: (methodListPresenter selections at: 2) source.
	comparisonPresenter view invalidate
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updatePackageInfo [
	| service |
	self updateTabLabel.
	service := packageListPresenter selectionIfNone: [^self].
	self todo:[classDefinitionPresenter value: service defaultTemplate.
	self resetClassDefinitionPane.
	classCommentPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false.
	classDefinitionPresenter ensureVisible]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updatePresenter: presenter selections: selections [
	| newSelections |
	newSelections := OrderedCollection new.
	selections do: 
			[:selection |
			(presenter list detect: [:service | service name = selection name] ifNone: [])
				ifNotNil: [:newSelection | newSelections add: newSelection]].
	presenter selections: newSelections
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateSUnitTab [
	self todo:[self selectedClass
		ifNil: [sunitPresenter testClassService: nil]
		ifNotNil: [:service | self setTestClass: service]]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateSUnitTab: service [
	service ifNil: [sunitPresenter testClassService: nil] ifNotNil: [self setTestClass: service]
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateSelectionsForUpdate: update [
	update updatePackageSelectionsFor: packageListPresenter.
	update updateClassCategorySelectionsFor: classCategoryPresenter.
	update updateClassSelectionFor: classListPresenter.
	update updateClassHierarchySelectionFor: classHierarchyPresenter.
	update updateSuperclassSelectionFor: superclassListPresenter.
	update updateMethodFilterSelectionFor: self methodFilterListPresenter.
	update updateMethodSelectionFor: self methodListPresenter.
	update projectSelectionUpdate: projectListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteProjectsBrowserPresenter >> updateSingleMethodSource [
	methodSourcePresenter value: methodListPresenter selection source.
	self refreshBreakPointsIn: methodSourcePresenter.
	self displayNoMods: methodSourcePresenter. 
]
