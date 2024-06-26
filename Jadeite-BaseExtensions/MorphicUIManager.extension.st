Extension { #name : 'MorphicUIManager' }

{ #category : '*Jadeite-BaseExtensions' }
MorphicUIManager >> jadeiteMultiLineRequest: queryString  initialAnswer: defaultAnswer answerHeight: answerHeight [
	"Create a multi-line instance of me whose question is queryString with
	the given initial answer. Answer the string the user accepts.  Answer nil if the user cancels.  An
	empty string returned means that the ussr cleared the editing area and
	then hit 'accept'.  Because multiple lines are invited, we ask that the user
	use the ENTER key, or (in morphic anyway) hit the 'accept' button, to
	submit; that way, the return key can be typed to move to the next line."

	|modalMorph|
	(ProvideAnswerNotification signal: queryString) ifNotNil: [:answer |
		^answer == #default ifTrue: [defaultAnswer] ifFalse: [answer]].
	modalMorph := self modalMorph.
	^(modalMorph theme
		jadeiteTextEditorIn: modalMorph
		text: queryString
		title: 'Information Required' translated
		entryText: defaultAnswer
		entryHeight: answerHeight)
			ifNotNil: [:text | text asString]
]

{ #category : '*Jadeite-BaseExtensions' }
MorphicUIManager >> uiProcess: aProcess [

	UIProcess := aProcess
]
