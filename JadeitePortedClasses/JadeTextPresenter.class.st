Class {
	#name : 'JadeTextPresenter',
	#superclass : 'TextPresenter',
	#category : 'JadeitePortedClasses'
}

{ #category : 'accessing' }
JadeTextPresenter >> currentSelectionOrLine [
	| range |
	self hasSelection ifFalse: [self view selectCurrentLine].
	range := self view selectionRange.
	^(self value copyFrom: range start to: range stop) replaceCrLfWithLf
]

{ #category : 'public' }
JadeTextPresenter >> onViewOpened [
	super onViewOpened.
	(view isKindOf: ScintillaView) ifFalse: [^self].
	view textStyles: JadeiteTextStyles default textStyles.
	view indicatorStyles: JadeiteTextStyles default defaultIndicatorStyles.
	view text: model value
]

{ #category : 'public' }
JadeTextPresenter >> selection [

	^view selection.

]

{ #category : 'private' }
JadeTextPresenter >> showCompileError: anArray [

	| result string count textView selectionRange offset |
	textView := self view.
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
