"
These windows will disconnect the connection if closed. 
No other checking of the windows is done. 
"
Class {
	#name : 'JadeiteGlobalWindowPresenter',
	#superclass : 'JadeiteWindowPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'edits' }
JadeiteGlobalWindowPresenter >> confirmDisconnect [

	| shouldClose |
	JadeiteConnectionProfile connectionProfile isConnected ifFalse: [
		^ true ].
	CurrentExecutionEnvironment value isTest ifTrue: [ ^ true ].
	shouldClose := UIManager default confirm:
		               'Really close window? This will disconnect and close all Jadeite windows.'.
	shouldClose ifFalse: [ ^ false ].
	JadeiteConnectionProfile connectionProfile disconnect.
	^ true
]

{ #category : 'edits' }
JadeiteGlobalWindowPresenter >> okToChange [ 

	^self confirmDisconnect
]
