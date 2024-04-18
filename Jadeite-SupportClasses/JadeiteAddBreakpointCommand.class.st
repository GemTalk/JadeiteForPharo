Class {
	#name : 'JadeiteAddBreakpointCommand',
	#superclass : 'JadeiteBreakpointCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteAddBreakpointCommand class >> defaultName [
	^'Add Breakpoint'
]

{ #category : 'execution' }
JadeiteAddBreakpointCommand >> execute [

	context setBreakpoint: stepPoint
]
