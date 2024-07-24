Class {
	#name : 'JadeiteMethodClearBreakpointsCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteMethodClearBreakpointsCommand class >> defaultName [ 
	
	^'Clear Method Breakpoints'
]

{ #category : 'execution' }
JadeiteMethodClearBreakpointsCommand >> execute [ 
	
	context clearAllMethodBreakpoints 
]
