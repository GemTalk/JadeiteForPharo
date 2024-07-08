"
Any service sent from the client gives it's group id to the client send, server receive, server return, client receive. 
id is the numbering within that group for display sorting. 
"
Class {
	#name : 'RowanLoggingService',
	#superclass : 'RowanService',
	#instVars : [
		'fileName',
		'id',
		'groupId',
		'date',
		'time',
		'comment',
		'services',
		'mode',
		'location',
		'isLogging',
		'name'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
RowanLoggingService class >> basicNewWithGroupId: integer logger: logger [
	| inst |
	inst := self new.
	inst
		groupId: integer;
		id: 0.
	^inst
]

{ #category : 'accessing' }
RowanLoggingService class >> loggingServiceClass [
	^Smalltalk at: #JadeiteTestLoggingServiceClass ifAbsent: [self]
]

{ #category : 'instance creation' }
RowanLoggingService class >> newWithGroupId: integer logger: logger [
	^self basicNewWithGroupId: integer logger: logger
]

{ #category : 'comparing' }
RowanLoggingService >> = methodService [

	^ methodService isService and: [
		  methodService isLoggingService and: [
			  groupId = methodService groupId and: [ id = methodService id ] ] ]
]

{ #category : 'accessing' }
RowanLoggingService >> addServices: newServices [
	services addAll: newServices
]

{ #category : 'displaying' }
RowanLoggingService >> clientDisplayString [
	^location == #client ifTrue: [self displayString] ifFalse: [String new]
]

{ #category : 'displaying' }
RowanLoggingService >> clientGroupIdDisplayString [

	^groupId printString
]

{ #category : 'displaying' }
RowanLoggingService >> clientIdDisplayString [

	^id printString
]

{ #category : 'accessing' }
RowanLoggingService >> comment [
	^comment
]

{ #category : 'accessing' }
RowanLoggingService >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
RowanLoggingService >> date [
	^date
]

{ #category : 'accessing' }
RowanLoggingService >> date: anObject [
	date := anObject
]

{ #category : 'displaying' }
RowanLoggingService >> displayCommand [

	| ws |
	ws := WriteStream on: String new.
	services do: [ :service |
		service command
			ifNil: [
				ws nextPutAll: (service updateType
						 ifNil: [ String new ]
						 ifNotNil: [ :theUpdates | theUpdates printString ]) ]
			ifNotNil: [
				ws nextPutAll: (service command
						 ifNil: [ String new ]
						 ifNotNil: [ :theUpdates | theUpdates printString ]) ].
		ws
			space;
			nextPutAll: (service displayName ifNil: [ String new ]) ].
	^ ws contents
]

{ #category : 'displaying' }
RowanLoggingService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'displaying' }
RowanLoggingService >> displayString [
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: date shortString;
		space.
	time printOn: ws format: 'HH:mm:ss'.
	comment
		ifNotNil: 
			[ws
				space;
				nextPutAll: comment].
	mode
		ifNotNil: 
			[ws
				space;
				nextPutAll: mode;
				space;
				nextPut: $-;
				space;
				nextPutAll: self displayCommand].
	^ws contents
]

{ #category : 'accessing' }
RowanLoggingService >> fileName [
	^fileName
]

{ #category : 'accessing' }
RowanLoggingService >> fileName: anObject [
	fileName := anObject
]

{ #category : 'accessing' }
RowanLoggingService >> groupId [
	^groupId
]

{ #category : 'accessing' }
RowanLoggingService >> groupId: anObject [
	groupId := anObject
]

{ #category : 'comparing' }
RowanLoggingService >> hash [
	^groupId hash bitXor: id hash
]

{ #category : 'accessing' }
RowanLoggingService >> id [
	^id
]

{ #category : 'accessing' }
RowanLoggingService >> id: anObject [
	id := anObject
]

{ #category : 'initialization' }
RowanLoggingService >> initialize [
	super initialize.
	services := OrderedCollection new.
	isLogging := false.
	location := #client
]

{ #category : 'accessing' }
RowanLoggingService >> isLogging [
	^isLogging
]

{ #category : 'public' }
RowanLoggingService >> isLogging: aBoolean [ 
	isLogging := aBoolean
]

{ #category : 'public' }
RowanLoggingService >> isLoggingService [

	^true
]

{ #category : 'public' }
RowanLoggingService >> isTestLoggingService [
	^false
]

{ #category : 'accessing' }
RowanLoggingService >> location [
	^location
]

{ #category : 'accessing' }
RowanLoggingService >> location: anObject [
	location := anObject
]

{ #category : 'logging' }
RowanLoggingService >> logComment: aString [
	| ws |
	id := id + 1.
	comment := aString.
	location := #client.
	mode := nil.
	ws := FileStream write: fileName mode: #append.
	
	[date := Date today.
	time := Time now.
	ws
		lf;
		nextPutAll: date shortString;
		space;
		nextPutAll: time printString;
		space;
		nextPut: ${;
		nextPutAll: Processor activeProcess identityHash printString; 
		nextPut: $};
		space;
		nextPutAll: aString]
			ensure: [ws close].
	comment := nil	"service may be reused. Clear comment"
]

{ #category : 'logging' }
RowanLoggingService >> logReceivedServices: theServices [
	| ws |
	mode := #received.
	ws := self logServiceStream.
	
	[theServices do: 
			[:svc |
			self logServiceDateTimeStampOn: ws.
			ws nextPutAll: svc logReceivedString]]
			ensure: [ws close]
]

{ #category : 'logging' }
RowanLoggingService >> logSentServices: theServices [
	| ws |
	mode := #sent. 
	ws := self logServiceStream.
	
	[theServices do: 
			[:svc |
			self logServiceDateTimeStampOn: ws.
			ws nextPutAll: svc logSentString]]
			ensure: [ws close]
]

{ #category : 'logging' }
RowanLoggingService >> logServiceDateTimeStampOn: ws [
	date := Date today.
	time := Time now.
	ws
		cr;
		nextPutAll: date shortString;
		space;
		nextPutAll: time printString;
		space;
		nextPutAll: mode;
		space
]

{ #category : 'logging' }
RowanLoggingService >> logServiceStream [
	| ws |
	id := id + 1.
	ws := FileStream write: fileName mode: #append.
	^ws
]

{ #category : 'accessing' }
RowanLoggingService >> mode [
	^mode
]

{ #category : 'accessing' }
RowanLoggingService >> name [
	^name
]

{ #category : 'accessing' }
RowanLoggingService >> name: aString [
	name := aString asString
]

{ #category : 'displaying' }
RowanLoggingService >> printString [
	^self class name , ' ' , self displayString
]

{ #category : 'displaying' }
RowanLoggingService >> serverDisplayString [
	^location == #server ifTrue: [self displayString] ifFalse: [String new]
]

{ #category : 'accessing' }
RowanLoggingService >> services [

	^services
]

{ #category : 'accessing' }
RowanLoggingService >> sortAspect [

	^name
]

{ #category : 'accessing' }
RowanLoggingService >> time [
	^time
]

{ #category : 'accessing' }
RowanLoggingService >> time: anObject [
	time := anObject
]
