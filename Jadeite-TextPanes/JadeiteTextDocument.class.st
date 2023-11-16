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
	#category : 'Jadeite-TextPanes'
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
	group register: (SpCodeDoItCommand forSpecContext: presenter). 
	group register: (JadeiteCodeInspectItCommand forSpecContext: presenter).  
	group register: (SpCodePrintItCommand forSpecContext: presenter).
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
	| openFilename |
	openFilename := filename.
	openFilename isNil ifTrue: [^nil].
	^(self showOnSession: aGciSession)
		openOn: openFilename;
		yourself
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
	^self executeSelectionOrLine: self contextObject shouldDebug: false  onCompileError: [^self]
]

{ #category : 'accessing' }
JadeiteTextDocument >> executeSelectionOrLine: aString shouldDebug: shouldDebug onCompileError: compileErrorBlock [

	| answeringService answer oop |
	oop := context ifNil: [ 20 ].
	answeringService := RowanAnsweringServiceClient new registerWith:
		                    gciSession library.
	answeringService
		command: #execReturningPrintString:context:shouldDebug:;
		commandArgs: (Array with: aString with: oop with: shouldDebug).
	self issueCommand: answeringService.
	answer := answeringService answer.
	answer ifNil: [ ^ nil ].
	answer first ifFalse: [
		self reportCompileError: answer.
		^compileErrorBlock value
		 ]. 
	^ answer last
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

{ #category : 'accessing' }
JadeiteTextDocument >> hasUnacceptedEdits: aBoolean [

	super hasUnacceptedEdits: aBoolean
]

{ #category : 'initialization' }
JadeiteTextDocument >> initialize [

	super initialize.
	environment := 0.
	lastSave := String new.
	self withoutSyntaxHighlight

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
		toolbar: self newJadeiteToolbar
]

{ #category : 'actions' }
JadeiteTextDocument >> insertPrintPopoverAfterCurrentSelection: anObject [
	"Jadeite will return a nil to this method if a compiler error occurred"
	anObject ifNotNil: [ super insertPrintPopoverAfterCurrentSelection: anObject]  
]

{ #category : 'testing' }
JadeiteTextDocument >> isModified [ 
	^self hasUnacceptedEdits 
]

{ #category : 'testing' }
JadeiteTextDocument >> isModified: aBoolean [
	self hasUnacceptedEdits: aBoolean
]

{ #category : 'as yet unclassified' }
JadeiteTextDocument >> issueCommand: service [

	^RowanServiceUpdater current issueCommand: service session: gciSession.
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> jadeDebug [
	"Intercepted by CodeSourcePresenter"
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> jadeDisplay [
	^ self insertPrintPopoverAfterCurrentSelection: (self
			   evaluate: self selectedTextOrLine
			   onCompileError: [ ^ self ]
			   onError: [ :e | e pass ])
]

{ #category : 'menu handlers' }
JadeiteTextDocument >> jadeExecute [

	^ self
		  evaluate: self selectedTextOrLine
		  onCompileError: [ ^ self ]
		  onError: [ :e | e pass ]
]

{ #category : 'Jade' }
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

{ #category : 'private' }
JadeiteTextDocument >> logoutRequested: aValueHolder [
	"Opportunity to save changes."

	aValueHolder value: true.

]

{ #category : 'private' }
JadeiteTextDocument >> maxPrintStringSize [
	^JadePresenter maxPrintStringSize
]

{ #category : 'scripting - widgets' }
JadeiteTextDocument >> newStatusBar [

	^ self instantiate: JadeiteStatusBarPresenter
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

{ #category : 'actions - saving methods' }
JadeiteTextDocument >> reportCompileError: gsArguments [

	| argArray |
	argArray := gsArguments first isArray
		            ifTrue: [ gsArguments first ]
		            ifFalse: [ (gsArguments at: 2) first ].
	self withAdapterDo: [ :theAdapter | 
		theAdapter widgetDo: [ :widget | 
			widget textArea unselect. 
			 widget notify: (argArray at: 3) at: (argArray at: 2) in: self text asString replaceLfWithCr] ].
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

{ #category : 'private' }
JadeiteTextDocument >> showText: aString [

	self setDocumentData: aString.
	self isModified: false.

]

{ #category : 'api' }
JadeiteTextDocument >> text [
	"Answer current text. Currently there's a hidden bug that disconnected 
	the spec widget from the underlying morphic widget. Once found, the 
	`withWidgetDo:` code can be removed."
	self withWidgetDo: [ :w | text := w editor text].
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
	aString isNil ifTrue:[^self]. 
	[self text: aString replaceLfWithCr ] ensure: [ 
	self isModified: false. "I think it's ok to always mark the it not dirty if Jadeite changes the value directly "]
]

{ #category : 'Jade' }
JadeiteTextDocument >> waitForAnswer: answeringService [
	^JadePresenter waitForAnswer: answeringService
]
