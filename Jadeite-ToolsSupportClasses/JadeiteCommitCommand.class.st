"
I execute a commit
"
Class {
	#name : 'JadeiteCommitCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'initialization' }
JadeiteCommitCommand class >> defaultIconName [ 

	^#thumbsUp
]

{ #category : 'default' }
JadeiteCommitCommand class >> defaultName [
	^'Commit'
]

{ #category : 'executing' }
JadeiteCommitCommand >> execute [

	^context commitTransaction
]
