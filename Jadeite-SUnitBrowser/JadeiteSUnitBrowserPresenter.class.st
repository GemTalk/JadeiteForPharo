Class {
	#name : 'JadeiteSUnitBrowserPresenter',
	#superclass : 'JadeiteSUnitAbstractPresenter',
	#instVars : [
		'#testCaseListPresenter',
		'#testClassService => ObservableSlot'
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

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> connectPresenters [

	
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

{ #category : 'nil' }
JadeiteSUnitBrowserPresenter >> debugTests: methodServices [

	| sem |
	methodServices do: [ :methodService | methodService testResult: nil ].
	testCaseListPresenter refresh.
	[
		sem := Semaphore new.
		methodServices do: [ :methodService |
				| process |
				process := Processor activeProcess.
				methodService
					command: #debugTest:inClassName:;
					commandArgs:
						(Array
							 with: methodService selector
							 with: testClassService className);
					catchBlock: [ process terminate ].
				RowanServiceUpdater current
					issueCommand: methodService
					session: self gciSession
					onCompletion: [ [ self refreshView ] ensure: [ sem signal ] ].
				sem wait ] ] fork
]

{ #category : 'layout' }
JadeiteSUnitBrowserPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> initialize [

	super initialize.
	self whenTestClassChangedDo: [ self updateTestCases ]
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
JadeiteSUnitBrowserPresenter >> initializePresenters [

	self initializeButtons.
	testCaseListPresenter := JadeiteListPresenter newNameSortedList
		                         beMultipleSelection.
	testCaseListPresenter
		addStyle: 'jadeiteTextBackgroundColor';
		displayIcon: [ :item | item testResultIconForBrowser: self ].
	self layout add: testCaseListPresenter.
	self initializeTestMenu
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
										action: [ self runSelected ] ] ] ]
]

{ #category : 'accessing' }
JadeiteSUnitBrowserPresenter >> invalidate [

	testCaseListPresenter invalidate
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
JadeiteSUnitBrowserPresenter >> setColorFor: aJadeTestResult [

	self owner owner statusBarText: aJadeTestResult summary.
	self setStatusColorTo: aJadeTestResult backgroundColor
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
JadeiteSUnitBrowserPresenter >> updateTestCases [

	self testClassService
		ifNil: [ testCaseListPresenter list: OrderedCollection new ]
		ifNotNil: [
		testCaseListPresenter list: self testClassService testMethods ]
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> whenTestClassChangedDo: aBlock [

	self property: #testClassService whenChangedDo: aBlock
]
