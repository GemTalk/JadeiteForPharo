Class {
	#name : 'JadeiteMonticelloAddRepositoryDialog',
	#superclass : 'JadeiteSessionPresenter',
	#instVars : [
		'repositoryTypePresenter',
		'repositoryTypeLabelPresenter',
		'urlPresenter',
		'urlLabelPresenter',
		'monticelloPackageService',
		'fileDialogPresenter',
		'addRepositoryButton',
		'cancelButton',
		'completionBlock'
	],
	#category : 'Jadeite-MiscellaneousBrowsers',
	#package : 'Jadeite-MiscellaneousBrowsers'
}

{ #category : 'accessing' }
JadeiteMonticelloAddRepositoryDialog class >> defaultPreferredExtent [
	"customExtent := nil"
	^ 60 @ 20

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

	| urlString commandSymbol service |
	urlString := urlPresenter text.
	(urlString isNil or: [ urlString isEmpty ]) ifTrue: [ ^ self ].
	commandSymbol := self commandForRepositoryType:
		                 repositoryTypePresenter selectedItem.
	service := RowanMonticelloService new
		           command: commandSymbol;
		           commandArgs: (Array with: urlString).
	self gciSession issueCommand: service onCompletion: [
			completionBlock cull: urlString.
			self window close ]
]

{ #category : 'actions' }
JadeiteMonticelloAddRepositoryDialog >> cancel [

	self window close
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

	| labelWidth typeRow urlRow buttonRow outer |
	labelWidth := 130.

	typeRow := SpBoxLayout newHorizontal
		           spacing: 8;
		           yourself.
	typeRow
		add: repositoryTypeLabelPresenter
		withConstraints: [ :c | c width: labelWidth ].
	typeRow
		add: repositoryTypePresenter
		withConstraints: [ :c | c width: 160 ].

	urlRow := SpBoxLayout newHorizontal
		          spacing: 4;
		          yourself.
	urlRow
		add: urlLabelPresenter
		withConstraints: [ :c | c width: labelWidth ].
	urlRow add: urlPresenter.
	urlRow add: fileDialogPresenter expand: false.

	buttonRow := SpBoxLayout newHorizontal.
	buttonRow addLast: cancelButton expand: false.
	buttonRow addLast: addRepositoryButton expand: false.

	outer := SpBoxLayout newVertical.
	outer borderWidth: 8.
	outer
		spacing: 10;
		add: typeRow expand: false;
		add: urlRow expand: false;
		add: buttonRow expand: false.
	^ outer
]

{ #category : 'initialization' }
JadeiteMonticelloAddRepositoryDialog >> initializePresenters [

	super initializePresenters.
	completionBlock := [  ].
	repositoryTypeLabelPresenter := self newLabel label: 'Repository Type:'.
	repositoryTypePresenter := self newDropList.
	repositoryTypePresenter items: #( #HTTP #FileTree #Github #MCZ ).
	urlLabelPresenter := self newLabel label: 'URL:'.
	urlPresenter := self newTextInput.
	fileDialogPresenter := self newButton
		                       label: 'Choose...';
		                       action: [ self openFileDialog ].
	fileDialogPresenter enabled: false.
	addRepositoryButton := self newButton
		                       label: 'Add Repository';
		                       action: [ self addRepository ].
	cancelButton := self newButton
		                label: 'Cancel';
		                action: [ self cancel ]
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
	fileDialogPresenter enabled: isFileBased.
	urlLabelPresenter label: (self urlLabelForType: selectedType)
]

{ #category : 'private' }
JadeiteMonticelloAddRepositoryDialog >> urlLabelForType: aSymbol [

	aSymbol = #FileTree ifTrue: [ ^ 'Directory:' ].
	aSymbol = #MCZ ifTrue: [ ^ 'File path:' ].
	^ 'URL:'
]
