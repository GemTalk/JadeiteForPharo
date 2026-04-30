Extension { #name : 'JadeiteConsole' }

{ #category : '*Jadeite-AI' }
JadeiteConsole >> openAIChatWindow [
	"Open the AI chat window, passing the live GemStone session for source-context injection."

	JadeiteAIChatPresenter openWithSession: gciSession
]
