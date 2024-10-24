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
JadeiteConsoleApplication >> start [

	| inst |
	RowanServiceUpdater current critical: [
		inst := self new: self jadeiteConsoleClass.
		inst
			addStyle: 'jadeiteTextBackgroundColor';
			gciSession: gciSession;
			installTranscript;
			updateProjects;
			initializeAutoCommit.
		self jadeiteConsoleClass currentConsole: inst.
		inst open ]
]
