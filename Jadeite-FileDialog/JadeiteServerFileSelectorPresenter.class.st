Class {
	#name : 'JadeiteServerFileSelectorPresenter',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'directoryContentsList',
		'pathText',
		'fileService'
	],
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> basicDive: service [

	service answer
		ifTrue: [
			| directoryName |
			directoryName := directoryContentsList selectedItem key.
			directoryName = '.' ifFalse: [
				pathText text:
					pathText text , '/' , directoryContentsList selectedItem key ].
			fileService path: pathText text.
			self showDirectoryContents ]
		ifFalse: [ self window triggerOkAction ]
]

{ #category : 'defaults' }
JadeiteServerFileSelectorPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> directoryContentsList [
	^directoryContentsList
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> dive [

	| sem directoryName |
	directoryName := directoryContentsList selectedItem key.
	directoryName = '..' ifTrue: [ ^ self pop ].
	sem := Semaphore new.
	fileService
		isDirectory: directoryContentsList selectedItem key
		onCompletion: [ :service | sem signal ].
	sem wait.
	self basicDive: fileService
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> fileName [
	^self model fileName
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> fileService [

	^ fileService
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> fileService: anObject [

	fileService := anObject. 
	fileService session: gciSession
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> goto [
	model value path: pathText value.
	self showDirectoryContents
]

{ #category : 'initialization' }
JadeiteServerFileSelectorPresenter >> initializeBottomWidgets [

	| bottomWidgets |
	bottomWidgets := SpBoxLayout newHorizontal.
	bottomWidgets add: (SpButtonPresenter new
			 label: 'Select';
			 action: [ self select ]).
	bottomWidgets add: (SpButtonPresenter new
			 label: 'Cancel';
			 action: [ self cancel ]).
	self layout add: bottomWidgets expand: false.
]

{ #category : 'initialization' }
JadeiteServerFileSelectorPresenter >> initializeContextMenu [

	| menu |
	menu := JadeiteMenuPresenter new.
	menu addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Dive';
				action: [ self dive ] ] ].
	self directoryContentsList contextMenu: menu
]

{ #category : 'initialization' }
JadeiteServerFileSelectorPresenter >> initializePresenters [

	super initializePresenters.
	self initializeTopWidgets.
	directoryContentsList := JadeiteListPresenter new
		                         display: #key;
		                         displayIcon: [ :assoc | 
			                         assoc value last
				                         ifTrue: [ 
					                         self iconNamed: #glamorousFolder ]
				                         ifFalse: [ nil ] ].
	directoryContentsList
		activateOnDoubleClick;
		whenActivatedDo: [ :selection | self dive ].
	self layout add: directoryContentsList.
	self initializeContextMenu
]

{ #category : 'initialization' }
JadeiteServerFileSelectorPresenter >> initializeTopWidgets [

	| topBox popButton |
	topBox := SpBoxLayout newHorizontal.
	topBox add: (SpLabelPresenter new label: 'Path:') expand: false.
	topBox add: (pathText := SpTextInputFieldPresenter new).
	popButton := SpButtonPresenter new
		             label: 'Pop';
		             action: [ self pop ].
	topBox add: popButton expand: false.
	self layout add: topBox expand: false
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> isDirectorySelected [
	^(directoryContentsList selectionIfNone: [^true]) value
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> isFileSelected [
	^(directoryContentsList selectionIfNone: [^false]) value not
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> load [

	^parentPresenter load
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> logoutRequested: aValueHolder [
	"Private - Opportunity to save changes."

	aValueHolder value: true.
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> newPathText [
	| item newPathText finalSlash |
	item := directoryContentsList selectionOrNil ifNil: [String new] ifNotNil: [:sel | sel key].
	finalSlash := pathText value isEmpty
				ifFalse: [pathText value last = $/ ifTrue: [String new] ifFalse: ['/']].
	newPathText := pathText value , finalSlash , item.
	^newPathText
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> parentDirectoryPath [
	^self model parentDirectoryPath
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> pathText [
	^pathText ifNil:[pathText := ValueHolder new]
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> pathText: anObject [
	pathText := anObject
]

{ #category : 'actions' }
JadeiteServerFileSelectorPresenter >> pop [

	fileService popWith: directoryContentsList with: pathText
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> select [
	parentPresenter select
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> selectedFileOrDirectory [

	^directoryContentsList selectedItem value ifNil:[ pathText text] ifNotNil: [ :array | array first ]
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> selectedFilePath [

	^ fileService pathStringFor: directoryContentsList selection key
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> selectionMade [
	| newPathText |
	model value path = pathText value ifFalse: [^self goto].
	newPathText := self newPathText.
	pathText value: newPathText
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> setPath: path [
	self pathText text: path.
	self todo:[self model value path: path]. 
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> showDirectoryContents [

	| sem |
	fileService := RowanFileServiceClient new session: self gciSession.
	fileService
		command: #directoryContents;
		commandArgs: Array new;
		path: pathText text.
	sem := Semaphore new.
	RowanServiceUpdater current
		issueCommand: fileService
		session: self gciSession
		onCompletion: [ sem signal ].
	sem wait.
	fileService answer ifNotNil: [
		directoryContentsList list: fileService shortNames ]
]
