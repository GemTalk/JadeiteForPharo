Class {
	#name : 'JadeiteResultSetBuilder',
	#superclass : 'CoASTResultSetBuilder',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'API - building' }
JadeiteResultSetBuilder >> buildCompletion [

	| answeringService rawSymbols fetcher |
	answeringService := RowanAnsweringService new
		                    command: #autocompleteSymbols;
		                    commandArgs: Array new.
	BrowserUpdate current
		issueCommand: answeringService
		session: GciSession current.
	[ answeringService answer first isNil ] whileTrue: [
		(Delay forMilliseconds: 1) wait ].
	rawSymbols := answeringService answer first
	              , answeringService answer last.
	fetcher symbols: (rawSymbols asSortedCollection collect: [ :string |
			 JadeiteNECEntry contents: string node: nil ]).
	^ CoResultSet fetcher: fetcher
]
