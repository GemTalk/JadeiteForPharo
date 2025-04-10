"
documentPresenter & codePane are identical as ported code from Dolphin used both. 
"
Class {
	#name : 'JadeiteInspector',
	#superclass : 'JadeInspector',
	#traits : 'JadeiteToolbarTrait',
	#classTraits : 'JadeiteToolbarTrait classTrait',
	#instVars : [
		'statusTextPresenter',
		'codePane',
		'model',
		'documentPresenter',
		'toolbar',
		'oopsCollection',
		'objectIndex'
	],
	#category : 'Jadeite-Inspector',
	#package : 'Jadeite-Inspector'
}

{ #category : 'as yet unclassified' }
JadeiteInspector class >> showOn: oop session: aGciSession [
	| inspector |
	inspector := self new gciSession: aGciSession.
	^inspector inspect: oop inContext: aGciSession oopNil
]

{ #category : 'accessing' }
JadeiteInspector >> _documentPresenter [

	^ documentPresenter
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> aboutToChange: aSelectionChangingEvent [
	aSelectionChangingEvent value ifTrue: [
		aSelectionChangingEvent value: self isOkayToChange.
	].

]

{ #category : 'as yet unclassified' }
JadeiteInspector >> addObject [
	| string |
	"might have inserted a string into another string so it won't find the object"
	model isVariable ifFalse: [^MessageBox notify: 'Cannot add elements to this object'].
	string := Prompter
				on: String new asValue
				prompt: 'Entry will be compiled and added to the object'
				caption: 'Add Object ...'.
	string ifNil: [^self].
	model isDictionary ifTrue: [^self basicAddKey: string].
	self basicAddObject: string
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> addOop: oop [
	codePane context: oop. 
	oop isNil ifTrue: [^self].
	(oopsCollection includes: oop) ifTrue: [^self].
	oopsCollection add: oop.
	objectIndex := objectIndex + 1
]

{ #category : 'adding' }
JadeiteInspector >> addStyle: aString [

	codePane addStyle: aString.
	
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> additionalAccelerators [
	^super additionalAccelerators
		, #(#(#fileSave 'Ctrl+S') #(#selectAll 'Ctrl+A') #(#jadeDebug 'Ctrl+B'))
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicAddKey: string [

	| addedObject newSelectionIndex |
	"might have inserted a string into another string so it won't find the object"
	model
		command: #addKey:;
		commandArgs: (Array with: string).
	self issueCommand: model onCompletion: [].
	addedObject := model objects
		               detect: [ :assoc |
			               (assoc value isKindOf: Array) and: [
				               assoc value first = model selectionOop ] ]
		               ifNone: [  ].
	newSelectionIndex := model objects indexOf: addedObject.
	newSelectionIndex := newSelectionIndex + 2. "inst vars & dynamic inst vars already included in objects"
	self displayObjectSelecting: newSelectionIndex
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicAddObject: string [

	| addedObject additionIndex newSelectionIndex |
	additionIndex := (self indexedOffsetFromInstVarList:
		                  instVarListPresenter selection selectedIndexes)
		                 first.
	model
		command: #addObject:after:;
		commandArgs: (Array with: string with: additionIndex).
	RowanServiceUpdater current
		issueCommand: model
		session: self gciSession
		onCompletion: [
			addedObject := model objects
				               detect: [ :array |
				               array last = model selectionOop ]
				               ifNone: [  ].
			newSelectionIndex := model objects indexOf: addedObject.
			newSelectionIndex := newSelectionIndex = 0
				                     ifTrue: [
					                     1 "might have inserted a string into another string so it won't find the object" ]
				                     ifFalse: [ newSelectionIndex + 2 ].
			self displayObjectSelecting: newSelectionIndex ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicRemoveDynamicInstVars [
	"remove dynamics, but let sender remove non-dynamics"

	| dynamicInstVarNames firstSelectionIndex nonDynamicsWereSelected selectionIndicesOfDynamics |
	firstSelectionIndex := instVarListPresenter selectionsByIndex first.
	selectionIndicesOfDynamics := instVarListPresenter selectionsByIndex
				select: [:index | '--*' match: (instVarListPresenter list at: index) key].
	dynamicInstVarNames := self selectedDynamicInstVars.
	nonDynamicsWereSelected := instVarListPresenter selections size - dynamicInstVarNames size > 0.
	model removeDynamicInstVarsNamed: dynamicInstVarNames session: gciSession.
	instVarListPresenter view
		selectionsByIndex: (instVarListPresenter selectionsByIndex difference: selectionIndicesOfDynamics).
	nonDynamicsWereSelected ifFalse: [self displayObjectSelecting: firstSelectionIndex - 1].
	^nonDynamicsWereSelected
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicRemoveFromDictionary [
	| selections newSelectionIndex |
	selections := instVarListPresenter selections collect: [:sel | sel value at: 1].
	self model removeKeys: selections session: gciSession.
	newSelectionIndex := instVarListPresenter view selectionsByIndex first min: model objects size + 2.
	self displayObjectSelecting: newSelectionIndex.
	(oopsCollection intersection: selections) do: 
			[:removedOop |
			oopsCollection remove: removedOop.
			objectIndex := objectIndex - selections size]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicRemoveObjects [
	| indices |
	model instVarsAreRemovable ifFalse: [^self].
	self isDynamicInstVarSelected
		ifTrue: [self basicRemoveDynamicInstVars ifFalse: [^self]	"might need to remove other elements"].
	indices := instVarListPresenter selectionsByIndex.
	model isDictionary ifTrue: [^self basicRemoveFromDictionary].
	self isNamedInstVarSelected ifTrue: [^MessageBox notify: 'Cannot remove inst var'].	"inst var"
	model isUnordered ifTrue: [^self basicRemoveOop: instVarListPresenter selection value].
	indices first - model instVarNames size <= 0 ifTrue: [^self].
	self basicRemoveObjectsAt: indices
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicRemoveObjectsAt: indices [
	| selections newSelectionIndex |
	selections := instVarListPresenter selections.
	model removeIndexedInstVarsAt: (self indexedOffsetFromInstVarList: indices) session: gciSession.
	newSelectionIndex := indices first
				min: model indexedSize + model instVarNames size + self dynamicInstVars size + 2.
	self displayObjectSelecting: newSelectionIndex.
	(selections collect: [:sel | sel value]) do: 
			[:oop |
			(oopsCollection includes: oop)
				ifTrue: 
					[oopsCollection remove: oop.
					objectIndex := objectIndex - 1]]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> basicRemoveOop: oop [
	| selection selectionIndex |
	selection := instVarListPresenter selection.
	self model removeOop: oop session: gciSession.
	selectionIndex := instVarListPresenter selectionByIndex min: model objects size + 2.
	self displayObjectSelecting: selectionIndex.
	oopsCollection remove: selection value ifAbsent: [^self].
	objectIndex := objectIndex - 1
]

{ #category : 'browsing' }
JadeiteInspector >> browseClass [

	| shell classService |
	classService := RowanClassService new name:
		                className substrings first. "strip off 'class' if meta"
	RowanServiceUpdater current
		updateService: classService
		session: gciSession
		onCompletion: [
			shell := self openBrowser.
			shell currentCard
				updateAfterFindClass: classService
				methodService: nil
				onCompletion: [  ] ].
	^ shell
]

{ #category : 'browsing' }
JadeiteInspector >> browseClassOfSelection [

	| shell classService oop answeringService |
	oop := self oopFromSelection.

	answeringService := RowanAnsweringService new.
	answeringService
		exec: '(Object _objectForOop: ' , oop printString
			, ') class name asString subStrings first'
		in: self gciSession
		onCompletion: [
			className := answeringService answer.
			classService := RowanClassService new
				                name:
					                (className copyFrom: 2 to: className size - 1);
				                "strip quotes"meta: false.
			RowanServiceUpdater current
				updateService: classService
				session: gciSession
				onCompletion: [ :svc |
					shell := self openBrowser.
					shell currentCard
						updateAfterFindClass: svc
						methodService: nil
						onCompletion: [  ] ] ]
]

{ #category : 'testing' }
JadeiteInspector >> canDiscardSelectionEdits [
	"selection changes have a different message"

	| theAdapter |
	theAdapter := codePane adapter.
	theAdapter ifNil: [ ^ true ].
	theAdapter widget hasUnacceptedEdits ifTrue: [
		(ProvideAnswerNotification signal: 'canDiscardSelectionEdits')
			ifNotNil: [ :answer | ^ answer ]. "for tests"
		^ (MessageBox confirm:
			   'You have unsaved changes. Discard changes and continue?')
			  ifTrue: [
				  self codePane
					  triggerResetAction;
					  hasUnacceptedEdits: false.
				  true ]
			  ifFalse: [ false ] ].
	^ true
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> canSave [
	^instVarListPresenter selections size = 1
		and: [self isSelfSelected not and: [self isAsOopSelected not]]
]

{ #category : 'accessing' }
JadeiteInspector >> caption [

	^ GciSession current titleBarFor: self shellName
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> computedListSelections [
	^instVarListPresenter selections difference: self nonComputedListSelections
]

{ #category : 'initialization' }
JadeiteInspector >> connectPresenters [

	instVarListPresenter whenSelectionChangedDo: [ :selection | 
		self selectedInstVar ].
	instVarListPresenter whenActivatedDo: [ :selection | 
		self inspectInstVar ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> contextObject [
	^model oop
]

{ #category : 'initialization' }
JadeiteInspector >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'displaying' }
JadeiteInspector >> displayAll [
	^self displayMore: model indexedSize
]

{ #category : 'displaying' }
JadeiteInspector >> displayMore [
	^self displayMore: model maxIndexedVars + model visibleIndices
]

{ #category : 'displaying' }
JadeiteInspector >> displayMore: stop [
	| service |
	service := RowanInspectorService new
				oop: model oop;
				indexedSize: model indexedSize.
	service
		nextIndexedVarsFrom: model visibleIndices + 1
		to: stop
		session: gciSession.
	model objects addAll: service nextIndices.
	model visibleIndices: service visibleIndices.
	self displayObjectSelecting: instVarListPresenter selectionByIndex
]

{ #category : 'displaying' }
JadeiteInspector >> displayObjectSelecting: selectionIndex [
	| contents reachedMax |
	contents := model objects copy.	"otherwise the presenter list will notice it's the same object and not update the view"
	(contents isEmpty or: [contents first ~= model myself])
		ifTrue: 
			[contents addFirst: (Array with: '-.asOop' with: model oop printString).
			contents addFirst: model myself].
	instVarListPresenter list: (ListModel on: contents).
	instVarListPresenter selectIndex: (selectionIndex ifNil: [1] ifNotNil: [selectionIndex]).
	reachedMax := model visibleIndices = self maxVariables
				ifTrue: [' (max displayable)']
				ifFalse: [String new].
	model statusText
		ifNil: 
			[model indexedSize > 0
				ifTrue: 
					[statusTextPresenter
						value: 'Displaying ' , model visibleIndices printString , reachedMax , ' of '
								, model indexedSize printString
									, (model isDictionary ifTrue: [' keys'] ifFalse: [' variable inst vars'])]
				ifFalse: [statusTextPresenter value: nil]]
		ifNotNil: [statusTextPresenter value: model statusText].
	className := model className.
	"documentPresenter view isModified: false"
]

{ #category : 'inspecting' }
JadeiteInspector >> dive [
	| oop |
	"instVarListPresenter selection is <anAssociation>"
	(self isSelfSelected or:[self isAsOopSelected]) ifTrue:[^self]. 
	oop := instVarListPresenter selections first value.
	(oop isKindOf: Array) ifTrue: [
			       | last |
			       last := oop last.
			      oop :=  last isArray
				       ifTrue: [ last last ]
				       ifFalse: [ last ]	
		].	"a dictionary entry will hold oop of key and oop of value"
	objectIndex = oopsCollection size
		ifFalse: [(oopsCollection at: objectIndex + 1) = oop ifTrue: [^self getNextObject]].
	self inspectOop: oop
]

{ #category : 'accessing' }
JadeiteInspector >> documentPresenter [
	"for older test support"

	^ codePane
]

{ #category : 'accessing' }
JadeiteInspector >> dynamicInstVars [
	^instVarListPresenter list select: [:instVar | '--*' match: instVar key]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> editRevert [
	self selectedInstVar
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> evaluateSelectedTextIn: textPresenter thenInspectInContext: context [
	| service |
	service := self evaluateText: textPresenter currentSelectionOrLine thenInspectInContext: context.
	service compileErrorArray
		ifNotNil: 
			[[^textPresenter showCompileError: service compileErrorArray first]
				ensure: [service compileErrorArray: nil]].
	^self showOn: service
]

{ #category : 'evaluating' }
JadeiteInspector >> evaluateText: string thenInspectInContext: context [

	| service |
	self createView: self class defaultView.
	service := RowanInspectorService new
		           executeThenInspect: string
		           context: context
		           session: gciSession
		           windowHandle: self view handle value
		           onCompletion: nil.
	^ service
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> executeThenInspect: aString inContext: context onCompletion: completionBlock [

	| window |
	window := self asWindow.
	RowanInspectorService new
		executeThenInspect: aString
		context: context
		session: gciSession
		windowHandle: window identityHash
		onCompletion: [ :service |
			completionBlock cull: service.
			service oop ifNotNil: [
				| windowPresenter |
				windowPresenter := self show: window on: service.
				self application addBorderStyleTo: windowPresenter presenter: self ] ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> expectedModelClass [
	^RowanInspectorService
]

{ #category : 'accessing' }
JadeiteInspector >> gciSession [ 
	
	^self application gciSession
]

{ #category : 'navigation' }
JadeiteInspector >> getNextObject [

	objectIndex := (objectIndex >= oopsCollection size) 
				ifTrue: [1]
				ifFalse:[objectIndex + 1].

	self setNewInspectedObject.
]

{ #category : 'navigation' }
JadeiteInspector >> getPreviousObject [
	objectIndex := (objectIndex <= 1) 
				ifTrue: [oopsCollection size]
				ifFalse:[objectIndex - 1].

	self setNewInspectedObject.
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> indexedOffsetFromInstVarList: indices [
	^indices
		collect: [:index | index - model instVarNames size - self dynamicInstVars size - 2 max: 0	"2 = self + asOop"]
]

{ #category : 'initialization' }
JadeiteInspector >> initialize [

	super initialize.
	oopsCollection := OrderedCollection new.
	objectIndex := 0
]

{ #category : 'menus' }
JadeiteInspector >> initializeBrowseMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Browse Class';
				  action: [ self browseClass ] ];
		  yourself
]

{ #category : 'menus' }
JadeiteInspector >> initializeInstVarContextMenu [

	instVarListPresenter contextMenu: [
		SpMenuPresenter new
			addGroup: [ :group |
				group
					addItem: [ :item |
						item
							name: 'Back';
							action: [ self getPreviousObject ] ];
					addItem: [ :item |
						item
							name: 'Dive';
							action: [ self dive ];
							enabled: self isInstVarComputed not ] ];
			addGroup: [ :group |
				group
					addItem: [ :item |
						item
							name: 'Browse Selection Class';
							shortcut: $b meta;
							action: [ self browseClassOfSelection ];
							enabled: (self isSelfOrNoncomputed and: [
										 instVarListPresenter selectedItems size = 1 ]) ];
					addItem: [ :item |
						item
							name: 'Inspect';
							shortcut: $i meta;
							action: [ self inspectInstVar ];
							enabled: (self isSelfOrNoncomputed and: [
										 instVarListPresenter selectedItems size = 1 ]) ];
					addItem: [ :item |
						item
							name: 'Select All';
							shortcut: $a meta;
							action: [ instVarListPresenter selectAll ] ] ] ]
]

{ #category : 'initialization' }
JadeiteInspector >> initializeInstVarList: box [

	instVarListPresenter := (JadeiteListPresenter new display: #first)
		                        beMultipleSelection.
	self initializeInstVarContextMenu.
	box add: instVarListPresenter
]

{ #category : 'initialization' }
JadeiteInspector >> initializeKeyBindings: aWindowPresenter [

	aWindowPresenter
		bindKeyCombination: $i meta
		toAction: [ self inspectInstVar ]
]

{ #category : 'initialization' }
JadeiteInspector >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Browse';
						  subMenu: self initializeBrowseMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteInspector >> initializePresenters [

	| box panedLayout |
	super initializePresenters.
	box := SpBoxLayout newHorizontal.
	box spacing: 10.
	self layout add: box.
	panedLayout := SpPanedLayout newHorizontal positionOfSlider: 0.30.
	self initializeInstVarList: panedLayout.
	panedLayout add:
		(documentPresenter := codePane := JadeiteTextDocument new
			                                  _gciSession: GciSession current).
	box add: panedLayout.
	statusTextPresenter := self newStatusBar.
	self layout addLast: statusTextPresenter expand: false
]

{ #category : 'initialization' }
JadeiteInspector >> initializeToolbar [

	toolbar := self newJadeiteToolbar
		           addItem: (SpToolbarButtonPresenter new
				            label: 'Back';
				            icon: (self iconNamed: #glamorousLeft);
				            help: 'returns to previous inspected object';
				            action: [ self getPreviousObject ];
				            yourself);
		           addItem: (SpToolbarButtonPresenter new
				            label: 'Dive';
				            icon: (self iconNamed: #glamorousRight);
				            help: 'dives into selected object';
				            action: [ self dive ];
				            yourself);
		           yourself.
	self layout
		add: #toolbar
		expand: false
		fill: false
		padding: 0
]

{ #category : 'initialization' }
JadeiteInspector >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		initialExtent: 80 @ 50 * StandardFonts defaultFont pointSize;
		menu: self initializeMenubar.
	self initializeKeyBindings: aWindowPresenter.
	self updateCaption
]

{ #category : 'inspecting' }
JadeiteInspector >> inspect: oop inContext: context [

	| window |
	window := self asWindow.
	RowanInspectorService new
		inspect: oop
		session: gciSession
		inWindow: window identityHash
		onCompletion: [ :service | self show: window on: service ]
]

{ #category : 'inspecting' }
JadeiteInspector >> inspectBytes [
	| inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector inspectBytes: (OopType64 fromInteger: oopsCollection first)
		inContext: gciSession oopNil value
]

{ #category : 'inspecting' }
JadeiteInspector >> inspectBytes: oop inContext: context [
	| service |
	self createView: self class defaultView.
	service := RowanInspectorService new
				inspectBytes: oop
				session: gciSession
				inWindow: self view handle value.
	^self showOn: service
]

{ #category : 'inspecting' }
JadeiteInspector >> inspectInNewWindow [
	| inspector key oop |
	inspector := JadeiteInspector new gciSession: gciSession.
	oop := instVarListPresenter selections first value.
	key := instVarListPresenter selections first key.
	key = 'self' ifTrue: [oop := model oop].
	key = '-.asOop' ifTrue: [oop := oop asNumber].
	(oop isKindOf: Array) ifTrue: [oop := oop last].
	^inspector inspect: (OopType64  fromInteger: oop) inContext: gciSession oopNil value
]

{ #category : 'inspecting' }
JadeiteInspector >> inspectInstVar [

	| oop |
	self isSelfOrNoncomputed ifFalse: [ ^ nil ].
	oop := self oopFromSelection.
	^ JadeiteInspectorApplication show: oop onSession: gciSession
]

{ #category : 'inspecting' }
JadeiteInspector >> inspectKeyInNewWindow [
	| inspector key oop |
	inspector := JadeiteInspector new gciSession: gciSession.
	oop := instVarListPresenter selections first value.
	key := instVarListPresenter selections first key.
	key = 'self' ifTrue: [oop := model oop].
	key = '-.asOop' ifTrue: [oop := oop asNumber].
	(oop isKindOf: Array) ifTrue: [oop := oop first].	"for dictionaries with real keys"
	^inspector inspect: (OopType64 fromInteger: oop) inContext: gciSession oopNil value
]

{ #category : 'inspecting' }
JadeiteInspector >> inspectOop: oop [

	RowanInspectorService new
		inspect: oop
		session: gciSession
		inWindow: self owner identityHash
		onCompletion: [ :service |
			model := service.
			self addOop: oop.
			self todo: [ "needed?" self setDocumentPresenterLabel ].
			self displayObjectSelecting: nil.
			self updateCaption ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> instVarListIndexFromIndexedOffset: index [
	^index + model instVarNames size + self dynamicInstVars size + 2	"2 = self + asOop"
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isAsOopSelected [
	^(instVarListPresenter selections detect: [:assoc | assoc key = '-.asOop'] ifNone: []) notNil
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isDynamicInstVarSelected [
	instVarListPresenter selections isEmpty ifTrue: [^false].
	^'--*' match: instVarListPresenter selections first key
]

{ #category : 'initialization' }
JadeiteInspector >> isInstVarComputed [

	^ self isSelectionComputed: instVarListPresenter selectedItem
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isNamedInstVarSelected [
	^model instVarNames includesAnyOf: self selectedNamedInstVars
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isOkayToChange [
	documentPresenter view isModified
		ifTrue: [^JadePresenter unsavedChangesDialogIn: documentPresenter].
	documentPresenter view isModified: false.
	^true
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isProtectedItemSelected [
	instVarListPresenter selections isEmpty ifTrue: [^false].
	(instVarListPresenter selectionsByIndex includesAnyOf: #(1 2)) ifTrue: [^true].
	instVarListPresenter selections
		do: [:selection | (('-*' match: selection key) and: [('--*' match: selection key) not]) ifTrue: [^true]].
	^false
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isSelectionComputed: assoc [
	assoc ifNil: [ ^false ].
	^assoc key = 'self' or: [assoc key = '-.asOop']
]

{ #category : 'initialization' }
JadeiteInspector >> isSelfOrNoncomputed [

	^ instVarListPresenter selections first key = 'self' or: [
		  self isInstVarComputed not ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isSelfSelected [
	^instVarListPresenter selections first key = 'self'
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> isStringObject [

	^true
]

{ #category : 'constants' }
JadeiteInspector >> maxPrintStringSize [
	^JadePresenter maxPrintStringSize
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> maxVariables [
	"sync with server method RowanInspectorService>>maxVariables"

	^65000
]

{ #category : 'menus' }
JadeiteInspector >> menuCommandClasses [

	^{JadeiteInspectInstVarCommand}
]

{ #category : 'menus' }
JadeiteInspector >> menuCommandGroup [

	| group |
	group := CmCommandGroup forSpec
		  beRoot;
			yourself.
	self menuCommands do: [:command | group register: command].
	^group
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> multipleInstVarsSelected [

	| writeStream oops answeringService computedSelections contents boldNeeded |
	writeStream := WriteStream on: String new.
	oops := self valueOops.
	answeringService := RowanAnsweringService new.
	answeringService
		command: #printStringOfOops:toMaxSize:;
		commandArgs: (Array with: oops with: self maxPrintStringSize).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: gciSession
		onCompletion: [
			computedSelections := self computedListSelections.
			boldNeeded := OrderedCollection new.
			computedSelections do: [ :assoc |
				boldNeeded add:
					(writeStream position to: writeStream position + assoc key size).
				writeStream
					nextPutAll: assoc key;
					nextPut: $:;
					space;
					nextPutAll: assoc last;
					cr ].
			1 to: oops size do: [ :index |
				| key |
				key := (instVarListPresenter selections at:
					        index + computedSelections size) key.
				boldNeeded add:
					(writeStream position to: writeStream position + key size).
				writeStream
					nextPutAll: key;
					nextPut: $:;
					space;
					nextPutAll: (answeringService answer at: index).
				index = oops size ifFalse: [ writeStream cr ] ].
			contents := writeStream contents.
			contents last = Character lf ifTrue: [
				contents := contents copyFrom: 1 to: contents size - 2 "crlf" ].
			documentPresenter value: contents ]
]

{ #category : 'initialization' }
JadeiteInspector >> newStatusBar [

	^ self instantiate: JadeiteStatusBarPresenter
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> nonComputedListSelections [
	| computedSelections |
	computedSelections := instVarListPresenter selectedItemsSorted
				reject: [:assoc | self isSelectionComputed: assoc].
	^computedSelections
]

{ #category : 'accessing' }
JadeiteInspector >> objectIndex [

	^ objectIndex
]

{ #category : 'accessing' }
JadeiteInspector >> objectIndex: anObject [

	^ objectIndex := anObject
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> objectIsVariable [

	| answeringService |
	model command: #isVariable.
	answeringService := RowanServiceUpdater current
		                    issueCommand: self
		                    session: gciSession
		                    onCompletion: nil.
	^ answeringService answer
]

{ #category : 'testing' }
JadeiteInspector >> okToClose [

	| theAdapter |
	theAdapter := codePane adapter.
	theAdapter ifNil: [ ^ true ].
	theAdapter widget hasUnacceptedEdits ifTrue: [
		^ (MessageBox confirm:
			   'You have unsaved changes. Discard changes and continue?
<' , self window title , '>')
			  ifTrue: [
				  codePane hasUnacceptedEdits: false.
				  true ]
			  ifFalse: [ false ] ].
	^ true
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> onCloseRequested: boolValueHolder [
	self isOkayToChange ifFalse:[boolValueHolder value: false]. 
]

{ #category : 'inspecting' }
JadeiteInspector >> oopFromSelection [

	^ instVarListPresenter selections first key = 'self'
		  ifTrue: [ model oop ]
		  ifFalse: [
			  | last |
			  last := instVarListPresenter selectedItem last.
			  last isArray
				  ifTrue: [ last last ]
				  ifFalse: [ last ] ]
]

{ #category : 'accessing' }
JadeiteInspector >> oopsCollection [

	^ oopsCollection
]

{ #category : 'accessing' }
JadeiteInspector >> oopsCollection: anObject [

	oopsCollection := anObject
]

{ #category : 'printing' }
JadeiteInspector >> printInstVar [

	| answeringService oop theValue |
	^ [
	  answeringService := RowanAnsweringServiceClient new registerWith:
		                      gciSession library.
	  theValue := instVarListPresenter selectedItems first last. "oop or Array"
	  oop := (theValue isKindOf: Array)
		         ifTrue: [ theValue at: 2 ]
		         ifFalse: [ theValue ].
	  answeringService
		  command: #printStringOf:toMaxSize:;
		  commandArgs: (Array with: oop with: self maxPrintStringSize).
	  RowanServiceUpdater current
		  issueCommand: answeringService
		  session: gciSession
		  onCompletion: [
			  codePane
				  text: answeringService answer;
				  hasUnacceptedEdits: false ].
	  answeringService answer ]
		  on: Error
		  do: [ :ex |
			  self
				  displayInstVarError: ex
				  instVar: instVarListPresenter selectedItems first last ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> queryCommand: query [
	| command |
	command := query command.
	command = #fileSave
		ifTrue: 
			[self shouldEnableFileSave: query.
			^true].
	(command = #displayMore or: [command = #displayAll])
		ifTrue: 
			[model isShowingAllIndexedVars
				ifTrue: 
					[query isEnabled: false.
					^true]].
	command = #addObject
		ifTrue: 
			[model isService ifTrue: [query isEnabled: model isVariable].
			^true].
	command = #removeObjects
		ifTrue: 
			[self isProtectedItemSelected
				ifTrue: 
					[query isEnabled: false.
					^true]].
	command = #inspectInNewWindow
		ifTrue: 
			[query isEnabled: instVarListPresenter selections size = 1.
			^true].
	command = #inspectKeyInNewWindow
		ifTrue: 
			[| selections |
			selections := instVarListPresenter selections.
			query isEnabled: (selections size = 1 and: [selections first value isKindOf: Array]).
			^true].
	command = #inspectBytes
		ifTrue: 
			[query isEnabled: (model isStringObject ifNil:[false]).
			^true].
	query command == #getPreviousObject
		ifTrue: 
			[query isEnabled: objectIndex ~= 1.
			^true].
	query command == #getNextObject
		ifTrue: 
			[query isEnabled: objectIndex < oopsCollection size.
			^true].
	(query command == #browseClass or: [query command == #browseSelectedClass])
		ifTrue: 
			[query isEnabled: true.
			^true].
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> registerWindow: handle rootObject: oop [
	^RowanBrowserService new
		registerWindow: handle value
		rootObject: oop
		session: self gciSession
]

{ #category : 'actions' }
JadeiteInspector >> removeObject [

	(oopsCollection size > 1) ifFalse: [^self].

	oopsCollection remove: self model value ifAbsent: [^self].

	objectIndex := (objectIndex <= 1) 
				ifTrue: [oopsCollection size]
				ifFalse:[objectIndex - 1].

	self setNewInspectedObject.

]

{ #category : 'as yet unclassified' }
JadeiteInspector >> removeObjects [
	(MessageBox confirm: 'Really remove selection(s)?') ifFalse: [^self].
	^self basicRemoveObjects
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> reportCompileError: ex [
	| position text |
	text := (ex list first at: 3) , '>>>>>'.
	position := ex list first at: 2.
	documentPresenter view caretPosition: position.
	documentPresenter view insertText: text at: position.
	^documentPresenter view selectionRange: (position to: position + text size - 1)
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> saveDictionaryElement [

	| keyOop |
	keyOop := instVarListPresenter selection value first.
	model
		command: #saveKey:value:;
		commandArgs: (Array with: keyOop with: documentPresenter value).
	self issueCommand: model onCompletion: [].
	self displayObjectSelecting: instVarListPresenter selectionByIndex
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> saveDocument [
	(self isSelfSelected or: [self isAsOopSelected])
		ifTrue: [^MessageBox notify: 'Cannot modify Self or the oop'].
	
	[self isDynamicInstVarSelected ifTrue: [^self saveDynamicInstVar].
	self isNamedInstVarSelected ifTrue: [^self saveNamedInstVar].
	model isDictionary ifTrue: [^self saveDictionaryElement].
	model isUnordered ifTrue: [^self saveUnorderedElement].
	self saveIndexedElement]
			on: GsCompileError
			do: [:ex | self reportCompileError: ex]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> saveDynamicInstVar [

	| instVarName |
	instVarName := self selectedDynamicInstVars first. "only save when one object selected"
	model
		command: #save:dynamicInstVar:;
		commandArgs: (Array with: documentPresenter value with: instVarName).
	self issueCommand: model onCompletion: [].
	self displayObjectSelecting: instVarListPresenter selectionByIndex
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> saveIndexedElement [

	| indices |
	indices := self indexedOffsetFromInstVarList:
		           instVarListPresenter selectionsByIndex. "should always be one if we get here"
	model
		command: #save:indexedVarAt:;
		commandArgs:
			(Array with: documentPresenter value with: indices first).
	self issueCommand: model onCompletion: [].
	self displayObjectSelecting:
		(self instVarListIndexFromIndexedOffset: indices first)
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> saveNamedInstVar [

	| index instVarName |
	instVarName := self selectedNamedInstVars first.
	model
		command: #save:namedInstVar:;
		commandArgs: (Array with: documentPresenter value with: instVarName).
	RowanServiceUpdater current
		issueCommand: model
		onCompletion: [ :unused |
			index := model instVarNames indexOf: instVarName.
			self displayObjectSelecting: index + 2 ]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> saveUnorderedElement [

	| oop addedObject newSelectionIndex |
	oop := instVarListPresenter view selections first value.
	model
		command: #replaceElement:with:;
		commandArgs: (Array with: oop with: documentPresenter value).
	self issueCommand: model onCompletion: [].
	addedObject := model objects
		               detect: [ :assoc | assoc value = model selectionOop ]
		               ifNone: [  ].
	newSelectionIndex := model objects indexOf: addedObject.
	self displayObjectSelecting: newSelectionIndex + 2
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> selectedDynamicInstVars [
	"if a named inst var is selected, return it's name as a symbol"

	^instVarListPresenter selections select: [:sel | '--*' match: sel key]
		thenCollect: [:sel | (sel key copyFrom: 3 to: sel key size) asSymbol]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> selectedInstVar [

	| key |
	instVarListPresenter selectedItems isEmpty ifTrue: [
		codePane text: String new.
		^ self ].
	instVarListPresenter selectedItems size > 1 ifTrue: [
		^ self multipleInstVarsSelected ].
	key := instVarListPresenter selectedItems first first.
	(key = 'self' or: [ key = '-.asOop' ]) ifTrue: [
		codePane
			text: instVarListPresenter selectedItems first last;
			hasUnacceptedEdits: false.
		^key ].
	[ self printInstVar ]
		on: GsRuntimeError
		do: [ :ex |
			ex number == 2106 ifTrue: [ "Forward reference error"
				ex return:
					'an invalid or hidden object (perhaps a LargeObjectNode)' ].
			ex pass ].

]

{ #category : 'as yet unclassified' }
JadeiteInspector >> selectedNamedInstVars [
	"if a named inst var is selected, return it's name as a symbol"

	^instVarListPresenter selections collect: [:assoc | (assoc key copyWithout: $-) asSymbol]
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> setNewInspectedObject [
	| oop |
	oop := oopsCollection at: objectIndex.
	self inspectOop: oop
]

{ #category : 'overrides' }
JadeiteInspector >> shellName [
	| inspectionTarget |
	inspectionTarget := className ifNil: [model ifNil: [String new] ifNotNil: [model printString]].
	^'Inspector on ' , inspectionTarget , self shellNameExtraInfo
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> shellNameExtraInfo [
	model ifNil: [ ^String new ].
	(model isKindOf: String) ifTrue: [^' (' , model size printString , ' characters)'].
	(model isKindOf: ByteArray) ifTrue: [^' (' , model size printString , ' bytes)'].
	^String new
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> shouldEnableFileSave: query [
	(instVarListPresenter selectionIfNone: [])
		ifNil: [query isEnabled: false]
		ifNotNil: 
			[query
				isEnabled: (documentPresenter view isModified and: 
							[self isSelfSelected not
								and: [self isAsOopSelected not and: [instVarListPresenter selections size = 1]]])]
]

{ #category : 'displaying' }
JadeiteInspector >> show: window on: service [
	"send #open to self to make sure we register window
	with connection profile."
	| windowPresenter | 
	model := service.
	windowPresenter := self open.
	self displayObjectSelecting: nil.
	self updateCaption.
	self addOop: model oop.
	^windowPresenter
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> showOn: service [
	model := service.
	self showShell.
	self displayObjectSelecting: nil.
	self updateCaption.
	self addOop: self model oop
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> statusText [
	^statusTextPresenter value
]

{ #category : 'accessing' }
JadeiteInspector >> updateCaption [

	self caption: self caption
]

{ #category : 'as yet unclassified' }
JadeiteInspector >> valueOops [
	^self nonComputedListSelections
		collect: [:assoc | assoc last isNumber ifTrue: [assoc last] ifFalse: [assoc last last	"dictionary"]]
]
