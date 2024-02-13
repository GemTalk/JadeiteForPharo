Class {
	#name : 'JadeiteInspectorApplication',
	#superclass : 'JadePresenterA',
	#category : 'Jadeite-Applications'
}

{ #category : 'instance creation' }
JadeiteInspectorApplication class >> executeThenShowOn: aString session: gciSession context: context [

	| inst |
	inst := self new gciSession: gciSession.
	^inst executeThenInspect: aString inContext: context.

]

{ #category : 'instance creation' }
JadeiteInspectorApplication class >> show: oop onSession: gciSession [

	| inst |
	inst := self new gciSession: gciSession.
	inst startOn: oop.
	^ inst
]

{ #category : 'accessing' }
JadeiteInspectorApplication >> executeThenInspect: aString inContext: context [

	| inst |
	inst := self new: JadeiteInspector. 
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	^inst executeThenInspect: aString inContext: context
]

{ #category : 'accessing' }
JadeiteInspectorApplication >> start [

	| inst |
	inst := self new: JadeiteInspector. 
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst open
]

{ #category : 'accessing' }
JadeiteInspectorApplication >> startOn: oop [

	| inst |
	inst := self new: JadeiteInspector. 
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst inspect: oop inContext: nil
]
