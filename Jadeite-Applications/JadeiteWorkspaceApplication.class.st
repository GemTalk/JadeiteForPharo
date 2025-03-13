Class {
	#name : 'JadeiteWorkspaceApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteWorkspaceApplication >> presenterClass [

	^ JadeiteWorkspacePresenter
]

{ #category : 'accessing' }
JadeiteWorkspaceApplication >> start [

	| inst windowPresenter |
	inst := self new: self presenterClass.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]
