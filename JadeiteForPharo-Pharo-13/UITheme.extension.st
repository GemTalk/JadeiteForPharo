Extension { #name : 'UITheme' }

{ #category : '*JadeiteForPharo-Pharo-13' }
UITheme >> jadeiteChooseForSaveFileReferenceIn: aThemedMorph title: title extensions: exts filename: path preview: preview [

	| dialog pathFileReference |
	pathFileReference := path asFileReference.
	dialog := aThemedMorph application newOpenFile
		          title: title;
		          path:
			          pathFileReference basename;
		          beSaveFile.
	"dialog fileSelectionBlock: [ :entry |
		entry isDirectory
			ifTrue: [ dialog showDirectoriesInFileList ]
			ifFalse: [ '*' match: entry basename ] ].
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: path ]."
	^ dialog openModal answer
]
