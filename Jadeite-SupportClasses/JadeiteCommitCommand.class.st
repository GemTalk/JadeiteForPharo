"
I execute a commit
"
Class {
	#name : 'JadeiteCommitCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteCommitCommand class >> defaultIconName [ 

	^#glamorousRefresh
]

{ #category : 'default' }
JadeiteCommitCommand class >> defaultName [
	^'Commit'
]

{ #category : 'executing' }
JadeiteCommitCommand >> execute [

	^context commitTransaction
]
