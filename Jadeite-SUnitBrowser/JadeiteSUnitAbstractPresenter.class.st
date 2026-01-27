Class {
	#name : 'JadeiteSUnitAbstractPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'methodListPresenter',
		'textResultPresenter',
		'shouldStopTestRun',
		'testProcess',
		'testResults',
		'testSemaphore'
	],
	#category : 'Jadeite-SUnitBrowser',
	#package : 'Jadeite-SUnitBrowser'
}

{ #category : 'testing' }
JadeiteSUnitAbstractPresenter class >> isAbstract [

	^ self name = 'JadeiteSUnitAbstractPresenter'
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> addError: methodService to: jadeResult [

	methodService testResult = 'error' ifTrue: [
		jadeResult addError: methodService ].
	methodService testResult = 'failure' ifTrue: [
		jadeResult addFailure: methodService ].
	methodService testResult = 'passed' ifTrue: [
		jadeResult addPassed: methodService ]
]

{ #category : 'testing' }
JadeiteSUnitAbstractPresenter >> canDiscardEdits [

	^true
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> debug [

	self subclassResponsibility
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> debugAll [

	self subclassResponsibility
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> debugTestAsFailureMethodServices: methodServices className: className [
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTestAsFailure:inClassName:
				methods: methodServices
				className: className.
	^jadeResult
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> debugTestMethodServices: methodServices className: className [
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> debugTests: methodServices [
	^self subclassResponsibility
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> editSelectAll [
	methodListPresenter selections: methodListPresenter list. 
]

{ #category : 'initialization' }
JadeiteSUnitAbstractPresenter >> initialize [
	super initialize.
	shouldStopTestRun := false
]

{ #category : 'accessing' }
JadeiteSUnitAbstractPresenter >> methodListPresenter [
	^methodListPresenter
]

{ #category : 'accessing' }
JadeiteSUnitAbstractPresenter >> methodListPresenter: anObject [
	methodListPresenter := anObject
]

{ #category : 'initialization' }
JadeiteSUnitAbstractPresenter >> newJadeiteSUnitToolbar [

	| theToolbar |
	theToolbar := self newJadeiteToolbar.
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
JadeiteSUnitAbstractPresenter >> refresh [

	self subclassResponsibility
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> refreshFromServerAfterAbort: browserService [
	self refresh
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> refreshView [ 
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> reset [

	methodListPresenter model do: [ :each | each testResult: nil ].
	textResultPresenter value: String new.
	methodListPresenter view invalidate.
	self setResultsPaneColor: Smalltalk ui theme jadeiteBackgroundColor
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> runAll [

	testSemaphore := Semaphore new.
	self basicRunAll
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> runSelected [
	
	testSemaphore := Semaphore new. 
	self basicRunSelected
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> runTestCommand: command methods: methodServices className: className [

	| jadeResult index methodService continueTest ms |
	shouldStopTestRun := false.
	jadeResult := JadeTestResult new.
	index := 1.
	methodService := methodServices at: index.
	continueTest := Semaphore new.
	[ shouldStopTestRun ] whileFalse: [
		methodService
			command: command;
			commandArgs: (Array
					 with: methodService selector
					 with: (className ifNil: [ methodService className ]));
			testResult: nil;
			catchBlock: [
				| testRunTime |
				testRunTime := Time millisecondClockValue - ms.
				jadeResult addMs: testRunTime.
				shouldStopTestRun := true.
				self addError: methodService to: jadeResult.
				self updateResult: jadeResult.
				continueTest signal ].
		ms := Time millisecondClockValue.
		RowanServiceUpdater current
			issueCommand: methodService
			session: self gciSession
			onCompletion: [
				| testRunTime |
				testRunTime := Time millisecondClockValue - ms.
				jadeResult addMs: testRunTime.
				self addError: methodService to: jadeResult.
				self refreshView. 
				continueTest signal ].
		continueTest wait.
		shouldStopTestRun ifFalse: [
			index := index + 1.
			index > methodServices size
				ifTrue: [
					shouldStopTestRun := true.
					self updateResult: jadeResult ]
				ifFalse: [ methodService := methodServices at: index ] ] ]
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> runTestMethodServices: methodServices className: className [
	| jadeResult |
	methodServices isEmpty ifTrue: [^self]. 
	jadeResult := self
				runTestCommand: #runTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> runTests: methodServices [
	^self runTestMethodServices: methodServices className: nil
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> runTests: methodServices in: className [
	^self runTestMethodServices: methodServices className: className
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> selectedClass [
	^self subclassResponsibility
]

{ #category : 'displaying' }
JadeiteSUnitAbstractPresenter >> setResultsPaneColor: aColor [

	self todo: 'should this use a style instead?'.
	textResultPresenter withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget | widget backgroundColor: aColor ] ]
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> stopTestProcess [
	testProcess
		ifNotNil: 
			[shouldStopTestRun := true.
			[shouldStopTestRun] whileTrue: [(Delay forMilliseconds: 1) wait].
			testProcess ifNotNil: [:proc | proc terminate].
			testProcess := nil]
]

{ #category : 'accessing' }
JadeiteSUnitAbstractPresenter >> testProcess [
	^testProcess
]

{ #category : 'accessing' }
JadeiteSUnitAbstractPresenter >> testProcess: anObject [
	^testProcess := anObject
]

{ #category : 'accessing' }
JadeiteSUnitAbstractPresenter >> textResultPresenter [
	^textResultPresenter
]

{ #category : 'accessing' }
JadeiteSUnitAbstractPresenter >> textResultPresenter: anObject [
	textResultPresenter := anObject
]

{ #category : 'actions' }
JadeiteSUnitAbstractPresenter >> updateResult: jadeiteResult [

	jadeiteResult setSummary.
	self setColorFor: jadeiteResult
]
