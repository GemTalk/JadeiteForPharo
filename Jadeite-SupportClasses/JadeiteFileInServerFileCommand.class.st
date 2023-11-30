"
I filein a file to the server
"
Class {
	#name : 'JadeiteFileInServerFileCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'default' }
JadeiteFileInServerFileCommand class >> defaultName [ 
	^'File in Server File ...'
]

{ #category : 'default' }
JadeiteFileInServerFileCommand class >> shortName [
	^String new 
]

{ #category : 'executing' }
JadeiteFileInServerFileCommand >> execute [ 
	self todo:[context fileOpen].
	MessageBox notify: 'This feature not implemented yet'
]
