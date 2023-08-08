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
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
GciSession class >> current [

	^Current ifNil: [ Current := self new ]
]

{ #category : 'accessing' }
GciSession >> autoCommit [
	^autoCommit
]

{ #category : 'accessing' }
GciSession >> autoCommit: anObject [

	autoCommit := anObject
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
		command: #execReturningPrintString:context:;
		commandArgs: (Array with: aString with: oop).
	BrowserUpdate current issueCommand: answeringService session: self.
	answer := answeringService answer.
	answer first ifFalse: [ ^ answer at: 2 ].
	^ answer last
]

{ #category : 'initialization' }
GciSession >> flipAutoCommit [

	| autoCommitService |
	autoCommitService := RowanAutoCommitService new.
	autoCommitService
		command: #flipAutoCommit;
		commandArgs: Array new.
	BrowserUpdate current
		issueCommands: (Array with: autoCommitService)
		session: self.
	self autoCommit value: autoCommitService autoCommit
]

{ #category : 'initialization' }
GciSession >> initializeAutoCommit [ 
	self autoCommit: (JadeiteValueHolder with: false). 
	self updateAutoCommit. 
	
]

{ #category : 'testing' }
GciSession >> isValidSession [

	^library notNil
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

	library disconnect
]

{ #category : 'server' }
GciSession >> serverPerform: unused with: stonString [
	"Temporarily, unpack the STON string and use RSR for replication. 
	We can possibly skip the creation of the STON string in the first place if RSR replication works"
	| services |
	services := STON fromString: stonString.
	services do: [ :service | 
		service executeCommand
		updates do:[:update | "handle update" ]]
]

{ #category : 'Jade convenience' }
GciSession >> serverPerformInterpreted: a with: b with: c [
]

{ #category : 'private' }
GciSession >> setInitials: initials [
	| pieces string |
	server isNil ifTrue: [^self].
	BrowserUpdate current inUpdateWhile: [string := self serverPerform: #mcInitials: with: initials].
	pieces := string subStrings collect: [:each | each asNumber].
	stoneSessionID := pieces at: 1.
	stoneSerial := pieces at: 2
]

{ #category : 'as yet unclassified' }
GciSession >> titleBarFor: windowName [

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: windowName;
		nextPutAll: ' on ';
		nextPutAll: library specification host;
		nextPutAll: ' [';
		print: library specification port;
		nextPutAll: ']'.
	^ stream contents
]

{ #category : 'initialization' }
GciSession >> updateAutoCommit [
	RowanAnsweringService new autoCommitIn: self
]
