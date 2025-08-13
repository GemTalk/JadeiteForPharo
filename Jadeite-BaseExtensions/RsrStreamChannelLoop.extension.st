Extension { #name : 'RsrStreamChannelLoop' }

{ #category : '*Jadeite-BaseExtensions' }
RsrStreamChannelLoop >> start [

	| existingProcess |
	existingProcess := Process allSubInstances
		                   detect: [ :ea |
			                   ea isTerminated not and: [
				                   self runLoopName , '*' match: ea name ] ]
		                   ifNone: [  ].
	existingProcess ifNotNil: [
		self halt: 'Trying to start a ' , self runLoopName
			, ' process while one is running!!!!  Debug this!!!' ].
	state := self runningState.
	process := RsrProcessModel
		           fork: [
			           RsrProcessModel configureCommunicationsProcess.
			           self runLoop.
			           process := nil ]
		           named: self runLoopName
]
