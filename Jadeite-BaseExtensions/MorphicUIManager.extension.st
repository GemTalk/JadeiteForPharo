Extension { #name : 'MorphicUIManager' }

{ #category : '*Jadeite-BaseExtensions' }
MorphicUIManager >> jadeiteMultiLineRequest: queryString initialAnswer: defaultAnswer answerHeight: answerHeight onCompletion: completionBlock [

	(ProvideAnswerNotification signal: queryString) ifNotNil: [ :answer |
		^ answer == #default
			  ifTrue: [ defaultAnswer ]
			  ifFalse: [ answer ] ].
	^ (self theme
		   jadeiteTextEditorIn: self
		   text: queryString
		   title: 'Information Required' translated
		   entryText: defaultAnswer
		   entryHeight: answerHeight
		   onCompletion: completionBlock) ifNotNil: [ :text | text asString ]
]

{ #category : '*Jadeite-BaseExtensions' }
MorphicUIManager >> uiProcess: aProcess [

	UIProcess := aProcess
]
