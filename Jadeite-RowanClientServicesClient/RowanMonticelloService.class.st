Class {
	#name : 'RowanMonticelloService',
	#superclass : 'RowanService',
	#instVars : [
		'changes'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

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
RowanMonticelloService >> packageChanges [

	| changesBrowser monticelloService |
	monticelloService := self projectListPresenter selectedItem.
	monticelloService
		changesUsing: self gciSession
		onCompletion: [ :operations |
			operations isEmpty
				ifTrue: [ MessageBox notify: 'No changes!' ]
				ifFalse: [
					changesBrowser := JadeiteChangesBrowser
						                  showOn: (RowanPatch new
								                   operations: operations;
								                   gciSession: self gciSession)
						                  name: 'Monticello package changes'
						                  application: self application.
					changesBrowser owner application: self application ] ]
]
