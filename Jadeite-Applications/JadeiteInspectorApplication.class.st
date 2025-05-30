Class {
	#name : 'JadeiteInspectorApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'instance creation' }
JadeiteInspectorApplication class >> executeThenShowOn: aString session: gciSession context: context onCompletion: completionBlock [

	^ self
		  executeThenShowOn: aString
		  session: gciSession
		  context: context
		  onCompletion: completionBlock
		  title: String new
]

{ #category : 'instance creation' }
JadeiteInspectorApplication class >> executeThenShowOn: aString session: gciSession context: context onCompletion: completionBlock title: windowTitle [

	| inst |
	inst := self new gciSession: gciSession.
	^ inst
		  executeThenInspect: aString
		  inContext: context
		  onCompletion: completionBlock
		  title: windowTitle
]

{ #category : 'instance creation' }
JadeiteInspectorApplication class >> show: oop onSession: gciSession [

	| inst |
	inst := self new gciSession: gciSession.
	^ inst startOn: oop
]

{ #category : 'accessing' }
JadeiteInspectorApplication >> executeThenInspect: aString inContext: context onCompletion: completionBlock title: windowTitle [

	| inst |
	inst := self new: JadeiteInspector.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	^ inst
		  executeThenInspect: aString
		  inContext: context
		  onCompletion: completionBlock
		  title: windowTitle
]

{ #category : 'accessing' }
JadeiteInspectorApplication >> start [

	| inst windowPresenter |
	inst := self new: JadeiteInspector.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	windowPresenter := inst open.
	self addBorderStyleTo: windowPresenter presenter: inst
]

{ #category : 'accessing' }
JadeiteInspectorApplication >> startOn: oop [

	| inst |
	inst := self new: JadeiteInspector.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst inspect: oop inContext: nil.
	^ inst
]
