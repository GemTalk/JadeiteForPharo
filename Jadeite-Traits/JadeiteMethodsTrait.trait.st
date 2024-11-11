Trait {
	#name : 'JadeiteMethodsTrait',
	#traits : 'JadeiteUtilityTrait',
	#classTraits : 'JadeiteUtilityTrait classTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'selecting' }
JadeiteMethodsTrait >> _selectSymbolFrom: wildcardString list: possibleSelectors title: listWindowTitle browseAction: browseAction guiAction: guiActionSymbol [

	| selector dialogWindow |
	possibleSelectors isEmpty ifTrue: [
		^ UIManager default alert: 'No symbols matching: ' , wildcardString ].
	possibleSelectors size = 1
		ifTrue: [ selector := possibleSelectors first ]
		ifFalse: [
			dialogWindow := ListDialogWindow new
				                getList: [ :rxMatcher |
					                possibleSelectors select: [ :substring |
							                rxMatcher isString
								                ifTrue: [ rxMatcher , '*' match: substring ]
								                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
									                rxMatcher matchesPrefix: substring ] ] ];
				                displayBlock: [ :e | e ];
				                browseBlock: [ :arg |
					                | queryService |
					                queryService := RowanQueryService new.
					                queryService serviceCompletionBlock: [
							                JadeiteMethodListBrowser
								                openOn: queryService
								                selecting: wildcardString
								                session: self gciSession ].
					                queryService
						                perform: browseAction
						                with: possibleSelectors ];
				                doubleClickOk;
				                title: listWindowTitle;
				                yourself.
			selector := dialogWindow chooseFromOwner: self currentWorld ].
	self perform: guiActionSymbol with: selector
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseBreakpointMethodsTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Breakpoints Methods';
			  action: [ self browseBreakpoints ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseClassItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse';
			action: [ self browseMethodClass ];
			enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseClassReferencesItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Class References';
			action: [ self browseClassReferences ];
			enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseDifferencesTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Differences';
			  action: [ self browseDifferences ];
			  enabled: [ self methodListPresenter selections size = 2 ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseHistoryTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Method History';
			  action: [ self browseMethodHistory ];
			  enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addDialogImplementorsDialogItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Implementors Of ...';
			action: [ self browseImplementorsOf ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addDialogSendersItemTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Senders Of ...';
			  action: [ self browseSendersOf ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addImplementorsItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Implementors';
			action: [ self browseImplementors ];
			enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addLiteralReferencesTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Literal References ...';
			  action: [ self browseLiteralReferences ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addMethodsContainingTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Method Containing ...';
			action: [ self browseMethodsContaining ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addSendersItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Senders';
			action: [ self browseSenders ];
			enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> basicHierarchySendersOf: string [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"

	| service shell |
	service := RowanQueryService
		           command: #hierarchySendersOf:inClass:
		           withArgs:
		           (Array
			            with: string asSymbol
			            with: self selectedClass name).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self openMethodListOn: service selecting: string.
			shell updateCaptionFromSearchString:
				service answer size printString , ' Hierarchy Senders of '
				, string asString printString , ' in ' , self selectedClass name ].
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> basicSendersOf: string [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"

	| service shell |
	service := RowanQueryService
		           command: #sendersOf:
		           withArgs: (Array with: string asSymbol).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self openMethodListOn: service selecting: string.
			shell updateCaptionFromSearchString:
				service answer size printString , ' Senders of '
				, string asString printString ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseBreakpoints [

	| service browser |
	service := RowanQueryService
		           command: #breakPointMethods
		           withArgs: Array new.
	RowanServiceUpdater current
		issueCommand: service
		session: GciSession current
		onCompletion: [
			browser := JadeiteMethodListBrowser
				           openOn: service
				           selectingAnyMatch: String new
				           session: GciSession current.
			browser updateCaptionFromSearchString:
				'Methods Containing BreakPoints' ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> browseDifferences [

	| diffBrowser methodService1 methodService2 |
	self methodListPresenter selectedItems size = 2 ifFalse: [ ^ self ].
	methodService1 := self methodListPresenter selectedItems first.
	methodService2 := self methodListPresenter selectedItems last.
	self
		updateServices: {
				methodService1.
				methodService2 }
		onCompletion: [
			diffBrowser := JadeiteDiffBrowser
				               compare: methodService1
				               to: methodService2
				               application: self application.
			diffBrowser owner application: self application ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseHierarchyImplementors [

	^ self browseHierarchyImplementorsOf: self selectedMethodName
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseHierarchyImplementorsOf: string [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"

	| service shell |
	string ifNil: [ ^ self ].
	string size > self maxSymbolSize ifTrue: [
		^ MessageBox notify:
			  'String exceeds max symbol size - '
			  , self maxSymbolSize printString , ' characters' ].

	service := RowanQueryService
		           command: #hierarchyImplementorsOf:inClass:
		           withArgs:
		           (Array
			            with: string asSymbol
			            with: self selectedClass name).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self openMethodListOn: service selecting: nil.
			shell updateCaptionFromSearchString:
				service answer size printString , ' Hierarchy Implementors of '
				, string asString printString , ' in ' , self selectedClass name ].
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseHierarchySenders [
 
	self browseHierarchySendersOf: self selectedMethodName
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseHierarchySendersOf: string [
	string size > self maxSymbolSize
		ifTrue: 
			[^MessageBox
				notify: 'String exceeds max symbol size - ' , self maxSymbolSize printString , ' characters'].
	self basicHierarchySendersOf: string
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseImplementors [

	^ self browseImplementorsOf: self selectedMethodName
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseImplementorsOf [

	| selector wildcardString listWindowTitle |
	wildcardString := UIManager default
		                  request: 'Enter wildcard string:'
		                  initialAnswer: String new.
	wildcardString ifNil: [ ^ self ].
	listWindowTitle := 'Jadeite Browse Implementors'.
	selector := self
		            selectSymbolFrom: wildcardString
		            titled: listWindowTitle
		            browseAction: #implementorsOfAll:
		            guiAction: #browseImplementorsOf:
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseImplementorsOf: string [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"
	| service shell |
	string ifNil: [ ^ self ].
	string size > self maxSymbolSize ifTrue: [
		^ MessageBox notify:
			  'String exceeds max symbol size - '
			  , self maxSymbolSize printString , ' characters' ].

	service := RowanQueryService
		           command: #implementorsOf:
		           withArgs: (Array with: string asSymbol).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self openMethodListOn: service selecting: nil.
			shell updateCaptionFromSearchString:
				service answer size printString , ' Implementors of '
				, string asString printString ].
	^shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseLiteralReferences [

	^ self
		  browseLiteralReferences: self gciSession
		  initialSuggestion: String new
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseLiteralReferences: string [
	"In a test, method won't return until completion block finished. Don't use return value except in tests"

	| service shell |
	(string isNil or: [ string isEmpty ]) ifTrue: [ ^ nil ].
	service := RowanQueryService
		           command: #literalReferences:
		           withArgs: (Array with: string).
	[
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [
			shell := self openMethodListOn: service selecting: string.
			shell updateCaptionFromSearchString:
				'Literal References To ' , string asString printString ] ]
		on: GsCompileError
		do: [ :ex |
			^ MessageBox warning:
				  'Compile error: ' , (ex gsArguments first at: 3) ].
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseLiteralReferences: session initialSuggestion: initialString [

	| string |
	string := UIManager default
		          request: 'Enter code to be compiled.
Example: To search for literal string add single quotes'
		          initialAnswer: String new.
	^ self browseLiteralReferences: string
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseMethodClass [

	| classService methodService |
	methodService := self methodListPresenter jadeiteSelections first.
	classService := RowanClassService new name: methodService className.
	classService meta: methodService meta.
	self updateService: classService onCompletion: [
		self openBrowserOn: self postOpen: [ :browserPresenter |
			browserPresenter
				updateAfterFindClass: classService
				method: methodService ] ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> browseMethodHistory [

	| methodService |
	self methodListPresenter selectedItems size = 1 ifFalse: [ ^ self ].
	methodService := self methodListPresenter selectedItem.
	self updateService: methodService onCompletion: [
		JadeiteHistoryBrowser
			showOn: self methodListPresenter selectedItem
			application: self application ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseMethodsContaining [

	| string |
	string := (UIManager default
		           request: 'Enter string:'
		           initialAnswer: String new
		           title: 'Browse Methods Containing ...') ifNil: [ ^ self ].
	^ Cursor wait showWhile: [ self browseMethodsContaining: string ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseMethodsContaining: string [

	| service shell |
	service := RowanQueryService
		           command: #methodsContaining:
		           withArgs: (Array with: string).
	RowanServiceUpdater current
		issueCommand: service
		session: self gciSession
		onCompletion: [shell := self openMethodListOn: service selecting: string.
shell updateCaptionFromSearchString:
	'Methods Containing ' , string asString printString].
	
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSelectedMethods [
	"convenience menu item to display randomly grouped methods in a browser"

	| shell |
	shell := (JadeiteMethodListApplication showOnSession:
		          self gciSession library) methods:
		         self methodListPresenter selectedItems.
	shell updateCaptionFromSearchString: 'Selected Methods'.
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSenders [
 
	self browseSendersOf: self selectedMethodName
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSendersOf [

	| selector wildcardString listWindowTitle |
	wildcardString := UIManager default
		                  request: 'Enter wildcard string:'
		                  initialAnswer: String new.
	wildcardString ifNil: [ ^ self ].
	listWindowTitle := 'Jadeite Browse Senders'.
	selector := self
		            selectSymbolFrom: wildcardString
		            titled: listWindowTitle
		            browseAction: #sendersOfAll:
		            guiAction: #browseSendersOf:
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSendersOf: string [
	string size > self maxSymbolSize
		ifTrue: 
			[^MessageBox
				notify: 'String exceeds max symbol size - ' , self maxSymbolSize printString , ' characters'].
	self basicSendersOf: string
]

{ #category : 'testing' }
JadeiteMethodsTrait >> canDiscardEdits [

	| theAdapter |
	theAdapter := self methodSourcePresenter adapter.
	theAdapter ifNil: [ ^ true ].
	theAdapter widget hasUnacceptedEdits ifTrue: [
		^ (MessageBox confirm:
			   'You have unsaved changes. Discard changes and continue?
<' , self window title , '>')
			  ifTrue: [
				  self methodSourcePresenter
					  triggerResetAction;
					  hasUnacceptedEdits: false.
				  true ]
			  ifFalse: [ false ] ].
	^ true
]

{ #category : 'actions' }
JadeiteMethodsTrait >> compilationWarningFrom: methodServices [
	methodServices do: 
			[:methodService |
			methodService compilationWarnings
				ifNotNil: 
					[:warningStream |
					| rs output |
					rs := ReadStream on: warningStream.
					output := 'WARNING: '.
					[rs atEnd] whileFalse: 
							[output := output , (rs upToAll: 'WARNING: ').
							output := output , (rs upTo: Character lf).
							output := output , '; '].
					^output]].
	^nil
]

{ #category : 'actions' }
JadeiteMethodsTrait >> copyMethodSelectors [

	| printString |
	self methodListPresenter selections isEmpty ifTrue: [
		^ UIManager default inform: 'No methods copied to clipboard' ].
	printString := self methodListPresenter selections size = 1
		               ifTrue: [
		               self methodListPresenter selectedItem fullSelector ]
		               ifFalse: [
			               | stream |
			               stream := WriteStream on: String new.
			               1 to: self methodListPresenter selectedItems size
				               do: [ :index |
					               | methodService |
					               methodService := self methodListPresenter
						                                selectedItems at: index.
					               stream nextPutAll: methodService fullSelector.
					               index
					               = self methodListPresenter selectedItems size
						               ifFalse: [ stream cr ] ].
			               stream contents ].
	Clipboard
		clipboardText: printString
		informing: 'Method selector(s) copied to clipboard'
]

{ #category : 'as yet unclassified' }
JadeiteMethodsTrait >> displayBreakpoints [

	self methodListPresenter selectedItem ifNil: [ ^ self ].
	self methodListPresenter selectedItem breakPoints do: [ :breakPoint |
		| range stepPointAssoc |
		stepPointAssoc := self methodListPresenter selectedItem stepPoints
			                  at: breakPoint.
		range := self methodListPresenter selectedItem stepPointRangeFrom:
			         stepPointAssoc.
		self methodSourcePresenter addTextSegmentDecoration:
			((SpTextPresenterDecorator new highlightColor: Color lightCyan)
				 interval: range) ]
]

{ #category : 'as yet unclassified' }
JadeiteMethodsTrait >> displayMethodSourceStepPoints [

	self methodListPresenter selectedItem ifNil: [ ^ self ].
	self methodSourcePresenter methodService stepPoints do: [
		:stepPointAssoc |
		| range |
		range := self methodSourcePresenter methodService
			         stepPointRangeFrom: stepPointAssoc.

		self methodSourcePresenter addTextSegmentDecoration:
			((SpTextPresenterDecorator new underlineColor: Color veryLightGray)
				 interval: range) ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> editSaveMethod: classService in: thePresenter category: category onCompletion: completionBlock [

	| index |
	thePresenter
		saveMethodIn: classService
		category: category
		completionBlock: [
			classService selectedMethods isEmpty ifFalse: [
				index := self methodListPresenter selectionMode indexOfItem:
					         classService selectedMethods first.
				self methodListPresenter
					selectIndex: index
					scrollToSelection: true ].
			(self compilationWarningFrom: classService selectedMethods)
				ifNil: [ self resetStatusBar ]
				ifNotNil: [ :warning |
					self setCompileWarningColor.
					self statusBarText pushMessage: warning ].
			self updateMethodSourceGlyphs.
			completionBlock value ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> fileoutMethods [
	"append .gs to the file so it matches what rowan does for packages & projects"

	| service fileService filePath |
	RowanServiceUpdater current critical: [
		service := self selectedMethods.
		filePath := self fileoutFileSelection: 'methods.gs'.
		filePath ifNotNil: [
			fileService := RowanFileService new path: filePath.
			fileService
				command: #fileoutMethods:;
				commandArgs: (Array with: self selectedMethods).
			RowanServiceUpdater current
				issueCommand: fileService
				session: self gciSession
				onCompletion: [  ] ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> fullMethodListMenu [

	| menu |
	menu := self newBrowseMethodListMenu.

	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Remove Method(s) ...';
				action: [ self removeMethods ] ] ].
	JadeitePreferences isRowanLoaded ifTrue: [
		menu addGroup: [ :group |
			group addItem: [ :item |
				item
					name: 'Move to Package ...';
					action: [ self moveMethodToPackage ] ] ] ].
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'File Out Selected Methods ...';
				action: [ self fileoutMethods ];
				enabled: [ self methodListPresenter selections notEmpty ] ] ].
	^ menu
]

{ #category : 'menus' }
JadeiteMethodsTrait >> initializeBrowseMethodListMenu [

	self methodListPresenter contextMenu: self newBrowseMethodListMenu
]

{ #category : 'menus' }
JadeiteMethodsTrait >> initializeFullMethodListMenu [

	self methodListPresenter contextMenu: self fullMethodListMenu
]

{ #category : 'commands' }
JadeiteMethodsTrait >> issueCommand: service onCompletion: completionBlock [

	^ RowanServiceUpdater current
		  issueCommands: (Array with: service)
		  session: self gciSession
		  onCompletion: completionBlock
]

{ #category : 'constants' }
JadeiteMethodsTrait >> maxSymbolSize [

	^1024
]

{ #category : 'actions' }
JadeiteMethodsTrait >> moveMethodToPackage [
	self selectPackageOnCompletion: [ :packageName |
		packageName ifNotNil: [ self moveMethodsToPackageNamed: packageName ] ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> moveMethods: selectedMethods inClass: selectedClass toPackageNamed: packageName [

	| classService |
	classService := self selectedClass.
	classService
		command: #moveMethodSelectors:toPackageNamed:;
		commandArgs: (Array
				 with: (selectedMethods collect: [ :theMethodService |
							  theMethodService selector ])
				 with: packageName).
	RowanServiceUpdater current
		issueCommand: classService
		session: self gciSession
		onCompletion: [ 	
			self
				postMoveToPackage: packageName
				classService: selectedClass
				selectedMethods: selectedMethods ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> moveMethodsToPackageNamed: packageName [

	| selectedClass selectedMethods |
	self methodListPresenter selections isEmpty ifTrue: [ ^ self ].
	selectedClass := self selectedClass.
	selectedMethods := self methodListPresenter selections.
	self
		moveMethods: selectedMethods
		inClass: selectedClass
		toPackageNamed: packageName
]

{ #category : 'menus' }
JadeiteMethodsTrait >> newBrowseMethodListMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  self addBrowseClassItemTo: group.
			  self addBrowseClassReferencesItemTo: group ];
		  addGroup: [ :group |
			  self addImplementorsItemTo: group.
			  self addDialogImplementorsDialogItemTo: group.
			  group addItem: [ :item2 |
					  item2
						  name: 'Browse Senders';
						  action: [ self browseSenders ];
						  enabled: [ self methodListPresenter selections size = 1 ] ].
			  self addDialogSendersItemTo: group ];
		  addGroup: [ :group |
			  group
				  addItem: [ :item2 |
					  item2
						  name: 'Browse Hierarchy Implementors';
						  action: [ self browseHierarchyImplementors ];
						  enabled: [ self methodListPresenter selections size = 1 ] ];
				  addItem: [ :item2 |
					  item2
						  name: 'Browse Hierarchy Senders';
						  action: [ self browseHierarchySenders ];
						  enabled: [ self methodListPresenter selections size = 1 ] ] ];
		  addGroup: [ :group |
			  self addMethodsContainingTo: group.
			  self addLiteralReferencesTo: group.
			  group addItem: [ :item |
				  item
					  name: 'Browse Selected Methods';
					  action: [ self browseSelectedMethods ];
					  enabled: [ self methodListPresenter selections notEmpty ] ].
			  self addBrowseDifferencesTo: group.
			  self addBrowseHistoryTo: group.
			  self addBrowseBreakpointMethodsTo: group ];
		  yourself
]

{ #category : 'menus' }
JadeiteMethodsTrait >> newBrowseMethodsConsoleMenu [

	^ JadeiteMenuPresenter new
		  addGroup: [ :group |
			  self
				  addDialogImplementorsDialogItemTo: group;
				  addDialogSendersItemTo: group;
				  addMethodsContainingTo: group;
				  addLiteralReferencesTo: group;
				  addBrowseBreakpointMethodsTo: group ];
		  yourself
]

{ #category : 'queries' }
JadeiteMethodsTrait >> noMatchesFoundMessageFor: wildcardString [

	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'No matches found for <1p>.'.
	(wildcardString includes: $*) ifFalse: [
		ws nextPutAll: '<r>Perhaps include a wildcard in search?' ].
	^ ws contents expandMacrosWith: wildcardString
]

{ #category : 'testing' }
JadeiteMethodsTrait >> okToChangeSelections [

	self methodSourcePresenter adapter widget hasUnacceptedEdits ifTrue: [
		(MessageBox confirm:
			 'You have unsaved changes. Discard changes and continue?')
			ifTrue: [
				self methodSourcePresenter hasUnacceptedEdits: false.
				^ true ]
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'queries' }
JadeiteMethodsTrait >> openBrowserOn: theOwner postOpen: aBlock [

	^ JadeiteBrowser openOn: theOwner postOpen: aBlock
]

{ #category : 'queries' }
JadeiteMethodsTrait >> openMethodListOn: service selecting: string [

	| selectionString |
	string ifNotNil: [ 
		selectionString := (ReadStream on: string) upTo: $: ].
	^ JadeiteMethodListBrowser
		  openOn: service
		  selecting: selectionString
		  session: self gciSession
]

{ #category : 'actions' }
JadeiteMethodsTrait >> postMoveToPackage: packageName classService: classService selectedMethods: selectedMethods [

	| packageServiceToSelect index |
	RowanServiceUpdater current critical: [
		packageServiceToSelect := self packageListPresenter list
			                          detect: [ :packageService |
			                          packageService name = packageName ]
			                          ifNone: [ ^ self ].
		self packageListPresenter unselectAll.
		self classListPresenter unselectAll.
		self classHierarchyPresenter unselectAll.
		index := self packageListPresenter list indexOf:
			         packageServiceToSelect.
		self packageListPresenter selectIndex: index scrollToSelection: true.
		index := self classListPresenter list indexOf: classService.
		self classListPresenter selectIndex: index scrollToSelection: true.
		index := self methodListPresenter list indexOf:
			         selectedMethods first.
		self methodListPresenter selectIndex: index scrollToSelection: true ]
]

{ #category : 'updates' }
JadeiteMethodsTrait >> preUpdate: services [

	services do: [ :service | 
		service preUpdate: self  ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> reformatSource [
	| formattedSource |
	formattedSource := self reformatSourceInPresenter: self methodSourcePresenter
				methodService: self methodToReformat.
	self methodValueChanged.
	^formattedSource
]

{ #category : 'actions' }
JadeiteMethodsTrait >> reformatSourceInPresenter: presenter methodService: theMethodService [

	theMethodService
		source: presenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[ self issueCommand: theMethodService onCompletion: [  ] ]
		on: Error
		do: [ :ex |
			self setCompileErrorColor.
			self statusBarText:
				'Reformat failed. Illegal source - ' , ex description.
			^ false ].
	presenter view performUndoableAction: [
		presenter view modifyText: [
			presenter view sciSetText: theMethodService source ] ].
	presenter value: theMethodService source.
	presenter view isModified: true.
	self setStatusBarDefault.
	self statusBarText: String new.
	^ presenter value
]

{ #category : 'compiler warning' }
JadeiteMethodsTrait >> removeCompileWarningColor [
	self statusBarText withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget |
			widget adoptPaneColor: Color transparent  ] ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> removeMethodSelectors: selectors [

	| selectedClass |
	selectedClass := self selectedClass.
	selectedClass
		command: #removeMethods:;
		commandArgs: (Array with: self methodListPresenter selections).
	self issueCommand: selectedClass onCompletion: [  ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> removeMethods [

	(MessageBox confirm: 'Really delete method(s)?') ifTrue: [ 
		self removeMethodSelectors: self selectedMethodNames ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> resetStatusBar [

	self removeCompileWarningColor.
	self statusBarText pushMessage: String new
]

{ #category : 'selecting' }
JadeiteMethodsTrait >> selectSymbolFrom: wildcardString titled: listWindowTitle browseAction: browseAction guiAction: guiActionSymbol [

	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService command: #lowercaseSelectorsMatching:.
	answeringService commandArgs: (Array with: wildcardString).
	RowanServiceUpdater current
		issueCommands: (Array with: answeringService)
		session: self gciSession
		onCompletion: [
			self
				_selectSymbolFrom: wildcardString
				list: answeringService answer
				title: listWindowTitle
				browseAction: browseAction
				guiAction: guiActionSymbol ]
]

{ #category : 'selections' }
JadeiteMethodsTrait >> selectedMethodName [

	^self methodListPresenter jadeiteSelections first selector

]

{ #category : 'selections' }
JadeiteMethodsTrait >> selectedMethodNames [

	^self methodListPresenter selections collect:[:methodService | methodService selector]

]

{ #category : 'selecting' }
JadeiteMethodsTrait >> selectedMethods [

	^self methodListPresenter selectedItems
]

{ #category : 'compiler warning' }
JadeiteMethodsTrait >> setCompileWarningColor [

	self statusBarText withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget |
			widget adoptPaneColor: Color yellow ] ]
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateMethodSourceGlyphs [

	self methodSourcePresenter removeAllTextSegmentDecorations.
	self displayMethodSourceStepPoints.
	self displayBreakpoints
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateService: service [

	self updateService: service onCompletion: [ ]
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateService: service onCompletion: completionBlock [

	service
		command: #update;
		commandArgs: Array new.
	^ RowanServiceUpdater current
		  issueCommand: service
		  session: self gciSession
		  onCompletion: completionBlock
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateServices: services [

	self updateServices: services onCompletion: []
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateServices: services onCompletion: completionBlock [

	| answeringService |
	services isEmpty ifTrue: [ ^ self ].
	self preUpdate: services.
	answeringService := RowanAnsweringService new
		                    command: #updateServices:;
		                    commandArgs: (Array with: services).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: completionBlock
]
