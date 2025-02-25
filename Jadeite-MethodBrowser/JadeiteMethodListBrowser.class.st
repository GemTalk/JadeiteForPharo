Class {
	#name : 'JadeiteMethodListBrowser',
	#superclass : 'JadeMethodListBrowser',
	#instVars : [
		'firstReferenceString'
	],
	#category : 'Jadeite-MethodBrowser',
	#package : 'Jadeite-MethodBrowser'
}

{ #category : 'as yet unclassified' }
JadeiteMethodListBrowser class >> openOn: service selecting: string session: session [

	| shell |
	(shell := JadeiteMethodListApplication showOnSession: session library)
		firstReferenceString: string.
	shell methods: service queryResults.
	service queryResults isEmpty ifTrue: [ ^ shell selecting: 0 ].
	service queryResults first firstReference
		ifNil: [
			string ifNotNil: [
				shell selecting:
					(service queryResults first source indexOfSubCollection: string) ] ]
		ifNotNil: [ :index | shell selecting: index ].
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
JadeiteMethodListBrowser >> shellName [

	^'Jadeite Method List Browser'.

]
