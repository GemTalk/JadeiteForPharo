Class {
	#name : 'JadeiteLogger',
	#superclass : 'Model',
	#instVars : [
		'loggingService',
		'isLogging',
		'nextGroupId',
		'logFileName',
		'shouldGetNewLoggerGroup'
	],
	#category : 'JadeiteLogger'
}

{ #category : 'operations' }
JadeiteLogger >> defaultLogFileName [
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'jadeiteCallTraceLog_'.
	Date today printOn: ws format: 'yyyy_MM_dd_'.
	Time now printOn: ws format: 'hh.mm.ss'.
	ws nextPutAll: '.txt'.
	^ws contents
]

{ #category : 'initialization' }
JadeiteLogger >> initialize [
	super initialize.
	isLogging := false.
	shouldGetNewLoggerGroup := true.
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
	isLogging ifTrue: [loggingService logComment: string]
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
	isLogging ifTrue: [loggingService logReceivedServices: services]
]

{ #category : 'accessing' }
JadeiteLogger >> logSentServices: services [
	isLogging ifTrue: [loggingService logSentServices: services]
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
	^shouldGetNewLoggerGroup
		ifTrue: 
			[inst := RowanLoggingService loggingServiceClass newWithGroupId: self nextGroupId logger: self.
			inst command: #logReceivedServices.
			inst fileName: logFileName.
			self loggingService: inst.
			inst]
		ifFalse: [loggingService]
]

{ #category : 'accessing' }
JadeiteLogger >> newServiceLoggingService [
	^self newLoggingService
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
	nextGroupId := nil.
	self isLogging: true.
	logFileName := self defaultLogFileName
]

{ #category : 'operations' }
JadeiteLogger >> stopLogging [
	nextGroupId := nil.
	self isLogging: false
]
