Class {
	#name : 'JadeiteClearBreakpointCommand',
	#superclass : 'JadeiteBreakpointCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteClearBreakpointCommand class >> defaultName [
	^'Clear Breakpoint'
]

{ #category : 'execution' }
JadeiteClearBreakpointCommand >> execute [

	context clearBreakpoint: stepPoint
]
