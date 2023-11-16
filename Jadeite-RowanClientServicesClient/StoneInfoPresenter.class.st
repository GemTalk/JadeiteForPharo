Class {
	#name : 'StoneInfoPresenter',
	#superclass : 'DolphinClass',
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
StoneInfoPresenter >> fillSessionInfo [
	| line list stream |
	RowanServiceUpdater current
		inUpdateWhile: [stream := ReadStream on: (gciSession serverPerform: #stoneInfo)].
	streamTypePresenter value: (stream upTo: Character tab).
	stringTypePresenter value: (stream upTo: Character tab).
	stream nextLine.
	list := OrderedCollection new.
	[(line := stream nextLine) = '%'] whileFalse: [list add: (line subStrings: Character tab)].
	versionReportPresenter list: list.
	list := OrderedCollection new.
	[(line := stream nextLine) = '%'] whileFalse: [list add: (line subStrings: Character tab)].
	configurationReportPresenter list: list
]
