Class {
	#name : 'JadeiteTreeModel',
	#superclass : 'TreeModel',
	#category : 'RowanClientServicesClient'
}

{ #category : 'constants' }
JadeiteTreeModel class >> defaultSearchPolicy [
	"Answer the default <searchPolicy> used by instances of the receiver."

	^SearchPolicy equality
]

{ #category : 'constants' }
JadeiteTreeModel >> nodeClass [
	"Answer the class of object to be used to represent the receiver's nodes."

	^JadeiteTreeNode
]

{ #category : 'public' }
JadeiteTreeModel >> removeChildrenOf: anObject [
	(self childrenOf: anObject) do: [:child | self remove: child ifAbsent: []]
]

{ #category : 'public' }
JadeiteTreeModel >> removeWithoutNotification: anObject ifAbsent: aNiladicValuable view: theView [
	"Jadeite - remove but don't trigger events to avoid trips to the server"

	| node parentNode parent |
	self getNodeFor: anObject ifAbsent:[^self]. 
	parent := self parentOf: anObject.
	node := self getNodeFor: anObject ifAbsent: [].
	node isNil ifTrue: [^aNiladicValuable value].
	parentNode := node parent.
	parentNode removeChildNode: node.
	self forgetNode: node.
	theView onItem: anObject removedFromParent: parent.
	^anObject
]

{ #category : 'constants' }
JadeiteTreeModel >> resetVisited [
	self asBag do: [:object | (self lookupNode: object) resetVisited]
]
