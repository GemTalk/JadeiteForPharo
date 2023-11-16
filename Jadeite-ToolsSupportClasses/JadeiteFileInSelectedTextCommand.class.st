"
I filein text from a workspace into the server
"
Class {
	#name : 'JadeiteFileInSelectedTextCommand',
	#superclass : 'JadeiteCommand',
	#category : 'Jadeite-ToolsSupportClasses'
}

{ #category : 'default' }
JadeiteFileInSelectedTextCommand class >> defaultName [
	^'File in Selected Text'
]

{ #category : 'default' }
JadeiteFileInSelectedTextCommand class >> shortName [
	^String new
]

{ #category : 'testing' }
JadeiteFileInSelectedTextCommand >> canBeExecuted [

	^context selectedText notEmpty
]

{ #category : 'executing' }
JadeiteFileInSelectedTextCommand >> execute [ 
	context fileInChunk
]
