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

	| activeProcess debuggerApplication |
	activeProcess := Processor activeProcess.
	debuggerApplication := JadeiteDebuggerApplication new gciSession:
		                       GciSession current.
	debuggerApplication gciSession library: GciSession current library.
	debugger := debuggerApplication new: JadeiteDebuggerPresenter.
	debugger
		suspendedProcess: activeProcess;
		gsProcess: self.
	debugger
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: GciSession current.
	debugger errorMessagePresenter text: errorMessage.
	1 to: frames size do: [ :index | (frames at: index) index: index ].
	debugger frameListPresenter items: frames.
	debugger selectInitialFrame.
	self class debuggedProcessServices add: self.
	UIManager default defer: [ debugger open ].
	WorldMorph doOneCycle. "make sure tests get a gui cycle"
	activeProcess suspend.
	^ debugger answer
]

{ #category : 'debugger' }
RowanProcessServiceClient >> updateClient [

	| activeProcess |
	activeProcess := Processor activeProcess.
	debugger suspendedProcess: activeProcess.
	1 to: frames size do: [ :index | 
		(frames at: index) index: index
		].
	debugger frameListPresenter items: frames.
	debugger selectInitialFrame.
	activeProcess suspend.
	^ debugger answer
]
