Class {
	#name : 'JadeiteDebuggerApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteDebuggerApplication >> start [

	| inst windowPresenter |
	inst := self new: JadeiteDebuggerPresenter.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]
