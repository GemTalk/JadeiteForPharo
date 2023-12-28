"
model - the context in which code can be executed
"
Class {
	#name : 'CodeSourcePresenter',
	#superclass : 'JadePresenterA',
	#instVars : [
		'documentPresenter',
		'menuTitle',
		'environment'
	],
	#classVars : [
		'CodeFont'
	],
	#category : 'Jadeite-PortedClasses'
}

{ #category : 'public' }
CodeSourcePresenter class >> codeFont [

	^CodeFont.

]

{ #category : 'public' }
CodeSourcePresenter class >> codeFont: aFont [

	CodeFont := aFont.
	self withAllSubclassesDo: [:eachClass | 
		eachClass allInstances do: [:each | 
			each codeFont: aFont.
		].
	].
	JadeiteTextDocument withAllSubclassesDo: [:eachClass | 
		eachClass allInstances do: [:each | 
			each updateCodeFont.
		].
	].

]

{ #category : 'menus' }
CodeSourcePresenter >> addMenu [

	| menuBar |
	menuBar := self view topShell view menuBar.
	self updateMenuBar: menuBar.
	self view topShell view menuBar: menuBar.

]

{ #category : 'menus' }
CodeSourcePresenter >> addMenuTo: aMenuBar [

	self updateMenuBar: aMenuBar.

]

{ #category : 'edit' }
CodeSourcePresenter >> addQuotesToSelection [

	documentPresenter view replaceSelection: documentPresenter selection printString.

]

{ #category : 'public' }
CodeSourcePresenter >> browseImplementors [
	^self browseImplementorsOf: self currentSelection
]

{ #category : 'public' }
CodeSourcePresenter >> browseSenders [
	^self browseSendersOf: self currentSelection
]

{ #category : 'Breakpoints' }
CodeSourcePresenter >> clearBreakAtStepPoint: anInteger [

	| method |
	(method := self trigger: #'needMethod') isNil ifTrue: [^self].
	method clearBreakAtStepPoint: anInteger session: gciSession.

]

{ #category : 'public' }
CodeSourcePresenter >> clearSelection [
	^self editDelete
]

{ #category : 'public' }
CodeSourcePresenter >> codeFont: aFont [

	documentPresenter view font: aFont.

]

{ #category : 'public' }
CodeSourcePresenter >> codePresenterIsMethod [

	^false
]

{ #category : 'edit' }
CodeSourcePresenter >> copySelection [

	documentPresenter view
		copySelection;
		updateModel;
		yourself.

]

{ #category : 'Jade' }
CodeSourcePresenter >> createSchematicWiring [
	super createSchematicWiring.
	documentPresenter
		when: #aboutToDisplayMenu:
			send: #methodMenu:
			to: self;
		when: #leftButtonDoubleClicked:
			send: #methodDoubleClicked:
			to: self
]

{ #category : 'Jade' }
CodeSourcePresenter >> currentSelectionOrLine [

	| range |
	documentPresenter hasSelection ifFalse: [documentPresenter view selectCurrentLine].
	range := documentPresenter view selectionRange.
	^(documentPresenter value copyFrom: range start to: range stop) replaceCrLfWithLf.

]

{ #category : 'public' }
CodeSourcePresenter >> cutSelection [
	^self editCut
]

{ #category : 'public' }
CodeSourcePresenter >> documentPresenter [

	^documentPresenter
]

{ #category : 'edit' }
CodeSourcePresenter >> editCut [

	documentPresenter view
		cutSelection;
		updateModel;
		yourself.

]

{ #category : 'edit' }
CodeSourcePresenter >> editDelete [
	self selectLfIfEndingOnCr.
	documentPresenter view
		clearSelection;
		updateModel;
		yourself.

]

{ #category : 'edit' }
CodeSourcePresenter >> editFind [
	documentPresenter view editFind.
	self showSelection.

]

{ #category : 'edit' }
CodeSourcePresenter >> editFindNext [

	documentPresenter view findNext.
	self showSelection.


]

{ #category : 'edit' }
CodeSourcePresenter >> editPaste [

	documentPresenter view
		pasteClipboard;
		updateModel;
		yourself.

]

{ #category : 'edit' }
CodeSourcePresenter >> editReplace [

	documentPresenter view
		findReplace;
		updateModel;
		yourself.

]

{ #category : 'edit' }
CodeSourcePresenter >> editRevert [
	self isOkayToChange ifTrue: [self parentPresenter editRevert]
]

{ #category : 'edit' }
CodeSourcePresenter >> editSelectAll [

	documentPresenter view selectAll.

]

{ #category : 'public' }
CodeSourcePresenter >> environment: anInteger [

	environment := anInteger.

]

{ #category : 'private' }
CodeSourcePresenter >> fileSave [
		"Private - Answer whether the save succeeded (false means to stay on the window and cancel any attempt to leave)"

	^parentPresenter fileSave
]

{ #category : 'public' }
CodeSourcePresenter >> findClassList [
"
	Array with: className with: dictionaryName with: catetory with: packageName.
"
	| string list |
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: '0 findClass'.
	list := (string subStrings: Character lf) collect: [:each | each subStrings: Character tab].
	list := list copyFrom: 2 to: list size.
	list := list collect: [:each | each size < 3 ifTrue: [each , #('' '' '')] ifFalse: [each]].
	list := list collect: [:each | (each at: 1) -> each].
	^list

]

{ #category : 'public' }
CodeSourcePresenter >> handleInvalidSession [

	documentPresenter view isModified ifFalse: [^false].
	self ensureVisible.
	documentPresenter ensureVisible.
	documentPresenter view isModified: false.
	(MessageBox confirm: 'Copy unsaved method to clipboard?' caption: 'Invalid Session!') ifTrue: [
		documentPresenter view selectAll; copySelection.
	].
	^true

]

{ #category : 'public' }
CodeSourcePresenter >> initialize [

	super initialize.
	environment := 0.

]

{ #category : 'public' }
CodeSourcePresenter >> isClassSelectedInEditor [

	| range string |
	(range := documentPresenter view selectionRange) isEmpty ifTrue: [^false].
	string := documentPresenter value copyFrom: range start to: range stop.
	^(string allSatisfy: [:each | each isAlphaNumeric]) and: [string first isLetter and: [string first isUppercase]]

]

{ #category : 'public' }
CodeSourcePresenter >> isModified [

	^documentPresenter isModified
]

{ #category : 'public' }
CodeSourcePresenter >> isOkayToChange [
	documentPresenter view isModified
		ifTrue: [(JadePresenter unsavedChangesDialogIn: documentPresenter) ifTrue: [^false]].
	documentPresenter view isModified: false.
	^true
]

{ #category : 'Jade' }
CodeSourcePresenter >> jadeDisplay [
	self jadeExecuteAndDisplay: true shouldDebug: false
]

{ #category : 'Jade' }
CodeSourcePresenter >> jadeExecute [
	self jadeExecuteAndDisplay: false shouldDebug: false
]

{ #category : 'Jade' }
CodeSourcePresenter >> jadeExecuteAndDisplay: showResult shouldDebug: shouldDebug [

	| result |
	result := self
		          executeSelectionOrLine: self parentPresenter contextObject
		          shouldDebug: shouldDebug
		          onCompileError: [ ^ self ]
		          showResult: showResult.
	result ifNil: [ ^ self ].
	result key
		ifTrue: [
			showResult
				ifTrue: [ self showResult: result value ]
				ifFalse: [ self setCaretToEndOfSelection ].
			^ result value ]
		ifFalse: [
			self showCompileError: result value first.
			^ self "flag for compile error" ]
]

{ #category : 'menus' }
CodeSourcePresenter >> menuTitle: aString [

	menuTitle := aString.

]

{ #category : 'Jade' }
CodeSourcePresenter >> methodDoubleClicked: anObject [

	| range string |
	range := documentPresenter view selectionRange.
	string := documentPresenter value.
	string size = range stop ifTrue: [^self].
	(string at: range stop + 1) = $: ifFalse: [^self].
	range stop: range stop + 1.
	documentPresenter view selectionRange: range.

]

{ #category : 'menus' }
CodeSourcePresenter >> methodMenu: aMenu [
	self methodMenuBreak: aMenu
]

{ #category : 'private' }
CodeSourcePresenter >> mySave [

]

{ #category : 'public' }
CodeSourcePresenter >> pasteClipboard [
	^self editPaste
]

{ #category : 'public' }
CodeSourcePresenter >> queryCommand: query [
	(#(#fileSave #editSaveMethod) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: documentPresenter view isModified.
			^true].
	(#(#cutSelection #copySelection) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: documentPresenter hasSelection.
			^true].
	query commandSymbol = #pasteClipboard
		ifTrue: 
			[query isEnabled: documentPresenter view canPaste.
			^true].
	query commandSymbol == #browseSelectedClass
		ifTrue: 
			[query isEnabled: self isClassSelectedInEditor.
			^true].
	(#(#undo #editRevert) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: ((View focus isKindOf: TextEdit) and: [View focus canUndo]). 
			^true].
	(#(#redo) includes: query commandSymbol)
		ifTrue: 
			[ query isEnabled: ((View focus isKindOf: TextEdit) and: [ View focus canRedo]).
			^true].
	^super queryCommand: query
]

{ #category : 'edit' }
CodeSourcePresenter >> redo [
	documentPresenter view redo
]

{ #category : 'menus' }
CodeSourcePresenter >> removeMenu [

	| menuBar item |
	(menuBar := self view topShell view menuBar) isNil ifTrue: [^self].
	item := menuBar items 
		detect: [:each | each text = self subMenuName]
		ifNone: [^self].
	menuBar removeItem: item.
	self view topShell view menuBar: menuBar.

]

{ #category : 'edit' }
CodeSourcePresenter >> removeQuotesFromSelection [

	| string |
	string := documentPresenter view selection trimBlanks.
	(string size >= 2 and: [string first = $' and: [string last = $']]) ifFalse: [
		^MessageBox notify: 'Selection must begin and end with quote'.
	].
	string := string copyFrom: 2 to: string size - 1.
	string := string 
		copyReplaceAll: ''''''
		with: ''''.
	documentPresenter view replaceSelection: string.

]

{ #category : 'public' }
CodeSourcePresenter >> selectAll [
	^self editSelectAll
]

{ #category : 'edit' }
CodeSourcePresenter >> selectLfIfEndingOnCr [
	"deleting a CR without the subsequent LF can leave things somewhat confused"

	| text selectionRange |
	selectionRange := documentPresenter view selectionRange.
	text := documentPresenter view "hide; show;" value.			"somehow the value gets out of synch"
	selectionRange stop < selectionRange start 			ifFalse: [^self ].
	selectionRange start < documentPresenter view value size 	ifFalse: [^self ].
	(text at: selectionRange start) = Character cr 			ifFalse: [^self ].
	(text at: selectionRange start + 1) = Character lf 		ifFalse: [^self ].
	documentPresenter view selectionRange: (selectionRange start to: selectionRange start + 1).

]

{ #category : 'public' }
CodeSourcePresenter >> selectedClassName [
	"assume the selection is the class name" 
	^documentPresenter selection
	
]

{ #category : 'public' }
CodeSourcePresenter >> selection [
	^documentPresenter selection
	
]

{ #category : 'public' }
CodeSourcePresenter >> selectionChanging: aSelectionChangingEvent [ 

	(documentPresenter view isKindOf: DeafObject) ifTrue: [^self].
	documentPresenter view isModified ifFalse: [^self].
	documentPresenter view ensureVisible.
	MessageBox 
		confirm: 'Save changes?' 
		onYes: 			[aSelectionChangingEvent value: self fileSave] 
		onNo: 			[documentPresenter view isModified: false] 
		onCancel: 	[aSelectionChangingEvent value: false].

]

{ #category : 'Breakpoints' }
CodeSourcePresenter >> setBreakAtStepPoint: anInteger [

	| method |
	(method := self trigger: #'needMethod') isNil ifTrue: [^self].
	method setBreakAtStepPoint: anInteger.
	self trigger: #'breaksChanged'.

]

{ #category : 'public' }
CodeSourcePresenter >> setBreakAtStepPoint: anInteger session: aGciSession [

	| method |
	(method := self trigger: #'needMethod') isNil ifTrue: [^self].
	method setBreakAtStepPoint: anInteger session: gciSession.
	self trigger: #'breaksChanged'.

]

{ #category : 'Jade' }
CodeSourcePresenter >> setCaretToEndOfSelection [

	| textView |
	textView := documentPresenter view.
	textView caretPosition: textView selectionRange stop + 1.

]

{ #category : 'public' }
CodeSourcePresenter >> setDocumentPresenterWith: aJadeGsClassShape [
	documentPresenter lastGsShape: aJadeGsClassShape
]

{ #category : 'private' }
CodeSourcePresenter >> setFont [

	| font |
	font := CodeFont notNil
		ifTrue: [FontDialog showModalOn: CodeFont]
		ifFalse: [FontDialog showModal].
	font notNil ifTrue: [
		self class codeFont: font.
	]

]

{ #category : 'Jade' }
CodeSourcePresenter >> showCompileError: anArray [

	| result string count textView selectionRange offset |
	textView := documentPresenter view.
	offset := anArray at: 2.
	result := anArray at: 3.
	selectionRange := textView selectionRange.
	string := textView value.
	string := string copyFrom: selectionRange start to: selectionRange stop.
	string := string replaceCrLfWithLf copyFrom: 1 to: offset - 1.
	count := (string select: [:each | each = Character lf]) size.
	offset := offset + count.
	textView
		caretPosition: selectionRange start + offset - 1;
		replaceSelection: result;
		selectionStart: textView caretPosition - result size length: result size.

]

{ #category : 'edit' }
CodeSourcePresenter >> showSelection [

	| range lineNumber |
	(range := documentPresenter view selectionRange) isEmpty ifTrue: [^self].
	lineNumber := documentPresenter view lineFromPosition: range first.
	lineNumber := lineNumber - 4 max: 1.
	documentPresenter view lineScroll: lineNumber.

]

{ #category : 'menus' }
CodeSourcePresenter >> subMenuName [

	^menuTitle.

]

{ #category : 'menus' }
CodeSourcePresenter >> subMenuPresenter [

	^documentPresenter.

]

{ #category : 'public' }
CodeSourcePresenter >> textStyles [

	^documentPresenter view editStyles textStyles
]

{ #category : 'edit' }
CodeSourcePresenter >> undo [

	documentPresenter view undo
]

{ #category : 'public' }
CodeSourcePresenter >> update [

	self subclassResponsibility.

]

{ #category : 'public' }
CodeSourcePresenter >> updateCodeFont [

	CodeFont notNil ifTrue: [
		documentPresenter view font: CodeFont.
	].

]
