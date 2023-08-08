Class {
	#name : 'RowanAutoCommitService',
	#superclass : 'RowanService',
	#instVars : [
		'autoCommit'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanAutoCommitService class >> templateClassName [

	^#RowanAutoCommitService
]

{ #category : 'accessing' }
RowanAutoCommitService >> autoCommit [
	^autoCommit
]

{ #category : 'accessing' }
RowanAutoCommitService >> autoCommit: anObject [
	autoCommit := anObject
]

{ #category : 'public' }
RowanAutoCommitService >> autoCommitUpdate: browser [
	| shouldAbort |
	autoCommit == #failed
		ifTrue: 
			[postUpdateBlock := 
					[shouldAbort := MessageBox
								confirm: 'Autocommit has failed to commit. Your changes will not be commited in the repository until you abort. Abort now?

(If you choose ''No'' you will be prompted with a list of transaction conflicts)'.
					shouldAbort
						ifTrue: [JadePresenter abortTransactionInSession: browser gciSession]
						ifFalse: [self displayTransactionConflicts: browser]]].
	browser autoCommit: autoCommit.
	^postUpdateBlock
]

{ #category : 'displaying' }
RowanAutoCommitService >> displayName [
	"for logging. for now"

	^self printString
]

{ #category : 'printing' }
RowanAutoCommitService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: autoCommit printString
]

{ #category : 'accessing' }
RowanAutoCommitService >> postUpdateBlock [

	^postUpdateBlock
]

{ #category : 'accessing' }
RowanAutoCommitService >> sortAspect [
	"don't think this is used"
	^self printString 
]
