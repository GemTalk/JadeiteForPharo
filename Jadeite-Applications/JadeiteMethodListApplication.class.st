Class {
	#name : 'JadeiteMethodListApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteMethodListApplication >> start [

	| inst windowPresenter |
	inst := self new: JadeiteMethodListPresenter.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]
