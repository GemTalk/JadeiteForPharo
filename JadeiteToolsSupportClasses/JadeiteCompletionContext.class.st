Class {
	#name : 'JadeiteCompletionContext',
	#superclass : 'CompletionContext',
	#instVars : [
		'remoteSymbols'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'entries' }
JadeiteCompletionContext >> initEntries [

	| answeringService |
	remoteSymbols ifNil: [
		answeringService := RowanAnsweringService new
			                    command: #autocompleteSymbols;
			                    commandArgs: Array new.
		BrowserUpdate current
			issueCommand: answeringService
			session: GciSession current.
		remoteSymbols := answeringService answer first
		                 , answeringService answer last ].

	^ sorter sortCompletionList:
		  (remoteSymbols asOrderedCollection collect: [ :string |
			   JadeiteNECEntry contents: string node: nil ])
]
