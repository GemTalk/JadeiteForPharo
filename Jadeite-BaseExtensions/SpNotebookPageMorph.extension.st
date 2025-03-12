Extension { #name : 'SpNotebookPageMorph' }

{ #category : '*Jadeite-BaseExtensions' }
SpNotebookPageMorph >> themeChanged [

	super themeChanged.
	labelMorph ifNotNil: [ labelMorph themeChanged ].
	actualPageMorph ifNotNil: [ actualPageMorph themeChanged ]
]
