Extension { #name : 'UITheme' }

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteBackgroundColor [

	^ Color
		  r: 0.9803921568627451
		  g: 0.9490196078431372
		  b: 0.8156862745098039
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteBorderColor [

	^ self borderColor
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteBorderWidth [

	^ self borderWidth
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteChangedTextBackgroundColor [ 

	^Color r: 0.96 g: 1 b: 0.8
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
UITheme >> jadeiteColorErrors [

	^ Color red muchLighter
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteColorFailures [

	^ Color yellow muchLighter
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteColorPass [

	^ Color fromHexString: #CEF1D1
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteExtensionTextColor [

	^ Color purple lighter 
]

{ #category : '*Jadeite-BaseExtensions' }
UITheme >> jadeiteTextEditorIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText entryHeight: entryHeight onCompletion: completionBlock [

	self questionSound play.
	^ ((JadeiteTextEditorDialogWindow newWithTheme: aThemedMorph theme)
		   textFont: self textFont;
		   title: aString;
		   text: aStringOrText;
		   basicEntryText: defaultEntryText;
		   entryHeight: entryHeight;
		   completionBlock: completionBlock) open
]
