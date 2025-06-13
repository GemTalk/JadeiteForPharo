Class {
	#name : 'JadeiteTextInputFieldAdapter',
	#superclass : 'SpMorphicTextInputFieldAdapter',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'factory' }
JadeiteTextInputFieldAdapter >> buildWidget [
	| newWidget |

	newWidget := (JadeiteRubTextFieldMorph on: self)
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		entryCompletion: self entryCompletion;
		ghostText: self getPlaceholderText;
		encrypted: self encrypted;
		askBeforeDiscardingEdits: false;
		autoAccept: false; "<<<< Changed by Jadeite so hasUnacceptedEdits state gets updated"
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		setBalloonText: self help;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		maxLength: self presenter maxLength;
		yourself.

	self presenter selectionInterval 
		ifNotNil: [  :anInterval | self selectionInterval: anInterval on: newWidget ].
	self presenter whenTextChangedDo: [ :text | newWidget setText: text ].
	self presenter whenSelectionChangedDo: [ :selectionInterval | 
		self selectionInterval: selectionInterval ].
	self presenter whenPlaceholderChangedDo: [ :text | 
		newWidget ghostText: (text ifNotNil: [ :aString | 
			aString localizedForPresenter: self presenter ]) ].
	self presenter whenPasswordChangedDo: [ :isPassword | 
		newWidget encrypted: isPassword ].
	self presenter whenMaxLengthChangedDo: [ :length | 
		newWidget maxLength: length ].
	self setEnabled: self presenter isEnabled to: newWidget. 
	self setEditable: self presenter isEditable to: newWidget. 
	self presenter whenEditableChangedDo: [ :value | 
		self setEditable: value to: newWidget ].
	^ newWidget
]

{ #category : 'nil' }
JadeiteTextInputFieldAdapter >> styleName [

	^ 'textInputField'
]
