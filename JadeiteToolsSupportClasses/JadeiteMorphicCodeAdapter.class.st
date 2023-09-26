Class {
	#name : 'JadeiteMorphicCodeAdapter',
	#superclass : 'SpMorphicCodeAdapter',
	#instVars : [
		'completionEngine'
	],
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'factory' }
JadeiteMorphicCodeAdapter >> buildWidget [

	| tmp1 tmp2 tmp3 tmp5 |
	tmp5 := JadeiteScrolledTextMorph on: self.
	tmp5
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		ghostText: self placeholder;
		beWrapped;
		askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		autoAccept: false;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		setBalloonText: self help;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		registerScrollChanges: #scrollValueChanged:;
		hScrollbarShowWhenNeeded.
	tmp1 := tmp5 yourself.
	self
		setEnabled: self presenter isEnabled to: tmp1;
		setEditable: self presenter isEditable to: tmp1;
		setEditingModeFor: tmp1.
	tmp1 textArea newJadeiteEditor.
	tmp1 textArea shoutStyler styler:
		(JadeiteCodeTextStyler newWithAttributeTableNamed:
			 self presenter syntaxHighlightTheme).
	self setText: self presenter text to: tmp1.
	(tmp2 := self presenter selectionInterval) ifNotNil: [
		self selectionInterval: tmp2 on: tmp1 ].
	self presenter hasLineNumbers ifTrue: [ tmp1 withLineNumbers ].
	(tmp3 := self presenter interactionModel) ifNotNil: [
		self setInteractionModel: tmp3 to: tmp1 ].
	self presenter
		whenLineNumbersChangedDo: [ :arg1 |
			self changeLineNumbers: arg1 to: tmp1 ];
		whenSyntaxHighlightChangedDo: [ :arg2 |
			self setEditingModeFor: tmp1 ];
		whenSmartCharactersChangedDo: [ :arg3 |
			self setSmartCharactersFor: tmp1 ].
	self presenter syntaxHighlightTheme ifNotNil: [
		self setSyntaxHighlightThemeFor: tmp1 ].
	self presenter whenSyntaxHighlightThemeChangedDo: [ :arg4 |
		self setSyntaxHighlightThemeFor: tmp1 ].
	self
		setWrapWord: self presenter isWrapWord to: tmp1;
		setUndoRedo: self presenter hasUndoRedoHistory to: tmp1.
	self presenter
		whenTextChangedDo: [ :arg5 | self setText: arg5 to: tmp1 ];
		whenSelectionChangedDo: [ :arg6 | self selectionInterval: arg6 ];
		whenPlaceholderChangedDo: [ :arg7 |
			self setGhostText: arg7 to: tmp1 ];
		whenEditableChangedDo: [ :arg8 | self setEditable: arg8 to: tmp1 ];
		whenWrapWordChangedDo: [ :arg9 | self setWrapWord: arg9 to: tmp1 ].
	^ tmp1
]

{ #category : 'private' }
JadeiteMorphicCodeAdapter >> newCompletionEngine: anInteractionModel [

	^ completionEngine ifNil: [
		  completionEngine := JadeiteCompletionEngine new
			                      smartCharacters:
				                      self presenter hasSmartCharacters;
			                      scripting: anInteractionModel isScripting;
			                      doItRequestor: anInteractionModel;
			                      doItContext: anInteractionModel doItContext;
			                      completionClass:
				                      anInteractionModel selectedClassOrMetaClass;
			                      yourself ]
]

{ #category : 'private' }
JadeiteMorphicCodeAdapter >> setSyntaxHighlightThemeFor: textArea [
	| theme |
	
	theme := self presenter syntaxHighlightTheme.
	theme ifNil: [ ^ self ].

	textArea shoutStyler 
		styler: (JadeiteCodeTextStyler newWithAttributeTableNamed: theme);
		refreshStyling
]
