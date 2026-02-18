Class {
	#name : 'JadeiteSUnitBrowserPresenter',
	#superclass : 'JadeiteSUnitAbstractPresenter',
	#traits : 'JadeiteMethodsTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait',
	#instVars : [
		'#testCaseListPresenter',
		'#testClassService => ObservableSlot',
		'#methodSourcePresenter',
		'#browserPresenter'
	],
	#category : 'Jadeite-SUnitBrowser',
	#package : 'Jadeite-SUnitBrowser'
}

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> addStyle: aString [

	super addStyle: aString.
	testCaseListPresenter addStyle: aString
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> addToolsToMenuGroup: group [

	^ self newJadeiteSUnitToolbar items do: [ :toolbarItem |
		  group addItem: [ :item |
			  item
				  name: toolbarItem label;
				  description: toolbarItem label;
				  icon: toolbarItem icon;
				  action: toolbarItem action ] ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> basicRunAll [

	testProcess := [
		               self reset.
		               testCaseListPresenter resetSelection.
		               [
		               self
			               runTests: testCaseListPresenter list
			               in: testClassService name ] ensure: [
				               testSemaphore signal.
				               testProcess := nil.
				               shouldStopTestRun := false ] ] fork
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> basicRunSelected [

	testProcess := [
		               testResults := [
			                              self reset.
			                              self
				                              runTests:
				                              testCaseListPresenter selectedItems
				                              in: testClassService name ] ensure: [
				                              testSemaphore signal.
				                              testProcess := nil.
				                              shouldStopTestRun := false ] ] fork
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> browserPresenter [

	^ browserPresenter
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> browserPresenter: anObject [

	browserPresenter := anObject
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> clearStatusBar [

	self resetStatusBarColor.
	browserPresenter statusBarText: String new
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> connectPresenters [

	self testCaseListPresenter whenSelectionChangedDo: [ :selection |
		self updateMethodSourceFrom: selection ].
	methodSourcePresenter whenSubmitDo: [ :text | self editSaveMethod ].
	self registerForMethodPaneAnnouncements.
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> debug [

	self debugSelected
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> debugAll [

	testSemaphore := Semaphore new.
	testClassService ifNil: [ ^ self ].
	testProcess := [
		               [
			               self reset.
			               self debugTests: testCaseListPresenter list.
			               testCaseListPresenter invalidate ] ensure: [
				               testSemaphore signal.
				               testProcess := nil.
				               shouldStopTestRun := false ] ] fork
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> debugSelected [

	testSemaphore := Semaphore new.
	testClassService ifNil: [ ^ self ].
	testProcess := [
		               [
			               self reset.
			               self debugTests: testCaseListPresenter selectedItems.
			               testCaseListPresenter invalidate ] ensure: [
				               testSemaphore signal.
				               testProcess := nil.
				               shouldStopTestRun := false ] ] fork
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> debugTests: methodServices [

	[
		self
			debugTestMethodServices: methodServices
			className: self testClassService name ] fork
]

{ #category : 'layout' }
JadeiteSUnitBrowserPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> displayBreakpoints [

	self methodSourcePresenter methodService breakPoints do: [
			:breakPoint |
			| range stepPointAssoc |
			stepPointAssoc := self methodSourcePresenter methodService
				                  stepPoints at: breakPoint ifAbsent: [ ].
			stepPointAssoc ifNotNil: [
					range := self methodSourcePresenter methodService
						         stepPointRangeFrom: stepPointAssoc.
					self methodSourcePresenter addTextSegmentDecoration:
						((SpTextPresenterDecorator new highlightColor: Color lightCyan)
							 interval: range) ] ]
]

{ #category : 'printing' }
JadeiteSUnitBrowserPresenter >> displayClassFrom: service [

	^ service className = browserPresenter selectedClassName
		  ifTrue: [ String new ]
		  ifFalse: [ service className ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> displayMethodSourceStepPoints [

	self testCaseListPresenter selectionOrNil ifNil: [ ^ self ].
	self methodSourcePresenter methodService ifNil: [
			self methodSourcePresenter methodService:
				self testCaseListPresenter selectedItem ].
	self methodSourcePresenter methodService stepPoints do: [
			:stepPointAssoc |
			| range |
			range := self methodSourcePresenter methodService
				         stepPointRangeFrom: stepPointAssoc.

			self methodSourcePresenter addTextSegmentDecoration:
				((SpTextPresenterDecorator new underlineColor: Color veryLightGray)
					 interval: range) ]
]

{ #category : 'printing' }
JadeiteSUnitBrowserPresenter >> displayStringFrom: methodService [

	| ws selectedClass |
	ws := WriteStream on: String new.
	ws nextPutAll: methodService selector.
	selectedClass := self browserPresenter selectedClass.
	selectedClass ifNil: [ ^ ws contents ].
	selectedClass name = methodService className ifFalse: [
			ws
				space;
				nextPut: $(;
				nextPutAll: methodService className;
				nextPut: $) ].
	^ ws contents
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> editSaveMethod [

	| category priorTestMethods classService |
	self testClassService ifNil: [ ^ self ].
	self testClassService meta: false.
	category := self testCaseListPresenter selectionOrNil
		            ifNil: [ 'tests' ]
		            ifNotNil: [
		            self testCaseListPresenter selectedItem category ].
	priorTestMethods := self testClassService visibleTests copy.
	classService := methodSourcePresenter methodService
		                ifNil: [ self testClassService ]
		                ifNotNil: [
				                RowanClassService new name:
					                methodSourcePresenter methodService className ].
	self
		editSaveMethod: classService
		in: methodSourcePresenter
		category: category
		onCompletion: [
				self uiManager defer: [
					self postSaveMethodIn: classService with: priorTestMethods ] ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> editSaveMethod: classService in: thePresenter category: category onCompletion: completionBlock [

	thePresenter
		saveMethodIn: classService
		category: category
		completionBlock: [
				(self compilationWarningFrom: classService selectedMethods)
					ifNil: [ self clearStatusBar ]
					ifNotNil: [ :warning |
							self setCompileWarningColor.
							browserPresenter statusBarText: warning ].
				self updateMethodSourceGlyphs.
				completionBlock value ]
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> gciSession: aSession [

	super gciSession: aSession.
	methodSourcePresenter gciSession: aSession
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initialize [

	super initialize.
	self whenTestClassChangedDo: [ self updateContents ]
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initializeButtons [

	| menuBar |
	toolbar := self newJadeiteSUnitToolbar.

	menuBar := self newMenuBar addGroup: [ :group |
		           self addToolsToMenuGroup: group ].

	self layout
		add: menuBar
		withConstraints: [ :constraints | constraints height: 25 ]
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initializeMethodSourceIn: testCaseBox [

	methodSourcePresenter := self methodSourcePaneClass new.
	methodSourcePresenter
		application: self application;
		saveAction: [ self editSaveMethod ];
		whenTextChangedDo: [
			browserPresenter ifNotNil: [ browserPresenter sourcePaneChanged ] ].

	testCaseBox add: methodSourcePresenter
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initializePresenters [

	| testCaseBox |
	self initializeButtons.
	testCaseBox := SpBoxLayout newHorizontal.
	self initializeTestCaseListIn: testCaseBox.
	self initializeMethodSourceIn: testCaseBox.
	self layout add: testCaseBox.
	self initializeTestMenu
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initializeTestCaseListIn: testCaseBox [

	| column1 column2 column3 |
	testCaseListPresenter := JadeiteTablePresenter new
		                         beMultipleSelection items:
		                         OrderedCollection new.
	column1 := (SpImageTableColumn evaluated: [ :service |
		            service testResultIconForBrowser: self ]) width: 20.
	column2 := (SpStringTableColumn
		            title: 'Test Selector'
		            evaluated: [ :service | service selector ]) beSortable.
	column3 := (SpStringTableColumn
		            title: 'Class'
		            evaluated: [ :service | self displayClassFrom: service ])
		           beSortable.
	testCaseListPresenter
		addColumn: column1;
		addColumn: column2;
		addColumn: column3;
		addStyle: 'jadeiteTextBackgroundColor'.

	testCaseBox add: testCaseListPresenter
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initializeTestMenu [

	testCaseListPresenter contextMenu: [
			SpMenuPresenter new
				addGroup: [ :group |
						group
							addItem: [ :item |
									item
										name: 'Debug All';
										action: [ self debugAll ] ];
							addItem: [ :item |
									item
										name: 'Debug Selected';
										action: [ self debugSelected ] ] ];
				addGroup: [ :group |
						group
							addItem: [ :item |
									item
										name: 'Run All';
										action: [ self runAll ] ];
							addItem: [ :item |
									item
										name: 'Run Selected';
										action: [ self runSelected ] ] ];
				addGroup: [ :group |
						group addItem: [ :item |
								item
									name: 'Reset';
									action: [ self reset ] ] ] ]
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> invalidate [

	testCaseListPresenter invalidate
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> methodSourcePresenter [

	^ methodSourcePresenter
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> methodSourcePresenter: anObject [

	methodSourcePresenter := anObject
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> newJadeiteSUnitToolbar [

	| theToolbar |
	theToolbar := JadeiteToolbarPresenter new.
	theToolbar displayMode: JadeiteToolbarDisplayMode modeIconAndLabel.
	theToolbar
		addItem: (SpToolbarButtonPresenter new
				 label: 'Run All';
				 icon: (self iconNamed: #glamorousSpawn);
				 help: 'run all tests in the selected classes';
				 action: [ self runAll ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Run Selected';
				 icon: (self iconNamed: #glamorousGo);
				 help: 'run selected tests';
				 action: [ self runSelected ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Debug All';
				 icon: (self iconNamed: #glamorousSpawn);
				 help: 'debug all tests in the selected classes';
				 action: [ self debugAll ];
				 yourself);
		addItem: (SpToolbarButtonPresenter new
				 label: 'Debug Selected';
				 icon: (self iconNamed: #glamorousGo);
				 help: 'debug selected tests';
				 action: [ self debug ];
				 yourself).
	^ theToolbar
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> postSaveMethodIn: classService with: priorTestMethods [

	| sel |
	self updateService: self testClassService onCompletion: [
			sel := self testCaseListPresenter selectedItem.
			testCaseListPresenter items: self testClassService visibleTests.
			(self testClassService visibleTests difference: priorTestMethods)
				ifEmpty: [ testCaseListPresenter selectItem: sel ]
				ifNotEmpty: [ :difference |
						testCaseListPresenter unselectAll.
						testCaseListPresenter selectItem: difference first ].
			methodSourcePresenter hasUnacceptedEdits: false ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> refresh [

	self refreshView
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> refreshView [
	self uiManager defer: [ testCaseListPresenter refresh ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> reset [

	testCaseListPresenter model do: [ :each | each testResult: nil ].
	testCaseListPresenter invalidate.
	self owner owner statusBarText: String new.
	self setStatusColorTo: Color transparent
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> resetSource [

	self methodSourcePresenter methodService
		ifNil: [ methodSourcePresenter text: String new ]
		ifNotNil: [ :service | methodSourcePresenter text: service source ].
	self clearStatusBar.
	methodSourcePresenter hasUnacceptedEdits: false.
	self updateMethodSourceGlyphs
]

{ #category : 'compiler warning' }
JadeiteSUnitBrowserPresenter >> resetStatusBarColor [
	self owner owner statusBarText withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget |
			widget adoptPaneColor: Color transparent  ] ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> setColorFor: aJadeTestResult [

	self browserPresenter statusBarText: aJadeTestResult summary.
	self setStatusColorTo: aJadeTestResult backgroundColor
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> setCompileWarningColor [

	self uiManager defer: [
			browserPresenter statusBarText withAdapterDo: [ :theAdapter |
					theAdapter widgetDo: [ :widget |
							widget adoptPaneColor: Color yellow.
							widget submorphsDo: [ :morph | morph color: Color black ] ] ] ]
]

{ #category : 'updates' }
JadeiteSUnitBrowserPresenter >> setMethodSourceTo: aString [

	self methodSourcePresenter
		text: aString;
		hasUnacceptedEdits: false
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> setStatusColorTo: aColor [

	self owner owner statusBarText withAdapterDo: [ :theAdapter |
		theAdapter widgetDo: [ :widget | widget color: aColor ] ]
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> testCaseListPresenter [

	^ testCaseListPresenter
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> testCaseListPresenter: anObject [

	testCaseListPresenter := anObject
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> testClassService [

	^ testClassService
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> testClassService: anObject [

	testClassService := anObject
]

{ #category : 'updates' }
JadeiteSUnitBrowserPresenter >> updateContents [

	self testClassService
		ifNil: [ testCaseListPresenter items: OrderedCollection new ]
		ifNotNil: [
				self uiManager defer: [
						self testClassService
							ifNil: [ testCaseListPresenter items: OrderedCollection new ]
							ifNotNil: [
							testCaseListPresenter items: self testClassService visibleTests ].
						self setMethodSourceTo: String new ] ]
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> updateMethodSource: anAnnouncement [

	| text |
	text := self methodSourcePresenter text.
	self methodSourcePresenter withAdapterDo: [ :a |
		a widgetDo: [ :w |
			w textArea scrollPane
				vScrollbarValue: anAnnouncement scrollOffset y;
				updateScrollbars ] ].
	self updateMethodSourceGlyphs 
]

{ #category : 'updates' }
JadeiteSUnitBrowserPresenter >> updateMethodSourceFrom: selection [

	| methodService |
	methodService := selection selectedItem.
	methodService ifNil: [
			self methodSourcePresenter text: String new.
			self methodSourcePresenter hasUnacceptedEdits: false.
			^ self ].
	self updateService: methodService onCompletion: [
			self uiManager defer: [
					self methodSourcePresenter methodService: methodService.
					self setMethodSourceTo: methodService source.
					self updateMethodSourceGlyphs ] ]
]

{ #category : 'updates' }
JadeiteSUnitBrowserPresenter >> updateMethodSourceGlyphs [

	self testCaseListPresenter selectedItem ifNil: [ ^ self ].
	self methodSourcePresenter removeAllTextSegmentDecorations.
	self displayMethodSourceStepPoints.
	self displayBreakpoints
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> updateStepPointStatus: anAnnouncement [

	self browserPresenter statusBarText pushMessage:
		anAnnouncement message
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> whenTestClassChangedDo: aBlock [

	self property: #testClassService whenChangedDo: aBlock
]
