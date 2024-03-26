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

	| activeProcess |
	self class debuggedProcessServices add: self.
	activeProcess := Processor activeProcess.
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
	^ [ self logCommand: thisContext printString with: 'Returning answer'. debugger answer ] ensure: [
		 ]
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
