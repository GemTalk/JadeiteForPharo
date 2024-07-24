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
	^context abortTransaction
]
