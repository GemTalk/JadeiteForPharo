Class {
	#name : 'JadeiteCodeDoItCommand',
	#superclass : 'SpCodeDoItCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'private' }
JadeiteCodeDoItCommand >> evaluate: aString andDo: aBlock [

	^ self context
		  executeSelectionOrLine: aString
		  shouldDebug: false
		  onCompileError: [ ^ self ]
		  showResult: false
]
