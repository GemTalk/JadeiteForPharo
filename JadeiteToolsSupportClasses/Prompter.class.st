Class {
	#name : 'Prompter',
	#superclass : 'DolphinClass',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'as yet unclassified' }
Prompter class >> on: old prompt: queryString caption: caption [

	^ UIManager default
		  request: queryString
		  initialAnswer: old
		  title: caption
]

{ #category : 'as yet unclassified' }
Prompter class >> prompt: queryString [

	^UIManager default request: queryString initialAnswer: ''
]
