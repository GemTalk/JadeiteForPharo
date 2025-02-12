Class {
	#name : 'JadeiteWorkspaceApplication',
	#superclass : 'JadeiteApplication',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'accessing' }
JadeiteWorkspaceApplication >> presenterClass [

	^ JadeiteWorkspacePresenter
]

{ #category : 'accessing' }
JadeiteWorkspaceApplication >> start [

	| inst |
	inst := self new: self presenterClass.
	inst
		addStyle: 'jadeiteTextBackgroundColor';
		gciSession: gciSession.
	inst open.
	^ inst
]
