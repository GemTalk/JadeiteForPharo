Class {
	#name : 'JadeiteMethodListPresenter',
	#superclass : 'RowanMethodListPresenter',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait',
	#instVars : [
		'textAreaTabs',
		'comparisonTab',
		'comparisonPresenter',
		'autoCommit',
		'search',
		'statusBarText',
		'firstReferenceString'
	],
	#pools : [
		'ScintillaConstants'
	],
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'actions' }
JadeiteMethodListPresenter >> abortTransaction [

	| abortResults |
	abortResults := self application abortTransaction.
	self refreshList.
	^ abortResults
]

{ #category : 'events' }
JadeiteMethodListPresenter >> abortedTransaction [

	self methodListPresenter selectedItem ifNotNil: [ :service |
		self methodSourcePresenter value: service source ].
	self removeCompileWarningColor. 
	self statusBarText pushMessage: String new. 
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> addStyle: aString [
	"don't send the super because we don't want the toolbar to be the same color as source pane"
	methodSourcePresenter addStyle: aString.
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> autoCommit: boolean [
	autoCommit value: boolean
]

{ #category : 'queries' }
JadeiteMethodListPresenter >> basicBrowseClassReferences: className session: session completionBlock: completionBlock [

	| service |
	service := RowanQueryService
		           command: #browseClassReferences:
		           withArgs: (Array with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: session
		onCompletion: completionBlock.
	^ service
]

{ #category : 'queries' }
JadeiteMethodListPresenter >> browseClassReferences [

	^ self browseClassReferences: self methodListPresenter selectedItem className
]

{ #category : 'queries' }
JadeiteMethodListPresenter >> browseClassReferences: className [

	| shell |
	self
		basicBrowseClassReferences: className
		session: self gciSession
		completionBlock: [ :service |
			shell := self openMethodListOn: service selecting: className.
			shell updateCaptionFromSearchString:
				service queryResults size printString , ' Class References to '
				, className asString ]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> cleanupComparisonBrowser [
	self todo:[comparisonPresenter
		beforeTitle: String new;
		afterTitle: String new;
		compare: String new with: String new]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> clearAllBreakpoints [
	^JadePresenter clearAllBreaksIn: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> clearMethodBreakpoints [
	^JadePresenter clearMethodBreakpoints: methodListPresenter selections in: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> comparisonPresenter [

	^comparisonPresenter
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> comparisonTab [
	^comparisonTab
		ifNil: 
			[comparisonTab := self textTabs
						detect: [:each | (each class canUnderstand: #text) ifTrue: [each text = 'Comparison'] ifFalse: [each = 'Comparison']]]
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> connectPresenters [

	super connectPresenters.
	methodListPresenter whenSelectionChangedDo: [ :selection |
		self updateMethodSource.
		self selectFirstReference: selection selectedItem ].
	methodSourcePresenter whenSubmitDo: [ :text | self editSave ].
	methodSourcePresenter whenResetDo: [
		methodSourcePresenter text:
			methodSourcePresenter methodService source.
		methodSourcePresenter isModified: false.
		self updateMethodSourceGlyphs ].
	self application
		when: #abortedTransaction
		send: #abortedTransaction
		to: self
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> contextObject [
	| methodService classService |
	methodService := methodListPresenter methodListPresenter selectionIfNone: [^nil].
	classService := RowanClassService named: methodService className.
	self updateService: classService.
	^classService oop
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'drag & drop' }
JadeiteMethodListPresenter >> dropMethods: array [

	| sorted |
	sorted := SortedCollection withAll: methodListPresenter list.
	sorted addAll: array.
	methodListPresenter list: (ListModel withAll: sorted).
	self refreshList.
	methodListPresenter unselectAll.
	methodListPresenter selectItem: array first
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> editSave [

	^methodSourcePresenter saveAction ifNotNil: [:action | action value]
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> editSaveMethod [

	methodListPresenter selectedItem ifNotNil: [ :selection |
		self editSaveMethod: selection classService onCompletion: nil ]
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> editSaveMethod: classService onCompletion: completionBlock [

	| compileResult |
	classService meta: self methodListPresenter selectedItem meta.
	compileResult := self
		                 editSaveMethod: classService
		                 in: methodSourcePresenter
		                 category: methodListPresenter selectedItem category
		                 onCompletion: [
			                 self updateService: classService onCompletion: [
				                 self statusBarText message ifNotNil: [ :text |
					                 text isEmpty ifTrue: [ "don't reselect methods when status bar is full so as not to upset the compile information"
						                 classService selectedMethods ifNotNil: [
							                 :methodServices |
							                 methodServices notEmpty ifTrue: [ "there will be no method selected on a compiler error"
								                 self selectMethodsFrom: classService ] ].
						                 completionBlock value ] ] ] ]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> fileSave [

	self halt. 
]

{ #category : 'accessing' }
JadeiteMethodListPresenter >> firstReferenceString [

	^ firstReferenceString
]

{ #category : 'accessing' }
JadeiteMethodListPresenter >> firstReferenceString: anObject [

	firstReferenceString := anObject
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> gciSession [
	^gciSession
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> gciSession: aGciSession [
	gciSession := aGciSession.
	methodSourcePresenter _gciSession: aGciSession.
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> getViews [ 
	textAreaTabs := parentPresenter view viewNamed: 'textAreaTabs'.
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Method';
						  subMenu: self fullMethodListMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> initializeMethodListTableOn: panedLayout [

	methodListPresenter := JadeiteTablePresenter new
		                       beMultipleSelection;
		                       addColumn: (SpStringTableColumn
				                        title: 'Project'
				                        evaluated: [ :service |
					                        service projectName ]) beSortable;
		                       addColumn: (SpStringTableColumn
				                        title: 'Package'
				                        evaluated: [ :service |
					                        service packageName ]) beSortable;
		                       addColumn: (SpStringTableColumn
				                        title: 'Class'
				                        evaluated: [ :service |
					                        service displayClassName ]) beSortable;
		                       addColumn: (SpStringTableColumn
				                        title: 'Category'
				                        evaluated: [ :service | service category ])
				                       beSortable;
		                       addColumn: (SpStringTableColumn
				                        title: 'Method'
				                        evaluated: [ :service | service selector ])
				                       beSortable;
		                       wantsDrop: [ :transfer |
										"#canUnderstand: used in case nefarious objects are dropped"
			                       (transfer passenger class canUnderstand:
					                        #allSatisfy:) ifTrue: [
					                       transfer passenger allSatisfy:
							                       #isMethodService ] ];
		                       acceptDrop: [ :transfer |
			                       self dropMethods: transfer passenger ];
		                       yourself.
	panedLayout add: methodListPresenter
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> initializeMethodSourceOn: panedLayout [

	| box |
	methodSourcePresenter := JadeiteMethodSourcePane new _gciSession:
		                         self gciSession.
	methodSourcePresenter
		application: self application;
		saveAction: [ self editSaveMethod ].
	box := SpBoxLayout newVertical.
	box borderWidth: 2.
	box add: methodSourcePresenter.
	panedLayout add: box
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> initializePresenters [

	| panedLayout copyButtonBox |
	super initializePresenters.
	panedLayout := SpPanedLayout newVertical positionOfSlider: 0.30.
	self initializeMethodListTableOn: panedLayout.
	self initializeFullMethodListMenu.
	self initializeMethodSourceOn: panedLayout.
	self layout add: panedLayout.
	copyButtonBox := SpBoxLayout newHorizontal.
	copyButtonBox
		add: (SpButtonPresenter new
				 icon: (self iconNamed: #smallCopy);
				 action: [ self copyMethodSelectors ])
		withConstraints: [ :constraints |
			constraints
				bePlacedAtEnd;
				width: 30 ].
	self layout
		add: copyButtonBox
		withConstraints: [ :constraints | constraints height: 20 ].
	statusBarText := self newStatusBar.
	self layout
		add: statusBarText
		withConstraints: [ :constraints | constraints height: 20 ]
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 100 @ 80 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self updateCaption
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> methodListSelection [
	^methodListPresenter selectionOrNil
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> methods: services [
	"services can legitimately be nil if call was blocked because it
	was already inUpdate"

	(services isNil or: [ services isEmpty ]) ifTrue: [ ^ self ].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> methods: services selectingAnyMatch: string [
	services isEmpty ifTrue: [^self].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod.

]

{ #category : 'testing' }
JadeiteMethodListPresenter >> okToClose [

	^ self okToChangeSelections
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> onCloseRequested: aCloseEvent [
	aCloseEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> postEditSaveMethod [
	| methodService |
	methodService := self methodListPresenter methodListPresenter selectionIfNone: [^self].

	"If we recompile a method in the method list browser
	reset the firstReference to nil. Although we have the
	string that was searched on, we don't know the type
	of search so it's better to show no reference than the
	wrong reference"
	methodService firstReference: nil
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> postMoveToPackage: packageName classService: className selectedMethods: selectedMethods [

	self refreshList
]

{ #category : 'drag & drop' }
JadeiteMethodListPresenter >> refreshList [

	methodListPresenter withAdapterDo: [ :anAdapter |
		anAdapter refreshList ]
]

{ #category : 'registration' }
JadeiteMethodListPresenter >> registerMethodPresentersForUpdates [

	RowanServiceUpdater current
		register: methodListPresenter selector: #removed:;
		register: methodListPresenter
		selector: #methodUpdate:browser:
		browser: self
]

{ #category : 'registration' }
JadeiteMethodListPresenter >> registerPresentersForUpdates [
	super registerPresentersForUpdates.
	RowanServiceUpdater current
		register: methodListPresenter selector: #removed:;
		register: methodListPresenter
		selector: #methodUpdate:browser:
		browser: self
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> removeComparisonTab [
	self textTabs remove: self comparisonTab ifAbsent: []
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> search [
	^search
		ifNil: 
			[search := JadeiteSearch on: methodSourcePresenter documentPresenter view session: self gciSession]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> selectComparisonTab [
	comparisonPresenter ensureVisible
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> selectFirstReference: methodService [

	methodService ifNil: [ ^ self ].
	methodService firstReference
		ifNil: [
			firstReferenceString ifNotNil: [
				methodService source ifNotNil: [
					self selecting:
						(methodService source indexOfSubCollection: firstReferenceString) ] ] ]
		ifNotNil: [ :index | self selecting: index ]
]

{ #category : 'updates' }
JadeiteMethodListPresenter >> selectMethodsFrom: classService [

	| selections selectedMethods |
	selections := OrderedCollection new.
	selectedMethods := classService selectedMethods.
	selectedMethods do: [ :methodService |
		| selection |
		selection := methodListPresenter list
			             detect: [ :svc | svc = methodService ]
			             ifNone: [  ].
		selection ifNotNil: [ :sel | selections add: sel ] ].
	methodListPresenter selectItems: selections
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> selectedClassName [
	^methodListPresenter methodListPresenter list first className
]

{ #category : 'selections' }
JadeiteMethodListPresenter >> selectedPackageServices [

	^ Array new
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> selecting: index [

	| range |
	index = 0 ifTrue: [ ^self ].
	firstReferenceString ifNotNil: [
		range := Interval
			         from: index
			         to: firstReferenceString size + index - 1.
		methodSourcePresenter selectionInterval: range ]
]

{ #category : 'constants' }
JadeiteMethodListPresenter >> shellName [
	^'Jadeite Method List Browser'
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> showComparisonTab [
	self textTabs add: self comparisonTab.
	comparisonPresenter ensureVisible
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> showSuperClassComparison [
	| methodService |
	methodService := methodListPresenter selection.
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

{ #category : 'accessing' }
JadeiteMethodListPresenter >> statusBarText [

	^ statusBarText
]

{ #category : 'accessing' }
JadeiteMethodListPresenter >> statusBarText: anObject [

	statusBarText := anObject
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> textAreaTabs [
	^textAreaTabs
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> textAreaTabs: anObject [
	textAreaTabs := anObject
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> textTabs [
	^(textAreaTabs subViews detect: [:each | each class == TabViewXP]) model
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> updateCaptionFromSearchString: searchString [

	self caption: (gciSession titleBarFor: searchString)
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateMethodSource [

	methodListPresenter selections isEmpty ifTrue: [
		self cleanupComparisonBrowser.
		^ methodSourcePresenter value: String new ].
	methodListPresenter selections size = 1 ifTrue: [
		^ self updateSingleMethodSourceFor:
			  self methodListPresenter selectedItem ].
	self updateMultiMethodComparison
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateMethodSourceFor: aMethodService [

	self updateSingleMethodSourceFor: aMethodService
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateMultiMethodComparison [
	self todo:[self selectComparisonTab.
	comparisonPresenter
		beforeTitle: (methodListPresenter selections at: 1) classMethodDisplayString;
		afterTitle: (methodListPresenter selections at: 2) classMethodDisplayString;
		compare: (methodListPresenter selections at: 1) source
			with: (methodListPresenter selections at: 2) source].
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateSingleMethodSourceFor: methodService [

	methodSourcePresenter methodService: methodService.
	methodSourcePresenter value: methodService source.
	methodSourcePresenter ensureVisible.
	self updateMethodSourceGlyphs.
	methodService firstReference ifNotNil: [ :index |
		methodSourcePresenter value ifNotNil: [ self selecting: index ] ]
]
