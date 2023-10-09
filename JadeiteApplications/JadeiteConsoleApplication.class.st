Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'JadeiteApplications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst |
	RowanServiceUpdater clearCurrent.
	inst := self new: JadeiteConsole.
	inst
		addStyle: 'jadedTextBackgroundColor';
		gciSession: gciSession;
		installTranscript;
		updateProjects;
		initializeAutoCommit.
	JadeiteConsole currentConsole: inst.
	inst open
]
