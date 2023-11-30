Class {
	#name : 'JadeiteAddBreakpointCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteAddBreakpointCommand class >> defaultName [
	^'Add Breakpoint'
]

{ #category : 'execution' }
JadeiteAddBreakpointCommand >> execute [

	context setBreakpoint  
]
