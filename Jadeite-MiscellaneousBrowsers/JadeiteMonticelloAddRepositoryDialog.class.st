Class {
	#name : 'JadeiteMonticelloAddRepositoryDialog',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'repositoryTypePresenter',
		'urlPresenter',
		'urlLabelPresenter',
		'monticelloPackageService',
		'fileDialogPresenter',
		'addRepositoryButton',
		'completionBlock'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteMonticelloAddRepositoryDialog class >> defaultPreferredExtent [
	"customExtent := nil"
	^ 60 @ 15

]

{ #category : 'instance creation' }
JadeiteMonticelloAddRepositoryDialog class >> showOnSession: aGciSession packageService: monticelloPackageService [

	^ self
		  showOnSession: aGciSession
		  packageService: monticelloPackageService
		  onCompletion: [  ]
]

{ #category : 'instance creation' }
JadeiteMonticelloAddRepositoryDialog class >> showOnSession: aGciSession packageService: monticelloPackageService onCompletion: aBlock [

	^ self new
		  gciSession: aGciSession;
		  monticelloPackageService: monticelloPackageService;
		  completionBlock: aBlock;
		  open
]

{ #category : 'actions' }
JadeiteMonticelloAddRepositoryDialog >> addRepository [

	| urlString commandSymbol |
	urlString := urlPresenter text.
	(urlString isNil or: [ urlString isEmpty ]) ifTrue: [ ^ self ].
	commandSymbol := self commandForRepositoryType:
		                 repositoryTypePresenter selectedItem.
	self monticelloPackageService
		command: commandSymbol;
		commandArgs: (Array with: urlString).
	self gciSession
		issueCommand: self monticelloPackageService
		onCompletion: [ completionBlock value ]
]

{ #category : 'private' }
JadeiteMonticelloAddRepositoryDialog >> commandForRepositoryType: aSymbol [

	aSymbol = #HTTP ifTrue: [ ^ #addHttpRepository: ].
	aSymbol = #FileTree ifTrue: [ ^ #addFiletreeRepository: ].
	aSymbol = #Github ifTrue: [ ^ #addGithubRepository: ].
	aSymbol = #MCZ ifTrue: [ ^ #addMCZRepository: ].
	^ self error: 'Unknown repository type: ' , aSymbol
]

{ #category : 'accessing' }
JadeiteMonticelloAddRepositoryDialog >> completionBlock [

	^ completionBlock
]

{ #category : 'accessing' }
JadeiteMonticelloAddRepositoryDialog >> completionBlock: aBlock [

	completionBlock := aBlock
]

{ #category : 'initialization' }
JadeiteMonticelloAddRepositoryDialog >> connectPresenters [

	super connectPresenters.
	repositoryTypePresenter whenSelectedItemChangedDo: [ :thing |
		self updateForRepositoryType ]
]

{ #category : 'layout' }
JadeiteMonticelloAddRepositoryDialog >> defaultLayout [

	^ SpGridLayout new
		  beColumnNotHomogeneous;
		  add: 'Repository Type:' atPoint: 1 @ 1;
		  add: repositoryTypePresenter atPoint: 2 @ 1 span: 4 @ 1;
		  add: urlLabelPresenter atPoint: 1 @ 2;
		  add: urlPresenter atPoint: 2 @ 2 span: 3 @ 1;
		  add: fileDialogPresenter atPoint: 5 @ 2;
		  add: (SpBoxLayout newHorizontal
				   addLast: addRepositoryButton expand: false;
				   yourself) atPoint: 1 @ 3 span: 5 @ 1;
		  yourself
]

{ #category : 'initialization' }
JadeiteMonticelloAddRepositoryDialog >> initializePresenters [

	super initializePresenters.
	completionBlock := [  ].
	repositoryTypePresenter := self newDropList.
	repositoryTypePresenter items: #( #HTTP #FileTree #Github #MCZ ).
	urlLabelPresenter := self newLabel label: 'URL:'.
	urlPresenter := self newTextInput.
	fileDialogPresenter := self newButton
		                       label: 'Choose...';
		                       action: [ self openFileDialog ].
	fileDialogPresenter hide.
	addRepositoryButton := self newButton
		                       label: 'Add Repository';
		                       action: [ self addRepository ]
]

{ #category : 'accessing' }
JadeiteMonticelloAddRepositoryDialog >> monticelloPackageService [

	^ monticelloPackageService
]

{ #category : 'accessing' }
JadeiteMonticelloAddRepositoryDialog >> monticelloPackageService: anObject [

	monticelloPackageService := anObject
]

{ #category : 'actions' }
JadeiteMonticelloAddRepositoryDialog >> openFileDialog [

	| shellName path |
	shellName := repositoryTypePresenter selectedItem = #MCZ
		             ifTrue: [ 'Choose MCZ File' ]
		             ifFalse: [ 'Choose Filetree Directory' ].
	path := JadeiteServerFileSelectorDialog
		        showOnSession: self gciSession
		        defaultPath: JadePresenter homeEnvVarString
		        shellName: shellName.
	path ifNil: [ ^ self ].
	urlPresenter text: path
]

{ #category : 'constants' }
JadeiteMonticelloAddRepositoryDialog >> shellName [

	^ 'Add Repository'
]

{ #category : 'actions' }
JadeiteMonticelloAddRepositoryDialog >> updateForRepositoryType [

	| selectedType isFileBased |
	selectedType := repositoryTypePresenter selectedItem.
	isFileBased := #( #FileTree #MCZ ) includes: selectedType.
	isFileBased
		ifTrue: [ fileDialogPresenter show ]
		ifFalse: [ fileDialogPresenter hide ].
	urlLabelPresenter label: (self urlLabelForType: selectedType)
]

{ #category : 'private' }
JadeiteMonticelloAddRepositoryDialog >> urlLabelForType: aSymbol [

	aSymbol = #FileTree ifTrue: [ ^ 'Directory:' ].
	aSymbol = #MCZ ifTrue: [ ^ 'File path:' ].
	^ 'URL:'
]
