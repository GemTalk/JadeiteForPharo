Class {
	#name : 'RowanMonticelloService',
	#superclass : 'RowanService',
	#instVars : [
		'changes'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanMonticelloService class >> templateClassName [ 
	^#RowanMonticelloService
]

{ #category : 'presenter support' }
RowanMonticelloService >> basicChangesUsing: session onCompletion: completionBlock [

	| operations |
	command := #changes.
	RowanServiceUpdater current
		issueCommand: self
		session: session
		onCompletion: [
			operations := OrderedCollection new.
			changes ifNotNil: [
				changes do: [ :changeString |
					operations addAll:
						(RowanPatch fromString: changeString session: session)
							operations ] ].
			changes := nil. "can be large, reclaim space"
			completionBlock cull: operations ]
]

{ #category : 'presenter support' }
RowanMonticelloService >> changesUsing: session onCompletion: completionBlock [

	self basicChangesUsing: session onCompletion: [ :operations |
		completionBlock value: operations ]
]

{ #category : 'actions' }
RowanMonticelloService >> packageChanges: aGciSession application: application [

	| changesBrowser  |
	self
		changesUsing: aGciSession
		onCompletion: [ :operations |
			operations isEmpty
				ifTrue: [ MessageBox notify: 'No changes!' ]
				ifFalse: [
					changesBrowser := JadeiteChangesBrowser
						                  showOn: (RowanPatch new
								                   operations: operations;
								                   gciSession: aGciSession)
						                  name: 'Monticello package changes'
						                  application: application.
					changesBrowser owner application: application ] ]
]
