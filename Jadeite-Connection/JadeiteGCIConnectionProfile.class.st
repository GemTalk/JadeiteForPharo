Class {
	#name : 'JadeiteGCIConnectionProfile',
	#superclass : 'JadeiteConnectionProfile',
	#instVars : [
		'session',
		'threadSafe',
		'version',
		'stone',
		'netldi',
		'user',
		'password',
		'path'
	],
	#classVars : [
		'DefaultPath'
	],
	#category : 'Jadeite-Connection',
	#package : 'Jadeite-Connection'
}

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> defaultPath [

	^DefaultPath
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> defaultPath: string [

	DefaultPath := string
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> initialize [

	DefaultPath := String new
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> stonAllInstVarNames [

	^ super stonAllInstVarNames copyWithout: #session
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> applyPreferences [

	| preferencesPath stream nextLine prefs |
	preferencesPath := JadeitePreferences preferencesPath.
	prefs := JadeitePreferences onSession: self.
	prefs autocommitEnabled:
		(JadeitePreferences current ifNotNil: [ :existingPrefs |
			 existingPrefs autocommitEnabled ]). "temporary - experimenting with integrating with Pharo settings"
	JadeitePreferences current: prefs.
	(File exists: preferencesPath) ifFalse: [ ^ self ].
	stream := (FileSystem disk open: preferencesPath writable: false)
		          reference readStream.
	[
	[ stream atEnd ] whileFalse: [
		nextLine := stream nextLine.
		prefs applyPreference: nextLine ] ] ensure: [ ^ stream close ]
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> confirmAllWindowsCanClose [

	JadeiteConnectionProfile connectionProfile jadeiteWindows do: [
		:window | window okToClose ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> connect [
	"initialize gci library"

	session ifNotNil: [ session logout ].
	user = 'SystemUser' ifFalse: [
		^ MessageBox notify: 'Only SystemUser is currently supported.' ].
	GciInterface libraryDirectory: path.
	session := GsSession
		           newForGsVersion: version
		           threadSafe: true
		           stone: stone
		           host: host
		           netldi: netldi.
	[
	session loginWithGsUser: user password: password "need to analyze result b4 proceeding" ]
		on: GciError
		do: [ :ex |
			self todo: 'is GciError the right error to signal?'.
			^ GciError signal: ex message ].
	GciSession current stoneName: stone.
	connection := self setupRSRConnection.
	GciSession current library: connection.
	self applyPreferences.
	"Uncomment following three lines to enable RSR tracing"
"	connection log addSink: (RsrCustomSink action: [ :message |
			 RowanServiceUpdater current logComment: message ]).
	connection log verbosity: connection log levelTrace."
	"Uncomment following two lines to enable jadeite tracing"
	"RowanServiceUpdater current isLogging: true.
	RowanServiceUpdater current logComment: 'Connection established!'."
	^ connection
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> disconnect [
	"not only close & logout the session, but cleanup any 
	subscriptions to the connection so launcher's don't get
	stuck open"
	connection ifNil: [ ^self ].
	self confirmAllWindowsCanClose ifFalse: [^self]. 
	connection close.
	(Delay forMilliseconds: 100) wait. "let RSR connection close completely before closing gci library. A non-blocking logout, when available through GemStone FFI, may eliminate the need for this delay."
	session ifNotNil: [ session logout ].
	session := nil.
	GciSession clearCurrent. 
	connection := nil.
	self notifyPropertyChanged: #connection.
	RowanServiceUpdater clearCurrent
]

{ #category : 'testing' }
JadeiteGCIConnectionProfile >> isConnected [ 

	^connection notNil and:[connection isOpen]
]

{ #category : 'testing' }
JadeiteGCIConnectionProfile >> isGciConnection [

	^true
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> netldi [

	^ netldi
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> netldi: anObject [

	netldi := anObject
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> password [

	^ password
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> password: anObject [

	password := anObject
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> path [

	^ path
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> path: anObject [

	path := anObject
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> reconnectIfNecessary [

	self isConnected ifFalse: [ self connect ]
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> session [

	^ session
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> session: anObject [

	session := anObject
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> setupRSRConnection [
	"Make and answer an RSR connection"

	| detailBytes initiator thePort token |
	detailBytes := session
		               executeStringAndFetchResultByteArray:
			               '| acceptor port detailBytes |
		acceptor := RsrGciAcceptConnection port: RsrAcceptConnection wildcardPort.
		acceptor ensureListening.
		SessionTemps current
			at: #PendingConnectionAcceptor
			put: acceptor.
		port := acceptor listeningPort.
		detailBytes := ByteArray new: 18.
		detailBytes unsigned16At: 1 put: port.
		detailBytes
			replaceFrom: 3
			to: 18
			with: acceptor token bytes.
		detailBytes'
		               maxResultSize: 1024.
	session executeStringNb: '| connection |
		connection := (SessionTemps current at: #PendingConnectionAcceptor) waitForConnection.
		SessionTemps current removeKey: #PendingConnectionAcceptor.
		"UNCOMMENT THESE LINES TO ADD TRACING TO RSR"
		"connection log addSink: (RsrCustomSink action: [:message | GsFile gciLogServer: message ]).
		connection log verbosity: connection log levelTrace."
		connection waitUntilClose.'.
	thePort := detailBytes unsignedShortAt: 1 bigEndian: true.
	token := RsrToken bytes: (detailBytes copyFrom: 3 to: 18).
	initiator := RsrGciInitiateConnection
		             host: host
		             port: thePort
		             token: token.
	^ initiator connect
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> stone [

	^ stone
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> stone: anObject [

	stone := anObject
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> threadSafe [

	^ threadSafe
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> threadSafe: anObject [

	threadSafe := anObject
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> user [

	^ user
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> user: anObject [

	user := anObject
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> version [

	^ version
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> version: anObject [

	version := anObject
]
