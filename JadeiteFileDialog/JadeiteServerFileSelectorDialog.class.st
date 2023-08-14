Class {
	#name : 'JadeiteServerFileSelectorDialog',
	#superclass : 'Dialog',
	#instVars : [
		'fileSelectorPresenter'
	],
	#category : 'JadeiteFileDialog'
}

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog class >> createDialogOn: aGciSession path: path [

	| service inst |
	service := RowanFileService new path: path.
	service session: aGciSession.
	inst := self new gciSession: aGciSession.
	^ inst
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog class >> showOnSession: aGciSession [
	^self showOnSession: aGciSession defaultPath: JadePresenter rowanProjectsHomeEnvVarString
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog class >> showOnSession: aGciSession defaultPath: path [
	| inst modal answer |
	inst := self createDialogOn: aGciSession path: path.
	modal := inst asModalWindow. 
	inst initializeWith: path. 
	answer := modal open.
	answer cancelled ifTrue:[^nil]. 
	^inst selectedFileOrDirectory
]

{ #category : 'actions' }
JadeiteServerFileSelectorDialog >> cancel [

	^nil
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> createComponents [
	super createComponents.
	fileSelectorPresenter := self add: JadeiteServerFileSelectorPresenter new name: 'fileSelectorPresenter'.

]

{ #category : 'initialization' }
JadeiteServerFileSelectorDialog >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> fileSelectorPresenter [
	"for testing" 
	^fileSelectorPresenter
]

{ #category : 'accessing' }
JadeiteServerFileSelectorDialog >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteServerFileSelectorDialog >> gciSession: anObject [

	gciSession := anObject
]

{ #category : 'initialization' }
JadeiteServerFileSelectorDialog >> initializePresenters [
	super initializePresenters.
	fileSelectorPresenter := JadeiteServerFileSelectorPresenter new. 
	self layout add: fileSelectorPresenter
]

{ #category : 'initialization' }
JadeiteServerFileSelectorDialog >> initializeWindow: aWindowPresenter [

	aWindowPresenter initialExtent: 800 @ 600
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

{ #category : 'actions' }
JadeiteServerFileSelectorDialog >> pop [

	self halt. 
]

{ #category : 'actions' }
JadeiteServerFileSelectorDialog >> select [
	| service |
	service := RowanFileService new
				path: fileSelectorPresenter newPathText;
				session: model session.
	service isDirectory ifTrue: [^MessageBox notify: 'Cannot open a directory'].
	fileSelectorPresenter selectionMade.
	self ok.
	^fileSelectorPresenter pathText value
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
JadeiteServerFileSelectorDialog >> setPresenterModel [
	fileSelectorPresenter model: model
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> setPresenterModelFor: session path: path [

	| fileService |
	fileService := RowanFileService new path: path.
	fileService session: session.
	fileSelectorPresenter fileService: fileService
]

{ #category : 'constants' }
JadeiteServerFileSelectorDialog >> shellName [

	^ 'Jadeite Select File Dialog'
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> showDirectoryContents [
	fileSelectorPresenter showDirectoryContents
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorDialog >> updateCaptionInSession: session [
	self caption: (session titleBarFor: self shellName)
]
