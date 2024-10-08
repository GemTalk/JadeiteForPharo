Class {
	#name : 'JadeiteDebuggerDataCuratorTestCase',
	#superclass : 'JadeiteAbstractTestCase',
	#instVars : [
		'debugger',
		'gsProcess',
		'process',
		'secondDebugger',
		'executionResult'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> cleanupProcesses [
	(debugger isKindOf: JadeiteDebugger)
		ifTrue: 
			[debugger debuggerService processes do: 
					[:processService |
					session executeString: '[(Object _objectForOop: ' , processService oop printString
								, ') terminate] on: Error do:[:ex | "ignore"]']]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> closeDebuggers [
	| list semaphore |
	list := JadeiteMethodListBrowser allInstances , JadeiteBrowser allInstances
				, JadeiteDebugger allInstances.
	semaphore := Semaphore new.
	list do: 
			[:each |
			session removeEventsTriggeredFor: each.
			
			[
			[self destroy: each.
			semaphore signal.
			SessionManager inputState prod]
					on: ProcessTermination
					do: 
						[:ex |
						"A debugger wants to terminate the current process!!"
						
						[semaphore signal.
						SessionManager inputState prod] forkAt: Processor userBackgroundPriority.
						ex pass]]
					fork.
			semaphore wait.
			debugger == each ifTrue: [debugger := nil]].
	list := nil.
	MemoryManager current collectGarbage.
	(Delay forMilliseconds: 50) wait.
	JadeiteMethodListBrowser allInstances
		do: [:browser | self assert: (browser view isKindOf: DeafObject)].
	JadeiteBrowser allInstances do: [:browser | self assert: (browser view isKindOf: DeafObject)].
	JadeiteDebugger allInstances
		do: [:theDebugger | (theDebugger view isKindOf: DeafObject) ifFalse: [(Delay forMilliseconds: 50) wait]].
	MemoryManager current collectGarbage.
	(Delay forMilliseconds: 50) wait.
	self purgeInstances: JadeiteBrowser.
	self purgeInstances: JadeiteMethodListBrowser.
	JadeiteDebugger allInstances do: [:theDebugger | theDebugger debuggerClosed: true].
	self purgeInstances: JadeiteDebugger.
	self assert: JadeiteDebugger allInstances isEmpty.
	self assert: JadeiteMethodListBrowser allInstances isEmpty.
	self assert: JadeiteBrowser allInstances isEmpty.
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> closeJadeiteLoginShells [
	| query |
	JadeiteLoginShell allInstances do: 
			[:inst |
			query := CommandQuery commandDescription: (CommandDescription command: #login)
						source: inst loginButtonPresenter view.
			inst queryCommand: query.
			self assert: query isEnabled.	"any login shell should have a disabled login button"
			inst view close].
	^query
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> createTestMethodWithBreakpoints [
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveMethod: 'test_highlightBreaks
	"self new test_highlightBreaks"
	| var i log |

	[
		var := WriteStream on: String new.
		log := String new.
		i := 20.
		var nextPutAll: ''123''.
		log add: ''abc''.
		
	] ensure: 
	[
		log size < 5 ifTrue: [log add: ''def''].
		var contents size < 5 ifTrue: [log add: ''456''].
		i = 20 ifTrue: [ i := 3].
	].

	self assert: i = 3'
		in: 'RowanSample1Test'
		category: 'tests'.
	self selectMethodNamed: #test_highlightBreaks.
	self setBreakAt: 22. "first add:"
	self setBreakAt: 25.
	self setBreakAt: 28
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> debuggerDo: aBlock [
	self assert: JadeiteDebugger semaphore isNil.
	JadeiteDebugger semaphore: Semaphore new.
	[aBlock value] ensure: 
			[SessionManager inputState processDeferredActions.
			JadeiteDebugger semaphore wait.
			JadeiteDebugger semaphore: nil]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> getClipboardContents [
	"Private - `Clipboard current getText` occasionally gets an `Access is denied` error.
	Retry several times, pausing in between each attempt, until the clipboard is retrieved."

	| clipboardContents contentsRetrieved |
	contentsRetrieved := true.
	[clipboardContents := Clipboard current getText] on: Error do: [:ex | contentsRetrieved := false].
	contentsRetrieved
		ifFalse: 
			[(Delay forMilliseconds: 100) wait.
			clipboardContents := Clipboard current getText].
	^clipboardContents
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> getDebugger [
	"need a more definitive test to know when debugger is fully built"

	100 timesRepeat: 
			[debugger := JadeiteDebugger allInstances detect: [:each | (each view isKindOf: DeafObject) not]
						ifNone: [nil].
			(debugger notNil and: 
					[debugger documentPresenter view selection notEmpty and: 
							[debugger gciSession notNil
								and: [debugger methodSourcePresenter gciSession notNil and: [debugger basicSelectedFrame notNil]]]])
				ifTrue: [^self].
			(Delay forMilliseconds: 10) wait]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> getSecondDebugger [
	"Private - we opened up one debugger in the test, then another. find the second"

	100 timesRepeat: 
			[secondDebugger := JadeiteDebugger allInstances detect: [:aDebugger | aDebugger ~~ debugger]
						ifNone: [].
			secondDebugger notNil and: 
					[secondDebugger gsProcess notNil
						and: [secondDebugger documentPresenter view selection notEmpty ifTrue: [^true]]].
			(Delay forMilliseconds: 10) wait]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> keyDownEscapeIn: view [
	^view
		postMessage: 16r100
			wParam: 27
			lParam: 0;
		postMessage: 16r101
			wParam: 27
			lParam: 0;
		yourself	"WM_KEYDOWN"	"VK_ESCAPE"	"WM_KEYUP"	"VK_ESCAPE"
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> menuItemIsEnabled: menuItem [
	| commandPolicy commandQuery |
	commandPolicy := CommandPolicy defaultClass commandSource: debugger view.
	commandQuery := menuItem queryAlong: commandPolicy.
	^commandQuery isEnabled
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> methodListBrowser [

	^JadeiteMethodListBrowser allInstances detect: [:each | true] ifNone: [nil]

]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> openDebuggerOn: aString [
	JadeiteDebugger allInstances
		do: [:theDebugger | self assert: (theDebugger view isKindOf: DeafObject)].
	self
		debuggerDo: 
				[process := [executionResult := session executeString: aString] forkAt: Processor activePriority + 1];
		getDebugger;
		yourself.
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> openSecondDebuggerOn: aString [
	self
		debuggerDo: [process := [session executeString: aString] forkAt: Processor activePriority + 1];
		getSecondDebugger;
		yourself
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> pressButtonIn: view [
	view
		postMessage: 16r204
			wParam: 0
			lParam: 16r12C0064;
		postMessage: 16r205
			wParam: 0
			lParam: 16r12C0064;
		yourself	"WM_RBUTTONDOWN"	" (300 @ 100) "	"WM_RBUTTONUP"
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> primaryTestWindow [
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^debugger
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> purgeInstances: aClass [
	| count |
	count := 0.
	aClass allInstances isEmpty
		ifFalse: 
			[[count < 50] whileTrue: 
					[count := count + 1.
					MemoryManager current collectGarbage.
					SessionManager inputState pumpMessages.
					(Delay forMilliseconds: 1) wait.
					aClass allInstances isEmpty ifTrue: [^self]]].
	aClass allInstances do: 
			[:each |
			JadePresenter removeEventsTriggeredFor: each.
			each become: Object new].
	^count
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> removeMethodNamed: aSymbol [

	| classService methodService |
	methodService := RowanMethodService new
		                 selector: aSymbol;
		                 className: 'RowanSample1Test';
		                 meta: false.
	classService := RowanClassService named: 'RowanSample1Test'.
	classService updateForSession: session.
	classService
		command: #removeMethods:;
		commandArgs: (Array with: (Array with: methodService)).
	^ self issueCommand: classService onCompletion: [  ]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> saveMethodWithHalt [
	| source |
	source := 'sampleMethodWithHalt
		| array  | 
		array := Array new halt. 
		^array'.
	self saveMethod: source in: 'RowanSample1' category: 'other'
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> selectFrameAt: integer [
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event |
	event := (SelectionChangingEvent forSource: self)
				oldSelections: debugger frameListPresenter selections;
				newSelections: (Array with: (debugger frameListPresenter list at: integer));
				cause: #test;
				yourself.
	debugger frameListPresenter onSelectionChanging: event.
	event value ifFalse:[^self]. 
	debugger frameListPresenter selection: (debugger frameListPresenter list at: integer)
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> selectFrameMatching: wildCardString [
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event selectedFrame |
	selectedFrame := debugger frameListPresenter list detect: [:frame | wildCardString match: frame].
	event := (SelectionChangingEvent forSource: self)
				oldSelections: debugger frameListPresenter selections;
				newSelections: (Array with: selectedFrame);
				cause: #test;
				yourself.
	debugger frameListPresenter onSelectionChanging: event.
	event value ifFalse: [^self].
	debugger frameListPresenter selection: selectedFrame
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> selectVariableNamed: aSymbol [
	| variable |
	variable := debugger variableListPresenter list detect: [:var | aSymbol = var key value] ifNone: [].
	debugger variableListPresenter
		selectionByIndex: (debugger variableListPresenter list indexOf: variable).
	self assert: debugger variableListPresenter selection _key equals: aSymbol
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> setUp [
	user ifNil: [user := 'DataCurator']. "SystemUser will already be set in the subclass if not running as DataCurator" 
	super setUp
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> statusBarValue [
	^(debugger view viewNamed: 'statusBarField') value
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> systemBrowser [

	^JadeiteBrowser allInstances detect: [:each | true] ifNone: [nil]

]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> tearDown [
	TestMessageBox disableJadeiteTestMessageBox.	"in case the test has gotten stuck while enabled"
	TestJadeErrorShell disableJadeiteErrorShell.
	self assert: (session isKindOf: GciSession).
	self cleanupProcesses.
	self assert: (session isKindOf: GciSession).
	projectsBrowser
		ifNotNil: 
			[projectsBrowser view close.
			projectsBrowser := nil].
	debugger ifNotNil: [debugger documentPresenter view isModified: false].
	self assert: (session isKindOf: GciSession).
	secondDebugger ifNotNil: [secondDebugger documentPresenter view isModified: false].
	self assert: (session isKindOf: GciSession).
	process
		ifNotNil: 
			[process terminate.
			process := nil].
	self terminateGsProcess.
	self assert: (session isKindOf: GciSession).
	self closeDebuggers.
	JadeiteDebugger debuggerClass: nil.
	JadeiteDebugger semaphore: nil.
	self assert: (session isKindOf: GciSession).
	super tearDown
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> terminateGsProcess [
	| string |
	gsProcess ifNil: [^self].
	string := '
| gsProcess |
gsProcess := Object _objectForOop: ' , gsProcess printString
				, '.
gsProcess ifNotNil: [gsProcess terminate. (Delay forMilliseconds: 10) wait].
Processor allProcesses includes: gsProcess'.
	gsProcess := nil.
	5 timesRepeat: 
			[(debugger gciSession executeString: string) == false ifTrue: [^self]	"might not be a boolean. process could be terminated"].
	self assert: false
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> test_browseMenuOptionEnablement [
	"Don't enable Browse methods if the class is not resolvable"

	| contextMenu browseMenuItems frame |
	self testsIssue: #issue774
		withTitle: 'Disable Browse* debugger frame list menu options if method not visible'.
	session userID = 'DataCurator' ifFalse: [^self].	"will fail unless run as DataCurator"
	self
		openDebuggerOn: '((Rowan platform serviceClassFor: ''RowanAnsweringService'') new) exec: ''self halt'''.
	debugger frameListPresenter selectionByIndex: 1.	"halt frame"
	contextMenu := debugger frameListPresenter view contextMenu.
	browseMenuItems := contextMenu items
				select: [:theItem | theItem isDivider not and: ['*Browse*' match: theItem description]].
	browseMenuItems do: 
			[:theItem |
			| query |
			query := CommandQuery commandDescription: theItem commandDescription
						source: debugger frameListPresenter view.
			debugger queryCommand: query.
			self assert: query isEnabled].
	frame := debugger frameListPresenter list
				detect: [:frameString | '*RowanAnsweringService*' match: frameString]
				ifNone: [].
	debugger frameListPresenter selectionByIndex: (debugger frameListPresenter list indexOf: frame).
	browseMenuItems do: 
			[:theItem |
			| query |
			query := CommandQuery commandDescription: theItem commandDescription
						source: debugger frameListPresenter view.
			debugger queryCommand: query.
			self deny: query isEnabled]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> test_doubleClickWhenClassNotResolvable [
	"Don't enable Browse methods if the class is not resolvable"

	self testsIssue: #issue774
		withTitle: 'Disable Browse* debugger frame list menu options if method not visible'.
	session userID = 'DataCurator' ifFalse: [^self].	"will fail unless run as DataCurator"
	self
		openDebuggerOn: '((Rowan platform serviceClassFor: ''RowanAnsweringService'') new) exec: ''self halt'''.
	debugger frameListPresenter selectionByIndex: debugger frameListPresenter list size - 2.	"Exec block frame"
	self assert: ('RowanAnsweringService >>*' match: debugger frameListPresenter selection).
	self assert: debugger browseFrameMethod isKindOf: JadeiteDebugger	"returned without opening browser"
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> test_globalAdditionalAccelerators [
	self openDebuggerOn: 'self halt'.
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7'))
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> test_multipleDebuggersAdHocHasTemps [
	| sourceDocument |
	self testsIssue: #issue364 withTitle: 'Debug-it does nothing if comment preceeding temp vars'.
	self openDebuggerOn: '''abc'' halt size'.
	
	[sourceDocument := debugger methodSourcePresenter documentPresenter.
	sourceDocument value: '"comment"
| temp |
temp := ''abc''.
temp first'.
	sourceDocument view selectAll.
	sourceDocument view setFocus.
	[debugger methodSourcePresenter jadeDebug] fork.
	self getSecondDebugger.
	(Delay forMilliseconds: 100) wait.
	self assert: secondDebugger methodSourcePresenter documentPresenter value
		equals: '"comment"
| temp |
temp := ''abc''.
temp first' replaceCrLfWithLf]
			ensure: 
				["the not nil tests are to avoid trying to resume if the test was stopped prematurely"
				secondDebugger ifNotNil: [self debuggerDo: [secondDebugger resumeProcess]].
				debugger ifNotNil: [self debuggerDo: [debugger resumeProcess]]]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> test_multipleDebuggersBasic [
	| sourceDocument |
	self testsIssue: #issue927 withTitle: '[3.2.9] Concurrent debuggers can hang Jadeite'.
	self openDebuggerOn: '''abc'' halt size'.
	
	[sourceDocument := debugger methodSourcePresenter documentPresenter.
	sourceDocument value: '123'.
	sourceDocument view selectAll.
	sourceDocument view setFocus. 
	[debugger methodSourcePresenter jadeDebug] fork.
	self getSecondDebugger.
	(Delay forMilliseconds: 100) wait. 
	self assert: secondDebugger methodSourcePresenter documentPresenter value equals: '123']
			ensure: 
				["the not nil tests are to avoid trying to resume if the test was stopped prematurely"
				secondDebugger ifNotNil: [self debuggerDo: [secondDebugger resumeProcess]].
				debugger ifNotNil: [self debuggerDo: [debugger resumeProcess]]]
]

{ #category : 'as yet unclassified' }
JadeiteDebuggerDataCuratorTestCase >> test_multipleDebuggersOpenedIndependently [
	self testsIssue: #issue927 withTitle: '[3.2.9] Concurrent debuggers can hang Jadeite'.
	self openDebuggerOn: '| foo | foo := ''abc''. self halt. foo := foo size'.
	self openSecondDebuggerOn: '| foo | foo := ''def''. self halt. foo := foo size'.
	2 timesRepeat: 
			[self debuggerDo: [secondDebugger stepOver].
			self debuggerDo: [debugger stepOver]].
	self assert: debugger frameListPresenter list notEmpty.
	self assert: secondDebugger frameListPresenter list notEmpty
]
