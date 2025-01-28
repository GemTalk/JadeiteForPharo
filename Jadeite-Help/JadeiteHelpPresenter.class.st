"
Not functional yet.
To continue development - JadeiteHelpBrowser new open
"
Class {
	#name : 'JadeiteHelpPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'contentsPresenter'
	],
	#category : 'Jadeite-Help',
	#package : 'Jadeite-Help'
}

{ #category : 'accessing' }
JadeiteHelpPresenter >> contentsPresenter [

	^ contentsPresenter
]

{ #category : 'accessing' }
JadeiteHelpPresenter >> contentsPresenter: anObject [

	contentsPresenter := anObject
]

{ #category : 'constants' }
JadeiteHelpPresenter >> defaultHelpCssFile [

	^ 'jadeitehelp.css'
]

{ #category : 'constants' }
JadeiteHelpPresenter >> defaultHelpHtmlFile [

	^ 'jadeitehelp.md'
]

{ #category : 'constants' }
JadeiteHelpPresenter >> defaultHelpMarkdownFile [

	^ 'jadeitehelp.md'
]

{ #category : 'defaults' }
JadeiteHelpPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteHelpPresenter >> displayCssFileMissingMessage [

	MessageBox notify:
		'jadeitehelp.css file not found in pharo working directory. Help displayed in plain text'
]

{ #category : 'actions' }
JadeiteHelpPresenter >> displayHtmlFileMissingMessage [

	contentsPresenter documentFromString:
		'jadeitehelp.html file not found in pharo working directory'
]

{ #category : 'initialization' }
JadeiteHelpPresenter >> initializePresenters [

	| box |
	super initializePresenters.
	box := SpBoxLayout newVertical.
	self layout add: box.
	contentsPresenter := MicrodownPresenter new.
	box add: contentsPresenter
]

{ #category : 'initialization' }
JadeiteHelpPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent:
		100 @ 100 * StandardFonts defaultFont pointSize.
	self updateCaption
]

{ #category : 'constants' }
JadeiteHelpPresenter >> shellName [

	^ 'Jadeite Help Browser'
]

{ #category : 'initialization' }
JadeiteHelpPresenter >> updatePresenter [

	| md |
	super updatePresenter.
	md := FileSystem workingDirectory resolveString:
		      self defaultHelpMarkdownFile.
	md exists ifFalse: [ ^ self displayHtmlFileMissingMessage ].
	contentsPresenter documentFromString: md contents
]
