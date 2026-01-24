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

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> basicRunAll [

	testProcess := [
		               [
			               self reset.
			               testCaseListPresenter resetSelection.
			               testResults := self
				                              runTests: testCaseListPresenter list
				                              in: testClassService name ] ensure: [
				               testSemaphore signal.
				               testProcess := nil.
				               shouldStopTestRun := false ] ] fork
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> basicRunSelected [

	testProcess := [
		               [
			               self reset.
			               testCaseListPresenter resetSelection.
			               testResults := self
				                              runTests:
				                              testCaseListPresenter selectedItems
				                              in: testClassService name ] ensure: [
				               testSemaphore signal.
				               testProcess := nil.
				               shouldStopTestRun := false ] ] fork
]

{ #category : 'initialization' }
JadeiteSUnitBrowserPresenter >> connectPresenters [

	self testCaseListPresenter whenSelectionChangedDo: [ :selection |
		selection traceCr ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> debugAll [

	testSemaphore := Semaphore new.
	testClassService ifNil: [ ^ self ].
	testProcess := [
		               [
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
JadeiteSUnitBrowserPresenter >> initializePresenters [

	testCaseListPresenter := JadeiteListPresenter newNameSortedList
		                         headerTitle: 'Test Cases';
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

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> refreshView [
	self uiManager defer: [ testCaseListPresenter refresh ]
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> reset [

	testCaseListPresenter model do: [ :each | each testResult: nil ].
	testCaseListPresenter invalidate
]

{ #category : 'actions' }
JadeiteSUnitBrowserPresenter >> setColorFor: jadeiteResult [

	
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
