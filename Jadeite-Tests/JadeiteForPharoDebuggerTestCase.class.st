Class {
	#name : 'JadeiteForPharoDebuggerTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'debugger'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'accessing' }
JadeiteForPharoDebuggerTestCase class >> testResourceClass [ 

	^TestResource
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> setUp [
	"Debuggers should be closed before debugger test is run.
	Don't call super setUp as we don't want to use the JadeiteTestResource for this test class"
	self ensureLauncherOpened.
	JadeiteConnectionProfile connectionProfile disconnect.
	JadeiteConnectionProfile connectionProfile connect.
	RowanProcessServiceClient debuggedProcessServices:
		OrderedCollection new
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> tearDown [

	super tearDown.
	self destroy: debugger.
]

{ #category : 'tests' }
JadeiteForPharoDebuggerTestCase >> test_instpectVar [

	| service item inspector |
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	item := debugger variableListPresenter list collection detect: [
		        :thing | thing key = #receiver ].
	debugger variableListPresenter selectItem: item.
	inspector := debugger inspectVariable.
	[ inspector codePane text = 'nil' ] whileFalse: [
		(Delay forMilliseconds: 1) wait ].
	[ self assert: inspector codePane text equals: 'nil' ] ensure: [
		self destroy: inspector ]
]

{ #category : 'tests' }
JadeiteForPharoDebuggerTestCase >> test_openDebugger [

	| service |
	"force it to be forked "
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	self assert: debugger isKindOf: JadeiteDebuggerPresenter
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> waitForDebugger [

	| debuggedProcesses |
	debuggedProcesses := RowanProcessServiceClient
		                     debuggedProcessServices.
	[ debuggedProcesses isEmpty ] whileTrue: [
		(Delay forMilliseconds: 1) wait ].
	debugger := debuggedProcesses first debugger
]
