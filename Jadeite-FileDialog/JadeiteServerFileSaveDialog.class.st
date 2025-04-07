Class {
	#name : 'JadeiteServerFileSaveDialog',
	#superclass : 'JadeiteServerFileSelectorDialog',
	#instVars : [
		'fileNamePresenter'
	],
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'instance creation' }
JadeiteServerFileSaveDialog class >> instantiateOnSession: aGciSession initialFileName: fileName [
	| service inst |
	service := RowanFileServiceClient new path: JadePresenter rowanProjectsHomeEnvVarString.
	service session: aGciSession.
	inst := self createOn: service.
	inst setPresenterModel.
	inst fileNamePresenter value: fileName.
	inst pathText value: service path.
	inst showDirectoryContents.
	^inst
]

{ #category : 'instance creation' }
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

{ #category : 'instance creation' }
JadeiteServerFileSaveDialog class >> showOnSession: aGciSession defaultPath: path defaultFileName: fileName [

	| inst modal answer expandedPath |
	(ProvideAnswerNotification signal: path) ifNotNil: [ :theAnswer |
		^ theAnswer ].
	inst := self createDialogOn: aGciSession path: path.
	expandedPath := inst fileSelectorPresenter pathText text. 
	modal := (inst application: JadeiteSpApplication new) asModalWindow.
	modal centered.
	inst initializeWith: expandedPath fileName: fileName.
	answer := modal open.
	answer cancelled ifTrue: [ ^ nil ].
	^ inst selectedFileOrDirectory
]

{ #category : 'instance creation' }
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
	ProvideAnswerNotification signal ifNotNil: [ :answer | ^ answer ].
	path := fileSelectorPresenter selectedFileOrDirectory.
	fileService := RowanFileServiceClient new
		               path: path;
		               session: self gciSession.
	fileService isDirectory ifTrue: [
		fileService setPathFor: fileNamePresenter text ].
	^ fileService exists
		  ifTrue: [
			  (UIManager default confirm:
				   fileService path , ' exists. Overwrite?')
				  ifTrue: [
					  aWindowPresenter beOk.
					  true ]
				  ifFalse: [ false ] ]
		  ifFalse: [
			  aWindowPresenter beOk.
			  true ]
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> fileNamePresenter [
	^fileNamePresenter
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> initializeDialogWindow: aDialogWindowPresenter [
	"Used to initialize the model in the case of the use into a dialog window.
	 Override this to set buttons other than the default (Ok, Cancel)."

	aDialogWindowPresenter
		addButton: 'Cancel' do: [ :presenter |
			presenter triggerCancelAction.
			presenter close ];
		addDefaultButton: 'Ok' do: [ :presenter |
			| okToClose |
			okToClose := presenter triggerOkAction.
			okToClose ifTrue: [ presenter close ] ]
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
	aWindowPresenter okAction: [
		| okToClose |
		okToClose := self confirmSave: aWindowPresenter.
		okToClose ifTrue: [ aWindowPresenter close ].
		okToClose ]
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
	fileService := RowanFileServiceClient new
		               path: selFileOrDir;
		               session: self gciSession.
	^ (fileService isDirectory
		   ifTrue: [ fileService pathStringFor: fileNamePresenter text ]
		   ifFalse: [ fileService pathStringFor: nil ])
]

{ #category : 'accessing' }
JadeiteServerFileSaveDialog >> shellName [

	^ 'Jadeite Save File Dialog'
]
