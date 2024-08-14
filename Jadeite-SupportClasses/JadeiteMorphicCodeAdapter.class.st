Class {
	#name : 'JadeiteMorphicCodeAdapter',
	#superclass : 'SpMorphicCodeAdapter',
	#instVars : [
		'completionEngine'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'initialization' }
JadeiteMorphicCodeAdapter >> addKeyBindingsTo: aMorph [
	"commented code is just to remind me how to override text editor character key bindings"

	super addKeyBindingsTo: aMorph.
	self
		bindKeyCombination: Character end
		toAction: [
		aMorph moveCursorToIndex: aMorph textArea editor endOfLine ].
	self
		bindKeyCombination: Character home
		toAction: [
		aMorph moveCursorToIndex: aMorph textArea editor beginningOfLine ]
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
		             askBeforeDiscardingEdits: false;
		             autoAccept: false;
		             vResizing: #spaceFill;
		             hResizing: #spaceFill;
		             setBalloonText: self help;
		             dragEnabled: self dragEnabled;
		             dropEnabled: self dropEnabled;
		             registerScrollChanges: #scrollValueChanged:;
		             hScrollbarShowWhenNeeded;
		             yourself.
	"<<<<<< Jadeite changes."
	newWidget textArea announcer
		when: RubMouseClick
		send: #mouseClickedAt:
		to: self presenter.
	newWidget textArea announcer
		when: RubKeystroke
		send: #keystrokeAt:
		to: self presenter.
	self setEnabled: self presenter isEnabled to: newWidget.
	self setEditable: self presenter isEditable to: newWidget.
	self setEditingModeFor: newWidget.
	newWidget textArea newJadeiteEditor. "<<<<<<Jadeite change"
	newWidget textArea shoutStyler ifNotNil: [ :shoutStyler |
		shoutStyler styler:
			(JadeiteCodeTextStyler newWithAttributeTableNamed:
				 self presenter syntaxHighlightTheme) ].
	self presenter text ifNotNil: [ :text |
		self setText: text to: newWidget ]. "<<<<<<Jadeite - Can text still be nil?"
	newWidget hasUnacceptedEdits: false. "<<<<<<Jadeite - HOW IS THIS DONE in Pharo 12?"
	self presenter selectionInterval ifNotNil: [ :anInterval |
		self selectionInterval: anInterval on: newWidget ].
	self presenter hasLineNumbers ifTrue: [ newWidget withLineNumbers ].
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
		text ifNotNil: [ self setText: text to: newWidget ] ]. "<<<<<<Jadeite change. text can be nil"
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
