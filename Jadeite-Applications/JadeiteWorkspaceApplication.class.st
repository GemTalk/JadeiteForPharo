Class {
	#name : 'JadeiteWorkspaceApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteWorkspaceApplication >> start [

	| inst |
	inst := self new: JadeiteWorkspacePresenter.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst open.
	^inst
]
