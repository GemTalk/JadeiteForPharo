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
		'statusBarText'
	],
	#pools : [
		'ScintillaConstants'
	],
	#category : 'Jadeite-MethodBrowser'
}

{ #category : 'initialization' }
JadeiteMethodListPresenter >> addStyle: aString [
	"don't send the super because we don't want the toolbar to be the same color as source pane"
	methodSourcePresenter addStyle: aString.
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> autoCommit [
	"for testing"

	^autoCommit value
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> autoCommit: boolean [
	autoCommit value: boolean
]

{ #category : 'testing' }
JadeiteMethodListPresenter >> canDiscardEdits [

	self methodSourcePresenter hasUnacceptedEdits ifTrue: [
		(MessageBox confirm:
			 'You have unsaved changes. Discard changes and continue?')
			ifTrue: [
				self methodSourcePresenter hasUnacceptedEdits: false.
				^ true ]
			ifFalse: [ ^ false ] ].
	^ true
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
		self updateMethodSource ].
	methodSourcePresenter whenSubmitDo: [ :text | self editSave ].
	methodSourcePresenter whenResetDo: [
		methodSourcePresenter text:
			methodSourcePresenter methodService source.
		methodSourcePresenter isModified: false ]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> contextObject [
	| methodService classService |
	methodService := methodListPresenter methodListPresenter selectionIfNone: [^nil].
	classService := RowanClassService named: methodService className.
	self updateService: classService.
	^classService oop
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> createComponents [
	methodListPresenter := self add: JadeiteBasicMethodListPresenter new name: 'methodList'.
	methodSourcePresenter := (self add: JadeiteMethodSourcePresenter new name: 'methodSource')
				menuTitle: '&Method Source'.
	comparisonPresenter := self add: JadeiteDifferencesPresenter new name: 'comparisonTab'.
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> editSave [

	^methodSourcePresenter saveAction ifNotNil: [:action | action value]
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> editSaveMethod [

	methodListPresenter selectedItem ifNotNil: [ :selection |
		self editSaveMethod: selection classService ]
]

{ #category : 'actions' }
JadeiteMethodListPresenter >> editSaveMethod: classService [
	| compileResult |
	classService meta: self methodListPresenter selectedItem meta. 
	compileResult := self
				editSaveMethod: classService
				in: methodSourcePresenter
				category: methodListPresenter selectedItem category.
	compileResult == false
		ifTrue: [self updateService: classService	"If we got a compile error our methods need a refresh"].
	self statusBarText message ifNotNil:[:text | text isEmpty ifFalse:[^self]].  "don't reselect methods when status bar is full so as not to upset the compile information"
	classService selectedMethods
		ifNotNil: 
			[:methodServices |
			methodServices notEmpty
				ifTrue: 
					["there will be no method selected on a compiler error"
					self selectMethodsFrom: classService]]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> fileSave [

	self halt. 
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
		  addItem: [ :item |
			  item
				  name: 'Method';
				  subMenu: self fullMethodListMenu ];
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

	| panedLayout |
	super initializePresenters.
	self initializeToolbar.
	panedLayout := SpPanedLayout newVertical positionOfSlider: 0.30.
	self initializeMethodListTableOn: panedLayout.
	self initializeFullMethodListMenu.
	self initializeMethodSourceOn: panedLayout.
	self layout add: panedLayout. 
	statusBarText := self newStatusBar.
	self layout
		add: statusBarText
		withConstraints: [ :constraints | constraints height: 20 ]
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 1000 @ 800;
		menu: self initializeMenubar.
	self updateCaption
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> methodListSelection [
	^methodListPresenter selectionOrNil
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> methods: services selecting: stringOrIndex [
	"services can legitimately be nil if call was blocked because it
	was already inUpdate"

	(services isNil or: [services isEmpty]) ifTrue: [^self].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod.
	stringOrIndex ifNil: [^self].
	self selecting: stringOrIndex
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> methods: services selectingAnyMatch: string [
	services isEmpty ifTrue: [^self].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod.

]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> onCloseRequested: aCloseEvent [
	aCloseEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> onDragMethod: aSession [
	| list |
	list := methodListPresenter selections collect: 
					[:each |
					(aSession newDragObject: each)
						format: #method data: each;
						yourself].
	aSession
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy;
		yourself
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> onViewClosed [
	super onViewClosed.
	RowanServiceUpdater current removeEventsTriggeredFor: methodListPresenter methodListPresenter.
	RowanServiceUpdater current removeEventsTriggeredFor: self.
	methodListPresenter removeEventsTriggeredFor: self.
	methodSourcePresenter removeEventsTriggeredFor: self.
	autoCommit removeEventsTriggeredFor: self.
	methodSourcePresenter documentPresenter removeEventsTriggeredFor: self
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> onViewDestroyed [
	super onViewDestroyed.
	subPresenters := nil
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> onViewOpened [

	super onViewOpened. 
	self registerPresentersForUpdates.
	self updateAutoCommitButton.
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

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> queryCommand: aCommandQuery [
	| command |
	command := aCommandQuery command.
	(#(#clearMethodBreakpoints #browseSelectedMethods) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
			^true].
	command = #flipAutoCommit
		ifTrue: 
			[aCommandQuery isEnabled: self transactionMode = #autoBegin.
			^true].
	#browseMethodHistory = command
		ifTrue: 
			[| selections |
			selections := self methodListPresenter selections.
			aCommandQuery isEnabled: (selections size = 1 and: [selections first hasMethodHistory]).
			^true].
	^super queryCommand: aCommandQuery
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

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> selecting: stringOrIndex string: searchString [
	self todo:[stringOrIndex isNumber
		ifTrue: 
			[| range stream selectionStop |
			stringOrIndex > methodSourcePresenter documentPresenter value size ifTrue: [^self].
			stream := ReadStream on: methodSourcePresenter documentPresenter value.
			stream position: stringOrIndex.
			stream nextWordWithoutPunctuation.
			selectionStop := searchString
						ifNil: [stream position]
						ifNotNil: [searchString size + stringOrIndex - 1].
			range := Interval from: stringOrIndex to: selectionStop.
			methodSourcePresenter documentPresenter selectionRange: range]
		ifFalse: 
			[searchBlock := [self searchFor: stringOrIndex].
			self doSearch].
	methodSourcePresenter documentPresenter view ensureCaretVisible]
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> selectionChanging: aSelectionChangingEvent [
	aSelectionChangingEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])
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

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateAutoCommitButton [
	| autoCommitButtonView |
	autoCommitButtonView := self topShell view viewNamed: 'autoCommitButton'.
	autoCommit value == #failed ifTrue: [^autoCommitButtonView backcolor: Color red].
	autoCommit value
		ifTrue: [autoCommitButtonView backcolor: Color green]
		ifFalse: [autoCommitButtonView backcolor: Color default].
	autoCommitButtonView isEnabled: self transactionMode = #autoBegin
]

{ #category : 'initialization' }
JadeiteMethodListPresenter >> updateCaptionFromSearchString: searchString [

	self caption: (gciSession titleBarFor: searchString)
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateMethodSource [
	methodListPresenter selections isEmpty
		ifTrue: 
			[self cleanupComparisonBrowser.
			^methodSourcePresenter value: String new].
	self methodSourcePresenter methodService: self methodListPresenter selectedItem. 	
	methodListPresenter selections size = 1
		ifTrue: 
			[self todo:[self showSuperClassComparison].
			^self updateSingleMethodSource].
	self updateMultiMethodComparison.
	self todo:[self refreshBreakPointsIn: methodSourcePresenter documentPresenter.
	self setStatusBarDefault]
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
JadeiteMethodListPresenter >> updateSingleMethodSource [
	| selection |
	selection := methodListPresenter selectedItem.
	methodSourcePresenter documentPresenter view isModified ifTrue: [^self].
	methodSourcePresenter value: selection source.
	selection firstReference
		ifNotNil: 
			[:index |
			methodSourcePresenter value ifNotNil: [self selecting: index string: selection searchString]].
	methodSourcePresenter ensureVisible.
	self updateMethodSourceGlyphs
]

{ #category : 'as yet unclassified' }
JadeiteMethodListPresenter >> updateSource [
	| selection |
	selection := methodListPresenter selectionOrNil.
	selection ifNil: [^self]. 
	methodSourcePresenter methodService: selection.
	methodSourcePresenter update.
	self doSearch. 
	methodSourcePresenter documentPresenter value ifNil:[^self]. 
	('*METHOD SOURCE CANNOT BE DISPLAYED*' match: methodSourcePresenter documentPresenter value)
		ifTrue: [methodSourcePresenter documentPresenter view backcolor: Color red faded faded].
]
