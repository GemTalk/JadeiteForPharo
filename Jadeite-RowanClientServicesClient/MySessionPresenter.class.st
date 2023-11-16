Class {
	#name : 'MySessionPresenter',
	#superclass : 'DolphinClass',
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
MySessionPresenter >> fillSessionInfo [
	| line list stream |
	gciVersionPresenter value: gciSession libraryVersion.
	userIDPresenter value: gciSession userID.
	stoneHostPresenter value: gciSession stoneHost.
	stoneNamePresenter value: gciSession stoneName.
	gciSession isLinkedGem
		ifTrue: [gemTypePresenter value: 'linked']
		ifFalse: 
			[gemTypePresenter value: 'RPC'.
			gemHostPresenter value: gciSession gemHost.
			netPortPresenter value: gciSession netPort.
			netTaskPresenter value: gciSession netTask].
	stoneSessionIDPresenter value: gciSession stoneSessionID.
	stoneSerialPresenter value: gciSession stoneSerial.
	gciSessionIdPresenter value: gciSession gciSessionId.
	RowanServiceUpdater current
		inUpdateWhile: [stream := ReadStream on: (gciSession serverPerform: #mySessionInfo)].
	logPathPresenter value: stream nextLine.
	list := OrderedCollection new.
	[(line := stream nextLine) = '%'] whileFalse: [list add: (line subStrings: Character tab)].
	versionReportPresenter list: list.
	list := OrderedCollection new.
	[(line := stream nextLine) = '%'] whileFalse: [list add: (line subStrings: Character tab)].
	configurationReportPresenter list: list
]
