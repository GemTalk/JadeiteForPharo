Class {
	#name : 'JadeiteResultSetBuilder',
	#superclass : 'CoASTResultSetBuilder',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'API - building' }
JadeiteResultSetBuilder >> buildCompletion [

	| answeringService rawSymbols fetcher |
	answeringService := RowanAnsweringService new
		                    command: #autocompleteSymbols;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: GciSession current.
	rawSymbols := self waitForResult: answeringService.
	fetcher := JadeiteFetcher new. 
	fetcher symbols: (rawSymbols asSet asSortedCollection collect: [ :string |
			 JadeiteNECEntry contents: string node: nil ]).
	^ CoResultSet fetcher: fetcher
]

{ #category : 'API - building' }
JadeiteResultSetBuilder >> waitForResult: answeringService [

	| waitCount |
	waitCount := 0.
	[
	answeringService answer first isNil and: [
		(waitCount := waitCount + 1) <= 10 ] ] whileTrue: [
		(Delay forMilliseconds: 1) wait ].

	^ waitCount > 10
		  ifTrue: [ Array new ]
		  ifFalse: [
		  answeringService answer first , answeringService answer last ]
]
