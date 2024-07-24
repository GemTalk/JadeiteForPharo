"
This class probably should not have any subclasses except Workspace (and Transcript). The CodeBrowser subclasses should be elsewhere since we don't want to treat the code as an external text file that can be loaded and saved. 
"
Class {
	#name : 'JadeiteTextDocument',
	#superclass : 'TextDocument',
	#traits : 'JadeiteMethodsTrait + JadeiteToolbarTrait',
	#classTraits : 'JadeiteMethodsTrait classTrait + JadeiteToolbarTrait classTrait',
	#instVars : [
		'gciSession',
		'codePane',
		'lastSave',
		'toolbar',
		'context',
		'saveAction'
	],
	#category : 'Jadeite-TextPanes',
	#package : 'Jadeite-TextPanes'
}

{ #category : 'specs' }
JadeiteTextDocument class >> adapterName [

	^#JadeiteMorphicCodeAdapter
]

{ #category : 'commands' }
JadeiteTextDocument class >> codeNavigationCommandsGroupWith: aPresenter [
	| group |
	"copied from super class implementation"
	group := (CmCommandGroup named: 'Code search') asSpecGroup
		description: 'Search the system from code selection.';
		beDisplayedAsSubMenu;
		yourself.
		
	self flag: #TODO. "This looks like a very bad way to do this :P"	
	{ 
		SpBrowseClassCommand.		
		JadeiteBrowseImplementorsCommand.
		JadeiteBrowseSendersCommand.
		SpBrowseMethodReferencesCommand.	
		SpBrowseMethodsMatchingStringInsensitiveCommand.
		SpBrowseMethodsMatchingStringSensitiveCommand.
		SpBrowseMethodsContainingStringCommand.
	 } 
	do:[ :commandClass | 
		group register: (commandClass forSpecContext: aPresenter) ].
	
	^ group
]

{ #category : 'commands' }
JadeiteTextDocument class >> codeSelectionActionCommandsGroupWith: presenter [
	| group |
	
	group := (CmCommandGroup named: 'Jaded action commands') asSpecGroup.
	group
		description: 'Jaded actions on code selection.';
		beDisplayedAsGroup.
	
	group register: (JadeiteCodeDebugItCommand forSpecContext: presenter). 
	group register: (JadeiteCodeDoItCommand forSpecContext: presenter). 
	group register: (JadeiteCodeInspectItCommand forSpecContext: presenter).  
	group register: (JadeiteCodePrintItCommand forSpecContext: presenter).
	^ group
]

{ #category : 'public' }
JadeiteTextDocument class >> defaultFileExtension [

	^'gs'.

]

{ #category : 'public' }
JadeiteTextDocument class >> fileTypes [

	^Array
		with: #('GemStone Files (*.gs)' '*.gs')
		with: #('Smalltalk Files (*.st)' '*.st')
		with: FileDialog allFilesType.

]

{ #category : 'public' }
JadeiteTextDocument class >> icon [

	^Icon fromFile: 'icons\GS32.ico'.

]

{ #category : 'public' }
JadeiteTextDocument class >> open: filename onSession: aGciSession [
	| openFilename workspace |
	openFilename := filename.
	openFilename isNil ifTrue: [^nil].
	workspace := (self showOnSession: aGciSession).
	workspace text: ((FileSystem disk open: filename writable: false) reference readStream) contents.
	workspace hasUnacceptedEdits: false. 
	^workspace
]

{ #category : 'public' }
JadeiteTextDocument class >> openOnSession: aGciSession [
	| openFilename |
	openFilename := self getFilename.
	openFilename isNil ifTrue: [^nil].
	^(self showOnSession: aGciSession)
		openOn: openFilename;
		yourself
]

{ #category : 'public' }
JadeiteTextDocument class >> shutdownOnExit [

	^false.

]

{ #category : 'accessing' }
JadeiteTextDocument >> _gciSession: session [

	gciSession := session
]

{ #category : 'Jade' }
JadeiteTextDocument >> abortTransaction [
	self parentPresenter abortTransaction
]

{ #category : 'constants' }
JadeiteTextDocument >> aboutJadeite [
	"This method still lives in Rowan UI Base package which has not been ported to Pharo yet"
	
	^'This is Jaded'
	
]

{ #category : 'private' }
JadeiteTextDocument >> activeTextEdit [ 

	^View focus.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> addQuotesToSelection [

	self activeTextEdit replaceSelection: self activeTextEdit selection printString.

]

{ #category : 'accessing' }
JadeiteTextDocument >> additionalAccelerators [

	^#(#(#raiseConsole 'Ctrl+F7') )
]

{ #category : 'accessing' }
JadeiteTextDocument >> codePane [
	^codePane
]

{ #category : 'accessing' }
JadeiteTextDocument >> codePane: anObject [
	codePane := anObject
]

{ #category : 'private' }
JadeiteTextDocument >> codePresenterIsMethod [

	^false
]

{ #category : 'private' }
JadeiteTextDocument >> codeSourcePresenterClass [

	^CodeSourcePresenter

]

{ #category : 'Jade' }
JadeiteTextDocument >> commitTransaction [
	self parentPresenter commitTransaction
]

{ #category : 'initialization' }
JadeiteTextDocument >> connectPresenters [ 

	super connectPresenters. 
	self whenResetDo: [ self isModified: false  ]
]

{ #category : 'accessing' }
JadeiteTextDocument >> context [

	^ context
]

{ #category : 'accessing' }
JadeiteTextDocument >> context: anObject [

	context := anObject
]

{ #category : 'Jade' }
JadeiteTextDocument >> contextObject [
	^gciSession oopNil value
]

{ #category : 'Jade' }
JadeiteTextDocument >> continueTransaction [

	MessageBox notify: 'Sorry, we are not yet prepared to handle this feature!'.
	SessionManager current pause.

]

{ #category : 'accessing' }
JadeiteTextDocument >> defaultColor [
	^ Color purple muchDarker
]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> displayResult: showResult orShowCompileError: theService [
	theService answer ifNil: [ ^self ]. "might have terminated out of an error"
	^ theService answer first
		  ifTrue: [
			  showResult ifTrue: [
				  UIManager default defer: [
					  self insertPrintPopoverAfterCurrentSelection:
						  theService answer last ] ] ]
		  ifFalse: [ self reportCompileError: theService answer ]
]

{ #category : 'commands' }
JadeiteTextDocument >> doBrowseClass [

	MessageBox notify: 'Should implement this'.
	self todo: 'to do'
]

{ #category : 'commands' }
JadeiteTextDocument >> doBrowseImplementors [

	^ self browseImplementorsOf: self selectedSelector 
]

{ #category : 'commands' }
JadeiteTextDocument >> doBrowseMethodReferences [

	^ self browseClassReferences: self selectedSelector 
]

{ #category : 'commands' }
JadeiteTextDocument >> doBrowseMethodsContainingString [
	
	self browseLiteralReferences: self selectedTextOrLine 
]

{ #category : 'commands' }
JadeiteTextDocument >> doBrowseMethodsMatchingStringSensitive [
	
	self browseMethodsContaining: self selectedTextOrLine 
]

{ #category : 'commands' }
JadeiteTextDocument >> doBrowseSenders [

	^ self browseSendersOf: self selectedSelector 
]

{ #category : 'accessing' }
JadeiteTextDocument >> documentPresenter [ 

	^codePane
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editCopy [
	self activeTextEdit  
		copySelection;
		updateModel;
		yourself.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editCut [

	self activeTextEdit 
		cutSelection;
		updateModel;
		yourself.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editDelete [

	self selectLfIfEndingOnCr.
	self activeTextEdit
		clearSelection;
		updateModel;
		yourself.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editFind [
	"sent through key binding Ctrl-F in a debugger"

	self activeTextEdit editFind
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editFindNext [

	self activeTextEdit findNext.
	self showSelection.


]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editPaste [

	self activeTextEdit 
		pasteClipboard;
		updateModel;
		yourself.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editReplace [

	self activeTextEdit 
		findReplace;
		updateModel;
		yourself.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> editSelectAll [

	self activeTextEdit selectAll.

]

{ #category : 'accessing' }
JadeiteTextDocument >> environment: anInteger [

	environment := anInteger.

]

{ #category : 'Jade' }
JadeiteTextDocument >> executeSelectionOrLine [
	"tests only?"
	^ self
		  executeSelectionOrLine: self contextObject
		  shouldDebug: false
		  onCompileError: [ ^ self ]
		  showResult: false
]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> executeSelectionOrLine: aString shouldDebug: shouldDebug onCompileError: compileErrorBlock showResult: showResult [

	| answeringService oop |
	oop := context ifNil: [ 20 ].
	answeringService := RowanAnsweringServiceClient new.
	answeringService
		command: #execReturningPrintString:context:shouldDebug:;
		commandArgs: (Array with: aString with: oop with: shouldDebug).
	RowanServiceUpdater current
		issueCommand: answeringService
		session: GciSession current
		onCompletion: nil.
	answeringService ifNotNil: [
		self displayResult: showResult orShowCompileError: answeringService ]
]

{ #category : 'as yet unclassified' }
JadeiteTextDocument >> fileInChunk [
	| service |
	service := RowanFileService new session: gciSession.
	service fileInChunk: codePane selection
]

{ #category : 'private' }
JadeiteTextDocument >> fileNew [
	^JadeiteWorkspace showOnSession: gciSession.

]

{ #category : 'private' }
JadeiteTextDocument >> fileOpen [
	"Prompts for a file to open into the receiver"

	| openFilename |
	openFilename := self class getFilename.
	openFilename isNil ifTrue: [^self].
	(JadeiteWorkspace showOnSession: gciSession)
		openOn: openFilename;
		yourself.

]

{ #category : 'private' }
JadeiteTextDocument >> gciSession [
	^gciSession
]

{ #category : 'private' }
JadeiteTextDocument >> gciSession: aGciSession [

	gciSession := aGciSession.
	gciSession
		when: #'logoutRequested:'			send: #'logoutRequested:'	to: self;
		when: #'logoutPending'			send: #'exit'			to: self;
		when: #forceJadeiteWindowClose	send: #exit			to: self;
		yourself.

]

{ #category : 'accessing' }
JadeiteTextDocument >> getDocumentData [

	^documentPresenter value ifNil: [''] ifNotNil: [:x | x asString].

]

{ #category : 'TODO' }
JadeiteTextDocument >> hasUnacceptedEdits: anObject [

	self adapter ifNotNil: [ :a | a widget hasUnacceptedEdits: anObject ]
]

{ #category : 'initialization' }
JadeiteTextDocument >> initialize [

	super initialize.
	environment := 0.
	lastSave := String new.
	self withoutSyntaxHighlight

]

{ #category : 'initialization' }
JadeiteTextDocument >> initializeMenubar [

	^ self newMenuBar
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'File';
						  subMenu: self initializeFileMenu ].
			  self addToolbarItemsToMenuGroup: group ];
		  yourself
]

{ #category : 'initialization' }
JadeiteTextDocument >> initializePresenters [

	super initializePresenters. 
	codePane := documentPresenter := self.
	
]

{ #category : 'initialization' }
JadeiteTextDocument >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	self updateCaption.
	aWindowPresenter
		initialExtent: 800 @ 500;
		menu: self initializeMenubar
]

{ #category : 'printing' }
JadeiteTextDocument >> insertPrintPopoverAfterCurrentSelection: anObject [
	"Inserts a print-it result popover. 
	 This is for use of SpCodePrintItCommand"

	self 
		insertPopoverAfterCurrentSelection: (JadeitePopoverPrintPresenter 
			newCode: self
			object: anObject)
		style: 'print'
]

{ #category : 'testing' }
JadeiteTextDocument >> isModified [ 
	^self adapter ifNil: [ false ] ifNotNil: [:a | a widget hasUnacceptedEdits]
]

{ #category : 'testing' }
JadeiteTextDocument >> isModified: aBoolean [
	self hasUnacceptedEdits: aBoolean
]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> jadeDebug [
	"Intercepted by CodeSourcePresenter"
]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> jadeDisplay [

	^ self
		  evaluate: self selectedTextOrLine
		  onCompileError: [ ^ self ]
		  onError: [ :e | e pass ]
		  showResult: true
]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> jadeExecute [
	^ self
		  evaluate: self selectedTextOrLine
		  onCompileError: [ ^ self ]
		  onError: [ :e | e pass ]
		  showResult: false
]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> jadeExecuteAndDisplay: showResult result: anAssociation view: focusViewOrNil [
	| textView result value selectionRange offset |
	anAssociation
		ifNil: 
			[MessageBox notify: 'nil result returned from execution. Terminated process?'.
			^self].
	(result := anAssociation) key isNil
		ifTrue: 
			[MessageBox notify: result value.
			^self].
	textView := focusViewOrNil ifNil: [self activeTextEdit].
	result key
		ifTrue: 
			[value := result value.
			result := ''.
			showResult
				ifTrue: 
					[(gciSession isOopType: value)
						ifFalse: [result := ' ' , value printString]
						ifTrue: [result := String new , (gciSession printString: value)]].
			selectionRange := textView selectionRange.
			result := result.	"replaceLfWithCrLf"
			textView
				caretPosition: selectionRange stop + 1;
				replaceSelection: result;
				selectionStart: textView caretPosition - result size length: result size]
		ifFalse: 
			[| string count |
			(result := result value first) isNil ifTrue: [^self].
			offset := result at: 2.
			result := result at: 3.
			selectionRange := textView selectionRange.
			(string := textView text) size < selectionRange stop
				ifTrue: 
					[self error: 'Selection range is beyond text size!?'.
					string := documentPresenter value].
			string := string copyFrom: selectionRange start to: selectionRange stop.
			string := string replaceCrLfWithLf copyFrom: 1 to: offset - 1.
			count := (string select: [:each | each = Character lf]) size.
			offset := offset + count.
			textView
				caretPosition: selectionRange start + offset - 1;
				replaceSelection: result;
				selectionStart: textView caretPosition - result size length: result size].
	^value
]

{ #category : 'accessing' }
JadeiteTextDocument >> keystrokeAt: click [

	
]

{ #category : 'private' }
JadeiteTextDocument >> logoutRequested: aValueHolder [
	"Opportunity to save changes."

	aValueHolder value: true.

]

{ #category : 'private' }
JadeiteTextDocument >> maxPrintStringSize [
	^JadePresenter maxPrintStringSize
]

{ #category : 'accessing' }
JadeiteTextDocument >> mouseClickedAt: click [

]

{ #category : 'scripting - widgets' }
JadeiteTextDocument >> newStatusBar [

	^ self instantiate: JadeiteStatusBarPresenter
]

{ #category : 'showing' }
JadeiteTextDocument >> open [

	| jadeiteWindow |
	jadeiteWindow := super open.
	JadeiteConnectionProfile connectionProfile ifNotNil: [ :profile |
		profile jadeiteWindows add: jadeiteWindow ].
	^ jadeiteWindow
]

{ #category : 'overrides' }
JadeiteTextDocument >> openOn: openFilename [
	super openOn: openFilename.
	lastSave := self model value
]

{ #category : 'event handlers support' }
JadeiteTextDocument >> positionToDefaultLocation [
	self view position: JadePresenter defaultWindowPosition
]

{ #category : 'private' }
JadeiteTextDocument >> print [
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> removeQuotesFromSelection [

	| string |
	string := self activeTextEdit selection trimBlanks.
	(string size >= 2 and: [string first = $' and: [string last = $']]) ifFalse: [
		^MessageBox notify: 'Selection must begin and end with quote'.
	].
	string := string copyFrom: 2 to: string size - 1.
	string := string 
		copyReplaceAll: ''''''
		with: ''''.
	self activeTextEdit replaceSelection: string.

]

{ #category : 'ad hoc execution' }
JadeiteTextDocument >> reportCompileError: gsArguments [

	| argArray selectionStart |
	selectionStart := self selectedText isEmpty
		                  ifTrue: [ 0 ]
		                  ifFalse: [ self selectionInterval first ].
	argArray := gsArguments first isArray
		            ifTrue: [ gsArguments first ]
		            ifFalse: [ (gsArguments at: 2) first ].
	self withAdapterDo: [ :theAdapter |
		theAdapter widgetDo: [ :widget |
			widget textArea unselect.
			widget
				notify: (argArray at: 3)
				at: (argArray at: 2) + selectionStart
				in: self text asString ] ].
	^ nil
]

{ #category : 'accessing' }
JadeiteTextDocument >> saveAction [

	^ saveAction
]

{ #category : 'accessing' }
JadeiteTextDocument >> saveAction: anObject [

	saveAction := anObject
]

{ #category : 'private' }
JadeiteTextDocument >> saveDocument [
	| result |
	result := super saveDocument.
	result
		ifTrue: 
			[self isModified: false.
			lastSave := self model value].
	^result
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> selectLfIfEndingOnCr [
	"deleting a CR without the subsequent LF can leave things somewhat confused"

	| textEdit text text1 text2 selectionRange |
	textEdit := self activeTextEdit.
	selectionRange := textEdit selectionRange.
	text := textEdit view "hide; show;" value.			"somehow the value gets out of synch"
	selectionRange stop < selectionRange start 				ifFalse: [^self ].
	selectionRange start < textEdit value size 					ifFalse: [^self ].
	(text at: selectionRange start) = Character cr 			ifFalse: [^self ].
	(text at: selectionRange start + 1) = Character lf 		ifFalse: [^self ].
	textEdit selectionRange: (selectionRange start to: selectionRange start + 1).

]

{ #category : 'accessing' }
JadeiteTextDocument >> setDocumentData: aString [
	documentPresenter value: aString.

]

{ #category : 'actions' }
JadeiteTextDocument >> setFocus [

	self todo: 'need to do anything?'
]

{ #category : 'private' }
JadeiteTextDocument >> showError: aList on: aString [

	self setDocumentData: aString.
	aList do: [:each | 
		| offset error |
		offset := (each at: 2).
		error := (each at: 3).
		self activeTextEdit 
			caretPosition: offset;
			replaceSelection: error;
			selectionStart: self activeTextEdit caretPosition - error size length: error size.
	].
	self isModified: false.
	(MessageBox confirm: 'Continue?' caption: 'Compile Error Found') ifTrue: [^self].
	TerminateProcess signal.

]

{ #category : 'menu handlers' }
JadeiteTextDocument >> showSelection [

	| myView range lineNumber |
	myView := self activeTextEdit.
	(range := myView selectionRange) isEmpty ifTrue: [^self].
	lineNumber := myView lineFromPosition: range first.
	lineNumber := lineNumber - 4 max: 1.
	myView lineScroll: lineNumber.

]

{ #category : 'api' }
JadeiteTextDocument >> text [
	"Answer current text. Currently there's a hidden bug that disconnected 
	the spec widget from the underlying morphic widget. Once found, the 
	`withWidgetDo:` code can be removed."

	self todo: 'self adapter ifNotNil: [ :a | text := adapter widget editor text ].' "needed?". 
	^ text
]

{ #category : 'public' }
JadeiteTextDocument >> undo [
	documentPresenter undo
]

{ #category : 'private' }
JadeiteTextDocument >> updateCodeFont [

	codePane updateCodeFont.

]

{ #category : 'private' }
JadeiteTextDocument >> updateStatusBar [

]

{ #category : 'private' }
JadeiteTextDocument >> updateStatusBarItem: aString with: anObject [

	| item |
	item := self view 
		viewNamed: aString
		ifNone: [self error: 'statusBar item ' , aString printString , ' not found'].
	item model: (ValueHolder with: anObject).

]

{ #category : 'accessing' }
JadeiteTextDocument >> value [
	"this may need to be '^self text'"
	^self
]

{ #category : 'accessing' }
JadeiteTextDocument >> value: aString [
	self todo: 'the nil check should not be needed?'. 
	aString ifNil: [^self]. 
	[self text: aString ] ensure: [ 
	self isModified: false. "I think it's ok to always mark the it not dirty if Jadeite changes the value directly "]
]

{ #category : 'Jade' }
JadeiteTextDocument >> waitForAnswer: answeringService [
	^JadePresenter waitForAnswer: answeringService
]
