Class {
	#name : 'JadeiteMonticelloChangesBrowser',
	#superclass : 'JadeiteChangesBrowser',
	#traits : 'JadeiteMonticelloTrait',
	#classTraits : 'JadeiteMonticelloTrait classTrait',
	#instVars : [
		'packageService',
		'repositoryService'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteMonticelloChangesBrowser >> packageService [

	^ packageService
]

{ #category : 'accessing' }
JadeiteMonticelloChangesBrowser >> packageService: anObject [

	packageService := anObject
]

{ #category : 'actions' }
JadeiteMonticelloChangesBrowser >> refresh [

	self
		changesFor: packageService
		against: repositoryService
		onCompletion: [ :svc |
				self operationsListPresenter items:
					(RowanPatch fromString: svc changes session: self gciSession)
						operations ]
]

{ #category : 'accessing' }
JadeiteMonticelloChangesBrowser >> repositoryService [

	^ repositoryService
]

{ #category : 'accessing' }
JadeiteMonticelloChangesBrowser >> repositoryService: anObject [

	repositoryService := anObject
]
