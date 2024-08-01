"
Simple class to log comments on the client. 
jadeiteCallTracing* file put in Pharo image directory. 
"
Class {
	#name : 'JadeiteLogger',
	#superclass : 'Model',
	#instVars : [
		'loggingService',
		'isLogging',
		'nextGroupId',
		'logFileName',
		'shouldGetNewLoggerGroup',
		'semaphore'
	],
	#category : 'Jadeite-Logger',
	#package : 'Jadeite-Logger'
}

{ #category : 'transcript' }
JadeiteLogger class >> logActiveProcessToTranscript [
	"for debugging - no need to turn logger on"
	Transcript
		cr;
		show: 'uiProcess: ';
		print: UIManager default uiProcess identityHash;
		flush.
	Transcript
		cr;
		show: 'activeProcess: ';
		print: Processor activeProcess identityHash;
		flush.
	Transcript
		cr;
		show: '------------------------';
		flush
]

{ #category : 'operations' }
JadeiteLogger >> defaultLogFileName [
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'jadeiteCallTraceLog_'.
	ws nextPutAll: Date today yyyymmdd.
	ws nextPut: $_.
	Time now jadeitePrint24: true showSeconds: true on: ws.
	ws nextPutAll: '.txt'.
	^ws contents
]

{ #category : 'initialization' }
JadeiteLogger >> initialize [
	super initialize.
	isLogging := false.
	shouldGetNewLoggerGroup := true.
	semaphore := Semaphore forMutualExclusion. 
	self newLoggingService.
]

{ #category : 'accessing' }
JadeiteLogger >> isLogging [
	^isLogging
]

{ #category : 'accessing' }
JadeiteLogger >> isLogging: boolean [
	isLogging := boolean.
	loggingService isLogging: boolean
]

{ #category : 'accessing' }
JadeiteLogger >> logComment: string [

	self newLoggingService.
	isLogging ifTrue: [
		semaphore critical: [ loggingService logComment: string ] ]
]

{ #category : 'public' }
JadeiteLogger >> logFileName [

	^logFileName
]

{ #category : 'public' }
JadeiteLogger >> logFileName: string [
	logFileName := string.
	loggingService fileName: string
]

{ #category : 'accessing' }
JadeiteLogger >> logReceivedServices: services [

	isLogging ifTrue: [
		semaphore critical: [ loggingService logReceivedServices: services ] ]
]

{ #category : 'accessing' }
JadeiteLogger >> logSentServices: services [

	isLogging ifTrue: [
		semaphore critical: [ loggingService logSentServices: services ] ]
]

{ #category : 'accessing' }
JadeiteLogger >> loggingService [
	^loggingService
]

{ #category : 'accessing' }
JadeiteLogger >> loggingService: anObject [
	loggingService := anObject.
	loggingService ifNotNil: [loggingService isLogging: isLogging]
]

{ #category : 'accessing' }
JadeiteLogger >> newLoggingService [
	| inst |
	logFileName ifNil: [ logFileName := self defaultLogFileName ].
	^shouldGetNewLoggerGroup
		ifTrue: 
			[inst := RowanLoggingService loggingServiceClass newWithGroupId: self nextGroupId logger: self.
			inst command: #logReceivedServices.
			inst fileName: logFileName.
			self loggingService: inst.
			inst]
		ifFalse: [loggingService]
]

{ #category : 'double dispatch' }
JadeiteLogger >> newWithGroupId: integer logger: logger [
	(loggingService isNil or: [loggingService isTestLoggingService not])
		ifTrue: [^RowanLoggingService loggingServiceClass basicNewWithGroupId: integer logger: logger].
	^loggingService
]

{ #category : 'accessing' }
JadeiteLogger >> nextGroupId [
	^nextGroupId ifNil: [nextGroupId := 1] ifNotNil: [nextGroupId := nextGroupId + 1]
]

{ #category : 'accessing' }
JadeiteLogger >> shouldGetNewLoggerGroup [
	^shouldGetNewLoggerGroup
]

{ #category : 'accessing' }
JadeiteLogger >> shouldGetNewLoggerGroup: boolean [
	shouldGetNewLoggerGroup := boolean
]

{ #category : 'operations' }
JadeiteLogger >> startLogging [

	| file |
	nextGroupId := nil.
	self isLogging: true.
	logFileName := self defaultLogFileName.
	(File named: logFileName) exists ifTrue: [ ^ self ].
	file := File named: logFileName asFileReference fullName.
	file writeStream close
]

{ #category : 'operations' }
JadeiteLogger >> stopLogging [
	nextGroupId := nil.
	self isLogging: false
]
