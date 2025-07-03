Class {
	#name : 'JadeiteForPharoDebuggerTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'debugger'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoDebuggerTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor"

	^ {
		  JadeiteDebuggerPresenter.
		  JadeiteDebuggerApplication } asOrderedCollection
]

{ #category : 'accessing' }
JadeiteForPharoDebuggerTestCase class >> jadeiteTestResourceClass [ 

	^TestResource
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> setUp [
	"Debuggers should be closed before debugger test is run.
	Don't call super setUp as we don't want to use the JadeiteTestResource for this test class"

	JadeitePreferences isRowanLoaded: true.
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

	| service count |
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	debugger frameListPresenter selectIndex: 1.

	projectsBrowser := debugger browseFrameMethod owner owner.
	count := 0.
	[ self projectsPresenter selectedClass isNil and: [ count < 2000 ] ]
		whileTrue: [
			count := count + 1.
			(Delay forMilliseconds: 1) wait ].
	self
		assert: self projectsPresenter selectedClass name
		equals: 'ProcessorScheduler'.
	count := 0.
	[
	self projectsPresenter methodListPresenter selectedItem isNil and: [
		count < 2000 ] ] whileTrue: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	self
		assert:
		self projectsPresenter methodListPresenter selectedItem selector
		equals: #_switchFrom:to:
]

{ #category : 'tests' }
JadeiteForPharoDebuggerTestCase >> test_fileInError [
	"file in errors should not result in a hung image"

	| fileContents fileName fileRef |
	self
		testsJadeiteForPharoIssue: #issue295
		title:
		'Hard hang on filein with method class set to unknown class name'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/295'.

	RowanServiceUpdater current singleThreaded: true.
	fileContents := 'method BananaSkidoo
testingFileinIssuePleaseIgnore
^6
%' replaceCrWithLf.

	fileName := FileSystem workingDirectory fullName
	            , 'test_fileInError.txt'.
	fileRef := fileName asFileReference.
	fileRef writeStream
		nextPutAll: fileContents;
		flush.
	[
	self assert: fileRef exists.
	[ JadeiteConsole currentConsole basicFileInServerFile: fileName ]
		fork.
	self waitForDebugger.
	self assert: debugger isKindOf: JadeiteDebuggerPresenter.
	self assert:
		('invalid class name ''BananaSkidoo'', at line 1 file*' match:
			 debugger errorMessagePresenter text).
	self
		assert: debugger frameListPresenter selectedItem printString
		equals: 'GsFileIn class >> _resolveClass: @7 line 4'.
	self
		assert: debugger frameListPresenter selection selectedIndex
		equals: 13.
	debugger frameListPresenter selectIndex: 14. "can do stuff so image not hung (and of course test continues)"
	self
		assert: debugger frameListPresenter selection selectedIndex
		equals: 14 ] ensure: [
		fileRef delete.
		RowanServiceUpdater current singleThreaded: false ]
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
JadeiteForPharoDebuggerTestCase >> test_reset [

	| service |
	service := RowanAnsweringServiceClient newForked.
	service exec: '$abc' in: GciSession current onCompletion: [  ].
	self waitForDebugger.
	self assertTextPaneResetFor: debugger methodSourcePresenter
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
JadeiteForPharoDebuggerTestCase >> toolUsedForCommonTests [

	^ debugger ifNil: [
		  | service |
		  service := RowanAnsweringServiceClient newForked.
		  service exec: '$abc' in: GciSession current onCompletion: [  ].
		  self waitForDebugger ]
]

{ #category : 'support' }
JadeiteForPharoDebuggerTestCase >> waitForDebugger [

	| debuggedProcesses |
	debuggedProcesses := RowanProcessServiceClient
		                     debuggedProcessServices.
	[ debuggedProcesses isEmpty ] whileTrue: [
		(Delay forMilliseconds: 1) wait.
		WorldMorph doOneCycle ].
	debugger := debuggedProcesses first debugger.
	(Delay forMilliseconds: 250) wait. "wait for widget to be built"
	^ debugger
]
