Class {
	#name : 'MethodListPresenter',
	#superclass : 'JadePresenterA',
	#instVars : [
		'methodListPresenter'
	],
	#category : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
MethodListPresenter class >> publishedEventsOfInstances [
    
    	^super publishedEventsOfInstances
			add: #'classSelectionChanged';
			add: #'methodSelectionChanged';
			add: #'needFilterList';
			add: #'needIsMeta';
			add: #'needIsVariables';
			add: #'needClassList';
			yourself.

]

{ #category : 'as yet unclassified' }
MethodListPresenter class >> resource_MultiClass_view [
	"Answer the literal data from which the 'MultiClass view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_MultiClass_view)
	"

	^#(#'!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 0 0 34 2 8 1409286144 131073 416 0 0 0 5 0 0 0 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 0 416 34 2 8 1140920905 1025 576 590662 2 ##(Smalltalk.ListModel) 138 144 528 0 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 0 13 265030 4 ##(Smalltalk.Menu) 0 true 34 10 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #removeFromList 8 'Remove from &List' 1 1 0 0 0 818 1 850 #browseClass 8 'Browse Class' 1 1 0 0 0 983366 1 ##(Smalltalk.DividerMenuItem) 4097 818 1 850 #browseImplementors 8 'Browse &Implementors' 1 1 0 0 0 818 1 850 #browseImplementorsOf 8 'Browse Implementors of ...' 1 1 0 0 0 818 1 850 #browseSenders 8 'Browse &Senders' 1 1 0 0 0 818 1 850 #browseSendersOf 8 'Browse Senders of ...' 1 1 0 0 0 818 1 850 #browseMethodsContaining 8 'Browse Methods Containing ...' 1 1 0 0 0 946 4097 818 1 850 #runTests 8 'Run &Test(s)' 1 1 0 0 0 8 '' 0 134217729 0 0 0 0 0 0 0 576 0 8 4294902371 459270 ##(Smalltalk.Message) #displayString 8 #() 0 1049926 1 ##(Smalltalk.IconImageManager) 0 0 0 0 0 0 138 144 34 5 920646 5 ##(Smalltalk.ListViewColumn) 8 'Dictionary' 201 #left 1314 #displayString 8 #() 1314 #<= 1488 787814 3 ##(Smalltalk.BlockClosure) 0 0 1180966 ##(Smalltalk.CompiledExpression) 3 1 1520 8 'doIt' 8 '[:each | each gsClass dictionary]' 8 #[31 105 226 0 159 106] #gsClass #dictionary 1536 7 257 0 0 576 0 1 0 0 1426 8 'Class Category' 241 #left 1314 #displayString 8 #() 1314 #<= 1680 1522 0 0 1554 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each gsClass category]' 8 #[31 105 226 0 159 106] #gsClass #category 1712 7 257 0 0 576 0 3 0 0 1426 8 'Class' 241 #left 1314 #displayString 8 #() 1314 #<= 1840 1522 0 0 1554 3 1 1520 8 'doIt' 8 '[:each | each gsClass name]' 8 #[31 105 226 0 159 106] #gsClass #name 1872 7 257 0 0 576 0 3 0 0 1426 8 'Method Category' 241 #left 1314 #displayString 1680 1314 #<= 1680 1522 0 0 1554 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each category]' 8 #[30 105 226 0 106] #category 2016 7 257 0 0 576 0 3 0 0 1426 8 'Method' 241 #left 1314 #displayString 1344 ##(Smalltalk.SortedCollection) 1522 0 0 1554 2 1 1520 8 'doIt' 8 '[:each | each name]' 8 #[30 105 226 0 106] #name 2144 7 257 0 0 576 0 3 0 0 #report 528 0 131169 0 34 4 0 0 328198 ##(Smalltalk.Point) 1 1 0 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 2242 1 1 2242 1201 401 576 2338 #contextMenu: 34 1 784 576 2338 #text: 34 1 8 'Dictionary' 576 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 88 2 0 0 200 0 0 0] 8 #() 2242 193 193 0 27 8 'methodList' 0 2274 138 144 34 1 2338 #createAt:extent: 34 2 2242 5119 21 2242 1201 401 416 2498 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 9 0 0 10 0 0 0 87 12 0 0 210 0 0 0] 34 1 576 2560 0 27 )
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> anyMethod [

	^methodListPresenter list anyOne.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> browseImplementors [
	^self browseImplementorsOf: methodListPresenter selection selector
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> browseSenders [

	self browseSendersOf: methodListPresenter selection selector.
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> createComponents [

	super createComponents.
	methodListPresenter :=  self add: ListPresenter new name: 'methodList'.

]

{ #category : 'initialization' }
MethodListPresenter >> initializeMethodListTable [

	methodListPresenter := JadeiteTablePresenter new
		                       addColumn: (SpStringTableColumn
				                        title: 'Project'
				                        evaluated: [ :service | 
					                        service projectName ]) beNotExpandable;
		                       addColumn: (SpStringTableColumn
				                        title: 'Package'
				                        evaluated: [ :service | 
					                        service packageName ]);
		                       addColumn: (SpStringTableColumn
				                        title: 'Class'
				                        evaluated: [ :service | service className ]);
		                       addColumn: (SpStringTableColumn
				                        title: 'Category'
				                        evaluated: [ :service | service category ]);
		                       addColumn: (SpStringTableColumn
				                        title: 'Method'
				                        evaluated: [ :service | service selector ]);
		                       yourself.
	self layout add: methodListPresenter
]

{ #category : 'initialization' }
MethodListPresenter >> initializePresenters [

	super initializePresenters.
	self initializeMethodListTable. 
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> list: aList [
	methodListPresenter list: aList.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> methodSelectionChanged [

	self trigger: #'methodSelectionChanged'.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> onDrag: aSession [ 

	| list |
	list := methodListPresenter selections collect: [:each | 
		(aSession newDragObject: each)
			format: #method data: each;
			yourself.
	].
	aSession 
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy;
		yourself.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> onLeftButtonPressed: aMouseEvent [

	self trigger: #'leftButtonPressed:' with: aMouseEvent.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> primaryPresenter [

	^methodListPresenter.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> queryCommand: aCommandQuery [
	(#(#browseClass #browseClassReferences #browseImplementors #browseSenders #browseHierarchyImplementors #browseHierarchySenders #browseInExistingBrowser)
		includes: aCommandQuery commandSymbol)
			ifTrue: 
				[aCommandQuery
					isEnabled: methodListPresenter selections size = 1;
					receiver: self;
					yourself.
				^true].
	(#(#runTests) includes: aCommandQuery commandSymbol)
		ifTrue: 
			[aCommandQuery
				isEnabled: (methodListPresenter selections notEmpty and: [self selectedMethodsAreTestCases]).
			^true].
	(#(#removeFromList) includes: aCommandQuery commandSymbol)
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
			^true].
	^super queryCommand: aCommandQuery
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> removeFromList [

	methodListPresenter selections copy do: [:each | 
		methodListPresenter model removeAtIndex: (methodListPresenter model list indexOf: each).
	].

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> runTests [

	| list |
	list := methodListPresenter selections.
	list do: [:each | 
		self gciSession 
			serverPerform: #'runAsTest:'
			with: each.
	].
	MessageBox notify: list size printString , ' test(s) passed!'.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> selectFirstMethod [

	methodListPresenter list notEmpty ifTrue: [
		methodListPresenter selectionByIndex: 1.
	].

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> selectMethod: aGsMethod [

	methodListPresenter selection: aGsMethod ifAbsent: []
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> selectedClasses [

	^nil
]

{ #category : 'as yet unclassified' }
MethodListPresenter >> selectedMethod [

	^methodListPresenter selectionOrNil.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> selectionOrNil [

	^methodListPresenter selectionOrNil.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> subMenuName [

	^'&Methods'.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> subMenuPresenter [

	^methodListPresenter.

]

{ #category : 'as yet unclassified' }
MethodListPresenter >> withSelectorDo: aBlock [

	| selector result list |
	(selector := Prompter prompt: 'Enter selector:') isNil ifTrue: [^self].
	selector := selector reject: [:each | each = Character space].
	(selector includes: $*) ifFalse: [
		aBlock value: selector.
		^self.
	].
	result := gciSession
		serverPerform: #selectorsMatching:
		with: selector.
	result isNil ifTrue: [^self].
	list := result subStrings: Character lf.
	(selector := ChoicePrompter choices: list) isNil ifTrue: [^self].
	aBlock value: selector.

]
