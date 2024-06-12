Class {
	#name : 'JadeiteCodeDoItCommand',
	#superclass : 'JadeiteCodeExecutionCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteCodeDoItCommand class >> defaultDescription [ 

	^ 'Evaluate selection.'
]

{ #category : 'default' }
JadeiteCodeDoItCommand class >> defaultIconName [

	^ #smallDoIt
]

{ #category : 'default' }
JadeiteCodeDoItCommand class >> defaultName [

	^ 'Do it'
]

{ #category : 'default' }
JadeiteCodeDoItCommand class >> defaultShortcutKey [

	^ $d command mac 
		| $d control win 
		| $d control unix
]

{ #category : 'executing' }
JadeiteCodeDoItCommand >> evaluate: aString andDo: aBlock [

	[
	self context
		executeSelectionOrLine: aString
		shouldDebug: false
		onCompileError: [ ^ self ]
		showResult: false ] fork
]
