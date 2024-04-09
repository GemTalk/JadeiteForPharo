Class {
	#name : 'RowanProcessServiceClient',
	#superclass : 'RowanProcessService',
	#instVars : [
		'answer',
		'debugger'
	],
	#classVars : [
		'DebuggedProcessServices'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProcessServiceClient class >> debuggedProcessServices [

	^ DebuggedProcessServices ifNil: [
		  DebuggedProcessServices := OrderedCollection new ]
]

{ #category : 'debugger' }
RowanProcessServiceClient >> cleanUpClient [

	self class debuggedProcessServices remove: self ifAbsent:[]
]

{ #category : 'debugger' }
RowanProcessServiceClient >> openDebugger [

	| activeProcess newUIProcess uiProcess |
	self class debuggedProcessServices add: self.
	activeProcess := Processor activeProcess.
	DefaultExecutionEnvironment beActiveDuring: [
		uiProcess := UIManager default uiProcess.
		RowanServiceUpdater current logComment:
			'uiProcess ' , uiProcess identityHash printString.
		[ uiProcess suspend ] ensure: [
			UIManager default spawnNewProcess.
			newUIProcess := UIManager default uiProcess.
			RowanServiceUpdater current logComment:
				'newUIProcess ' , newUIProcess identityHash printString ] ].
	UIManager default defer: [
		debugger := JadeiteDebuggerApplication showOnSession:
			            GciSession current library.
		debugger
			suspendedProcess: activeProcess;
			gsProcess: self.
		debugger errorMessagePresenter text: errorMessage.
		debugger frameListPresenter items: frames.
		debugger selectInitialFrame ].
	activeProcess suspend.
	^ [ debugger answer ] ensure: [
		  [
		  RowanServiceUpdater current logComment:
			  'newUIProcess about to terminate '
			  , newUIProcess identityHash printString.
		  newUIProcess
			  suspend;
			  terminate.
		  RowanServiceUpdater current logComment:
			  'newUIProcess terminated' , newUIProcess identityHash printString ]
			  ensure: [
				  debugger answer == #terminate ifFalse: [
					  RowanServiceUpdater current logComment:
						  'uiProcess about to resume.'
						  , uiProcess identityHash printString.
					  UIManager default resumeUIProcess: uiProcess ] ] ]
]

{ #category : 'debugger' }
RowanProcessServiceClient >> updateClient [

	| activeProcess |
	activeProcess := Processor activeProcess.
	UIManager default defer: [
		activeProcess suspend.
		debugger suspendedProcess: activeProcess.
		debugger frameListPresenter items: frames.
		debugger selectInitialFrame ].
	activeProcess suspend.
	^ debugger answer
]
