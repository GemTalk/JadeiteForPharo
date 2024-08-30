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
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProcessServiceClient class >> debuggedProcessServices [

	^ DebuggedProcessServices ifNil: [
		  DebuggedProcessServices := OrderedCollection new ]
]

{ #category : 'accessing' }
RowanProcessServiceClient class >> debuggedProcessServices: aCollection [

	DebuggedProcessServices := OrderedCollection new
]

{ #category : 'debugger' }
RowanProcessServiceClient >> cleanUpClient [

	self class debuggedProcessServices remove: self ifAbsent:[]
]

{ #category : 'accessing' }
RowanProcessServiceClient >> debugger [

	^ debugger
]

{ #category : 'debugger' }
RowanProcessServiceClient >> openDebugger [

	| activeProcess |
	activeProcess := Processor activeProcess.
	debugger := JadeiteDebuggerApplication showOnSession:
		            GciSession current library.
	debugger
		suspendedProcess: activeProcess;
		gsProcess: self.
	debugger errorMessagePresenter text: errorMessage.
	debugger frameListPresenter items: frames.
	debugger selectInitialFrame.
	self class debuggedProcessServices add: self.
	activeProcess suspend.
	^ debugger answer
]

{ #category : 'debugger' }
RowanProcessServiceClient >> updateClient [

	| activeProcess |
	activeProcess := Processor activeProcess.
	debugger suspendedProcess: activeProcess.
	debugger frameListPresenter items: frames.
	debugger selectInitialFrame.
	activeProcess suspend.
	^ debugger answer
]
