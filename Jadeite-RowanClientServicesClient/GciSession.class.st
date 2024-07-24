Class {
	#name : 'GciSession',
	#superclass : 'DolphinClass',
	#instVars : [
		'briefDescription',
		'clientForwarders',
		'eventCount',
		'gciSessionId',
		'gemHost',
		'gemNRS',
		'heartbeatProcess',
		'isHandlingClientForwarderSend',
		'isPackagePolicyEnabled',
		'library',
		'netPort',
		'netTask',
		'server',
		'stoneHost',
		'stoneName',
		'stoneNRS',
		'stoneSerial',
		'stoneSessionID',
		'userID',
		'blocking',
		'autoCommit',
		'isLoggingOut'
	],
	#classVars : [
		'Current',
		'GemCursor'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
GciSession class >> current [

	^Current ifNil: [ Current := self new ]
]

{ #category : 'accessing' }
GciSession >> autoCommit [

	autoCommit
		ifNil: [ autoCommit := JadeiteValueHolder with: false ]
		ifNotNil: [ autoCommit value ifNil: [ autoCommit value: false ] ].
	^ autoCommit
]

{ #category : 'accessing' }
GciSession >> autoCommit: anObject [

	autoCommit := anObject
]

{ #category : 'initialization' }
GciSession >> basicFlipAutoCommit [

	| autoCommitService |
	autoCommitService := RowanAutoCommitService new.
	autoCommitService
		command: #flipAutoCommit;
		commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: autoCommitService
		session: self
		onCompletion: [ self autoCommit value: autoCommitService autoCommit ]
]

{ #category : 'actions' }
GciSession >> commit [
	JadeiteApplication commitTransactionInSession: self
]

{ #category : 'actions' }
GciSession >> executeString: aString [

	| answeringService answer oop |
	oop := 20.
	answeringService := RowanAnsweringServiceClient new registerWith:
		                    library.
	answeringService
		command: #exec:context:shouldDebug:;
		commandArgs: (Array with: aString with: oop with: false).
	RowanServiceUpdater current issueCommand: answeringService session: self.
	answer := answeringService answer.
	answer first ifFalse: [ ^ answer at: 2 ].
	^ answer last
]

{ #category : 'initialization' }
GciSession >> flipAutoCommit [
	self basicFlipAutoCommit
	
]

{ #category : 'initialization' }
GciSession >> initializeAutoCommitRefreshing: console [

	self updateAutoCommitRefreshing: console
]

{ #category : 'testing' }
GciSession >> isValidSession [

	^ library notNil and: [ library isOpen ]
]

{ #category : 'actions' }
GciSession >> issueCommand: service onCompletion: anObject [

	RowanServiceUpdater current issueCommand: service session: self
]

{ #category : 'accessing' }
GciSession >> library [ 
	^library
]

{ #category : 'accessing' }
GciSession >> library: anObject [

	library := anObject
]

{ #category : 'actions' }
GciSession >> logout [

	library close
]

{ #category : 'accessing' }
GciSession >> oopNil [ 
	^20
]

{ #category : 'server' }
GciSession >> serverPerform: unused with: stonString [
	"Temporarily, unpack the STON string and use RSR for replication. 
	We can possibly skip the creation of the STON string in the first place if RSR replication works"

	| services |
	services := STON fromString: stonString.
	services do: [ :service |
		RowanServiceUpdater current logger newLoggingService logComment:
			'GciSession>>#serverPerform:with: - command '
			, service command printString.
		RowanServiceUpdater current logger newLoggingService logComment:
			'GciSession>>#serverPerform:with: - commandArgs '
			, service commandArgs printString.
		service executeCommand updates do: [ :update | "handle update" ] ]
]

{ #category : 'Jade convenience' }
GciSession >> serverPerformInterpreted: a with: b with: c [
]

{ #category : 'private' }
GciSession >> setInitials: initials [
	| pieces string |
	server isNil ifTrue: [^self].
	RowanServiceUpdater current inUpdateWhile: [string := self serverPerform: #mcInitials: with: initials].
	pieces := string subStrings collect: [:each | each asNumber].
	stoneSessionID := pieces at: 1.
	stoneSerial := pieces at: 2
]

{ #category : 'accessing' }
GciSession >> stoneName [

	^ stoneName
]

{ #category : 'accessing' }
GciSession >> stoneName: anObject [

	stoneName := anObject
]

{ #category : 'as yet unclassified' }
GciSession >> titleBarFor: windowName [

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: windowName;
		nextPutAll: ' on ';
		nextPutAll: stoneName;
		space;
		nextPut: $@;
		space;
		nextPutAll: library specification host;
		nextPutAll: ' [';
		print: library specification port;
		nextPutAll: ']'.
	^ stream contents
]

{ #category : 'initialization' }
GciSession >> updateAutoCommitRefreshing: console [

	| service |
	service := RowanAnsweringService new.
	service autoCommitIn: self onCompletion: [
		self autoCommit value: (service answer ifNil: [ false ]).
		self autoCommit whenChangedSend: #updateAutoCommitButton to: console.
		console updateAutoCommitButton ]
]
