Class {
	#name : 'JadeiteGCIConnectionProfile',
	#superclass : 'JadeiteConnectionProfile',
	#instVars : [
		'version',
		'stone',
		'netldi',
		'user',
		'password',
		'port',
		'session',
		'toolbarServerVersion'
	],
	#classVars : [
		'ClientLibrariesPath'
	],
	#category : 'Jadeite-Connection',
	#package : 'Jadeite-Connection'
}

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> clientLibrariesPath [

	ClientLibrariesPath ifNil: [
		^ FileSystem disk workingDirectoryPath pathString ].
	^ ClientLibrariesPath
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> clientLibrariesPath: string [

	ClientLibrariesPath := string
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile class >> initialize [

	ClientLibrariesPath ifNil: [
		ClientLibrariesPath := FileSystem workingDirectory pathString ]
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

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> basicConnectWithPostConnect: postConnectBlock [

	| theConnection |
	[
	session loginWithGsUser: user password: password "need to analyze result b4 proceeding" ]
		on: GciError
		do: [ :ex |
				session := nil.
				^ GciError signal: ex message ].
	GciSession current
		stoneName: stone;
		userID: user.
	[ theConnection := self setupRSRConnection ] ensure: [
			session logoutNbNoError.
			session := nil ].
	GciSession current library: theConnection.
	postConnectBlock value.
	self
		setIsRowanAvailableOnCompletion: [
				connection := theConnection. "don't trigger events until isRowanAvailable is set"
				self applyPreferences.
				self announcer announce: JadeiteConnectedAnnouncement new
				"Uncomment following three lines to enable RSR tracing""	
		connection log addSink: (RsrCustomSink action: [ :message |
		RowanServiceUpdater current logComment: message ]).
	connection log verbosity: connection log levelTrace.""Uncomment following two lines to enable jadeite tracing""RowanServiceUpdater current isLogging: true.
	RowanServiceUpdater current logComment: 'Connection established!'." ]
		catchBlock: [ self basicDisconnect: theConnection ]
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> basicDisconnect: aConnection [
	"can be called before the connection inst var is set so pass in aConnection"

	aConnection close.
	aConnection channel sink isProcessActive ifTrue: [
			UIManager default alert:
				'aConnection not properly closed. Channel sink process is still active.' ].
	aConnection channel source isProcessActive ifTrue: [
			UIManager default alert:
				'aConnection not properly closed. Channel source process is still active.' ].
	(Delay forMilliseconds: 100) wait. "let RSR aConnection close completely before closing gci library. A non-blocking logout, when available through GemStone FFI, may eliminate the need for this delay."
	GciSession clearCurrent.
	RowanServiceUpdater clearCurrent.
	self class connectionProfile connection: nil
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

	^ '| ws sortedLoadedProjects rsrProj rcsProj aUserId userId userProfile userPlatformDict registry |
rsrProj := Rowan image loadedProjectNamed: ''RemoteServiceReplication'' ifAbsent: []. 
aUserId := ''SystemUser''.
	userProfile := AllUsers userWithId: aUserId.
	(userProfile defaultObjectSecurityPolicy ifNil: [true] ifNotNil: [:x |x currentUserCanRead])
		ifFalse: [
			"do not have permissions to read objects created by <aUserId>"
			^ nil ].
	userPlatformDict := (AllUsers userWithId: aUserId) objectNamed: ''UserGlobals''.
	registry := userPlatformDict
		at: #''RwGsLoadedProjectRegistry''
		ifAbsent: [ 
			(self currentUserId = aUserId)
				ifFalse: [ ^ nil ].
			userPlatformDict at: #''RwGsLoadedProjectRegistry'' put: StringKeyValueDictionary new ].
rcsProj := registry at: ''RowanClientServices'' ifAbsent: [ ].
ws := WriteStream on: String new. 
ws nextPutAll: ''Server Required Projects:'';
	cr;
	cr;
	nextPutAll: ''RemoteServiceReplication''; 
	space. 
ws nextPutAll: (
	rsrProj ifNil: [''Project not loaded'']
	ifNotNil: [rsrProj loadedCommitId]); 
	cr. 
ws nextPutAll: ''RowanClientServices''; 
	space.
ws nextPutAll: (
	rcsProj ifNil: [''Project not loaded'']
	ifNotNil: [rcsProj loadedCommitId]); 
	cr;
	nextPutAll: ''---------------------------------------------'';
	cr;
	nextPutAll: ''All loaded projects:''; 
	cr; 
	cr. 
sortedLoadedProjects := Rowan image loadedProjects asSortedCollection: [:x :y | x name < y name].
sortedLoadedProjects do:[:proj |  
	ws nextPutAll: proj name; 
	space; 
	nextPutAll: proj loadedCommitId;
	lf] .
ws contents'
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> commitIdServerInfoCode [

	^ '| ws | 
	ws := WriteStream on: String new.
	ws nextPutAll: System gemVersionReportString. 
	ws cr.
	ws nextPutAll: ''User id: ''; 
	nextPutAll: System myUserProfile userId.
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
	"tests only"

	RowanServiceUpdater current critical: [
		self connectWithPostConnect: [ ] ]
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> connectWithPostConnect: postConnectBlock [
	"initialize gci library"

	"need to analyze result b4 proceeding""Uncomment following three lines to enable RSR tracing""	connection log addSink: (RsrCustomSink action: [ :message |
			 RowanServiceUpdater current logComment: message ]).
	connection log verbosity: connection log levelTrace.""Uncomment following two lines to enable jadeite tracing""RowanServiceUpdater current isLogging: true.
	RowanServiceUpdater current logComment: 'Connection established!'."

	GciInterface libraryDirectory: self path.
	[
		session := GsSession
			           newForGsVersion: version
			           threadSafe: true
			           stone: stone
			           host: host
			           netldi: netldi ]
		on: FileDoesNotExistException
		do: [ :ex |
				self uiManager alert:
					'Client library could not be found. Error message: '
					, ex messageText.
				^ self ].
	self basicConnectWithPostConnect: postConnectBlock
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> disconnect [
	"not only close & logout the session, but cleanup any 
	subscriptions to the connection so launcher's don't get
	stuck open"

	connection ifNil: [ ^ self ].
	self confirmAllWindowsCanClose ifFalse: [ ^ self ].
	self basicDisconnect: connection.
	self notifyPropertyChanged: #connection
]

{ #category : 'instance creation' }
JadeiteGCIConnectionProfile >> fromSton: stonReader [

	[ ^ super fromSton: stonReader ]
		on: InstanceVariableNotFound
		do: [ :ex |
			ex instVarName = 'path' ifFalse: [ "allow older connection files without the library path to work "
				ex pass ] ]
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> gciCommitIds [

	[
		self toolbarServerVersion:
			(session gciInterface executeStringAndFetchResultString:
				 self commitIdServerInfoCode).
		^ JadeitePreferences isRowanLoaded
			  ifTrue: [
					  session gciInterface executeStringAndFetchResultString:
						  self commitIdServerCode ]
			  ifFalse: [
					  | ws |
					  ws := WriteStream on: String new.
					  ws
						  nextPutAll: 'Rowan not available';
						  lf;
						  contents ] ]
		on: Error
		do: [ :ex |
				| errorStream |
				errorStream := WriteStream on: String new.
				errorStream
					nextPutAll: '<Error getting server information through gci>';
					cr;
					nextPutAll: 'Error Message: <' , ex messageText , '>';
					cr.
				^ errorStream contents ]
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
	^ workspace
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> gitShaWorkspaceUsing: launcher [

	^ session
		  ifNil: [ self serverCommitIdsUsingGciUsing: launcher ]
		  ifNotNil: [ self serverCommitIdsUsingServices ]
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

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> loginErrorMessage: errorMessage [

	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll:
			'<Unable to login to gemstone. Cannot get server information>';
		cr;
		nextPutAll: 'Error Message: <';
		nextPutAll: errorMessage;
		nextPut: $>;
		cr.
	^ ws contents
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

	^ self class clientLibrariesPath
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> port [

	^ port
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> port: anObject [

	port := anObject
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> serverCommitIdsUsingGciUsing: launcherWindow [
	"commit ids"

	"must be logged out.
	Try to handle the gci hanging or getting an error during login
	and give the user a reasonable error message. "

	| commitIdString sem proc loggedIn errorMessage launcher |
	launcher := launcherWindow presenter.
	sem := Semaphore new.
	GciInterface clearLibraryDirectory.
	SessionManager default unregisterClassNamed: 'GsSession'.
	GciInterface libraryDirectory: launcher unsavedPath.

	loggedIn := false.
	proc := [
		        [
			        session := GsSession
				                   newForGsVersion: launcher unsavedVersion
				                   threadSafe: true
				                   stone: launcher unsavedStone
				                   host: launcher unsavedHost
				                   netldi: launcher unsavedNetldi.
			        session
				        loginWithGsUser: launcher unsavedUser
				        password: launcher unsavedPassword.
			        loggedIn := true.
			        sem signal ]
			        on: Error
			        do: [ :ex |
					        errorMessage := ex class name , ' ' , ex messageText.
					        sem signal ] ] fork.
	(sem waitTimeoutSeconds: 3) ifTrue: [ proc terminate ].

	loggedIn
		ifTrue: [
				commitIdString := self gciCommitIds.
				session logoutNbNoError.
				session := nil ]
		ifFalse: [ commitIdString := self loginErrorMessage: errorMessage ].

	^ self
		  gitShaWorkspace: JadeiteGitShaWorkspaceApplication show
		  using: commitIdString
]

{ #category : 'commit ids' }
JadeiteGCIConnectionProfile >> serverCommitIdsUsingServices [

	| answeringService workspacePresenter withoutQuotes sem |
	workspacePresenter := JadeiteGitShaWorkspaceApplication show.
	self class connectionProfile isConnected ifFalse: [
			self
				gitShaWorkspace: workspacePresenter
				using: (self loginErrorMessage: 'No Error Message Available').
			^ workspacePresenter workspace ].
	sem := Semaphore new.
	[
		answeringService := RowanAnsweringServiceClient new.
		answeringService
			exec: self commitIdServerCode
			in: GciSession current
			onCompletion: [
					withoutQuotes := answeringService answer copyWithout: $'.
					self gitShaWorkspace: workspacePresenter using: withoutQuotes.
					sem signal ] ] fork.
	sem wait.
	[
		answeringService
			exec: self commitIdServerInfoCode
			in: GciSession current
			onCompletion: [
					withoutQuotes := answeringService answer copyWithout: $'.
					self toolbarServerVersion: withoutQuotes.
					sem signal ] ] fork.
	sem wait.
	^ workspacePresenter workspace
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> session [

	^ session
]

{ #category : 'actions' }
JadeiteGCIConnectionProfile >> setIsRowanAvailableOnCompletion: completionBlock catchBlock: catchBlock [

	| answeringService |
	answeringService := RowanAnsweringService new command:
		                    #isRowanAvailable.
	answeringService catchBlock: catchBlock. 
	RowanServiceUpdater current
		issueCommand: answeringService
		session: GciSession current
		onCompletion: [
			answeringService answer
				ifTrue: [
				JadeitePreferences isRowanLoaded: answeringService answer ]
				ifFalse: [ JadeitePreferences isRowanLoaded: #notAvailable ].
			completionBlock value ]
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
	session executeStringAndDetachNb: '| connection resolverClass |
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
		Processor activeProcess name: ''RSR waitUntilClose''.
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
JadeiteGCIConnectionProfile >> toolbarServerVersion [

	^ toolbarServerVersion
]

{ #category : 'accessing' }
JadeiteGCIConnectionProfile >> toolbarServerVersion: anObject [

	^ toolbarServerVersion := anObject
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
