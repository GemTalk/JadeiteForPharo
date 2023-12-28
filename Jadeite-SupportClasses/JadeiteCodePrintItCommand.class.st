Class {
	#name : 'JadeiteCodePrintItCommand',
	#superclass : 'SpCodePrintItCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'private' }
JadeiteCodePrintItCommand >> evaluate: aString andDo: aBlock [

	^ self context
		  executeSelectionOrLine: aString
		  shouldDebug: false
		  onCompileError: [ ^ self ]
		  showResult: true
]
