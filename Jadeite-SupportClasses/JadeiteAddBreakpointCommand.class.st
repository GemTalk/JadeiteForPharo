Class {
	#name : 'JadeiteAddBreakpointCommand',
	#superclass : 'JadeiteBreakpointCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteAddBreakpointCommand class >> defaultName [
	^'Add Breakpoint'
]

{ #category : 'execution' }
JadeiteAddBreakpointCommand >> execute [

	context setBreakpoint: stepPoint
]

{ #category : 'accessing' }
JadeiteAddBreakpointCommand >> name [

	^ 'Add Breakpoint at step point ' , self selectedStepPoint asString
]
