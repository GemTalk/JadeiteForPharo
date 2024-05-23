Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst |
	inst := self new: JadeiteConsole.
	[
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession;
		installTranscript;
		updateProjects;
		initializeAutoCommit ] jadeiteSchedule.
	JadeiteConsole currentConsole: inst.
	inst open
]
