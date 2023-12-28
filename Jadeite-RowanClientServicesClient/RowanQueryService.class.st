Class {
	#name : 'RowanQueryService',
	#superclass : 'RowanService',
	#instVars : [
		'queryResults'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'rsr' }
RowanQueryService class >> templateClassName [ 

	^#RowanQueryService
]

{ #category : 'accessing' }
RowanQueryService >> answer [
	^queryResults	
]

{ #category : 'public' }
RowanQueryService >> hasResults [

	^queryResults notEmpty
]

{ #category : 'commands' }
RowanQueryService >> implementorsOfAll: selectors [
	^self implementorsOfAll: selectors session: GciSession current
]

{ #category : 'commands' }
RowanQueryService >> implementorsOfAll: selectors session: session [

	command := #implementorsOfAll:.
	commandArgs := Array with: selectors.
	RowanServiceUpdater current
		issueCommands: (Array with: self)
		session: session
		onCompletion: nil
]

{ #category : 'accessing' }
RowanQueryService >> queryResults [
	^queryResults asOrderedCollection 
]

{ #category : 'accessing' }
RowanQueryService >> queryResults: anObject [
	queryResults := anObject
]

{ #category : 'commands' }
RowanQueryService >> sendersOfAll: selectors [
	^self sendersOfAll: selectors session: GciSession current
]

{ #category : 'commands' }
RowanQueryService >> sendersOfAll: selectors session: session [

	command := #sendersOfAll:.
	commandArgs := Array with: selectors.
	RowanServiceUpdater current
		issueCommands: (Array with: self)
		session: session
		onCompletion: nil
]
