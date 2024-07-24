"
This class register information in the registry (JadeAutocompletationRegistry) each time a user select a class in the hierarchy browser.

see:
#registerClassData
"
Class {
	#name : 'JadeAutoSystemBrowserPresenter',
	#superclass : 'JadeSystemBrowserPresenter',
	#instVars : [
		'lastGsShape'
	],
	#category : 'Jadeite-Browser',
	#package : 'Jadeite-Browser'
}

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> codePresenterIsMethod [

	^true
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> createArrayFromString: arrayString [
	| startParenthesis endParenthesis|

	startParenthesis := (arrayString indexOfSubCollection: '(') + 1.
	endParenthesis := (arrayString indexOfSubCollection: ')')  - 1.

	[^((arrayString copyFrom: startParenthesis to: endParenthesis) subStrings: ' ') select: [:each | each notEmpty]] on: Error do: [:ex | ^Array new]

]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> getClassHierarchy [
	"
classHierarchyPresenter model anArray of Arrays #(#('Object') #('Object' 'Boolean') #('Object' 'True'))"

	^classHierarchyPresenter model asOrderedCollection detect: [:eachArray | eachArray last = self getClassName] ifNone: [#()]	
"
	^classHierarchyPresenter selection
"
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> getClassName [

	"classHierarchyPresenter hasSelection ifFalse: [^'none'].

	^classHierarchyPresenter selection last."

	^(self selectedClasses size = 1) 
	ifFalse: ['none']
	ifTrue: [self selectedClasses last]
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> gsClassMethods [

	^methodListPresenter model collect: [:each | each first]
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> gsClassPoolDictionaries [
	| arrayString i j |

	classDefinition ifNil: [^#()].
	i := classDefinition indexOfSubCollection: 'poolDictionaries:'.
	j := classDefinition indexOfSubCollection: 'inDictionary:'.
	(i == 0 or: [j == 0]) ifTrue: [^#()].
	arrayString := (classDefinition copyFrom: i to: j - 1) allButFirst: 17"poolDictionaries:".

	^self createArrayFromString: arrayString.
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> gsClassVariables [
	| arrayString i j |

	classDefinition ifNil: [^#()].
	i := classDefinition indexOfSubCollection: 'classVars:'.
	j := classDefinition indexOfSubCollection: 'classInstVars:'.
	(i == 0 or: [j == 0]) ifTrue: [^#()].
	arrayString := (classDefinition copyFrom: i to: j - 1) allButFirst: 10 "classVars:".

	^self createArrayFromString: arrayString.
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> gsInstClassVariables [
	| arrayString i j |

	classDefinition ifNil: [^#()].
	i := classDefinition indexOfSubCollection: 'classInstVars:'.
	j := classDefinition indexOfSubCollection: 'poolDictionaries:'.
	(i == 0 or: [j == 0]) ifTrue: [^#()].
	arrayString := (classDefinition copyFrom: i to: j - 1) allButFirst: 14 "classInstVars:".

	^self createArrayFromString: arrayString.
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> gsInstVariables [
	"The receiver get the instances variable names of the selected class from the class definition pane <classDefinition>"
	| instVars arrayString |

	classDefinition ifNil: [^self].
	((classDefinition indexOfSubCollection: 'instVarNames:') = 0) ifTrue: [^#()].
	((classDefinition indexOfSubCollection: 'classVars:') = 0) ifTrue: [^#()].
	arrayString := (classDefinition copyFrom: (classDefinition indexOfSubCollection: 'instVarNames:') to:  (classDefinition indexOfSubCollection: 'classVars:') - 1) allButFirst: 13 "remove: -instVarNames:-".

	instVars := self createArrayFromString: arrayString.

	^instVars
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> gsMethods [

	^methodListPresenter model collect: [:each | each first]
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> hasClassSideSelected [

	^classListHierarchyTabs currentCard name = 'classTab'
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> lastGsShape [
	^lastGsShape
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> lastGsShape: anObject [
	lastGsShape := anObject
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> newMethodPresenter [

	^JadeTextPresenter new.
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> removeClass [
	| list |

	list := self selectedClasses.
	
	super removeClass.

	list do: [:each | self registry unregister: each]
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> restoreFrom: aJadeHistoryEntry [
	aJadeHistoryEntry isPackageSelected
		ifTrue: 
			[self isPackageListTabSelected ifFalse: [packageDictionaryTabs previousCard].
			packageListPresenter selections: aJadeHistoryEntry packageOrDictionary ifAbsent: []]
		ifFalse: 
			[self isPackageListTabSelected ifTrue: [packageDictionaryTabs nextCard].
			dictionaryListPresenter selections: aJadeHistoryEntry packageOrDictionary ifAbsent: []].
	classCategoryPresenter selection: aJadeHistoryEntry classCategory ifAbsent: [].
	aJadeHistoryEntry isHierarchySelected
		ifTrue: 
			[self isClassListTabSelected ifTrue: [classHierarchyTabs nextCard].
			classHierarchyPresenter selection: aJadeHistoryEntry className ifAbsent: []]
		ifFalse: 
			[self isClassListTabSelected ifFalse: [classHierarchyTabs previousCard].
			classListPresenter selection: aJadeHistoryEntry className ifAbsent: []].
	aJadeHistoryEntry isCategoriesSelected
		ifTrue: 
			[self isCategoryTabSelected ifFalse: [methodFilterTabs previousCard].
			categoryListPresenter selection: aJadeHistoryEntry categoriesOrVariables ifAbsent: []]
		ifFalse: 
			[self isCategoryTabSelected ifTrue: [methodFilterTabs nextCard].
			variableListPresenter selection: aJadeHistoryEntry categoriesOrVariables ifAbsent: []].
	methodListPresenter selection: aJadeHistoryEntry methodName ifAbsent: [].
	self resetCursor
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> updateAndSelect: aView [

	super updateAndSelect: aView.

	inUpdate ifTrue: [^self]. "when the browser is updating we avoid to register any data we must wait until the browser has finish"

	self registerClassData.
]

{ #category : 'as yet unclassified' }
JadeAutoSystemBrowserPresenter >> updateMethodList [
	"The receiver must keep update with any add/remove of a method in order to be acurate in the autocompletation"

	super updateMethodList.

	lastGsShape ifNil: [^self].

	categoryListPresenter hasSelection ifTrue: [^self]. "if a category is selected then not all methods are displayed --> we only register a class data with ALL methods (no category selected)"

	self hasClassSideSelected ifTrue: [^lastGsShape gsClassMethods: self gsClassMethods].

	^lastGsShape gsMethods: self gsMethods.
]
