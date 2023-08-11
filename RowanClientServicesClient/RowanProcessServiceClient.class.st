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
	#category : 'RowanClientServicesClient'
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
	[
	activeProcess suspend.
	UIManager default defer: [ "open debugger in ui thread"
		debugger := JadeiteDebuggerApplication showOnSession:
			            GciSession current library.
		debugger
			suspendedProcess: activeProcess;
			gsProcess: self.
		debugger errorMessagePresenter text: errorMessage.
		debugger frameListPresenter items: frames.
		debugger selectInitialFrame ] ] fork.
	Processor yield.
	^ debugger answer
]

{ #category : 'debugger' }
RowanProcessServiceClient >> updateClient [

	| activeProcess |
	activeProcess := Processor activeProcess.
	[
	activeProcess suspend.
	debugger suspendedProcess: activeProcess.
	debugger frameListPresenter items: frames.
	debugger selectInitialFrame ] fork.
	Processor yield.
	^ debugger answer
]
