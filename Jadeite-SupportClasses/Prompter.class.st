Class {
	#name : 'Prompter',
	#superclass : 'DolphinClass',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
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
