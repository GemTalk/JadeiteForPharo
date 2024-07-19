"
An answer service doesn't understand any update commands. 
He just responds with an answer object. 
"
Class {
	#name : 'RowanAnsweringService',
	#superclass : 'RowanService',
	#instVars : [
		'answer'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanAnsweringService class >> templateClassName [

	^#RowanAnsweringService
]

{ #category : 'accessing' }
RowanAnsweringService >> answer [
	^answer
]

{ #category : 'accessing' }
RowanAnsweringService >> answer: anObject [
	answer := anObject
]

{ #category : 'commands' }
RowanAnsweringService >> autoCommitIn: session onCompletion: anObject [

	command := #autoCommit.
	RowanServiceUpdater current issueCommand: self session: session onCompletion: nil.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> breakPointsAreEnabled: session [

	command := #breakPointsAreEnabled.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'public' }
RowanAnsweringService >> breakpointSettingChanged: transcript [
	self todo:[updateType
		ifNotNil: 
			[transcript areBreakpointsEnabled value: answer.
			RowanServiceUpdater current breakpointsEnabled: answer]]
]

{ #category : 'commands' }
RowanAnsweringService >> canAccessServiceClasses: session [

	command := #canAccessServiceClasses.
	self commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> exec: string in: session [

	command := #exec:.
	commandArgs := Array with: string.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'commands' }
RowanAnsweringService >> execReturningObject: string in: session [
	"instead of just returning a printString of the remote execution results, return
	a fully-formed object. If only simple objects are used, it might work. Else, STON
	might become unhappy and crash. Use at your own risk"

	command := #execReturningObject:.
	commandArgs := Array with: string.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'commands' }
RowanAnsweringService >> expressionSelector: string session: session [

	command := #expressionSelector:.
	commandArgs := Array with: string.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> flipTranscriptIn: session [

	command := #flipTranscript.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'public' }
RowanAnsweringService >> getProcessList [
	"do nothing. See JadePresenter class>>waitForAnswer: 
	Maybe shouldn't overload that method. Hmmm" 
]

{ #category : 'public' }
RowanAnsweringService >> isAnsweringService [

	^true
]

{ #category : 'public' }
RowanAnsweringService >> isDeafObject [
	^false
]

{ #category : 'commands' }
RowanAnsweringService >> isTranscriptInstalledIn: session [

	command := #transcriptInstalled.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'printing' }
RowanAnsweringService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: 'answer: ';
		nextPutAll: (answer printString leftString: 100).
	answer printString size > 100 ifTrue: [aStream nextPutAll: '...']
]

{ #category : 'commands' }
RowanAnsweringService >> needsCommit: session [

	command := #needsCommit.
	self commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> projectRepositoryRoots: projectServices [

	
]

{ #category : 'commands' }
RowanAnsweringService >> projectRepositoryRoots: projectServices session: session onCompletion: completionBlock [

	self
		command: #projectsRepositoryRoots:;
		commandArgs: (Array with:
					 (projectServices collect: [ :projectService |
							  projectService name ])).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: completionBlock.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> setAutoCommit: boolean for: session [

	command := #setRemoteAutoCommit:.
	self commandArgs: (Array with: boolean).
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> setBreakpointsEnabled: boolean session: session [

	command := #setBreakPointsAreEnabled:.
	commandArgs := Array with: boolean.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil
]

{ #category : 'commands' }
RowanAnsweringService >> symbolDictionaryNames: session [
	self
		command: #symbolDictionaryNames;
		commandArgs: Array new.
	RowanServiceUpdater current issueCommand: self session: session.
	^answer
]

{ #category : 'commands' }
RowanAnsweringService >> symbolExists: aSymbol session: session [

	command := #symbolExists:.
	commandArgs := Array with: aSymbol.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'commands' }
RowanAnsweringService >> symbolsMatching: string session: session [

	command := #symbolsMatching:.
	commandArgs := Array with: string.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: nil.
	^ answer
]

{ #category : 'public' }
RowanAnsweringService >> update [
	"do nothing. See JadePresenter class>>waitForAnswer: 
	Maybe shouldn't overload that method. Hmmm" 
]
