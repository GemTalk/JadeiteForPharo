Class {
	#name : 'JadeiteHistoryBrowser',
	#superclass : 'JadeitePresenter',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'diffsPresenter',
		'versionList'
	],
	#category : 'Jadeite-Changes'
}

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

"	col := SpStringTableColumn
		       title: 'Type'
		       evaluated: [ :operation | operation typeString ].
	col displayColor: [ :operation |
		operation reverted ifTrue: [ Color green adjustBrightness: -0.5 ] ].
	versionList addColumn: col.
	versionList addColumn: (SpStringTableColumn
			 title: 'Package'
			 evaluated: [ :operation | operation packageName ]).

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
