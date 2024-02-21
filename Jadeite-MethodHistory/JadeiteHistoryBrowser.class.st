Class {
	#name : 'JadeiteHistoryBrowser',
	#superclass : 'JadeitePresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'diffsPresenter',
		'versionList',
		'methodService'
	],
	#category : 'Jadeite-MethodHistory'
}

{ #category : 'instance creation' }
JadeiteHistoryBrowser class >> showOn: methodService application: application [

	| historyBrowser |
	historyBrowser := self new methodService: methodService.
	historyBrowser
		gciSession: application gciSession.
	historyBrowser open.
	historyBrowser updateHistory. 
	historyBrowser owner application: application.
	^ historyBrowser
]

{ #category : 'actions' }
JadeiteHistoryBrowser >> addStyle: aStyle [
	super addStyle: aStyle. 
	diffsPresenter addStyle: aStyle. 
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> connectPresenters [

	super connectPresenters.
	versionList whenSelectionChangedDo: [ :selection | 
		self versionSelected ]
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeDiffsPresenter [
	diffsPresenter := JadeiteDiffPresenter new. 
	self layout add: diffsPresenter.
	diffsPresenter showOptions: false
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializePresenters [ 

	super initializePresenters.
	self initializeVersionsList. 
	self initializeDiffsPresenter 
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeVersionsList [

	| col |
	versionList := JadeiteTablePresenter new.
	versionList addColumn: (SpStringTableColumn
			 title: 'Method'
			 evaluated: [ :operation | operation selectorPrintString ]).
	"	col displayColor: [ :operation |
		operation reverted ifTrue: [ Color green adjustBrightness: -0.5 ] ]."
	versionList addColumn: (SpStringTableColumn
			 title: 'category'
			 evaluated: [ :operation | operation category ]).
	"
	versionList addColumn: (SpStringTableColumn
			 title: 'Class'
			 evaluated: [ :operation | operation definition jadeiteClassName ]).
	versionList addColumn: (SpStringTableColumn
			 title: 'Selector'
			 evaluated: [ :operation | operation selector ]).
	versionList addColumn: (SpStringTableColumn
			 title: 'Detail'
			 evaluated: [ :operation | operation detailsString ])."

	self layout add: versionList
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 1000 @ 750.
	self updateCaption
]

{ #category : 'accessing' }
JadeiteHistoryBrowser >> methodService [

	^ methodService
]

{ #category : 'accessing' }
JadeiteHistoryBrowser >> methodService: anObject [

	methodService := anObject
]

{ #category : 'constants' }
JadeiteHistoryBrowser >> shellName [

	^'Jadeite Version Browser'
]

{ #category : 'actions' }
JadeiteHistoryBrowser >> updateHistory [
	"Get the historic information for the method."

	| answeringService history |
	Cursor wait showWhile: [
		answeringService := RowanAnsweringService new
			                    command: #methodHistoryFor:;
			                    commandArgs: (Array with: self methodService);
			                    yourself.
		RowanServiceUpdater current
			issueCommand: answeringService
			session: self gciSession
			onCompletion: nil ].
	history := OrderedCollection new.
	versionList list: ListModel new.
	versionList list addAll: answeringService answer reversed.
	self todo: [ self setCaption ]
]

{ #category : 'events' }
JadeiteHistoryBrowser >> versionSelected [

	| selectedIndex previousItem |
	selectedIndex := versionList selection selectedIndex.
	selectedIndex = versionList items size ifTrue: [
		diffsPresenter rightText: versionList selectedItem source.
		diffsPresenter leftText: String new.
		^ self ].
	previousItem := versionList items at: selectedIndex + 1.
	diffsPresenter
		leftText: previousItem source;
		leftLabel: 'Previous Source';
		rightText: versionList selectedItem source;
		rightLabel: 'Selected Source'
]
