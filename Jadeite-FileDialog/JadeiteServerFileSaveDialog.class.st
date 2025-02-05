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

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog >> answer [
	^self isConfirmed
		ifTrue: [ fileSelectorPresenter pathText value ]
		ifFalse: [ nil ]
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog >> fileNamePresenter [
	^fileNamePresenter
]

{ #category : 'actions' }
JadeiteServerFileSaveDialog >> goto [
	model value path: fileSelectorPresenter pathText value.
	self showDirectoryContents
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
JadeiteServerFileSaveDialog >> initializeWith: path fileName: fileName [

	super initializeWith: path. 
	fileNamePresenter text: fileName 
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog >> pop [

	^fileSelectorPresenter pop
]

{ #category : 'actions' }
JadeiteServerFileSaveDialog >> save [
	model value path = fileSelectorPresenter pathText value ifFalse: [^self goto].
	fileSelectorPresenter pathText
		value: fileSelectorPresenter pathText value , '/' , fileNamePresenter value.
	self ok
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> selectedFileOrDirectory [

	^self fileSelectorPresenter selectedFileOrDirectory, '/', fileNamePresenter text
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> shellName [

	^ 'Jadeite Save File Dialog'
]
