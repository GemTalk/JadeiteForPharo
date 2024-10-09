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

	self destroy: debugger.
	JadeiteConnectionProfile connectionProfile disconnect. 
]

{ #category : 'tests' }
JadeiteForPharoDebuggerTestCase >> test_browseFrameMethod [

	| service |
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	debugger frameListPresenter selectIndex: 1.

	projectsBrowser := debugger browseFrameMethod owner owner.
	[ self projectsPresenter selectedClass isNil ] whileTrue: [
		(Delay forMilliseconds: 1) wait ].
	self
		assert: self projectsPresenter selectedClass name
		equals: 'ProcessorScheduler'.
	[ self projectsPresenter methodListPresenter selectedItem isNil ]
		whileTrue: [ (Delay forMilliseconds: 1) wait ].
	self
		assert:
		self projectsPresenter methodListPresenter selectedItem selector
		equals: #_switchFrom:to:
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
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	self assert: debugger isKindOf: JadeiteDebuggerPresenter
]

{ #category : 'tests' }
JadeiteForPharoDebuggerTestCase >> test_selectDebuggerVariable [
	"selecting the display labels was giving walkback"

	| service |
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	debugger frameListPresenter selectIndex:
		debugger frameListPresenter selectionMode selectedIndex - 1.
	self assert: ('*doesNotUnderstand*' match:
			 debugger frameListPresenter selectedItem label).
	debugger variableListPresenter selectionMode selectIndex: 1.
	self deny:
		debugger variableListPresenter selectedItem isVariableDisplayLabel.
	self assert: debugger variableDataPresenter text equals: '$a'.
	debugger variableListPresenter selectionMode selectIndex: 2.
	self assert:
		debugger variableListPresenter selectedItem isVariableDisplayLabel.
	self assert: debugger variableDataPresenter text equals: String new
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> waitForDebugger [

	| debuggedProcesses |
	debuggedProcesses := RowanProcessServiceClient
		                     debuggedProcessServices.
	[ debuggedProcesses isEmpty ] whileTrue: [
		(Delay forMilliseconds: 1) wait.
		WorldMorph doOneCycle ].
	debugger := debuggedProcesses first debugger
]
