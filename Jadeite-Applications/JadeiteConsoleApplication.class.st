Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst |
	RowanServiceUpdater current critical: [
		inst := self new: JadeiteConsole.
		inst
			addStyle: 'jadeiteTextBackgroundColor';
			gciSession: gciSession;
			installTranscript;
			updateProjects;
			initializeAutoCommit.
		JadeiteConsole currentConsole: inst.
		inst open ]
]
