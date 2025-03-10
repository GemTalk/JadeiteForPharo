"
I execute an abort
"
Class {
	#name : 'JadeiteAbortCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteAbortCommand class >> defaultIconName [ 

	^#flag
]

{ #category : 'default' }
JadeiteAbortCommand class >> defaultName [
	^'Abort'
]

{ #category : 'executing' }
JadeiteAbortCommand >> execute [

	^ self isConnected
		  ifTrue: [ context abortTransaction ]
		  ifFalse: [ UIManager default alert: 'Jadeite Not Connected ' ]
]
