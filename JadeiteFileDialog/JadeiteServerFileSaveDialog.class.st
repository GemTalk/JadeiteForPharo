Class {
	#name : 'JadeiteServerFileSaveDialog',
	#superclass : 'JadeiteServerFileSelectorDialog',
	#instVars : [
		'fileNamePresenter'
	],
	#category : 'JadeiteFileDialog'
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
JadeiteServerFileSaveDialog class >> showNonModalOnSession: aGciSession initialFileName: fileName [
	| inst |
	"for testing only"
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	inst show.
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
	inst := self createDialogOn: aGciSession path: path.
	modal := inst asModalWindow. 
	inst initializeWith: path fileName: fileName. 
	answer := modal open.
	answer cancelled ifTrue:[^nil]. 
	^inst selectedFileOrDirectory
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
JadeiteServerFileSaveDialog >> createComponents [
	super createComponents.
	fileNamePresenter := self add: TextPresenter new name: 'fileName'.
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog >> fileNamePresenter [
	^fileNamePresenter
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSaveDialog >> goto [
	model value path: fileSelectorPresenter pathText value.
	self showDirectoryContents
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> initializeFileNamePresenter [

	fileNamePresenter := SpTextPresenter new
		                     beNotWrapWord;
		                     withoutScrollBars.
	fileNamePresenter addStyle: 'jadedTextBackgroundColor'.
	self layout
		add: fileNamePresenter
		withConstraints: [ :c | c height: 30 ]
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

{ #category : 'as yet unclassified' }
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
