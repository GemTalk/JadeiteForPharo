Class {
	#name : 'JadeiteClearBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'default' }
JadeiteClearBreakpointCommand class >> defaultName [
	^'Clear Breakpoint'
]

{ #category : 'execution' }
JadeiteClearBreakpointCommand >> execute [

	context clearBreakpoint
]
