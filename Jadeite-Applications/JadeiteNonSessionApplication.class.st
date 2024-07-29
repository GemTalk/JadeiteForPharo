Class {
	#name : 'JadeiteNonSessionApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteNonSessionApplication >> start [

	| inst |
	inst := self new: JadeiteNonSessionWorkspace.
	inst addStyle: 'jadeiteTextBackgroundColor'.
	inst open.
	^inst
]
