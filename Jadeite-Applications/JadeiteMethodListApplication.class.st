Class {
	#name : 'JadeiteMethodListApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteMethodListApplication >> start [

	| inst |
	inst := self new: JadeiteMethodListPresenter.
	inst
		addStyle: 'jadedTextBackgroundColor';
		gciSession: gciSession. 
	^inst open; yourself
]
