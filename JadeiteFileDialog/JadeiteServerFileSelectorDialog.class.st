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
JadeiteServerFileSelectorDialog class >> resource_Default_view [
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 723 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #fixedParentRight 1 946 #fixedParentTop 1 946 #fixedParentBottom 1 170 192 34 2 592 8 'fileSelectorPresenter' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006068576 690 138 144 34 1 754 #createAt:extent: 34 2 498 6947 21 498 1201 801 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 145 13 0 0 10 0 0 0 233 15 0 0 154 1 0 0] 34 1 592 896 nil 27 )
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
