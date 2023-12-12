Class {
	#name : 'JadeiteWorkspaceApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteWorkspaceApplication >> start [

	| inst |
	inst := self new: JadeiteWorkspace.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst open.
	^inst
]
