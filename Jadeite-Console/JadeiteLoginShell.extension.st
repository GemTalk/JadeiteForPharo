Extension { #name : 'JadeiteLoginShell' }

{ #category : '*Jadeite-Console' }
JadeiteLoginShell class >> defaultTranscript [
	^JadeiteConsole allInstances
		detect: [:trans | trans gciSession = GciSession current and: [trans view class ~= DeafObject]]
		ifNone: []
]
