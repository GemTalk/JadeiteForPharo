Class {
	#name : 'JadeiteNonSessionApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteNonSessionApplication >> start [

	| inst |
	inst := self new: JadeiteNonSessionWorkspace.
	inst addStyle: 'jadedTextBackgroundColor'.
	inst open.
	^inst
]
