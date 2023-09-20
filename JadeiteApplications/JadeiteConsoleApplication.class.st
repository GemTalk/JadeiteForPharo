Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'JadeiteApplications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst |
	BrowserUpdate clearCurrent.
	inst := self new: JadeiteConsole.
	inst
		addStyle: 'jadedTextBackgroundColor';
		gciSession: gciSession;
		installTranscript;
		updateProjects;
		initializeAutoCommit. 
	inst open.
]
