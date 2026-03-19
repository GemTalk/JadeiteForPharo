Class {
	#name : 'JadeiteHistoryBrowser',
	#superclass : 'JadeiteSessionPresenter',
	#traits : 'JadeiteToolbarTrait + JadeiteMethodsTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait + JadeiteMethodsTrait classTrait',
	#instVars : [
		'diffsPresenter',
		'methodService',
		'versionListPresenter'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'constants' }
JadeiteHistoryBrowser class >> defaultPreferredExtent [

	^ 100 @ 75
]

{ #category : 'instance creation' }
JadeiteHistoryBrowser class >> showOn: methodService application: application [

	| historyBrowser windowPresenter |
	historyBrowser := self new methodService: methodService.
	historyBrowser gciSession: application gciSession.
	windowPresenter := historyBrowser open.
	historyBrowser updateHistory.
	historyBrowser owner application: application.
	application
		addBorderStyleTo: windowPresenter
		presenter: historyBrowser
]

{ #category : 'actions' }
JadeiteHistoryBrowser >> addStyle: aStyle [
	super addStyle: aStyle. 
	diffsPresenter addStyle: aStyle. 
]

{ #category : 'actions' }
JadeiteHistoryBrowser >> browseDifferences [
	"for consistent display, display first selection (by index) on right, second selection on list. "

	| selectedIndices |
	versionListPresenter selectedItems size = 2 ifFalse: [ ^ self ].
	selectedIndices := versionListPresenter selection selectedIndexes
		                   asSortedCollection.
	diffsPresenter rightText:
		(versionListPresenter list at: selectedIndices first) source.
	diffsPresenter rightLabel: 'First Selection'.
	diffsPresenter leftText:
		(versionListPresenter list at: selectedIndices second) source.
	diffsPresenter leftLabel: 'Second Selection'
]

{ #category : 'testing' }
JadeiteHistoryBrowser >> canDiscardEdits [

	^ true
]

{ #category : 'testing' }
JadeiteHistoryBrowser >> canDiscardSelectionEdits [

	^ true
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> connectPresenters [

	super connectPresenters.
	versionListPresenter whenSelectionChangedDo: [ :selection | 
		self versionSelected ]
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeDiffsPresenter: panedLayout [

	diffsPresenter := JadeiteDiffPresenter new.
	panedLayout add: diffsPresenter.
	diffsPresenter showOptions: false
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group | self addToolsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializePresenters [

	| panedLayout |
	super initializePresenters.
	panedLayout := SpPanedLayout newVertical positionOfSlider: 0.30.
	self initializeVersionsList: panedLayout.
	self initializeDiffsPresenter: panedLayout.
	self layout add: panedLayout.
	self initializeVersionsListContextMenu
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeVersionsList: panedLayout [

	versionListPresenter := JadeiteTablePresenter new beMultipleSelection.
	versionListPresenter addColumn: (SpStringTableColumn
			 title: 'Method'
			 evaluated: [ :operation | operation selectorPrintString ]).
	versionListPresenter addColumn: (SpStringTableColumn
			 title: 'category'
			 evaluated: [ :operation | operation category ]).
	panedLayout add: versionListPresenter
]

{ #category : 'initialization' }
JadeiteHistoryBrowser >> initializeVersionsListContextMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Revert';
				action: [ self revert ];
				enabled: [ versionListPresenter selections size = 1 ] ] ].

	versionListPresenter contextMenu: menu
]

{ #category : 'accessing' }
JadeiteHistoryBrowser >> methodService [

	^ methodService
]

{ #category : 'accessing' }
JadeiteHistoryBrowser >> methodService: anObject [

	methodService := anObject
]

{ #category : 'actions' }
JadeiteHistoryBrowser >> reportCompileError: gsArguments [

	| argArray |
	argArray := gsArguments first isArray
		            ifTrue: [ gsArguments first ]
		            ifFalse: [ (gsArguments at: 2) first ].
	diffsPresenter withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget | widget dstMorph textArea readOnly: false. 
			 widget dstMorph notify: (argArray at: 3) at: (argArray at: 2) in: widget dstMorph getText asString.
			widget dstMorph textArea readOnly: true. ] ].
	^ nil
]

{ #category : 'actions' }
JadeiteHistoryBrowser >> revert [

	| compileResult selectedService classService |
	selectedService := versionListPresenter selectedItem.
	classService := RowanClassService new
		                name: selectedService className;
		                meta: selectedService meta.
	classService
		command: #saveMethodSource:category:;
		commandArgs:
			(Array with: selectedService source with: selectedService category).
	compileResult := [
	                 self issueCommand: classService onCompletion: [
		                 self updateHistory.
		                 versionListPresenter selectIndex: 1.
		                 self todo: [
			                 compileResult "do something with this?" ].
		                 self todo: [
			                 self statusBarText message ifNotNil: [ :text |
				                 text isEmpty ifFalse: [ ^ self ] ] ] ] ]
		                 on: GsCompileError
		                 do: [ :ex |
			                 self todo:
				                 'need to work on compile errors everywhere'.
			                 self reportCompileError: ex gsArguments.
			                 ^ false ]
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
			onCompletion: [
				history := OrderedCollection new.
				versionListPresenter items: answeringService answer reversed.
				self todo: [ self setCaption ] ] ]
]

{ #category : 'events' }
JadeiteHistoryBrowser >> versionSelected [

	| selectedIndex previousItem |
	versionListPresenter selectedItems size = 2 ifTrue: [
		^ self browseDifferences ].
	versionListPresenter selectedItems size > 2 ifTrue: [
		diffsPresenter rightText: String new.
		diffsPresenter leftText: String new.
		^ self ].
	selectedIndex := versionListPresenter selection selectedIndex.
	selectedIndex = 0 ifTrue: [ ^ self ].

	selectedIndex = versionListPresenter items size ifTrue: [
		diffsPresenter rightText: versionListPresenter selectedItem source.
		diffsPresenter leftText: String new.
		^ self ].
	previousItem := versionListPresenter items at: selectedIndex + 1.
	diffsPresenter
		leftText: previousItem source;
		leftLabel: 'Previous Source';
		rightText: versionListPresenter selectedItem source;
		rightLabel: 'Selected Source'
]
