Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication class >> jadeiteConsoleClass [

	^ JadeitePreferences isRowanLoaded
		  ifTrue: [ JadeiteConsole ]
		  ifFalse: [ JadeiteConsoleWithoutRowan ]
]

{ #category : 'accessing' }
JadeiteConsoleApplication >> resetConfiguration [

	super resetConfiguration.
	JadeiteConsole allInstances do: [ :console |
		console window ifNotNil: [ :window |
			window isOpen ifTrue: [
				console addStyle: 'jadeiteTextBackgroundColor' ] ] ]
]

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst windowPresenter |
	RowanServiceUpdater current critical: [
		inst := self new: self class jadeiteConsoleClass.
		inst
			gciSession: gciSession;
			installTranscript;
			updateProjectsOnCompletion: [  ];
			initializeAutoCommit.
		self class jadeiteConsoleClass currentConsole: inst.
		windowPresenter := inst open.
		self addBorderStyleTo: windowPresenter presenter: inst.
		inst addStyle: 'jadeiteTextBackgroundColor' ]
]
