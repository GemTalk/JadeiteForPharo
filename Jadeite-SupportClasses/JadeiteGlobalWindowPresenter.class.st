"
these windows will disconnect the connection if closed
"
Class {
	#name : 'JadeiteGlobalWindowPresenter',
	#superclass : 'JadeiteWindowPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'edits' }
JadeiteGlobalWindowPresenter >> canDiscardEdits [ 

	^self confirmDisconnect
]

{ #category : 'edits' }
JadeiteGlobalWindowPresenter >> confirmDisconnect [

	| shouldClose |
	JadeiteConnectionProfile connectionProfile isConnected ifFalse: [
		^ true ].
	shouldClose := UIManager default confirm:
		               'Really close window? This will disconnect and close all Jadeite windows.'.
	shouldClose ifFalse: [ ^ false ].
	JadeiteConnectionProfile connectionProfile disconnect.
	^ true
]
