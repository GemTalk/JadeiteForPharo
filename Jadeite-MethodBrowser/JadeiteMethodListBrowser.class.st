Class {
	#name : 'JadeiteMethodListBrowser',
	#superclass : 'JadeMethodListBrowser',
	#instVars : [
		'firstReferenceString'
	],
	#category : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser class >> openOn: service selecting: string session: session [

	| shell |
	(shell := JadeiteMethodListApplication showOnSession: session library)
		firstReferenceString: string.
	service queryResults isEmpty ifTrue: [
		^ shell methods: service queryResults selecting: 0 ].
	service queryResults first firstReference
		ifNil: [
			shell
				methods: service queryResults
				selecting:
				(service queryResults first source indexOfSubCollection: string) ]
		ifNotNil: [ :index |
		shell methods: service queryResults selecting: index ].
	^ shell
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser class >> openOn: service selectingAnyMatch: string session: gciSession [
	| shell |
	(shell := JadeiteMethodListApplication showOnSession: gciSession library) methods: service queryResults
		selectingAnyMatch: string.
	^shell
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> createSchematicWiring [

	super createSchematicWiring. 
	self  	 when: #'closeRequested:'		send: #'onCloseRequested:'	to: self primaryPresenter.
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> editSaveMethod [
	self primaryPresenter methodSourcePresenter editSaveMethod
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> firstReferenceString [
	^firstReferenceString
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> firstReferenceString: anObject [
	firstReferenceString := anObject
]

{ #category : 'accessing' }
JadeiteMethodListBrowser >> methods: methodServices selection: stringOrIndex [

	self methodListPresenter methods: methodServices
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> onViewClosed [
	super onViewClosed.
	RowanServiceUpdater current
		logComment: 'Closing Method List Browser {' , self identityHash printString , '}'.
	RowanServiceUpdater current removeEventsTriggeredFor: self primaryPresenter.
	RowanServiceUpdater current removeEventsTriggeredFor: self primaryPresenter methodSourcePresenter documentPresenter.  
	self primaryPresenter removeEventsTriggeredFor: self. 
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> onViewDestroyed [
	super onViewDestroyed.
	subPresenters := nil
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> onViewOpened [
	super onViewOpened.
	RowanServiceUpdater current
		logComment: 'Opening Method List Browser {' , self identityHash printString , '}'
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> presenterClass [

	^JadeiteMethodListPresenter
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> reformatSource [

	^myPresenter reformatSource
]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> shellName [

	^'Jadeite Method List Browser'.

]

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser >> updateMethodsWithoutTriggeringEvents: methodServices [
	self primaryPresenter methodListPresenter methodListPresenter
		noEventsDo: [self primaryPresenter methods: (Array with: methodServices) selecting: nil]
]
