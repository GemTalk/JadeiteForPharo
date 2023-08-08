Class {
	#name : 'JadeiteClearBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'default' }
JadeiteClearBreakpointCommand class >> defaultName [
	^'Clear Breakpoint'
]

{ #category : 'execution' }
JadeiteClearBreakpointCommand >> execute [

	context clearBreakpoint
]
