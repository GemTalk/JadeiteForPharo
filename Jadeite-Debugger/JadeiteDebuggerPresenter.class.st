Class {
	#name : 'JadeiteDebuggerPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait + JadeiteMethodsTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait + JadeiteMethodsTrait classTrait',
	#instVars : [
		'answer',
		'errorMessagePresenter',
		'frame',
		'frameListOffset',
		'frameListPresenter',
		'gsProcess',
		'processList',
		'processListPresenter',
		'terminateOnClose',
		'variableDataPresenter',
		'variableListPresenter',
		'debuggerProcess',
		'statusTextPresenter',
		'search',
		'debuggerService',
		'debuggerClosed',
		'codePane',
		'debuggerToolbar',
		'suspendedProcess',
		'statusBarText'
	],
	#category : 'Jadeite-Debugger'
}

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> addDebuggerActions [

	toolbar
		addItem: (SpToolbarButtonPresenter new
				 label: 'Proceed';
				 icon: (self iconNamed: #smallPrintIt);
				 help: 'resumes execution';
				 action: [
					 answer := #resume.
					 self window close ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Step Over';
				 icon: (self iconNamed: #glamorousOver);
				 help: 'steps over current frame';
				 action: [
					 self stepOver.
					 suspendedProcess resume ]);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Step Into';
				 icon: (self iconNamed: #glamorousInto);
				 help: 'steps into current frame';
				 action: [
					 self stepInto.
					 suspendedProcess resume ]);
			addItem: (SpToolbarButtonPresenter new
				 label: 'Step Through';
				 icon: (self iconNamed: #glamorousThrough);
				 help: 'steps through current frame';
				 action: [
					 self stepThrough.
					 suspendedProcess resume ]);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Stop';
				 icon: (self iconNamed: #changeRemove);
				 help: 'stops execution';
				 action: [
					 answer := #terminate.
					 self window close ])
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> addStyle: aString [
	super addStyle: aString. 
	codePane addStyle: aString.
	errorMessagePresenter addStyle: aString
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> answer [

	^ answer
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> connectPresenters [

	super connectPresenters.
	frameListPresenter whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :sel |
			self displayVariables: sel.
			self updateSourcePaneWith: selection.
			variableDataPresenter
				text: String new;
				hasUnacceptedEdits: false ] ].
	variableListPresenter whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :sel |
			variableDataPresenter
				text: sel value;
				hasUnacceptedEdits: false ] ].
	self methodSourcePresenter whenSubmitDo: [ :text | self editSave ].
	self methodSourcePresenter whenResetDo: [
		self methodSourcePresenter text:
			self methodSourcePresenter methodService source.
		self methodSourcePresenter isModified: false ]
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> copyStack [

	| writeStream |
	writeStream := WriteStream on: String new.
	gsProcess dumpStackOn: writeStream.
	Clipboard
		clipboardText: writeStream contents
		informing: 'Process stack copied to clipboard'
]

{ #category : 'selection' }
JadeiteDebuggerPresenter >> defaultFirstFrame [

	frameListPresenter items do: [ :item |
		self stackInitialSelectionData do: [ :frameString |
			('*', frameString , '*' match: item printString) ifTrue: [
				^ (frameListPresenter items indexOf: item) + 1 ] ] ].
	^ 1
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> displayVariables: selectedFrame [
	| variables sortedVariables receiver instVars argsAndTemps displayVariables dynamicInstVars |
	selectedFrame ifNil: [ ^self ]. 
	[variables := selectedFrame vars.
	"we show receiver separately so take it out of the list. Distinguish it from temp vars named 'receiver' by the symbol. Other args are inst vars"
	sortedVariables := (variables reject: [:variableService | variableService _key == #receiver])
				asSortedCollection: [:x :y | (x _key asString <= y _key asString) ].
	sortedVariables := sortedVariables asOrderedCollection.
	instVars := sortedVariables select: [:var | var _key first = $-].
	dynamicInstVars := sortedVariables select: [:var | var _key first = $.].
	argsAndTemps := sortedVariables select: [:var | var _key first ~= $- and: [var _key first ~= $.]].
	receiver := variables detect: [:variableService | variableService _key = 'receiver'] ifNone: [].
	displayVariables := OrderedCollection with: receiver.
	instVars notEmpty
		ifTrue: 
			[displayVariables add: (RowanDisplayLabelVariableService new value: 'instance variables'). 
			displayVariables addAll: instVars].
	dynamicInstVars notEmpty
		ifTrue: 
			[displayVariables add: (RowanDisplayLabelVariableService new value: 'dynamic instance variables').
			displayVariables addAll: dynamicInstVars].
	argsAndTemps notEmpty
		ifTrue: 
			[displayVariables add: (RowanDisplayLabelVariableService new value: 'args and temps').
			displayVariables addAll: argsAndTemps].
	variableListPresenter items: displayVariables] on: Error do:[:ex | Transcript cr; show: ex printString; flush]. 
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> dumpStackToFile [

	| writeStream fileName fileStream |
	writeStream := WriteStream on: String new.
	gsProcess dumpStackOn: writeStream.
	fileName := Date today yyyymmdd , '_'
	            , Time millisecondClockValue printString
	            , '_rowanServerStackDump.txt'.
	fileStream := File openForWriteFileNamed: fileName.
	[ fileStream nextPutAll: writeStream contents ] ensure: [
		fileStream close ].
	UIManager inform: 'Stack written to: ' , Smalltalk imageDirectory pathString, File delimiter asString, fileName
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> editSave [

	^self methodSourcePresenter saveAction ifNotNil: [:action | action value]
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> editSaveMethod [
	| source |
	source := codePane text asString. 
	frameListPresenter selectedItem ifNotNil: [ :selection |
		self selectHomeMethod.
		codePane text: source. "because we potentially switched frames"
		self editSaveMethod: frameListPresenter selectedItem method classService ].
	codePane value: source. 
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> editSaveMethod: classService [

	| compileResult |
	compileResult := self
		                 editSaveMethod: classService
		                 in: self methodSourcePresenter
		                 category:
		                 frameListPresenter selectedItem method category.
	compileResult ifFalse: [ ^ self ].
	self trimStack
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> errorMessagePresenter [

	^ errorMessagePresenter
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> errorMessagePresenter: anObject [

	errorMessagePresenter := anObject
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> frameListPresenter [

	^ frameListPresenter
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> frameListPresenter: anObject [

	frameListPresenter := anObject
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> gciSession: aGciSession [

	super gciSession: aGciSession.
	codePane _gciSession: self gciSession
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> gsProcess [

	^ gsProcess
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> gsProcess: anObject [

	gsProcess := anObject
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> homeFrame [
	^self homeFrameOf: frameListPresenter selectedItem
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> homeFrameOf: theFrame [
	^gsProcess frames detect: 
			[:frameService |
			frameService homeMethodSelector = theFrame homeMethodSelector and: 
					[frameService method selector = frameService homeMethodSelector
						and: [theFrame homeMethodClassName = frameService homeMethodClassName]]]
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> initializeFileMenu [

	^ self newMenu
		  addGroup: [ :group |
			  group
				  addItem: [ :item |
					  item
						  name: 'Copy Stack';
						  action: [ self copyStack ] ];
				  addItem: [ :item |
					  item
						  name: 'Dump Stack To File';
						  action: [ self dumpStackToFile ] ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'File';
						  subMenu: self initializeFileMenu ] ];
		  yourself
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> initializePresenters [

	| topPanes panedLayout codePaneBox |
	super initializePresenters.
	self initializeToolbar.
	self addDebuggerActions.
	errorMessagePresenter := (JadeiteTextDocument new text: String new)
		                         beNotEditable;
		                         withoutSyntaxHighlight;
		                         withoutLineNumbers.
	self layout
		add: errorMessagePresenter
		withConstraints: [ :constraints | constraints height: 30 ].
	panedLayout := SpPanedLayout newVertical positionOfSlider: 0.50.
	topPanes := SpPanedLayout newHorizontal positionOfSlider: 0.50.
	frameListPresenter := JadeiteListPresenter new display: [
		                      :frameService | frameService printString ].
	topPanes add: frameListPresenter.
	self initializeVariablePanesIn: topPanes.
	panedLayout add: topPanes.
	codePaneBox := SpBoxLayout newVertical.
	codePaneBox
		add: self newStatusBar
		withConstraints: [ :constraints | constraints height: 5 ].
	codePane := JadeiteMethodSourcePane new.
	codePane application: self application.
	codePane saveAction: [
		self editSaveMethod.
		suspendedProcess resume ].
	codePaneBox add: codePane.
	panedLayout add: codePaneBox.
	self layout add: panedLayout.
	statusBarText := self newStatusBar.
	self layout
		add: statusBarText
		withConstraints: [ :constraints | constraints height: 20 ]
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> initializeVariablePanesIn: framesAndVariables [

	| variablePanes column1 column2 column3  variableDataBox |
	variablePanes := SpPanedLayout newVertical positionOfSlider: 0.50.
	variableListPresenter := JadeiteTablePresenter new.
	variableListPresenter addColumn: (column1 := SpStringTableColumn
			            title: 'Variable'
			            evaluated: [ :variableService | variableService key ]).

	variableListPresenter addColumn: (column2 := SpStringTableColumn
			            title: 'Value'
			            evaluated: [ :variableService | variableService value ]).
	column2 displayColor: [ :variableService |
		variableService isVariableDisplayLabel
			ifTrue: [ Color blue ]
			ifFalse: [ Smalltalk ui theme textColor ] ].

	variableListPresenter addColumn: (column3 := SpStringTableColumn
			            title: 'OOP'
			            evaluated: [ :variableService |
			            variableService displayOop ]).
	variableListPresenter contextMenu: self newVariableListMenu.
	variableDataBox := SpBoxLayout newVertical. 
	variableDataBox
		add: self newStatusBar
		withConstraints: [ :constraints | constraints height: 5 ].
	variableDataPresenter := (JadeiteMethodSourcePane new text:
			                          String new)
		                         withoutLineNumbers;
		                         hasUnacceptedEdits: false.
	variableDataBox add: variableDataPresenter. 
	variablePanes
		add: variableListPresenter;
		add: variableDataBox.
	framesAndVariables add: variablePanes
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 1000 @ 1200.
	self updateCaption.
	aWindowPresenter menu: self initializeMenubar. 
	aWindowPresenter whenClosedDo: [
		answer ifNil: [ answer := #terminate ].
		[ suspendedProcess resume ] forkAt: Processor activePriority - 1 ]
]

{ #category : 'menus' }
JadeiteDebuggerPresenter >> inspectVariable [

	^ JadeiteInspectorApplication
		  executeThenShowOn: 'Object _objectForOop: '
			  , variableListPresenter selectedItem oop printString
		  session: gciSession
		  context: 20
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> methodSourcePresenter [

	^codePane
]

{ #category : 'menus' }
JadeiteDebuggerPresenter >> newVariableListMenu [

	^ SpMenuPresenter new
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Inspect';
						  action: [ self inspectVariable ];
						  enabled: [ variableListPresenter selections size = 1 ] ] ];
		  yourself
]

{ #category : 'registration' }
JadeiteDebuggerPresenter >> registerPresentersForUpdates [
	RowanServiceUpdater  current
		register: codePane
		selector: #debuggerMethodSourceUpdate:browser:
		browser: self
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> selectHomeMethod [
	frameListPresenter selection: self homeFrame
]

{ #category : 'selection' }
JadeiteDebuggerPresenter >> selectInitialFrame [

	frameListPresenter selectIndex: self defaultFirstFrame
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> shellName [

	^'Debugger'
]

{ #category : 'selection' }
JadeiteDebuggerPresenter >> stackInitialSelectionData [
	"Line number to select if string included on previous line (need not be exact match)"

	^#(
		'(AbstractException) >> _signalAsync @7 line 21'
		'(AbstractException) >> _signalAsync: @6 line 21'
		'(Object) >> _doesNotUnderstand:args:envId:reason: @7 line 12'
		'(Object) >> _doesNotUnderstand:args:envId:reason: @8 line 13'
		'(Object) >> _doesNotUnderstand:args:envId:reason: @12 line 17'
		'(Object) >> error: @6 line 7'
		'(Object) >> error: (envId 0) @6 line 7'
		'(Object) >> error: @6 line 7'
		'(Object) >> halt @2 line 5'
		'(Object) >> halt (envId 0) @2 line 5'
		'(Object) >> pause @2 line 7'
		'(Object)>>#_doesNotUnderstand: @1 line 6'
		'(Object)>>#error: @1 line 6'
		'(Object)>>#error: @3 line 7'
		'(Object)>>#halt @1 line 6'
		'(Object) >> halt @2 line 5'
		'(Object)>>#pause @2 line 8'
		'(TestCase)>>#assert: @1 line 1'
		'(TestCase)>>#deny: @2 line 3'
		'(TestCase)>>#should:raise: @10 line 9'
		'(TestCase)>>#shouldnt:raise: @4 line 2'
		'(GsTestCase) >> assert: @2 line 3'
		'(GsTestCase) >> assert: (envId 0) @2 line 3'
		'Object >> _doesNotUnderstand:'
		'Object >> _doesNotUnderstand:args:envId:reason: @7 line 12'
		'Object >> _doesNotUnderstand:args:envId:reason: (envId 0) @7 line 12'
		'Object >> _doesNotUnderstand:args:envId:reason: @8 line 13'
		'Object >> error: @6 line 7'
		'Object >> error: (envId 0) @6 line 7'
		'Object >> halt @2 line 5'
		'Object >> halt (envId 0) @2 line 5'
		'(TestAsserter) >> assert: @5 line 4'
		'TestAsserter >> assert: (envId 0) @5 line 4'
		'UndefinedObject (Object) >> _doesNotUnderstand:args:envId:reason: @8 line 14'
		'UndefinedObject (Object) >> _doesNotUnderstand:args:envId:reason: @12 line 17'
	)
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> statusBarText [

	^ statusBarText
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> statusBarText: anObject [

	statusBarText := anObject
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> stepInto [

	answer := Array
		          with: #setStepIntoBreaksAtLevel:
		          with: frameListPresenter selection selectedIndex 
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> stepOver [

	answer := Array
		          with: #setStepOverBreaksAtLevel:
		          with: frameListPresenter selection selectedIndex 
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> stepThrough [

	answer := Array
		          with: #setStepThroughBreaksAtLevel:
		          with: frameListPresenter selection selectedIndex 
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> suspendedProcess [

	^ suspendedProcess
]

{ #category : 'accessing' }
JadeiteDebuggerPresenter >> suspendedProcess: anObject [

	suspendedProcess := anObject
]

{ #category : 'actions' }
JadeiteDebuggerPresenter >> trimStack [

	| selectionIndex |
	selectionIndex := frameListPresenter selection selectedIndex.
	answer := Array
		          with: #trimStackToLevel:
		          with: selectionIndex.
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> updateCaption [
	self caption: (self gciSession titleBarFor: self shellName)
]

{ #category : 'initialization' }
JadeiteDebuggerPresenter >> updateSourcePaneWith: selection [
	codePane context: frameListPresenter selectedItem oop. 
	codePane methodService: selection selectedItem method.
	codePane value: selection selectedItem source.
	codePane showStepPoint: frameListPresenter selectedItem stepPoint
]
