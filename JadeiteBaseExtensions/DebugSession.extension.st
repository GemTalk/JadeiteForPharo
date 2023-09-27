Extension { #name : 'DebugSession' }

{ #category : '*JadeiteBaseExtensions' }
DebugSession >> isContextPostMortem: selectedContext [
	"return whether we're inspecting a frozen exception without a process attached"
	"Jadeite override - return false if interruptedProcess is nil"
	| suspendedContext |
	interruptedProcess ifNil: [ ^false ].
	suspendedContext := interruptedProcess suspendedContext.
	suspendedContext ifNil: [ ^ false ].
	^ (suspendedContext hasContext: selectedContext) not.
]
