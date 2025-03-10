Class {
	#name : 'JadeiteCommand',
	#superclass : 'SpToolCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'execution' }
JadeiteCommand >> execute [ 
	^self subclassResponsibility
]

{ #category : 'testing' }
JadeiteCommand >> isConnected [

	^ JadeiteGCIConnectionProfile connectionProfile
		  ifNil: [ false ]
		  ifNotNil: [ :profile | profile isConnected ]
]
