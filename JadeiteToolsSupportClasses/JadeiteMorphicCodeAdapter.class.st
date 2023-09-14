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
	| newWidget |
	
	newWidget := (SpRubScrolledTextMorph on: self)
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		ghostText: self placeholder;
		beWrapped;
		askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		autoAccept: false; "<<<<<<Jadeite change here"
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
	newWidget textArea newJadeiteEditor. "<<<<<<Jadeite addition here"
	self setText: self presenter text to: newWidget.
	self presenter selectionInterval 
		ifNotNil: [  :anInterval | self selectionInterval: anInterval on: newWidget ].

	self setWrapWord: self presenter isWrapWord to: newWidget.	
	self setUndoRedo: self presenter hasUndoRedoHistory to: newWidget. 
	self presenter whenTextChangedDo: [ :text | 
		self setText: text to: newWidget ].
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
