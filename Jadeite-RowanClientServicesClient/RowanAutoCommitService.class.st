Class {
	#name : 'RowanAutoCommitService',
	#superclass : 'RowanService',
	#instVars : [
		'autoCommit'
	],
	#category : 'Jadeite-RowanClientServicesClient'
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

{ #category : 'displaying' }
RowanAutoCommitService >> displayName [
	"for logging. for now"

	^self printString
]

{ #category : 'as yet unclassified' }
RowanAutoCommitService >> displayTransactionConflicts: browser [
	| inspector session service |
	session := browser gciSession.
	inspector := JadeiteInspector new gciSession: session.
	service := inspector evaluateText: 'System transactionConflicts'
				thenInspectInContext: session oopNil value.
	inspector showOn: service.
	inspector updateCaption: 'Transaction Conflicts'. 
]

{ #category : 'printing' }
RowanAutoCommitService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: autoCommit printString
]

{ #category : 'accessing' }
RowanAutoCommitService >> sortAspect [
	"don't think this is used"
	^self printString 
]
