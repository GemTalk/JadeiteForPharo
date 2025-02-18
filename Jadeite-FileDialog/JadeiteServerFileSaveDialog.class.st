Class {
	#name : 'JadeiteServerFileSaveDialog',
	#superclass : 'JadeiteServerFileSelectorDialog',
	#instVars : [
		'fileNamePresenter'
	],
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog class >> instantiateOnSession: aGciSession initialFileName: fileName [
	| service inst |
	service := RowanFileService new path: JadePresenter rowanProjectsHomeEnvVarString.
	service session: aGciSession.
	inst := self createOn: service.
	inst setPresenterModel.
	inst fileNamePresenter value: fileName.
	inst pathText value: service path.
	inst showDirectoryContents.
	^inst
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog class >> showOnSession: aGciSession defaultFilePath: path [
	"assumes path is a full path + file name" 
	| inst answer  |
	inst := self createDialogOn: aGciSession path: path.
	inst fileNamePresenter value: inst fileSelectorPresenter fileName.
	inst fileSelectorPresenter setPath:  inst fileSelectorPresenter parentDirectoryPath.  
	inst showDirectoryContents. 
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog class >> showOnSession: aGciSession defaultPath: path defaultFileName: fileName [

	| inst modal answer |
	(ProvideAnswerNotification signal: path) ifNotNil: [ :theAnswer |
		^ theAnswer ].
	inst := self createDialogOn: aGciSession path: path.
	modal := (inst application: JadeiteSpApplication new) asModalWindow.
	modal centered.
	inst initializeWith: path fileName: fileName.
	answer := modal open.
	answer cancelled ifTrue: [ ^ nil ].
	^ inst selectedFileOrDirectory
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog class >> showOnSession: aGciSession initialFileName: fileName [
	"assumes default $ROWAN_PROJECTS_HOME directory"
	| inst answer |
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> answer [
	^self isConfirmed
		ifTrue: [ fileSelectorPresenter pathText value ]
		ifFalse: [ nil ]
]

{ #category : 'actions' }
JadeiteServerFileSaveDialog >> confirmSave: aWindowPresenter [

	| path fileService |
	path := fileSelectorPresenter selectedFileOrDirectory.
	fileService := RowanFileService new
		               path: path;
		               session: self gciSession.
	^ fileService exists
		  ifTrue: [
			  (UIManager default confirm: path , ' exists. Overwrite?')
				  ifTrue: [ aWindowPresenter beOk ] ]
		  ifFalse: [ aWindowPresenter beOk ]
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> fileNamePresenter [
	^fileNamePresenter
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> initializeFileNamePresenter [

	| box |
	box := SpBoxLayout newHorizontal.
	box add: (self newLabel label: 'File Name:   ') centered expand: false.
	fileNamePresenter := SpTextPresenter new
		                     beNotWrapWord;
		                     withoutScrollBars.
	fileNamePresenter addStyle: 'jadeiteTextBackgroundColor'.
	box add: fileNamePresenter.
	self layout add: box withConstraints: [ :c | c height: 30 ]
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> initializePresenters [
	super initializePresenters.
	self initializeFileNamePresenter.
	self layout add: fileSelectorPresenter
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter okAction: [ self confirmSave: aWindowPresenter ]
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> initializeWith: path fileName: fileName [

	super initializeWith: path. 
	fileNamePresenter text: fileName 
]

{ #category : 'actions' }
JadeiteServerFileSaveDialog >> pop [

	^fileSelectorPresenter pop
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> selectedFileOrDirectory [

	| fileService selFileOrDir |
	selFileOrDir := self fileSelectorPresenter selectedFileOrDirectory.
	fileService := RowanFileService new
		               path: selFileOrDir;
		               session: self gciSession.
	^ (fileService isDirectory
		   ifTrue: [ selFileOrDir asFileReference / fileNamePresenter text ]
		   ifFalse: [ selFileOrDir asFileReference]) pathString
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> shellName [

	^ 'Jadeite Save File Dialog'
]
