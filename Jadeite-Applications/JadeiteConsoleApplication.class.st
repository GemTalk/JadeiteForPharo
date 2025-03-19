Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> jadeiteConsoleClass [

	^ JadeitePreferences isRowanLoaded
		  ifTrue: [ JadeiteConsole ]
		  ifFalse: [ JadeiteConsoleWithoutRowan ]
]

{ #category : 'accessing' }
JadeiteConsoleApplication >> resetConfiguration [

	super resetConfiguration.
	JadeiteConsole allInstances do: [ :console |
		console addStyle: 'jadeiteTextBackgroundColor' ]
]

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst windowPresenter |
	RowanServiceUpdater current critical: [
		inst := self new: self jadeiteConsoleClass.
		inst
			gciSession: gciSession;
			installTranscript;
			updateProjects;
			initializeAutoCommit.
		self jadeiteConsoleClass currentConsole: inst.
		windowPresenter := inst open.
		self addBorderStyleTo: windowPresenter presenter: inst.
		inst addStyle: 'jadeiteTextBackgroundColor' ]
]
