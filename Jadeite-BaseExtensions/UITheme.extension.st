Extension { #name : 'UITheme' }

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteBackgroundColor [

	^JadeiteApplication jadeiteBackgroundColor
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteChooseForSaveFileReferenceIn: aThemedMorph title: title extensions: exts path: path preview: preview [

	| dialog pathFileReference |
	pathFileReference := path asFileReference.
	dialog := (FileDialogWindow newWithTheme: aThemedMorph theme)
		          title: title;
		          fileNameText: pathFileReference basename;
		          answerSaveFile.
	dialog fileSelectionBlock: [ :entry |
		entry isDirectory
			ifTrue: [ dialog showDirectoriesInFileList ]
			ifFalse: [ '*' match: entry basename ] ].
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteTextEditorIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText entryHeight: entryHeight [
	"Answer the result of a text editor (multiline) dialog ( a string or nil if cancelled)
	with the given label and title."

	self questionSound play.
	^((JadeiteTextEditorDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText;
			entryText: defaultEntryText;
			entryHeight: entryHeight) openModal entryText
]
