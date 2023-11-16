Class {
	#name : 'JadeTranscript',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'allSessionsPresenter',
		'historyPresenter',
		'mySessionPresenter',
		'stoneInfoPresenter',
		'toolbarPresenter',
		'transcriptPresenter'
	],
	#category : 'Jadeite-Console'
}

{ #category : 'as yet unclassified' }
JadeTranscript >> allSessionsPresenter [
	^allSessionsPresenter
]

{ #category : 'as yet unclassified' }
JadeTranscript >> allSessionsPresenter: anObject [
	allSessionsPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeTranscript >> autocompletion [

	JadeAutocompletationConfigurationShell show.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> browseProcesses [

	JadeProcessBrowser showOnSession: gciSession.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> createComponents [

	super createComponents.
	allSessionsPresenter	:= self add: AllSessionsPresenter		new name: 'All Sessions'.
	historyPresenter	:= self add: TextPresenter				new name: 'history'.
	mySessionPresenter	:= self add: MySessionPresenter			new name: 'My Session'.
	stoneInfoPresenter	:= self add: StoneInfoPresenter			new name: 'Stone'.
	toolbarPresenter	:= self add: JadeToolsToolBarPresenter	new name: 'Toolbar'.
	transcriptPresenter	:= self add: TranscriptPresenter			new name: 'Transcript'.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> createSchematicWiring [

	super createSchematicWiring.
	(self view viewNamed: 'cardContainer') when: #'currentCardChanged' send: #'currentCardChanged' to: self.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> currentCardChanged [

	| currentCard |
	currentCard := (self view viewNamed: 'cardContainer') currentCard. 
	(currentCard isKindOf: TextEdit) 	ifTrue: [currentCard setFocus].
	"(currentCard name = 'codePane')		ifTrue: [[(currentCard viewNamed: 'document') setFocus] postToInputQueue. ^self]."
	(currentCard name = 'history')		ifTrue: [historyPresenter value isEmpty ifTrue: [historyPresenter value: (gciSession executeString: 'DbfHistory')]. ^self].
	(currentCard name = 'My Session')	ifTrue: [mySessionPresenter fillSessionInfo. ^self].
	(currentCard name = 'Stone')		ifTrue: [stoneInfoPresenter fillSessionInfo. ^self].
]

{ #category : 'as yet unclassified' }
JadeTranscript >> describeErrorNumber [

	| string result |
	(string := Prompter prompt: 'Enter GemStoneError number:') isNil ifTrue: [^self].
	(string allSatisfy: [:each | each isDigit]) ifFalse: [
		MessageBox warning: 'Invalid number!'.
		^self.
	].
	result := gciSession 
		serverPerform: #'descriptionOfErrorNumber:'
		with: string asNumber.
	MessageBox 
		notify: result
		caption: 'GemStoneError ' , string.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> disableNativeCode [

	gciSession executeString: 'System configurationAt: #GemNativeCodeEnabled put: false'.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> gciSession: aGciSession [

	super gciSession: aGciSession.
	mySessionPresenter	gciSession: aGciSession.
	allSessionsPresenter	gciSession: aGciSession.
	stoneInfoPresenter	gciSession: aGciSession.
	toolbarPresenter	gciSession: aGciSession.
	transcriptPresenter	gciSession: aGciSession.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> hasClassSideSelected [
	^false
]

{ #category : 'as yet unclassified' }
JadeTranscript >> historyPresenter [
	^historyPresenter
]

{ #category : 'as yet unclassified' }
JadeTranscript >> historyPresenter: anObject [
	historyPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeTranscript >> inspectOop [

	| string result |
	(string := Prompter prompt: 'Enter OOP Number:') isNil ifTrue: [^self].
	(string allSatisfy: [:each | each isDigit]) ifFalse: [
		MessageBox warning: 'Invalid number!'.
		^self.
	].
	result := gciSession executeString: 'Object _objectForOop: ' , string.
	JadeInspector showOn: result session: gciSession.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> methodsChanged24 [

| string result |
	
	result := gciSession executeString: '| result methods|
		result := MethodVersionHistory uniqueInstance methodsNewerThan: (DateTime now subtractDays: 1 ).
		methods := IdentitySet new.
		result do: [:e | e asCompiledMethod ifNotNil: [:m | methods add: m]].
		methods asArray'.
(JadeMethodListBrowser showOnSession: self gciSession) primaryPresenter
		browseMethods: result;
		yourself.
	"JadeInspector showOn: result session: gciSession."

]

{ #category : 'as yet unclassified' }
JadeTranscript >> methodsChangedDays [

| string result |
	(string := Prompter prompt: 'Enter number of days:') isNil ifTrue: [^self].	
	result := gciSession executeString: '| result methods|
		result := MethodVersionHistory uniqueInstance methodsNewerThan: (DateTime now subtractDays: ' , string , ' ).
		methods := IdentitySet new.
		result do: [:e | e asCompiledMethod ifNotNil: [:m | methods add: m]].
		methods asArray'.
	(JadeMethodListBrowser showOnSession: self gciSession) primaryPresenter
		browseMethods: result;
		yourself.


]

{ #category : 'as yet unclassified' }
JadeTranscript >> mySessionPresenter [
	^mySessionPresenter
]

{ #category : 'as yet unclassified' }
JadeTranscript >> mySessionPresenter: anObject [
	mySessionPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeTranscript >> onCloseRequested: boolValueHolder [
	| answer |
	super onCloseRequested: boolValueHolder.
	boolValueHolder value ifFalse: [^self].
	gciSession isNil ifTrue: [^self].
	gciSession isValidSession
		ifFalse: 
			[gciSession trigger: #forceJadeiteWindowClose.
			^self].
	gciSession logoutRequested
		ifFalse: 
			[boolValueHolder value: false.
			^self].
	answer := MessageBox new
				caption: 'Close Requested';
				confirmOrCancel: 'Commit current transaction?'.
	boolValueHolder value: (#(#yes #no) includes: answer).
	answer = #yes ifTrue: [gciSession commit].
	boolValueHolder value ifFalse: [^self].

	"We are going to close, so do some things first..."
	"self view hide."
	allSessionsPresenter aboutToClose.
	gciSession notNil
		ifTrue: 
			[| temp |
			temp := gciSession.	"A logout will trigger closing all open windows, including this one."
			gciSession := nil.
			temp forceLogout]
]

{ #category : 'as yet unclassified' }
JadeTranscript >> onIdleEntered [
	"gciSession might be nil on a fast moving test"

	| shouldUpdateCursor |
	shouldUpdateCursor := gciSession ifNil: [true] ifNotNil: [gciSession isCallInProgress not].
	shouldUpdateCursor
		ifTrue: 
			[Cursor current
				ifNotNil: [[Cursor current ifNotNil: [Cursor current: nil]] forkAt: Processor userBackgroundPriority]].
	^super onIdleEntered
]

{ #category : 'as yet unclassified' }
JadeTranscript >> openRowanProjectList [
	^(JadeiteProjectListBrowser showOnSession: self gciSession) primaryPresenter
		updateProjects;
		yourself
]

{ #category : 'as yet unclassified' }
JadeTranscript >> queryCommand: query [
	(#(#'turnAutoMigrateOff' #'turnAutoMigrateOn') includes: query commandSymbol) ifTrue: [
		query isEnabled: true.
		^true.
	].
	^super queryCommand: query.


]

{ #category : 'as yet unclassified' }
JadeTranscript >> resetCursor [

	[Cursor current: nil] forkAt: Processor userBackgroundPriority.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> stoneInfoPresenter [
	^stoneInfoPresenter
]

{ #category : 'as yet unclassified' }
JadeTranscript >> stoneInfoPresenter: anObject [
	stoneInfoPresenter := anObject
]

{ #category : 'as yet unclassified' }
JadeTranscript >> transcriptPresenter [
	"Private - for tests" 
	^transcriptPresenter
]

{ #category : 'as yet unclassified' }
JadeTranscript >> turnAutoMigrateOff [

	gciSession executeString: 'MCPlatformSupport autoMigrate: false'.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> turnAutoMigrateOn [

	gciSession executeString: 'MCPlatformSupport autoMigrate: true'.

]

{ #category : 'as yet unclassified' }
JadeTranscript >> updateCaption [

	self caption: (gciSession titleBarFor: 'Console').

]
