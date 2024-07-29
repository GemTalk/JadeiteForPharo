Class {
	#name : 'JadeiteMethodListApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteMethodListApplication >> start [

	| inst |
	inst := self new: JadeiteMethodListPresenter.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession. 
	inst open.
	^inst
]
