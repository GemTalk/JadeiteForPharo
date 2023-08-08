Class {
	#name : 'JadeiteAddBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'default' }
JadeiteAddBreakpointCommand class >> defaultName [
	^'Add Breakpoint'
]

{ #category : 'execution' }
JadeiteAddBreakpointCommand >> execute [

	context setBreakpoint  
]
