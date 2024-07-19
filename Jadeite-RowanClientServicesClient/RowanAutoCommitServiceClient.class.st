Class {
	#name : 'RowanAutoCommitServiceClient',
	#superclass : 'RowanAutoCommitService',
	#instVars : [
		'inCommand',
		'postUpdateBlock',
		'serviceCompletionBlock'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'public' }
RowanAutoCommitServiceClient >> autoCommitUpdate: browser [

	| shouldAbort |
	autoCommit == #failed ifTrue: [
		postUpdateBlock := [
		                   shouldAbort := MessageBox confirm:
			                                  'Autocommit has failed to commit. Your changes will not be commited in the repository until you abort. Abort now?

(If you choose ''No'' you will be prompted with a list of transaction conflicts)'.
		                   shouldAbort
			                   ifTrue: [
			                   JadePresenter abortTransactionInSession:
				                   browser gciSession ]
			                   ifFalse: [
			                   self displayTransactionConflicts: browser ] ] ].
	browser autoCommit: autoCommit.
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
