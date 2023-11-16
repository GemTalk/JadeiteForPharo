Class {
	#name : 'JadeiteDebuggerApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteDebuggerApplication >> start [

	| inst |
	inst := self new: JadeiteDebuggerPresenter.
	inst
		addStyle: 'jadedTextBackgroundColor';
		gciSession: gciSession.
	inst open.
	^inst
]
