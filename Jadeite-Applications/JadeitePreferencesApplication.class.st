Class {
	#name : 'JadeitePreferencesApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeitePreferencesApplication >> start [

	| inst |
	inst := self new: JadeitePreferencesWorkspace.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst open.
	^inst
]
