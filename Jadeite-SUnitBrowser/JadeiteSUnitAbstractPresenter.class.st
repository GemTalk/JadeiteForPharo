Class {
	#name : 'JadeiteSUnitAbstractPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'methodListPresenter',
		'textResultPresenter',
		'shouldStopTestRun',
		'testProcess',
		'testResults'
	],
	#category : 'Jadeite-SUnitBrowser',
	#package : 'Jadeite-SUnitBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> debugTestAsFailureMethodServices: methodServices className: className [
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTestAsFailure:inClassName:
				methods: methodServices
				className: className.
	^jadeResult
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> debugTestMethodServices: methodServices className: className [
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> debugTests: methodServices [
	^self subclassResponsibility
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> editSelectAll [
	methodListPresenter selections: methodListPresenter list. 
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> initialize [
	super initialize.
	shouldStopTestRun := false
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> methodListPresenter [
	^methodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> methodListPresenter: anObject [
	methodListPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> refresh [

	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> refreshFromServerAfterAbort: browserService [
	self refresh
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> reset [

	methodListPresenter model do: [ :each | each testResult: nil ].
	textResultPresenter value: String new.
	methodListPresenter view invalidate.
	self setResultsPaneColor: JadeiteApplication defaultBackgroundColor
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> runTestCommand: command methods: methodServices className: className [

	| jadeResult index methodService |
	shouldStopTestRun := false.
	jadeResult := JadeTestResult new.
	index := 1.
	methodService := methodServices at: index.

	[ shouldStopTestRun ] whileFalse: [
		methodService
			command: command;
			commandArgs: (Array
					 with: methodService selector
					 with: (className ifNil: [ methodService className ])).
		RowanServiceUpdater current
			issueCommand: methodService
			session: self gciSession
			onCompletion: nil.
		methodService testResult = 'error' ifTrue: [
			jadeResult addError: methodService ].
		methodService testResult = 'failure' ifTrue: [
			jadeResult addFailure: methodService ].
		methodService testResult = 'passed' ifTrue: [
			jadeResult addPassed: methodService ].
		shouldStopTestRun ifFalse: [
			index := index + 1.
			index > methodServices size
				ifTrue: [
					shouldStopTestRun := true.
					self updateResult: jadeResult ]
				ifFalse: [ methodService := methodServices at: index ] ] ]
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> runTestMethodServices: methodServices className: className [
	| jadeResult |
	methodServices isEmpty ifTrue: [^self]. 
	jadeResult := self
				runTestCommand: #runTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> runTests: methodServices [
	^self runTestMethodServices: methodServices className: nil
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> runTests: methodServices in: className [
	^self runTestMethodServices: methodServices className: className
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> selectedClass [
	^self subclassResponsibility
]

{ #category : 'displaying' }
JadeiteSUnitAbstractPresenter >> setResultsPaneColor: aColor [

	self todo: 'should this use a style instead?'.
	textResultPresenter withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget | widget backgroundColor: aColor ] ]
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> stopTestProcess [
	testProcess
		ifNotNil: 
			[shouldStopTestRun := true.
			[shouldStopTestRun] whileTrue: [(Delay forMilliseconds: 1) wait].
			testProcess ifNotNil: [:proc | proc terminate].
			testProcess := nil]
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> testProcess [
	^testProcess
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> testProcess: anObject [
	^testProcess := anObject
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> textResultPresenter [
	^textResultPresenter
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> textResultPresenter: anObject [
	textResultPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeiteSUnitAbstractPresenter >> updateResult: jadeResult [
	jadeResult setSummary.
	self setColorFor: jadeResult
]
