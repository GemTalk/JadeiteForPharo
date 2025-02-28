Class {
	#name : 'JadeiteGCIConnectionProfile',
	#superclass : 'JadeiteConnectionProfile',
	#instVars : [
		'threadSafe',
		'version',
		'stone',
		'netldi',
		'user',
		'password',
		'path',
		'port',
		'session'
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

	| prefs |
	prefs := JadeitePreferences current session: self.
	prefs applyPreferences
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> clientCommitIdDescription [

	| ws | 
	ws := WriteStream on: String new. 
	self clientCommitIdDescriptionOn: ws. 
	^ws contents
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> clientCommitIdDescriptionOn: ws [

	ws
		nextPutAll: 'Client:';
		cr;
		cr.
	self jadeiteClientGitRepositories doWithIndex: [ :repoName :index |
		| repo |
		repo := IceRepository registry detect: [ :ea | ea name = repoName ].
		index = 1 ifFalse: [ ws cr ].
		ws
			nextPutAll: repoName;
			space;
			nextPutAll: repo properties commitish shortId ]
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> commitIdServerCode [

	^ '| ws sortedLoadedProjects |
ws := WriteStream on: String new. 
ws nextPutAll: ''Server:''; cr; cr. 
sortedLoadedProjects := Rowan image loadedProjects asSortedCollection: [:x :y | x name < y name].
sortedLoadedProjects do:[:proj |  
	ws nextPutAll: proj name; 
	space; 
	nextPutAll: proj loadedCommitId;
	lf] .
ws contents'
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
		do: [ :ex | ^ GciError signal: ex message ].
	GciSession current stoneName: stone.
	connection := self setupRSRConnection.
	"session logoutNbNoError. don't logout or nil the session. Need to revert when on 3731 or later"
	"session := nil"
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
	GciSession clearCurrent. 
	connection := nil.
	session logoutNoError. 
	session := nil. 
	self notifyPropertyChanged: #connection.
	RowanServiceUpdater clearCurrent
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> gciCommitIds [

	^ JadeitePreferences isRowanLoaded
		  ifTrue: [
			  session gciInterface executeStringAndFetchResultString:
				  self commitIdServerCode ]
		  ifFalse: [ 'Rowan not available' ]
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> gitShaWorkspace [

	^ session
		  ifNil: [ self serverCommitIdsUsingGci ]
		  ifNotNil: [ self serverCommitIdsUsingServices ]
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> gitShaWorkspace: workspacePresenter using: serverCommitIds [
	"need to be able to open a git commit id workspace
	with gci and services. Services requires it be done
	in a completion block so we have that code here. "

	| workspace ws |
	workspace := workspacePresenter workspace.
	ws := WriteStream on: String new.
	ws
		nextPutAll: self clientCommitIdDescription;
		cr;
		nextPutAll: '---------------------------------------------';
		cr.
	ws nextPutAll: serverCommitIds.
	workspace text: ws contents.
	workspace hasUnacceptedEdits: false.
	workspacePresenter window title: 'Jadeite Git Commit Ids'.
	^ workspace
]

{ #category : 'testing' }
JadeiteGCIConnectionProfile >> isConnected [ 

	^connection notNil and:[connection isOpen]
]

{ #category : 'testing' }
JadeiteGCIConnectionProfile >> isGciConnection [

	^true
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> jadeiteClientGitRepositories [

	^ #( 'JadeiteForPharo' 'PharoGemStoneFFI' 'RemoteServiceReplication' )
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

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> port [

	^ port
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> port: anObject [

	port := anObject
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> reconnectIfNecessary [

	self isConnected ifFalse: [ self connect ]
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> serverCommitIdsUsingGci [
	"must be logged out"

	| commitIdString |
	GciInterface libraryDirectory: path.
	session := GsSession
		           newForGsVersion: version
		           threadSafe: true
		           stone: stone
		           host: host
		           netldi: netldi.
	[ session loginWithGsUser: user password: password ]
		on: GciError
		do: [ :ex |
			^ 'Unable to login to gci. Cannot get server project commitIds' ].

	commitIdString := self gciCommitIds.
	session logoutNbNoError.
	session := nil. 
	^ self
		  gitShaWorkspace: JadeiteWorkspaceApplication show
		  using: commitIdString
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> serverCommitIdsUsingServices [

	| answeringService workspacePresenter |
	workspacePresenter := JadeiteWorkspaceApplication show.
	answeringService := RowanAnsweringServiceClient new.
	answeringService
		exec: self commitIdServerCode
		in: GciSession current
		onCompletion: [
			| withoutQuotes |
			withoutQuotes := answeringService answer copyWithout: $'.
			self gitShaWorkspace: workspacePresenter using: withoutQuotes ].
	^ workspacePresenter workspace
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> setupRSRConnection [
	"Make and answer an RSR connection"

	| detailBytes initiator thePort token portString invalidPort |
	invalidPort := false.
	portString := (port isNil or: [
		               port isEmpty or: [
			               invalidPort := port asInteger isNil ] ])
		              ifTrue: [ 'RsrAcceptConnection wildcardPort' ]
		              ifFalse: [ port asString ].
	invalidPort ifTrue: [
		UIManager default inform: 'Invalid fixed port entered. Ignored.' ].
	detailBytes := session
		               executeStringAndFetchResultByteArray:
			               '| acceptor port detailBytes |
		acceptor := RsrGciAcceptConnection port: ' , portString , '.
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
	session executeStringNb: '| connection resolverClass |
		connection := (SessionTemps current at: #PendingConnectionAcceptor) waitForConnection.
		resolverClass := ((AllUsers userWithId: ''SystemUser'') objectNamed: ''RowanClientServiceTemplateResolver'').
		GsFile gciLogServer: ''resolverClass: '', resolverClass printString. 
		"ifNil: [connection log debug: ''''''''Unable to resolve 			RowanClientServiceTemplateResolver''''''''. connection close. Error signal]."
		connection templateResolver: resolverClass new.
		SessionTemps current removeKey: #PendingConnectionAcceptor.
		"UNCOMMENT THESE LINES TO ADD TRACING TO RSR"
		"connection log addSink: (RsrCustomSink action: [:message | GsFile gciLogServer: message ]).
		connection log verbosity: connection log levelTrace."
		GsFile gciLogServer: ''about to waitUntilClose''.
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
