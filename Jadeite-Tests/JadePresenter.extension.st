Extension { #name : 'JadePresenter' }

{ #category : '*Jadeite-Tests' }
JadePresenter >> browseClassReferences [
	^JadePresenter browseClassReferencesInSession: self gciSession
]
