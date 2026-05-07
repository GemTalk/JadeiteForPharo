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
JadeiteServerFileSaveDialog class >> _showOnSession: aGciSession defaultPath: defaultPath defaultFileName: fileName [
	"private for testing - open non-modally and return dialog instance"

	| inst theWindow expandedPath |
	inst := self createDialogOn: aGciSession path: defaultPath.
	expandedPath := inst fileSelectorPresenter pathText text.
	theWindow := (inst application: JadeiteSpApplication new) asWindow.
	inst initializeWith: expandedPath fileName: fileName.
	theWindow open.
	^ inst
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
JadeiteServerFileSaveDialog class >> showOnSession: aGciSession defaultPath: defaultPath defaultFileName: fileName [

	| inst modal answer expandedPath path newFilePath service |
	(ProvideAnswerNotification signal: defaultPath) ifNotNil: [
		:theAnswer | ^ theAnswer ].
	path := JadePresenter lastFilePath
		        ifNil: [ defaultPath ]
		        ifNotNil: [ :thePath | thePath ].
	inst := self createDialogOn: aGciSession path: path.
	expandedPath := inst fileSelectorPresenter pathText text.
	modal := (inst application: JadeiteSpApplication new) asModalWindow.
	modal centered.
	inst initializeWith: expandedPath fileName: fileName.
	answer := modal open.
	answer cancelled ifTrue: [ ^ nil ].
	service := RowanFileServiceClient new session: GciSession current.
	service path: inst pathText text.
	service / inst fileNamePresenter text.
	newFilePath := service answer.
	self setLastPath: inst pathText text.
	^ newFilePath
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
	path := fileSelectorPresenter selectedDirectory.
	fileService := RowanFileServiceClient new
		               path: path;
		               session: self gciSession.
	fileService setPathFor: fileNamePresenter text.
	^ fileService exists
		  ifNil: [ false "no permissions" ]
		  ifNotNil: [ :bool |
			  bool
				  ifTrue: [
					  (UIManager default confirm:
						   fileService path , ' exists. Overwrite?')
						  ifTrue: [
							  aWindowPresenter beOk.
							  true ]
						  ifFalse: [ false ] ]
				  ifFalse: [
					  aWindowPresenter beOk.
					  true ] ]
]

{ #category : 'initialization' }
JadeiteServerFileSaveDialog >> connectPresenters [

	super connectPresenters.
	fileNamePresenter bindKeyCombination: KeyboardKey enter toAction: [
		self window
			beOk;
			triggerOkAction ]
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
	(aWindowPresenter respondsTo: #okAction:) ifTrue: [
		aWindowPresenter okAction: [
			| okToClose |
			okToClose := self confirmSave: aWindowPresenter.
			okToClose ifTrue: [ aWindowPresenter close ].
			okToClose ] ]
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
JadeiteServerFileSaveDialog >> shellName [

	^ 'Jadeite Save File Dialog'
]
