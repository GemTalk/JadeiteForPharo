Extension { #name : 'JadeiteLoginShell' }

{ #category : '*Jadeite-Console' }
JadeiteLoginShell class >> defaultTranscript [
	^JadeiteConsole allInstances
		detect: [:trans | trans gciSession = GciSession current and: [trans view class ~= DeafObject]]
		ifNone: []
]

{ #category : '*Jadeite-Console' }
JadeiteLoginShell >> postShellLogin: aGciSession [
	| transcript |
	aGciSession isRowanLoaded ifFalse: [^aGciSession logout].
	versionListPresenter view disable.
	aGciSession
		when: #postLogout
		send: #postLogoutActions
		to: self.
	transcript := JadeiteConsole showOnSession: aGciSession.
	transcript view position: self view position + JadePresenter defaultWindowOffset
]
