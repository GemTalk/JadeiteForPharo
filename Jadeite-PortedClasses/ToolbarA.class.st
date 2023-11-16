Class {
	#name : 'ToolbarA',
	#superclass : 'Toolbar',
	#category : 'Jadeite-PortedClasses'
}

{ #category : 'commands' }
ToolbarA >> commandSource [
	"Answer the <View> which is the starting point for routing commands issued by the receiver.
	Delegate to the parent."

	^self parentView commandSource
]
