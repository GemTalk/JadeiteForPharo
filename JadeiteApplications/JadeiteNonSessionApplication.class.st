Class {
	#name : 'JadeiteNonSessionApplication',
	#superclass : 'JadeiteApplication',
	#category : 'JadeiteApplications'
}

{ #category : 'actions' }
JadeiteNonSessionApplication >> start [

	| inst |
	inst := self new: JadeiteNonSessionWorkspace.
	inst addStyle: 'jadedTextBackgroundColor'.
	inst open.
	^inst
]
