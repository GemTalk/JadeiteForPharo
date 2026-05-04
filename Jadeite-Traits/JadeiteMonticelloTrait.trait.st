Trait {
	#name : 'JadeiteMonticelloTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'actions' }
JadeiteMonticelloTrait >> changesFor: package against: repository onCompletion: completionBlock [

	package
		command: #changesAgainst:;
		commandArgs: (Array with: repository repositoryOop).
	RowanServiceUpdater current
		issueCommand: package
		session: self gciSession
		onCompletion: completionBlock
]

{ #category : 'actions' }
JadeiteMonticelloTrait >> loadSelectedPackage [

	| confirmation selectedPackage |
	self packagesPresenter hasSelection ifFalse: [ ^ self ].
	selectedPackage := self packagesPresenter selectedItem.
	confirmation := self uiManager confirm:
		                'Load selected package '
		                , selectedPackage description , '?'.
	confirmation ifFalse: [ ^ self ].
	selectedPackage
		command: #loadPackageFrom:;
		commandArgs: (Array with: self repositoriesPresenter selectedItem).
	RowanServiceUpdater current
		issueCommand: selectedPackage
		session: self gciSession
		onCompletion: [ self updateRepositories ]
]

{ #category : 'testing' }
JadeiteMonticelloTrait >> selectedPackageIsLoaded [

	self packagesPresenter selectedItem ifNil: [ ^ false ].
	^ self isLoaded: self packagesPresenter selectedItem
]

{ #category : 'actions' }
JadeiteMonticelloTrait >> unloadSelectedPackage [

	| confirmation selectedPackage |
	self packagesPresenter hasSelection ifFalse: [ ^ self ].
	selectedPackage := self packagesPresenter selectedItem.
	confirmation := self uiManager confirm:
		                'Unload selected package '
		                , selectedPackage description , '?'.
	confirmation ifFalse: [ ^ self ].
	selectedPackage command: #unloadPackage.
	RowanServiceUpdater current
		issueCommand: selectedPackage
		session: self gciSession
		onCompletion: [ self updateRepositories ]
]

{ #category : 'updates' }
JadeiteMonticelloTrait >> updateMonticelloPackages [

	self updateMonticelloPackagesOnCompletion: [ ] catchBlock: [ ]
]

{ #category : 'updates' }
JadeiteMonticelloTrait >> updateMonticelloPackages: anAnnouncement [
	"pass the announcement if and when needed"
	self updateMonticelloPackagesOnCompletion: [ ] catchBlock: [ ]
]

{ #category : 'updates' }
JadeiteMonticelloTrait >> updateMonticelloPackagesOnCompletion: completionBlock catchBlock: catchBlock [

	| monticelloService |
	monticelloService := RowanMonticelloService new.
	monticelloService command: #update.
	monticelloService catchBlock: catchBlock.
	RowanServiceUpdater current
		issueCommand: monticelloService
		session: self gciSession
		onCompletion: [
				monticelloService packages do: [ :pkg |
					pkg sourceRepository ifNil: [
						pkg repositoryGroups repositories ifNotEmpty: [ :repos |
							pkg sourceRepository: repos last ] ] ].
				self monticelloPackageListPresenter items:
					monticelloService packages.
				completionBlock cull: monticelloService ]
]
