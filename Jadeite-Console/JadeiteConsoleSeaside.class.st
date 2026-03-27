Class {
	#name : 'JadeiteConsoleSeaside',
	#superclass : 'JadeiteConsoleWithoutRowan',
	#instVars : [
		'monticelloPackageListPresenter',
		'monticelloRepositoryListPresenter'
	],
	#category : 'Jadeite-Console',
	#package : 'Jadeite-Console'
}

{ #category : 'initialization' }
JadeiteConsoleSeaside >> connectPresenters [

	super connectPresenters.
	monticelloPackageListPresenter whenSelectionChangedDo: [ :selection |
			monticelloRepositoryListPresenter list: (selection selectedItem
					 ifNil: [ OrderedCollection new ]
					 ifNotNil: [ selection selectedItem repositoryDescriptions ]) ]
]

{ #category : 'menus' }
JadeiteConsoleSeaside >> initializeMonticelloPackageListMenu [
]

{ #category : 'initialization' }
JadeiteConsoleSeaside >> initializePrimaryListPresenter: tabs [

	| box |
	box := SpBoxLayout newHorizontal.
	monticelloPackageListPresenter := JadeiteListPresenter new display:
		                                  #description.
	box add: monticelloPackageListPresenter.
	monticelloRepositoryListPresenter := JadeiteListPresenter new.
	box add: monticelloRepositoryListPresenter.
	tabs add: box label: 'Loaded Packages'.
	self initializeMonticelloPackageListMenu
]

{ #category : 'as yet unclassified' }
JadeiteConsoleSeaside >> updateMonticelloPackagesOnCompletion: completionBlock catchBlock: catchBlock [

	| monticelloService |
	monticelloService := RowanMonticelloService new.
	monticelloService command: #update.
	monticelloService catchBlock: catchBlock.
	RowanServiceUpdater current
		issueCommand: monticelloService
		session: self gciSession
		onCompletion: [
				monticelloPackageListPresenter list: monticelloService packages.
				completionBlock value ]
]

{ #category : 'as yet unclassified' }
JadeiteConsoleSeaside >> updateProjectsOnCompletion: completionBlock catchBlock: catchBlock [
	"we don't deal with rowan projects in seaside"

	^ self
		  updateMonticelloPackagesOnCompletion: completionBlock
		  catchBlock: catchBlock
]
