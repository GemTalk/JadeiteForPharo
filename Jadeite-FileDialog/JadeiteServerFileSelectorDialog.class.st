Class {
	#name : 'JadeiteServerFileSelectorDialog',
	#superclass : 'Dialog',
	#instVars : [
		'fileSelectorPresenter',
		'shellName'
	],
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> _showOnSession: aGciSession defaultPath: path shellName: shellName [
	"private for testing - return the dialog instead of the answer and  do not open modal"
	| inst theWindow answer |
	inst := self createDialogOn: aGciSession path: path.
	inst shellName: shellName.
	theWindow := inst asWindow.
	inst initializeWith: path.
	answer := theWindow open.
	answer cancelled ifTrue: [ ^ nil ].
	^ inst
]

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> basicShowOnSession: aGciSession defaultPath: path shellName: shellName [

	| modal inst answer |
	inst := self createDialogOn: aGciSession path: path.
	inst shellName: shellName.
	inst application: JadeiteSpApplication new.
	modal := inst asModalWindow.
	inst initializeWith: path.
	answer := modal open.
	answer cancelled ifTrue: [ ^ nil ].
	self setLastPath: inst pathText text.
	^ inst selectedFileOrDirectory
]

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> createDialogOn: aGciSession path: path [

	| service inst |
	service := RowanFileServiceClient new path: path.
	service session: aGciSession.
	RowanServiceUpdater current critical: [service expandPath].
	inst := self new gciSession: aGciSession.
	inst fileSelectorPresenter pathText text: service answer.
	^ inst
]

{ #category : 'constants' }
JadeiteServerFileSelectorDialog class >> defaultPreferredExtent [

	^ 80 @ 60
]

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> setLastPath: aString [

	JadePresenter lastFilePath: aString
]

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> showOnSession: aGciSession [

	^ self
		  showOnSession: aGciSession
		  defaultPath: JadePresenter homeEnvVarString
]

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> showOnSession: aGciSession defaultPath: path [
	^self showOnSession: aGciSession defaultPath: path shellName: nil
]

{ #category : 'instance creation' }
JadeiteServerFileSelectorDialog class >> showOnSession: aGciSession defaultPath: defaultPath shellName: shellName [

	| path |
	(ProvideAnswerNotification signal: defaultPath) ifNotNil: [
		:theAnswer | ^ theAnswer ].
	path := JadePresenter lastFilePath
		        ifNil: [ defaultPath ]
		        ifNotNil: [ :thePath | thePath ].
	^ self
		  basicShowOnSession: aGciSession
		  defaultPath: path
		  shellName: shellName
]

{ #category : 'actions' }
JadeiteServerFileSelectorDialog >> cancel [

	^nil
]

{ #category : 'initialization' }
JadeiteServerFileSelectorDialog >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'constants' }
JadeiteServerFileSelectorDialog >> defaultShellName [

	^ 'Jadeite Select File Dialog'
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> fileSelectorPresenter [

	^fileSelectorPresenter
]

{ #category : 'accessing' }
JadeiteServerFileSelectorDialog >> gciSession: aSession [

	gciSession := aSession.
	fileSelectorPresenter gciSession: aSession
]

{ #category : 'initialization' }
JadeiteServerFileSelectorDialog >> initializePresenters [

	super initializePresenters.
	fileSelectorPresenter := JadeiteServerFileSelectorPresenter new
		                         gciSession: gciSession.
	self layout add: fileSelectorPresenter
]

{ #category : 'initialization' }
JadeiteServerFileSelectorDialog >> initializeWith: path [

	self fileSelectorPresenter setPath:  path.  
	self setPresenterModelFor: self gciSession path: path.
	self showDirectoryContents.
	self updateCaptionInSession: self gciSession
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> pathText [
	^fileSelectorPresenter pathText
]

{ #category : 'accessing' }
JadeiteServerFileSelectorDialog >> selectedFileOrDirectory [

	^self fileSelectorPresenter selectedFileOrDirectory
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> setPathText: thePathText [
	fileSelectorPresenter pathText value: thePathText
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> setPresenterModelFor: session path: path [

	| fileService |
	fileService := RowanFileServiceClient new path: path.
	fileService session: session.
	fileSelectorPresenter fileService: fileService
]

{ #category : 'constants' }
JadeiteServerFileSelectorDialog >> shellName [

	^ shellName ifNil: [ self defaultShellName ]
]

{ #category : 'constants' }
JadeiteServerFileSelectorDialog >> shellName: aString [

	shellName := aString
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> showDirectoryContents [
	fileSelectorPresenter showDirectoryContents
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> updateCaptionInSession: session [
	self caption: (session titleBarFor: self shellName)
]
