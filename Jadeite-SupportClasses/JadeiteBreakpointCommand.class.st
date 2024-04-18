Class {
	#name : 'JadeiteBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#instVars : [
		'stepPoint'
	],
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'testing' }
JadeiteBreakpointCommand >> canBeExecuted [
	stepPoint := context selectedStepPoint. 
	^stepPoint notNil
]
