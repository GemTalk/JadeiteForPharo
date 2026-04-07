Trait {
	#name : 'JadeiteMonticelloTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'actions' }
JadeiteMonticelloTrait >> changesFor: package against: repository onCompletion: completionBlock [

	package
		command: #changesAgainst:;
		commandArgs: (Array with: repository repositoryOop).
	RowanServiceUpdater current
		issueCommand: package
		session: self gciSession
		onCompletion: completionBlock
]
