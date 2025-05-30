Class {
	#name : 'RowanAutoCommitServiceClient',
	#superclass : 'RowanAutoCommitService',
	#instVars : [
		'inCommand',
		'postUpdateBlock',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
RowanAutoCommitServiceClient class >> autoCommitFailureMessage [

	^ 'Auto Commit has failed to commit. Your changes will not be commited in the repository until you abort. If you do not abort, Auto Commit will be disabled. Abort now?

(If you choose ''No'' you will be prompted with a list of transaction conflicts)'
]

{ #category : 'public' }
RowanAutoCommitServiceClient >> autoCommitFailureMessage [
	^ self class autoCommitFailureMessage
]

{ #category : 'public' }
RowanAutoCommitServiceClient >> autoCommitUpdate: browser [

	| shouldAbort |
	autoCommit == #failed ifTrue: [
		postUpdateBlock := [
		                   shouldAbort := MessageBox confirm:
			                                  self autoCommitFailureMessage.
		                   shouldAbort
			                   ifTrue: [
			                   JadePresenter abortTransactionInSession:
				                   browser gciSession ]
			                   ifFalse: [
				                   RowanAnsweringService new
					                   setAutoCommit: false
					                   for: GciSession current.
				                   self displayTransactionConflicts: browser ] ] ].
	browser autoCommit: autoCommit.
	browser updateAutoCommitButton.
	^ postUpdateBlock
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> inCommand [

	^ inCommand ifNil: [ inCommand := RowanSemaphore new ]
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> inCommand: anObject [

	inCommand := anObject
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> indexOfInCommandInstVar [
	"performance enhancement"

	^12
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> indexOfServiceCompletionBlock [
	"performance enhancement"

	^14
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> postUpdateBlock [

	^postUpdateBlock
]

{ #category : 'accessing' }
RowanAutoCommitServiceClient >> serviceCompletionBlock [

	^ serviceCompletionBlock
]

{ #category : 'service completion' }
RowanAutoCommitServiceClient >> serviceCompletionBlock: anObject [

	serviceCompletionBlock := anObject
]
