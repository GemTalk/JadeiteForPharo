Class {
	#name : 'JadeiteDebuggerApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteDebuggerApplication >> start [

	| inst |
	inst := self new: JadeiteDebuggerPresenter.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst open.
	^inst
]
