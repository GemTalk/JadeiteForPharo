"
Not functional yet.
To continue development - JadeiteHelpBrowser new open
"
Class {
	#name : 'JadeiteHelpBrowser',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'contentsPresenter'
	],
	#category : 'Jadeite-Help',
	#package : 'Jadeite-Help'
}

{ #category : 'constants' }
JadeiteHelpBrowser >> defaultHelpCssFile [

	^ 'jadeitehelp.css'
]

{ #category : 'constants' }
JadeiteHelpBrowser >> defaultHelpHtmlFile [

	^ 'jadeitehelp.md'
]

{ #category : 'defaults' }
JadeiteHelpBrowser >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteHelpBrowser >> displayCssFileMissingMessage [

	MessageBox notify:
		'jadeitehelp.css file not found in pharo working directory. Help displayed in plain text'
]

{ #category : 'actions' }
JadeiteHelpBrowser >> displayHtmlFileMissingMessage [

	contentsPresenter documentFromString:
		'jadeitehelp.html file not found in pharo working directory'
]

{ #category : 'initialization' }
JadeiteHelpBrowser >> initializePresenters [

	| box |
	super initializePresenters.
	box := SpBoxLayout newVertical.
	self layout add: box.
	contentsPresenter := MicrodownPresenter new.
	box add: contentsPresenter
]

{ #category : 'initialization' }
JadeiteHelpBrowser >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent:
		100 @ 100 * StandardFonts defaultFont pointSize.
	self updateCaption
]

{ #category : 'constants' }
JadeiteHelpBrowser >> shellName [

	^ 'Jadeite Help Browser'
]

{ #category : 'initialization' }
JadeiteHelpBrowser >> updatePresenter [

	| html css page |
	super updatePresenter.
	html := FileSystem workingDirectory resolveString:
		        self defaultHelpHtmlFile.
	html exists ifFalse: [ ^ self displayHtmlFileMissingMessage ].
	contentsPresenter documentFromString: html contents.
	
	true ifTrue: [ ^self ].
	css := FileSystem workingDirectory resolveString:
		       self defaultHelpCssFile.
	css exists ifFalse: [ ^ self displayCssFileMissingMessage ].
	"contentsPresenter textStyler: css contents"
	
	"experiments"
	page := ZnHtmlOutputStream streamContents: [ :htmlStream |
		htmlStream nextPutAll: html contents.
		htmlStream tag: #style attributes: #(type 'text/css') with: css contents.
		  ].
	^ ZnResponse ok: (ZnEntity html: page)
]
