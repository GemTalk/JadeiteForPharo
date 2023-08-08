"
The inst var `visited` is used when updating a JadeiteTreeModel. 
After a node is added, it is visited.  Nodes that are not visited are subsequently removed. 
"
Class {
	#name : 'JadeiteTreeNode',
	#superclass : 'TreeNode',
	#instVars : [
		'visited'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'initialization' }
JadeiteTreeNode >> initialize [
	super initialize.
	visited := true
]

{ #category : 'accessing' }
JadeiteTreeNode >> newChildCollection [
	^SortedCollection sortBlock:[:x :y | x object name < y object name]
]

{ #category : 'public' }
JadeiteTreeNode >> resetVisited [

	visited := false
]

{ #category : 'accessing' }
JadeiteTreeNode >> visited [
	^visited
]

{ #category : 'accessing' }
JadeiteTreeNode >> visited: anObject [
	visited := anObject
]
