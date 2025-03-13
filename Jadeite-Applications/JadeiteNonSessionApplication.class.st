Class {
	#name : 'JadeiteNonSessionApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteNonSessionApplication >> start [

	| inst windowPresenter |
	inst := self new: JadeiteNonSessionWorkspace.
	inst addStyle: 'jadeiteTextBackgroundColor'.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]
