Extension { #name : 'JadePresenter' }

{ #category : '*JadeiteTests' }
JadePresenter >> browseClassReferences [
	^JadePresenter browseClassReferencesInSession: self gciSession
]
