Trait {
	#name : 'JadeiteMethodsTrait',
	#category : 'Jadeite-Traits'
}

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseImplementorsDialogItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Implementors of ...';
			action: [ self browseImplementorsOf ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseImplementorsItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Implementors';
			action: [ self browseImplementors ];
			enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseLiteralReferencesTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Literal References ...';
			  action: [ self browseLiteralReferences ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseMethodsContainingTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Method Containing ...';
			action: [ self browseMethodsContaining ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseSendersDialogItemTo: group [

	^ group addItem: [ :item |
		  item
			  name: 'Browse Senders Of ...';
			  action: [ self browseSendersOf ] ]
]

{ #category : 'menus' }
JadeiteMethodsTrait >> addBrowseSendersItemTo: group [

	group addItem: [ :item |
		item
			name: 'Browse Senders';
			action: [ self browseSenders ];
			enabled: [ self methodListPresenter selections size = 1 ] ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> basicSendersOf: string [

	| service shell |
	service := RowanQueryService
		           command: #sendersOf:
		           withArgs: (Array with: string asSymbol).
	self issueCommands: (Array with: service) onCompletion: [ :unused |
		shell := self openMethodListOn: service selecting: string.
		shell updateCaptionFromSearchString:
			service answer size printString , ' Senders of '
			, string asString printString ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseImplementors [

	^ self browseImplementorsOf: self selectedMethodName
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseImplementorsOf [

	| wildcardString listWindowTitle |
	wildcardString := UIManager default
		                  request: 'Enter wildcard string:'
		                  initialAnswer: String new.
	wildcardString ifNil: [ ^ self ].
	listWindowTitle := 'Jadeite Browse Implementors'.
	self
		selectSymbolFrom: wildcardString
		titled: listWindowTitle
		browseAction: #implementorsOfAll:
		onCompletion: [ :string |
		string ifNotNil: [ self browseImplementorsOf: string ] ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseImplementorsOf: string [

	| service shell |
	string size > self maxSymbolSize ifTrue: [
		^ MessageBox notify:
			  'String exceeds max symbol size - '
			  , self maxSymbolSize printString , ' characters' ].

	service := RowanQueryService
		           command: #implementorsOf:
		           withArgs: (Array with: string asSymbol).
	RowanServiceUpdater current
		issueCommands: (Array with: service)
		session: self gciSession
		onCompletion: [ :unused |
	shell := self openMethodListOn: service selecting: string.
	shell updateCaptionFromSearchString:
		service answer size printString , ' Implementors of '
		, string asString printString]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseLiteralReferences [

	^ self
		  browseLiteralReferences: self gciSession
		  initialSuggestion: String new
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseLiteralReferences: string [

	| service shell |
	(string isNil or: [ string isEmpty ]) ifTrue: [ ^ nil ].
	service := RowanQueryService
		           command: #literalReferences:
		           withArgs: (Array with: string).
	RowanServiceUpdater current
		issueCommands: (Array with: service)
		session: self gciSession
		onCompletion: nil.
	shell := self openMethodListOn: service selecting: string.
	shell updateCaptionFromSearchString:
		'Literal References To ' , string asString printString.
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseLiteralReferences: session initialSuggestion: initialString [

	| string |
	string := UIManager default
		          request: 'Enter code to be compiled.
Example: To search for literal string add single quotes'
		          initialAnswer: String new.
	^ Cursor wait showWhile: [ 
		  [ self browseLiteralReferences: string ]
			  on: GsCompileError
			  do: [ :ex | 
				  MessageBox notify: 'Error compiling expression: ' , string.
				  ^ self browseLiteralReferences: string ] ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseMethodClass [

	| classService className |
	classService := RowanClassService new name:
		                self methodListPresenter jadeiteSelections first.
	classService meta:
		self methodListPresenter jadeiteSelections first meta.
	RowanServiceUpdater current
		updateService: classService
		session: self gciSession.
	className := self methodListPresenter jadeiteSelections first
		             className.
	^ Cursor wait showWhile: [
		  self openBrowser findClassNamed: className ]
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
		issueCommands: (Array with: service)
		session: self gciSession
		onCompletion: nil.
	shell := self openMethodListOn: service selecting: string.
	shell updateCaptionFromSearchString:
		'Methods Containing ' , string asString printString.
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSelectedMethods [

	"convenience menu item to display randomly grouped methods in a browser"

	| shell |
	shell := (JadeiteMethodListApplication showOnSession:
		          self gciSession library) methods:
		         self methodListPresenter selectedItems selecting: nil.
	shell updateCaptionFromSearchString: 'Selected Methods'.
	^ shell
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSenders [
 
	self browseSendersOf: self selectedMethodName
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSendersOf [

	| wildcardString listWindowTitle |
	wildcardString := UIManager default
		                  request: 'Enter wildcard string:'
		                  initialAnswer: String new.
	wildcardString ifNil: [ ^ self ].
	listWindowTitle := 'Jadeite Browse Senders'.
	self
		selectSymbolFrom: wildcardString
		titled: listWindowTitle
		browseAction: #sendersOfAll:
		onCompletion: [ :string |
		string ifNotNil: [ self browseSendersOf: string ] ]
]

{ #category : 'queries' }
JadeiteMethodsTrait >> browseSendersOf: string [
	string size > self maxSymbolSize
		ifTrue: 
			[^MessageBox
				notify: 'String exceeds max symbol size - ' , self maxSymbolSize printString , ' characters'].
	self basicSendersOf: string
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

{ #category : 'as yet unclassified' }
JadeiteMethodsTrait >> displayBreakpoints [
	
	self methodListPresenter selectedItem breakPoints do: [ :breakPoint |
		| range stepPointAssoc |
		stepPointAssoc := self methodListPresenter selectedItem stepPoints at: breakPoint. 
		range := self methodListPresenter selectedItem stepPointRangeFrom:
			         stepPointAssoc.
		self methodSourcePresenter addTextSegmentDecoration:
			((SpTextPresenterDecorator new highlightColor: Color lightCyan)
				 interval: range) ]
]

{ #category : 'as yet unclassified' }
JadeiteMethodsTrait >> displayMethodSourceStepPoints [

	self methodListPresenter selectedItem stepPoints do: [ :stepPointAssoc |
		| range |
		range := self methodListPresenter selectedItem stepPointRangeFrom:
			         stepPointAssoc.
		self methodSourcePresenter addTextSegmentDecoration:
			((SpTextPresenterDecorator new underlineColor: Color veryLightGray)
				 interval: range) ]
]

{ #category : 'actions' }
JadeiteMethodsTrait >> editSaveMethod: classService in: thePresenter category: category [

	(thePresenter saveMethodIn: classService category: category) 
		ifFalse: [ ^ false ].
	(self compilationWarningFrom: classService selectedMethods)
		ifNil: [ self resetStatusBar ]
		ifNotNil: [ :warning |
			self setCompileWarningColor.
			self statusBarText pushMessage: warning ].
	self todo: [ self refreshBreakPointsIn: thePresenter ].
	^true
]

{ #category : 'menus' }
JadeiteMethodsTrait >> fullMethodListMenu [

	| menu |
	menu := self newBrowseMethodListMenu.

	menu addItem: [ :item |
		item
			name: 'Remove Method(s) ...';
			action: [ self removeMethods ] ].
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

	^ self issueCommands: (Array with: service) onCompletion: completionBlock
]

{ #category : 'commands' }
JadeiteMethodsTrait >> issueCommands: services onCompletion: completionBlock [
	RowanServiceUpdater current
		issueCommands: services
		session: self gciSession
		onCompletion: completionBlock
]

{ #category : 'constants' }
JadeiteMethodsTrait >> maxSymbolSize [

	^1024
]

{ #category : 'menus' }
JadeiteMethodsTrait >> newBrowseMethodListMenu [

	^ SpMenuPresenter new
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Browse Class';
						  action: [ self browseMethodClass ];
						  enabled: [ self methodListPresenter selections size = 1 ] ].
			  group addItem: [ :item1 |
				  item1
					  name: 'Browse Implementors';
					  action: [ self browseImplementors ];
					  enabled: [ self methodListPresenter selections size = 1 ] ].
			  self addBrowseImplementorsDialogItemTo: group.
			  group addItem: [ :item2 |
				  item2
					  name: 'Browse Senders';
					  action: [ self browseSenders ];
					  enabled: [ self methodListPresenter selections size = 1 ] ].
			  self addBrowseSendersDialogItemTo: group ];
		  addGroup: [ :group |
			  group addItem: [ :item |
				  self addBrowseMethodsContainingTo: group.
				  self addBrowseLiteralReferencesTo: group.
				  item
					  name: 'Browse Selected Methods';
					  action: [ self browseSelectedMethods ];
					  enabled: [ self methodListPresenter selections notEmpty ] ] ];
		  yourself
]

{ #category : 'menus' }
JadeiteMethodsTrait >> newBrowseMethodsConsoleMenu [

	^ SpMenuPresenter new
		  addGroup: [ :group |
			  self addBrowseImplementorsDialogItemTo: group.
			  self addBrowseSendersDialogItemTo: group.
			  self addBrowseMethodsContainingTo: group.
			  self addBrowseLiteralReferencesTo: group ];
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

	self methodSourcePresenter hasUnacceptedEdits ifTrue: [
		(MessageBox confirm:
			 'You have unsaved changes. Discard changes and continue?')
			ifTrue: [
				self methodSourcePresenter hasUnacceptedEdits: false.
				^ true ]
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'queries' }
JadeiteMethodsTrait >> openMethodListOn: service selecting: string [
	| selectionString |
	selectionString := (ReadStream on: string) upTo: $:.
	^JadeiteMethodListBrowser
		openOn: service
		selecting: selectionString
		session: self gciSession
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
JadeiteMethodsTrait >> reformatSourceInPresenter: presenter methodService: methodService [

	methodService
		source: presenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[ self issueCommand: methodService onCompletion: nil ]
		on: Error
		do: [ :ex |
			self setCompileErrorColor.
			self statusBarText:
				'Reformat failed. Illegal source - ' , ex description.
			^ false ].
	presenter view performUndoableAction: [
		presenter view modifyText: [
			presenter view sciSetText: methodService source ] ].
	presenter value: methodService source.
	presenter view isModified: true.
	self setStatusBarDefault.
	self statusBarText: String new.
	^ presenter value
]

{ #category : 'actions' }
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
	self issueCommand: selectedClass onCompletion: nil
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

{ #category : 'queries' }
JadeiteMethodsTrait >> selectSymbolFrom: wildcardString titled: listWindowTitle browseAction: browseAction onCompletion: completionBlock [

	| dialogWindow answeringService possibleSelectors |
	answeringService := RowanAnsweringService new
		                    command: #lowercaseSelectorsMatching:;
		                    commandArgs: (Array with: wildcardString).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [ :service |
			possibleSelectors := service answer.
			possibleSelectors isEmpty
				ifTrue: [
					| message |
					message := self noMatchesFoundMessageFor: wildcardString.
					UIManager inform: message ]
				ifFalse: [
					possibleSelectors size = 1
						ifTrue: [ completionBlock value: possibleSelectors first ]
						ifFalse: [
							dialogWindow := ListDialogWindow new
								                getList: [ :rxMatcher |
									                possibleSelectors select: [ :substring |
											                rxMatcher isString
												                ifTrue: [
													                rxMatcher , '*' match: substring ]
												                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
													                rxMatcher matchesPrefix: substring ] ] ];
								                displayBlock: [ :e | e ];
								                browseBlock: [ :arg |
									                | queryService |
									                queryService := RowanQueryService new
										                                perform: browseAction
										                                with: possibleSelectors.
									                JadeiteMethodListBrowser
										                openOn: queryService
										                selecting: wildcardString
										                session: self gciSession ];
								                doubleClickOk;
								                title: listWindowTitle;
								                yourself.
							completionBlock value:
								(dialogWindow chooseFromOwner: self currentWorld) ] ] ]
]

{ #category : 'selections' }
JadeiteMethodsTrait >> selectedMethodName [

	^self methodListPresenter jadeiteSelections first selector

]

{ #category : 'selections' }
JadeiteMethodsTrait >> selectedMethodNames [

	^self methodListPresenter selections collect:[:methodService | methodService selector]

]

{ #category : 'actions' }
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
	^self updateService: service onCompletion: nil
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateService: service onCompletion: completionBlock [
	^self updateServices: (Array with: service) onCompletion: completionBlock
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateServices: services [

	^self updateServices: services onCompletion: nil
]

{ #category : 'updates' }
JadeiteMethodsTrait >> updateServices: services onCompletion: completionBlock [

	services isEmpty ifTrue: [ ^ self ].
	services do: [ :service |
		service
			command: #update;
			commandArgs: #(  ) ].
	RowanServiceUpdater current
		issueCommands: services
		session: self gciSession
		onCompletion: completionBlock
]
