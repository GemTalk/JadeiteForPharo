Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'JadeiteApplications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst |
	inst := self new: JadeiteConsole.
	inst
		addStyle: 'jadedTextBackgroundColor';
		gciSession: gciSession;
		installTranscript;
		updateProjects;
		initializeAutoCommit. 
	BrowserUpdate clearCurrent.
	inst open
]
