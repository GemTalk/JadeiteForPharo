Class {
	#name : 'JadeiteMethodListApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'as yet unclassified' }
JadeiteMethodListApplication class >> showOn: aSymbol session: aConnection [

	| inst |
	inst := self new.
	inst
		classToInstantiate: aSymbol;
		gciSession: GciSession current.
	inst gciSession library: aConnection.
	^ inst start
]

{ #category : 'as yet unclassified' }
JadeiteMethodListApplication class >> showOnSession: aConnection [

	^ self showOn: #JadeiteMethodListPresenter session: aConnection
]

{ #category : 'accessing' }
JadeiteMethodListApplication >> start [

	| inst windowPresenter |
	inst := (Smalltalk at: classToInstantiate) new.
	inst application: self.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst.
	^ inst
]
