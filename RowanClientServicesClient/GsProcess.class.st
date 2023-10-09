Class {
	#name : 'GsProcess',
	#superclass : 'DolphinClass',
	#category : 'RowanClientServicesClient'
}

{ #category : 'public' }
GsProcess >> frameForLevel: anInteger [
	| string |
	anInteger = 0 ifTrue: [self error: 'No such frame level!'].
	
	[RowanServiceUpdater current inUpdateWhile: 
			[string := gciSession
						serverPerform: #sourceForProcess:frame:
						with: self
						with: anInteger].
	(string beginsWith: '?????') ifTrue: [self error: (string copyFrom: 6 to: string size)]]
			on: Error
			do: 
				[:ex |
				MessageBox
					warning: 'Error when attempting to read stack frame.
Maybe an object got an error on a #printString method.
'
							, ex description.
				SessionManager current pause.
				^nil].
	^GsStackFrame fromStringXML: string session: gciSession
]

{ #category : 'public' }
GsProcess >> stack [
	stack notNil ifTrue: [^stack].
	self oopType = (gciSession oopTypeFor: nil) ifTrue: [^#()].
	RowanServiceUpdater current
		inUpdateWhile: [stack := gciSession serverPerform: #stackForProcess: with: oopType].
	stack := stack copyReplaceAll: ' | ' with: '>>#'.
	stack := stack subStrings: Character lf.
	^stack
]
