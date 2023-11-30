Class {
	#name : 'JadeiteMorphicCodeAdapter',
	#superclass : 'SpMorphicCodeAdapter',
	#instVars : [
		'completionEngine'
	],
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteMorphicCodeAdapter >> addKeyBindingsTo: aMorph [
	"commented code is just to remind me how to override text editor character key bindings"
	super addKeyBindingsTo: aMorph.
	"self
		bindKeyCombination: Character end toAction: [ aMorph textArea editor atEndOfLineInsertAndSelect: String new ];
		bindKeyCombination: Character home toAction: [ aMorph moveCursorToIndex: 0 ]"
]

{ #category : 'factory' }
JadeiteMorphicCodeAdapter >> buildWidget [

	| newWidget |
	newWidget := (JadeiteScrolledTextMorph on: self)
		             getTextSelector: #getText;
		             setTextSelector: #accept:notifying:;
		             getSelectionSelector: #readSelection;
		             menuProvider: self selector: #codePaneMenu:shifted:;
		             setSelectionSelector: #setSelection:;
		             ghostText: self placeholder;
		             beWrapped;
		             askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		             autoAccept: false;  "<<<<<<Jadeite change here"
		            vResizing: #spaceFill;
		             hResizing: #spaceFill;
		             setBalloonText: self help;
		             dragEnabled: self dragEnabled;
		             dropEnabled: self dropEnabled;
		             registerScrollChanges: #scrollValueChanged:;
		             hScrollbarShowWhenNeeded;
		             yourself.
	self setEnabled: self presenter isEnabled to: newWidget.
	self setEditable: self presenter isEditable to: newWidget.
	self setEditingModeFor: newWidget. 
	newWidget textArea newJadeiteEditor. "<<<<<<more Jadeite changes  (not fully implemented)"
	newWidget textArea shoutStyler ifNotNil: [ :shoutStyler | shoutStyler styler:
		(JadeiteCodeTextStyler newWithAttributeTableNamed:
			 self presenter syntaxHighlightTheme)].
	self setText: self presenter text to: newWidget.
	model hasUnacceptedEdits: false. 
	self presenter selectionInterval ifNotNil: [ :anInterval |
		self selectionInterval: anInterval on: newWidget ].
	self presenter hasLineNumbers ifTrue: [ 
		newWidget withLineNumbers ].
	self presenter interactionModel ifNotNil: [ :im | 
		self setInteractionModel: im to: newWidget ].
	self presenter whenLineNumbersChangedDo: [ :hasLineNumbers | 
		self changeLineNumbers: hasLineNumbers to: newWidget ].
	self presenter whenSyntaxHighlightChangedDo: [ :hasSyntaxHighlight | 
		self setEditingModeFor: newWidget ].
	self presenter whenSmartCharactersChangedDo: [ :hasSmartCharacters | 
		self setSmartCharactersFor: newWidget ].
	
	self presenter syntaxHighlightTheme ifNotNil: [ 
		self setSyntaxHighlightThemeFor: newWidget ].
	self presenter whenSyntaxHighlightThemeChangedDo: [ :value |
		self setSyntaxHighlightThemeFor: newWidget ].
	
	self setWrapWord: self presenter isWrapWord to: newWidget.
	self setUndoRedo: self presenter hasUndoRedoHistory to: newWidget.
	self presenter whenTextChangedDo: [ :text |
		text ifNotNil: [self setText: text to: newWidget]].
	self presenter whenSelectionChangedDo: [ :selectionInterval |
		self selectionInterval: selectionInterval ].
	self presenter whenPlaceholderChangedDo: [ :text |
		self setGhostText: text to: newWidget ].
	self presenter whenEditableChangedDo: [ :value |
		self setEditable: value to: newWidget ].
	self presenter whenWrapWordChangedDo: [ :value |
		self setWrapWord: value to: newWidget ].

	^ newWidget
]

{ #category : 'private' }
JadeiteMorphicCodeAdapter >> newCompletionEngine: anInteractionModel [
	true ifTrue:[^super newCompletionEngine: anInteractionModel]. 
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
	true ifTrue:[^super setSyntaxHighlightThemeFor: textArea]. 
	theme := self presenter syntaxHighlightTheme.
	theme ifNil: [ ^ self ].

	textArea shoutStyler 
		styler: (JadeiteCodeTextStyler newWithAttributeTableNamed: theme);
		refreshStyling
]
