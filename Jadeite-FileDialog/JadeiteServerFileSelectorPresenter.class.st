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

{ #category : 'actions' }
JadeiteServerFileSelectorPresenter >> activationAction [

	| directoryName sem |
	directoryName := directoryContentsList selectedItem key.
	directoryName = '..' ifTrue: [ ^ self pop ].
	sem := Semaphore new.
	fileService
		isDirectory: directoryContentsList selectedItem key
		onCompletion: [ sem signal ].
	sem wait.
	fileService answer ifNil: [ ^ self "no permission" ].
	fileService answer ifTrue: [ ^ self basicDive: fileService ].
	self window okAction value 
]

{ #category : 'actions' }
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

{ #category : 'initialization' }
JadeiteServerFileSelectorPresenter >> connectPresenters [

	super connectPresenters.
	pathText bindKeyCombination: KeyboardKey enter toAction: [
		pathText text: pathText adapter widget text asString.
		self showDirectoryContents ]
]

{ #category : 'defaults' }
JadeiteServerFileSelectorPresenter >> defaultLayout [ 

	^SpBoxLayout newVertical
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> fileName [
	^pathText text 
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
		whenActivatedDo: [ :selection | self activationAction ].
	self layout add: directoryContentsList.
	self initializeContextMenu
]

{ #category : 'initialization' }
JadeiteServerFileSelectorPresenter >> initializeTopWidgets [

	| topBox popButton |
	topBox := SpBoxLayout newHorizontal.
	topBox add: (SpLabelPresenter new label: 'Path:') expand: false.
	topBox add: (pathText := JadeiteTextInputFieldPresenter new).
	popButton := SpButtonPresenter new
		             label: 'Pop';
		             action: [ self pop ].
	topBox add: popButton expand: false.
	self layout add: topBox expand: false
]

{ #category : 'testing' }
JadeiteServerFileSelectorPresenter >> isDirectorySelected [
	^(directoryContentsList selectionIfNone: [^true]) value
]

{ #category : 'testing' }
JadeiteServerFileSelectorPresenter >> isFileSelected [
	^(directoryContentsList selectionIfNone: [^false]) value not
]

{ #category : 'actions' }
JadeiteServerFileSelectorPresenter >> logoutRequested: aValueHolder [
	"Private - Opportunity to save changes."

	aValueHolder value: true.
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> newPathText [
	| item newPathText finalSlash |
	item := directoryContentsList selectionOrNil ifNil: [String new] ifNotNil: [:sel | sel key].
	finalSlash := pathText value isEmpty
				ifFalse: [pathText value last = $/ ifTrue: [String new] ifFalse: ['/']].
	newPathText := pathText value , finalSlash , item.
	^newPathText
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> parentDirectoryPath [
	^self model parentDirectoryPath
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> pathText [
	^pathText ifNil:[pathText := ValueHolder new]
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> pathText: anObject [
	pathText := anObject
]

{ #category : 'actions' }
JadeiteServerFileSelectorPresenter >> pop [

	fileService popWith: directoryContentsList with: pathText
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> selectedDirectory [

	^ pathText text
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> selectedFileOrDirectory [

	^directoryContentsList selectedItem value ifNil:[ pathText text] ifNotNil: [ :array | array first ]
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> selectedFilePath [

	^ fileService pathStringFor: directoryContentsList selection key
]

{ #category : 'actions' }
JadeiteServerFileSelectorPresenter >> setPath: path [
	self pathText text: path.
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> shellName [
	"to avoid 'should be implemented' category"

	
]

{ #category : 'actions' }
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
	fileService answer
		ifNil: [
			self window ifNotNil: [
				self uiManager
					alert: 'Invalid path entered'
					title: 'File Dialog Alert' ] ]
		ifNotNil: [ directoryContentsList list: fileService shortNames ]
]
