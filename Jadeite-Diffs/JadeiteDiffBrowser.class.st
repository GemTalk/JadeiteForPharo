Class {
	#name : 'JadeiteDiffBrowser',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait + JadeiteMethodsTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait + JadeiteMethodsTrait classTrait',
	#instVars : [
		'diffsPresenter',
		'toolbar'
	],
	#category : 'Jadeite-Diffs',
	#package : 'Jadeite-Diffs'
}

{ #category : 'instance creation' }
JadeiteDiffBrowser class >> compare: methodService1 to: methodService2 application: application [

	| diffBrowser |
	diffBrowser := self new
		               leftText: methodService1 source;
		               rightText: methodService2 source;
		               leftLabel: methodService1 selectorPrintString;
		               rightLabel: methodService2 selectorPrintString;
		               yourself.
	diffBrowser gciSession: application gciSession.
	diffBrowser addStyle: 'jadeiteTextBackgroundColor'.
	diffBrowser open.
	diffBrowser owner application: application.
	^ diffBrowser
]

{ #category : 'api' }
JadeiteDiffBrowser >> addStyle: aString [

	super addStyle: aString.
	diffsPresenter addStyle: 'jadeiteTextBackgroundColor'
]

{ #category : 'testing' }
JadeiteDiffBrowser >> canDiscardEdits [

	^true
]

{ #category : 'accessing' }
JadeiteDiffBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteDiffBrowser >> initializeDiffsPresenter [
	diffsPresenter := JadeiteDiffPresenter new. 
	self layout add: diffsPresenter.
	diffsPresenter showOptions: false
]

{ #category : 'initialization' }
JadeiteDiffBrowser >> initializePresenters [

	super initializePresenters.
	self initializeToolbar.
	self initializeDiffsPresenter
]

{ #category : 'initialization' }
JadeiteDiffBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 100 @ 50 * StandardFonts defaultFont pointSize.
	self updateCaption
]

{ #category : 'accessing' }
JadeiteDiffBrowser >> leftLabel: aString [

	diffsPresenter leftLabel: aString
]

{ #category : 'accessing' }
JadeiteDiffBrowser >> leftText: aString [

	diffsPresenter leftText: aString
]

{ #category : 'accessing' }
JadeiteDiffBrowser >> rightLabel: aString [

	diffsPresenter rightLabel: aString
]

{ #category : 'accessing' }
JadeiteDiffBrowser >> rightText: aString [

	diffsPresenter rightText: aString
]

{ #category : 'accessing' }
JadeiteDiffBrowser >> shellName [

	^'Difference Browser'
]
