Class {
	#name : 'JadeiteAIKnowledgeBase',
	#superclass : 'Object',
	#classVars : [
		'Current'
	],
	#category : 'Jadeite-AI',
	#package : 'Jadeite-AI'
}

{ #category : 'accessing' }
JadeiteAIKnowledgeBase class >> current [
	"Return the singleton."

	Current ifNil: [ Current := self new ].
	^ Current
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase class >> reset [
	"Clear the singleton (used in tests or after clearing the file)."

	Current := nil
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase >> appendText: aString [
	"Append aString to the knowledge file, creating it if needed."

	| file existing |
	file := self filePath.
	existing := file exists ifTrue: [ file contents ] ifFalse: [ '' ].
	file writeStreamDo: [ :stream |
		stream nextPutAll: existing , aString ]
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase >> clear [
	"Remove all permanent knowledge."

	self filePath deleteIfAbsent: [  ]
]

{ #category : 'private' }
JadeiteAIKnowledgeBase >> filePath [

	^ FileLocator home / '.jadeite-ai-knowledge.txt'
]

{ #category : 'testing' }
JadeiteAIKnowledgeBase >> isEmpty [

	| file |
	file := self filePath.
	^ file exists not or: [ file contents trimBlanks isEmpty ]
]

{ #category : 'accessing' }
JadeiteAIKnowledgeBase >> knowledgeText [
	"Return the knowledge file contents wrapped in markers for LLM injection.
	 Returns empty string when there is nothing to inject."

	| file text |
	file := self filePath.
	file exists ifFalse: [ ^ '' ].
	text := [ file contents ]
		        on: Error
		        do: [ ^ '' ].
	text trimBlanks isEmpty ifTrue: [ ^ '' ].
	^ String lf , '--- Permanent GemStone Knowledge ---' , String lf
	  , text , String lf , '--- End Knowledge ---'
]
