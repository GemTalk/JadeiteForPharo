Class {
	#name : 'JadeiteForPharoDebuggerTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'debugger'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> setUp [

	super setUp.
	JadeiteConnectionProfile connectionProfile disconnect.
	RowanProcessServiceClient debuggedProcessServices:
		OrderedCollection new.
	JadeiteConnectionProfile connectionProfile connect.
	RowanServiceUpdater current: RowanServiceUpdater new "don't use test updater so we can force forking"
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> tearDown [

	super tearDown.
	self destroy: debugger.
]

{ #category : 'tests' }
JadeiteForPharoDebuggerTestCase >> test_instpectVar [

	| service item inspector |
	self assert:
		RowanProcessServiceClient debuggedProcessServices isEmpty.
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	[ debugger variableListPresenter list collection isEmpty ]
		whileTrue: [ (Delay forMilliseconds: 1) wait ].
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
	self assert:
		RowanProcessServiceClient debuggedProcessServices isEmpty.
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	self assert: debugger isKindOf: JadeiteDebuggerPresenter
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> waitForDebugger [

	[ RowanProcessServiceClient debuggedProcessServices isEmpty ]
		whileTrue: [ (Delay forMilliseconds: 1) wait ].
	[
	(debugger := JadeiteDebuggerPresenter allInstances
		             detect: [ :theDebugger |
			             theDebugger gsProcess
			             ==
			             RowanProcessServiceClient debuggedProcessServices
				             first ]
		             ifNone: [  ]) isNil ] whileTrue: [
		(Delay forMilliseconds: 1) wait ]
]
