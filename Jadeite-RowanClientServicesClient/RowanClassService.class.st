"
Don't change the order of the inst vars without checking
the index of the meta & methods inst vars. These have
constant methods for performance. 

#indexOfMetaInstVar
#indexOfMethodsInstVar
"
Class {
	#name : 'RowanClassService',
	#superclass : 'RowanService',
	#instVars : [
		'name',
		'comment',
		'instVarNames',
		'classVarNames',
		'classInstVarNames',
		'superclassName',
		'subclassType',
		'poolDictionaryNames',
		'classType',
		'meta',
		'isExtension',
		'version',
		'versions',
		'oop',
		'template',
		'filters',
		'filterType',
		'methods',
		'selectedPackageServices',
		'packageName',
		'definedPackageName',
		'selectedMethods',
		'projectName',
		'hierarchyServices',
		'variables',
		'categories',
		'isTestCase',
		'expand',
		'visibleTests',
		'isNewClass',
		'updateAfterCommand',
		'isInSymbolList',
		'dictionaryName',
		'wasRemoved',
		'renamedName',
		'hasSubclasses'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'constants' }
RowanClassService class >> computedExtensionCategory [

	^ (JadeiteCategory named: self computedExtensionCategoryName)
		  isComputed: true
]

{ #category : 'constants' }
RowanClassService class >> computedExtensionCategoryName [

	^'extensions'
]

{ #category : 'private' }
RowanClassService class >> defaultIconName [
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Behavior' extension: 'ico'.
]

{ #category : 'private' }
RowanClassService class >> icon [
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon
]

{ #category : 'instance creation' }
RowanClassService class >> named: theName [
	| inst |
	inst := self new name: theName.
	^inst
]

{ #category : 'accessing' }
RowanClassService class >> templateClassName [ 

	^#RowanClassService
]

{ #category : 'comparing' }
RowanClassService >> = classService [

	^ classService isService and: [
		  classService isClassService and: [
			  self name asString = classService name asString and: [
				  meta isNil or: [ classService meta = meta ] ] ] ]
]

{ #category : 'categories' }
RowanClassService >> addComputedCategoriesTo: presenter [

	presenter list addFirst: self class computedExtensionCategory
]

{ #category : 'private' }
RowanClassService >> addHierarchyService: service to: treeModel withParent: parentService [
	treeModel getNodeFor: service ifAbsent: [treeModel add: service asChildOf: parentService].
	(hierarchyServices at: service ifAbsent: [Array new]) do: 
			[:classService |
			self
				addHierarchyService: classService
				to: treeModel
				withParent: service].
	service hierarchyServices ifNil: [^self].
	(service hierarchyServices at: #expand ifAbsent: [^self]) do: 
			[:classService |
			classService == service
				ifFalse: 
					[self
						addHierarchyService: classService
						to: treeModel
						withParent: service]]
]

{ #category : 'private' }
RowanClassService >> addSorted: sortedAdditions to: theModel [
	theModel beSorted addAll: sortedAdditions
]

{ #category : 'hierarchy' }
RowanClassService >> addSubclassesOf: classService from: theDictionary [

	| theSubclassServices |
	theSubclassServices := hierarchyServices 
		                       at: classService
		                       ifAbsent: [ ^ nil ].
	classService subclassServices: theSubclassServices.
	theSubclassServices do: [ :subclassService | 
		self addSubclassesOf: subclassService from: theDictionary ]
]

{ #category : 'public' }
RowanClassService >> basicPrepareForReplication [
	"don't call anything potentially recursive here.
	method & package services don't iterate over subcollections"

	"methods := Array new. "

	hierarchyServices := Array new.
	selectedMethods := Array new.
	visibleTests := Array new.
	methods ifNotNil: [
		methods do: [ :methodService |
			methodService basicPrepareForReplication ] ].
	selectedMethods ifNotNil: [
		selectedMethods do: [ :methodService |
			methodService basicPrepareForReplication ] ].
	selectedPackageServices do: [ :packageService |
		packageService basicPrepareForReplication ]
]

{ #category : 'accessing' }
RowanClassService >> behaviorIdentifier [
	"for old school stuff"

	^(WriteStream on: String new)
		nextPutAll: name;
		tab;
		nextPutAll: oop printString;
		tab;
		nextPutAll: name printString;
		contents
]

{ #category : 'categories' }
RowanClassService >> categories [

	^categories
]

{ #category : 'categories' }
RowanClassService >> categories: aCollection [
	" for testing"
	categories := aCollection
]

{ #category : 'public' }
RowanClassService >> classHierarchyUpdate: presenter browser: browser [
	| treeModel subclasses parent selectedPath |
	browser isHierarchyTabSelected ifFalse: [^self].
	(self shouldBeInTree: presenter) ifFalse: [^self].
	(self reparentOrAddChildServiceIn: presenter) ifTrue: [^self].
	hierarchyServices isNil ifTrue: [^self].
	hierarchyServices isEmpty ifTrue:[^self].
	(browser isNoneProjectSelected not and: [browser packageListPresenter selections isEmpty])
		ifTrue: [^self].
	(browser isNoneProjectSelected and: [browser dictionaryListPresenter selections isEmpty])
		ifTrue: [^self].
	(browser classHierarchyPresenter model notEmpty
		and: [(browser classHierarchyPresenter model includes: self) not]) ifTrue: [^self].
	presenter selectedItem ifNotNil: [^self].
	treeModel := presenter.
	parent := nil.
	subclasses := hierarchyServices at: #nil
				ifAbsent: 
					[parent := presenter model parentOf: self.
					hierarchyServices at: #expand].
	presenter disableActivationDuring: [ 
	self todo:[selectedPath := (presenter selection selectedPath collect: [ :each | self pathItemOf: each ])].
	subclasses do:[:subclassService |
		self addSubclassesOf: subclassService from: hierarchyServices]. 
	presenter roots: subclasses. 
	presenter selectItem: (self copy meta: false). "will this scroll if necessary? If not, perhaps #selectPath:scrollToSelection: will do it - presenter selection pathOf: self"
	
	self todo:[treeModel asBag do: 
			[:classService |
			| node |
			classService selectedPackageServices: browser packageListPresenter selections browser: browser.
			node := treeModel getNodeFor: classService.
			(node children isEmpty and: [node object hasSubclasses])
				ifTrue: [treeModel add: RowanFillerClassService new asChildOf: classService]].
	selectedPath ifNotEmpty: [ 
			self selectPaths: (selectedPath collect: [ :each | self pathIndexOf: each ]) ]
	presenter selectionIfNone: [^presenter view ensureItemVisible: treeModel roots first]]].
	self todo:[presenter selection: self.
	presenter view ensureSelectionVisible]
]

{ #category : 'public' }
RowanClassService >> classMethodsUpdate: presenter browser: browser [
	browser selectedClass ifNil: [ ^self].
	self = browser selectedClass ifFalse: [^self].
	browser methodsUpdate: self
]

{ #category : 'private' }
RowanClassService >> classOrHierarchyPresenter: browser [
	^browser isClassListTabSelected
		ifTrue: [browser classListPresenter]
		ifFalse: [browser classHierarchyPresenter]
]

{ #category : 'accessing' }
RowanClassService >> comment [
	^comment
]

{ #category : 'accessing' }
RowanClassService >> comment: anObject [
	comment := anObject
]

{ #category : 'private' }
RowanClassService >> computeVisibleMethods: presenter browser: browser [
	| visibleMethods |
	methods ifNil: [ ^Array new ].
	filters := browser selectedFilters.
	visibleMethods := filters isEmpty ifTrue: [methods] ifFalse: [self filterMethods: browser].
	"visibleMethods
		do: [:svc | svc inSelectedPackage: (self selectedPackageServiceNames includes: svc packageName)]."
	^visibleMethods
]

{ #category : 'accessing' }
RowanClassService >> definedClass [
	#rowanFixMe. "looks like an update to RSR broke this. Maybe?" 
	^nil
]

{ #category : 'accessing' }
RowanClassService >> definedPackageName [
	^definedPackageName
]

{ #category : 'accessing' }
RowanClassService >> definedPackageName: anObject [
	definedPackageName := anObject
]

{ #category : 'accessing' }
RowanClassService >> dictionaryName [
	^dictionaryName
]

{ #category : 'public' }
RowanClassService >> displayMethodsOn: presenter browser: browser [
	| visibleMethods |
	visibleMethods := self computeVisibleMethods: presenter browser: browser.
	self updateListIn: presenter from: visibleMethods.
]

{ #category : 'displaying' }
RowanClassService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'displaying' }
RowanClassService >> displayString [
	| displayString |
	displayString := self name ifNil: [String new]. 
	versions ~= 1
		ifTrue: 
			[displayString := displayString , ' (' , version printString , '/' , versions printString , ')'].
	isInSymbolList == false ifTrue: [displayString := displayString , ' {' , oop printString , '}'].
	^displayString
]

{ #category : 'displaying' }
RowanClassService >> displayStringFor: displayThing browser: browser [
	(self shouldColorAsExtension: browser) ifTrue: [displayThing forecolor: Color darkMagenta].
	self isInSymbolList ifFalse: [displayThing forecolor: Color darkRed].
	^self displayString
]

{ #category : 'comparing' }
RowanClassService >> equalBeforeRename: aClassService [
	aClassService ifNil: [ ^false ].
	^self renamedName = aClassService name
]

{ #category : 'public' }
RowanClassService >> excludedInstVars [

	^super excludedInstVars, #( 'hierarchyServices' )

]

{ #category : 'accessing' }
RowanClassService >> expand [
	^expand
]

{ #category : 'accessing' }
RowanClassService >> expand: anObject [
	expand := anObject
]

{ #category : 'public' }
RowanClassService >> filterCategoryUpdate: presenter browser: browser [
	browser selectedClass ifNil: [^self].
	browser selectedClass name asString = name asString ifFalse: [^self].
	presenter model isEmpty ifTrue: [presenter list: SortedCollection new]. "needed?"
	self updateCategories: presenter browser: browser
]

{ #category : 'private' }
RowanClassService >> filterMethods: browser [ 
	^browser isCategoryTabSelected
		ifTrue: [methods select: [:methodService | filters includes: methodService category]]
		ifFalse: 
			[browser isVariablesTabSelected
				ifTrue: 
					[methods select: [:methodService | (filters intersection: methodService accessedInstVars) notEmpty]]
				ifFalse: [methods select: [:methodService | filters includes: methodService definedPackage]]]
]

{ #category : 'public' }
RowanClassService >> filterPackageUpdate: presenter browser: browser [

	browser selectedClass ifNil: [ ^ self ].
	browser selectedClass name asString = name asString ifFalse: [
		^ self ].
	presenter model isEmpty ifTrue: [
		presenter list: SortedCollection new ].
	self updateMethodPackages: presenter
]

{ #category : 'public' }
RowanClassService >> filterUpdate: presenter browser: browser [

	browser selectedClass ifNil: [ ^ self ].
	browser selectedClass name asString = name asString ifFalse: [
		^ self ].
	browser isCategoryTabSelected
		ifTrue: [
			presenter list = self jadeiteCategoriesWithExtensions ifTrue: [ ^ self ].
			self updateCategories: presenter browser: browser ]
		ifFalse: [
			browser isVariablesTabSelected
				ifTrue: [
					presenter list = variables asSortedCollection asOrderedCollection
						ifTrue: [ ^ self ].
					self updateVariables: presenter ]
				ifFalse: [
					presenter list
					= self methodPackages asSortedCollection asOrderedCollection
						ifTrue: [ ^ self ].
					self updateMethodPackages: presenter ] ]
]

{ #category : 'public' }
RowanClassService >> filterVariableUpdate: presenter browser: browser [

	browser selectedClass ifNil: [ ^ self ].
	browser isVariablesTabSelected ifFalse: [ ^ self ].
	browser selectedClass name asString = name asString ifFalse: [
		^ self ].
	presenter model isEmpty ifTrue: [
		presenter list: SortedCollection new ].
	self updateVariables: presenter
]

{ #category : 'accessing' }
RowanClassService >> filters [
	^filters
]

{ #category : 'accessing' }
RowanClassService >> filters: anObject [
	filters := anObject
]

{ #category : 'accessing' }
RowanClassService >> hasSubclasses [
	^hasSubclasses
]

{ #category : 'accessing' }
RowanClassService >> hasSubclasses: anObject [
	hasSubclasses := anObject
]

{ #category : 'comparing' }
RowanClassService >> hash [
	^self name hash
]

{ #category : 'public' }
RowanClassService >> hierarchyClassServiceNames [
	^self hierarchyClassServices collect: [:service | service name]
]

{ #category : 'public' }
RowanClassService >> hierarchyClassServices [
	"flatten the unique format that hierarchyServices is returned
	into a collection of classes found in the service"

	| classes |
	classes := Set new.
	hierarchyServices keysAndValuesDo: 
			[:anchor :chain |
			classes add: anchor.
			chain do: [:service | classes add: service]].
	^classes reject:[:service | service == #nil]. 
]

{ #category : 'accessing' }
RowanClassService >> hierarchyServices [
	^hierarchyServices
]

{ #category : 'accessing' }
RowanClassService >> hierarchyServices: anObject [
	hierarchyServices := anObject
]

{ #category : 'constants' }
RowanClassService >> indexOfMetaInstVar [
	"performance enhancement"
	^17
]

{ #category : 'constants' }
RowanClassService >> indexOfMethodsInstVar [
	"performance enhancement"

	^25
]

{ #category : 'Init / Release' }
RowanClassService >> initialize [
	
	super initialize. 
	filters := Array new. 
	selectedPackageServices := Array new. "method list browser will not have packages to select"
	isTestCase := false. 
	isNewClass := false. 
	wasRemoved := false. 
	hasSubclasses := false. 
]

{ #category : 'accessing' }
RowanClassService >> instVarNames [
	^instVarNames
]

{ #category : 'testing' }
RowanClassService >> isClassService [

	^true
]

{ #category : 'testing' }
RowanClassService >> isDefined [

	^isExtension not
]

{ #category : 'accessing' }
RowanClassService >> isExtension [

	^isExtension
]

{ #category : 'accessing' }
RowanClassService >> isExtension: anObject [
	isExtension := anObject
]

{ #category : 'accessing' }
RowanClassService >> isInSymbolList [
	^isInSymbolList
]

{ #category : 'testing' }
RowanClassService >> isMeta [
	"meta may be nil, hence the == test"
	^meta == true	
]

{ #category : 'accessing' }
RowanClassService >> isNewClass [
	^isNewClass
]

{ #category : 'accessing' }
RowanClassService >> isNewClass: anObject [
	isNewClass := anObject
]

{ #category : 'public' }
RowanClassService >> isTestCase [
	^isTestCase ifNil:[false]
]

{ #category : 'categories' }
RowanClassService >> jadeiteCategories [
	"for comparing against presenter lists"

	^self jadeiteCategoriesFor: categories
]

{ #category : 'accessing' }
RowanClassService >> jadeiteCategoriesFor: aCollection [
	"for comparing against presenter lists"

	^ aCollection collect: [ :categoryOrString |
		  categoryOrString isString
			  ifFalse: [ categoryOrString ]
			  ifTrue: [ JadeiteCategory named: categoryOrString ] ]
]

{ #category : 'categories' }
RowanClassService >> jadeiteCategoriesWithExtensions [

	^ (self jadeiteCategoriesFor: categories)
		  addFirst: self class computedExtensionCategory;
		  yourself
]

{ #category : 'printing' }
RowanClassService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: name
]

{ #category : 'printing' }
RowanClassService >> logSentOn: aStream [
	super logSentOn: aStream.
	aStream
		space;
		nextPutAll: name
]

{ #category : 'accessing' }
RowanClassService >> meta [
	^meta
]

{ #category : 'accessing' }
RowanClassService >> meta: anObject [
	meta := anObject
]

{ #category : 'accessing' }
RowanClassService >> methodPackages [
	^(methods collect: [:methodService | methodService definedPackage]) asSet asSortedCollection asOrderedCollection
]

{ #category : 'public' }
RowanClassService >> methodUpdate: presenter browser: anObject [
	presenter list ifNil:[^self]. 
	presenter list do: 
			[:methodService |
			| updatedMethodService |
			updatedMethodService := methods detect: [:newMethodService | newMethodService = methodService]
						ifNone: [].
			updatedMethodService
				ifNotNil: 
					[:service |
					methodService replicateFrom: updatedMethodService	"#replicateFrom: will ensure we only replicate the proper methods"]].
	self todo:[presenter view invalidate]
]

{ #category : 'accessing' }
RowanClassService >> methods [
	^methods
]

{ #category : 'accessing' }
RowanClassService >> methods: anObject [
	methods := anObject
]

{ #category : 'public' }
RowanClassService >> methodsWithBreakpoints [
	^methods detect: [:methodService | methodService breakPoints notEmpty]
]

{ #category : 'private' }
RowanClassService >> moveNodeToBeChildOf: superclassService in: classHierarchyPresenter [
	| superclassNode myNode |
	superclassNode := classHierarchyPresenter model getNodeFor: superclassService.
	myNode := classHierarchyPresenter model getNodeFor: self.
	((classHierarchyPresenter model childrenOfNode: superclassNode) includes: myNode)
		ifFalse: 
			[classHierarchyPresenter model move: self asChildOf: superclassService].
	classHierarchyPresenter view expand: myNode
]

{ #category : 'accessing' }
RowanClassService >> name [
	^name
]

{ #category : 'accessing' }
RowanClassService >> name: aString [
	name := aString asString
]

{ #category : 'accessing' }
RowanClassService >> oop [
	^oop
]

{ #category : 'accessing' }
RowanClassService >> oop: anObject [
	oop := anObject
]

{ #category : 'accessing' }
RowanClassService >> packageName [
	^packageName
]

{ #category : 'accessing' }
RowanClassService >> packageName: anObject [
	packageName := anObject
]

{ #category : 'public' }
RowanClassService >> postReload [
	" don't retain reference to (possibly) different version of class"

	oop := nil
]

{ #category : 'public' }
RowanClassService >> prepareForReplication [
	super prepareForReplication.
	self basicPrepareForReplication
]

{ #category : 'accessing' }
RowanClassService >> projectName [
	^projectName
]

{ #category : 'must not strip' }
RowanClassService >> remoteServiceName [
	^'Rowan classServiceClass'
]

{ #category : 'public' }
RowanClassService >> removedClass: presenter [
	| removal |
	updateType == #removedClass: ifFalse: [^self].
	removal := presenter model asBag detect: [:classService | classService name = name] ifNone: [].
	removal
		ifNotNil: 
			[presenter model
				removeWithoutNotification: removal
				ifAbsent: []
				view: presenter view]
]

{ #category : 'public' }
RowanClassService >> renamedClass: presenter browser: browser [
	"because class service equality is name-based, 
	we can't just do a simple replication. We have to
	remove then add the class service to ensure the
	list doesn't get in trouble"

	presenter model asBag do: 
			[:classService |
			(self equalBeforeRename: classService)
				ifTrue: 
					[| wasSelected |
					wasSelected := (presenter selectionIfNone: []) = classService.
					presenter model remove: classService.
					classService basicReplicateFrom: self.
					classService renamedName: nil.
					presenter model add: classService.
					wasSelected
						ifTrue: 
							[presenter selection: classService.
							browser classDefinitionPresenter value: template.
							browser displayNoMods: browser classDefinitionPresenter]]].
	presenter view invalidate
]

{ #category : 'public' }
RowanClassService >> renamedClassInHierarchy: presenter browser: anObject [
	"because class service equality is name-based, 
	we have to remove then add the class service
	to ensure the tree can find it"

	presenter model asBag do: 
			[:classService |
			(self equalBeforeRename: classService)
				ifTrue: 
					[| parent children wasSelected |
					wasSelected := (presenter selectionIfNone:[]) = classService.
					parent := presenter model parentOf: classService.
					children := presenter model getChildrenOf: classService.
					children do: [:child | presenter model remove: child ifAbsent: []].
					presenter model remove: classService ifAbsent: [].
					classService basicReplicateFrom: self.
					classService renamedName: nil.
					presenter model add: classService asChildOf: parent.
					children do: [:child | presenter model add: child asChildOf: classService].
					presenter view expand: parent.
					presenter view ensureItemVisible: classService.
					wasSelected ifTrue: [presenter selection: classService]]]
]

{ #category : 'accessing' }
RowanClassService >> renamedName [
	^renamedName
]

{ #category : 'accessing' }
RowanClassService >> renamedName: anObject [
	renamedName := anObject
]

{ #category : 'private' }
RowanClassService >> reparentOrAddChildServiceIn: presenter [
	| superclassService |
	superclassService := self superclassServiceIn: presenter.
	superclassService ifNil:[^false]. 
	(presenter model asBag includes: self)
		ifTrue: 
			[(presenter model parentOf: self) = superclassService
				ifFalse: 
					[presenter model move: self asChildOf: superclassService.
					^true].
			^false].
	presenter model add: self asChildOf: superclassService.
	^true
]

{ #category : 'public' }
RowanClassService >> replicateFrom: newService [
	newService isClassService
		ifTrue: [self = newService ifTrue: [^super basicReplicateFrom: newService]]
]

{ #category : 'Init / Release' }
RowanClassService >> rowanPostUpdate [
	super rowanPostUpdate.
	hierarchyServices := nil.
	methods := Array new.
	renamedName := nil
]

{ #category : 'actions' }
RowanClassService >> saveMethod: source category: category session: session [

	self
		command: #saveMethodSource:category:;
		commandArgs: (Array with: source with: category).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'accessing' }
RowanClassService >> selectedMethods [

	^selectedMethods
		
]

{ #category : 'private' }
RowanClassService >> selectedPackageNames [
	^selectedPackageServices
		ifNil: [Array new]
		ifNotNil: [selectedPackageServices collect: [:packageService | packageService name]]
]

{ #category : 'private' }
RowanClassService >> selectedPackageServiceNames [
	^selectedPackageServices collect: [:pkgService | pkgService name]
]

{ #category : 'accessing' }
RowanClassService >> selectedPackageServices [
	^selectedPackageServices
]

{ #category : 'accessing' }
RowanClassService >> selectedPackageServices: collection [
	selectedPackageServices := collection
]

{ #category : 'accessing' }
RowanClassService >> selectedPackageServices: anObject browser: browser [
	"selected packages don't apply when dictionaries are showing"

	selectedPackageServices := browser isRowanProjectSelected ifTrue: [anObject] ifFalse: [Array new]
]

{ #category : 'private' }
RowanClassService >> shouldBeInTree: presenter [

	"I should go in the tree if either I or my parent is in the tree"

	(presenter contains: self) ifTrue: [ ^ true ].
	presenter roots isEmpty ifTrue:[^true]. 
	^presenter contains: (RowanClassService new name: superclassName)
]

{ #category : 'public' }
RowanClassService >> shouldColorAsExtension: browser [
	^browser isNoneProjectSelected
		ifTrue: [false]
		ifFalse: 
			[browser selectedPackageServices isEmpty
				ifTrue: [false]
				ifFalse: 
					[((browser selectedPackageServices collect: [:service | service name]) includes: definedPackageName)
						not]]
]

{ #category : 'public' }
RowanClassService >> shouldReplicateInstVarAtIndex: index newService: newService [
	(super shouldReplicateInstVarAtIndex: index newService: newService) ifFalse:[^false]. 
	self indexOfMetaInstVar = index ifTrue: [^false].
	self indexOfMethodsInstVar = index ifTrue: [newService meta = meta ifFalse: [^false]].
	^true
]

{ #category : 'public' }
RowanClassService >> silentlyExpandHierarchyOneLevel: treeView [
	| presenter |
	presenter := treeView presenter.
	Cursor wait showWhile: 
			[| selection |
			treeView model removeChildrenOf: self.
			self command: #oneLevelClassHierarchy.
			RowanServiceUpdater current issueCommand: self session: GciSession current.
			selection := treeView model asBag detect: [:classService | classService name = self name] ifNone: [].
			selection ifNotNil: [presenter selection: selection]]
]

{ #category : 'accessing' }
RowanClassService >> sortAspect [

	^name
]

{ #category : 'accessing' }
RowanClassService >> subclassServices [

	^self subclassResponsibility
]

{ #category : 'accessing' }
RowanClassService >> subclassServices: anObject [

	^self subclassResponsibility
]

{ #category : 'public' }
RowanClassService >> sunitMethodsUpdate: presenter browser: browser [
	| selections oldClassService |
	browser classListPresenter selections isEmpty ifTrue: [^self].
	browser classListPresenter selections size > 1
		ifFalse: [browser classListPresenter jaditeSelection name asString = name asString ifFalse: [^self]].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	selections := browser classListPresenter selections asOrderedCollection.
	oldClassService := selections detect: [:classService | classService = self] ifNone: [^self].
	oldClassService replicateFrom: self. 
	browser updateMethodsFrom: selections
]

{ #category : 'private' }
RowanClassService >> superclassServiceIn: presenter [
	| superclassService path |
	(presenter pathIndexOf: (Array with: self)) first = 0 ifTrue:[^nil]. 
	superclassService := RowanClassService new name: superclassName.
	(path := presenter pathIndexOf: (Array with: superclassService)) first = 0 ifTrue:[^nil]. 
	^(presenter itemAtPath: (Array with: path)) first
]

{ #category : 'accessing' }
RowanClassService >> template [
	^template
]

{ #category : 'accessing' }
RowanClassService >> template: anObject [
	template := anObject
]

{ #category : 'public' }
RowanClassService >> toolTip [
	^'Defined package: ' , self definedPackageName
]

{ #category : 'updates' }
RowanClassService >> updateAfterCommand: boolean [

	updateAfterCommand := boolean
]

{ #category : 'categories' }
RowanClassService >> updateCategories: presenter browser: browser [
	"Update without losing selections hopefully"

	| jadeiteCategories |
	meta = browser isClassSideSelected ifFalse: [ ^ self ].
	browser isCategoryTabSelected ifFalse: [ ^ self ].
	jadeiteCategories := categories collect: [ :category |
		                     JadeiteCategory named: category ].
	presenter model replaceAndSort: jadeiteCategories.
	browser isDictionaryTabSelected ifFalse: [
		self addComputedCategoriesTo: presenter ].
	presenter model announcer announce:
		(ValueChanged newValue: presenter model) "necessary to get gui to update"
]

{ #category : 'updates' }
RowanClassService >> updateListIn: presenter from: visibleMethods [
	| updated theModel toRemove toAdd |
	theModel := presenter hasSelection
				ifTrue: 
					[(visibleMethods includesAnyOf: presenter selections)
						ifTrue: [presenter model]
						ifFalse: [presenter model copy]]
				ifFalse: [presenter model copy].
	toRemove := OrderedCollection new.
	presenter list copy do: 
			[:old |
			updated := visibleMethods detect: [:new | new = old] ifNone: [].
			updated ifNil: [toRemove add: old] ifNotNil: [old replicateFrom: updated]].
	theModel removeAll: toRemove.
	toAdd := SortedCollection new sortBlock: [:x :y | x selector < y selector].
	visibleMethods do: 
			[:new |
			updated := theModel detect: [:old | new = old] ifNone: [].
			updated ifNil: [toAdd add: new]].
	self addSorted: toAdd to: theModel.
	(presenter parentPresenter class canUnderstand: #updateSUnitTab)
		ifTrue: [presenter parentPresenter updateSUnitTab].
	theModel == presenter model ifFalse: [presenter model: theModel]
]

{ #category : 'updates' }
RowanClassService >> updateMethodPackages: presenter [

	presenter list = self methodPackages asSortedCollection asOrderedCollection
		ifFalse: [ presenter list: self methodPackages ]
]

{ #category : 'updates' }
RowanClassService >> updateVariables: presenter [

	variables ifNil: [ ^ self ].
	presenter list = variables asSortedCollection asOrderedCollection
		ifFalse: [
		presenter list: variables asSortedCollection asOrderedCollection ]
]

{ #category : 'updates' }
RowanClassService >> updatedClass: aPresenter browser: browser [
	browser updateClass: self
]

{ #category : 'updates' }
RowanClassService >> updatedClassDefinition: classDefinitionPresenter browser: browser [
	(browser selectedClass = self or: [self equalBeforeRename: browser selectedClass])
		ifTrue: 
			[classDefinitionPresenter view isModified
				ifFalse: 
					[classDefinitionPresenter value: template.
					self todo:[browser displayNoMods: classDefinitionPresenter]]]
]

{ #category : 'updates' }
RowanClassService >> updatedClassInHierarchy: classHierarchyPresenter browser: projectBrowser [
	"a newly added class should show up in the list but selection (say) of an existing class
	should in another browser that isn't in the displayed hierarchy but exists in the full 
	hierarchy should not"

	| classNode superclassService selectedPackageNames |
	
	self todo: [classHierarchyPresenter view invalidate.
	classNode := classHierarchyPresenter model getNodeFor: self ifAbsent: [^self].
	superclassService := classHierarchyPresenter model parentOf: self.
	(self isNewClass not and: [classNode parent object ~= superclassService])
		ifTrue: [self moveNodeToBeChildOf: superclassService in: classHierarchyPresenter].
	projectBrowser packageListPresenter selections isEmpty ifTrue: [^self].
	selectedPackageNames := projectBrowser packageListPresenter selections
				collect: [:packageService | packageService name].
	(selectedPackageNames includes: packageName) ifFalse: [^self].
	classNode object replicateFrom: self.
	classNode parent object = superclassService
		ifFalse: [classHierarchyPresenter model move: self asChildOf: superclassService]]
]

{ #category : 'updates' }
RowanClassService >> updatedOneLevelInClassHierarchy: classHierarchyPresenter browser: projectBrowser [
	updateType = #updatedOneLevelInClassHierarchy:browser: ifFalse: [ "must be specifically requested by server"
		^ self ].
	self subclassServices = (hierarchyServices at: #expand) ifTrue: [ 
		^ self ].
	self subclassServices: (hierarchyServices at: #expand).
	self subclassServices do: [ :subclassService | 
		subclassService hasSubclasses ifTrue: [ 
			subclassService subclassServices:
				(subclassService hierarchyServices ifNotNil: [ :hier | 
					 hier at: #expand ]) ] ]
]

{ #category : 'accessing' }
RowanClassService >> variables [
	^variables
]

{ #category : 'accessing' }
RowanClassService >> version [
	"Private - for testing"
	^version
]

{ #category : 'accessing' }
RowanClassService >> versions [
	"Private - for testing"
	^versions
]

{ #category : 'accessing' }
RowanClassService >> visibleTests [
	^visibleTests ifNil: [Array new]
]

{ #category : 'accessing' }
RowanClassService >> wasRemoved [
	^wasRemoved == true
]

{ #category : 'accessing' }
RowanClassService >> wasRemoved: anObject [
	wasRemoved := anObject
]

{ #category : 'public' }
RowanClassService >> wasRenamed [

	^renamedName notNil
]
