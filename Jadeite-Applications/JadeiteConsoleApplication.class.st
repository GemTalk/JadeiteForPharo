Class {
	#name : 'JadeiteConsoleApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteConsoleApplication >> start [

	| inst |
	inst := self new: JadeiteConsole.
	UIManager default defer: [
		inst
			addStyle: 'jadeiteTextBackgroundColor';
			gciSession: gciSession;
			installTranscript;
			updateProjects;
			initializeAutoCommit.
		JadeiteConsole currentConsole: inst.
		inst
			open;
			updateAutoCommitButton ]
]
