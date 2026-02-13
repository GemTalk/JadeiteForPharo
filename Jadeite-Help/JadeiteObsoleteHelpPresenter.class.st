"
Obsolete presenter that displayed the jadeitehelp.md file. 
Superseded by a link to web help. 
"
Class {
	#name : 'JadeiteObsoleteHelpPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'contentsPresenter'
	],
	#category : 'Jadeite-Help',
	#package : 'Jadeite-Help'
}

{ #category : 'accessing' }
JadeiteObsoleteHelpPresenter >> contentsPresenter [

	^ contentsPresenter
]

{ #category : 'accessing' }
JadeiteObsoleteHelpPresenter >> contentsPresenter: anObject [

	contentsPresenter := anObject
]

{ #category : 'constants' }
JadeiteObsoleteHelpPresenter >> defaultHelpCssFile [

	^ 'jadeitehelp.css'
]

{ #category : 'constants' }
JadeiteObsoleteHelpPresenter >> defaultHelpHtmlFile [

	^ 'jadeitehelp.md'
]

{ #category : 'constants' }
JadeiteObsoleteHelpPresenter >> defaultHelpMarkdownFile [

	^ 'jadeitehelp.md'
]

{ #category : 'defaults' }
JadeiteObsoleteHelpPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'actions' }
JadeiteObsoleteHelpPresenter >> displayCssFileMissingMessage [

	MessageBox notify:
		'jadeitehelp.css file not found in pharo working directory. Help displayed in plain text'
]

{ #category : 'actions' }
JadeiteObsoleteHelpPresenter >> displayHtmlFileMissingMessage [

	contentsPresenter documentFromString:
		'jadeitehelp.html file not found in pharo working directory'
]

{ #category : 'initialization' }
JadeiteObsoleteHelpPresenter >> initializePresenters [

	| box |
	super initializePresenters.
	box := SpBoxLayout newVertical.
	self layout add: box.
	contentsPresenter := MicrodownPresenter new.
	box add: contentsPresenter
]

{ #category : 'initialization' }
JadeiteObsoleteHelpPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent:
		100 @ 100 * StandardFonts defaultFont pointSize.
	self updateCaption
]

{ #category : 'constants' }
JadeiteObsoleteHelpPresenter >> shellName [

	^ 'Jadeite Help Browser'
]

{ #category : 'initialization' }
JadeiteObsoleteHelpPresenter >> updatePresenter [

	| md |
	super updatePresenter.
	md := FileSystem workingDirectory resolveString:
		      self defaultHelpMarkdownFile.
	md exists ifFalse: [ ^ self displayHtmlFileMissingMessage ].
	contentsPresenter documentFromString: md contents
]
