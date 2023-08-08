Class {
	#name : 'JadeiteServerFileSelectorPresenter',
	#superclass : 'JadeitePresenter',
	#instVars : [
		'directoryContentsList',
		'pathText',
		'fileService'
	],
	#category : 'JadeiteFileDialog'
}

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> createSchematicWiring [
	super createSchematicWiring.
	directoryContentsList
		when: #actionPerformed
		send: #dive
		to: self. 
	pathText
		when: #focusLost
		send: #goto
		to: self.
	
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
	(fileService isDirectory: directoryContentsList selectedItem key)
		ifTrue: 
			[| directoryName |
			directoryName := directoryContentsList selectedItem key.
			directoryName = '..' ifTrue: [^self pop].
			directoryName = '.'
				ifFalse: [pathText text: pathText text , '/' , directoryContentsList selectedItem key].
			fileService path: pathText text.
			self showDirectoryContents]
		ifFalse: [self window triggerOkAction]
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

	fileService := anObject
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
	self layout add: directoryContentsList
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

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> pop [
	directoryContentsList list: fileService pop.
	pathText text: fileService path
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> select [
	parentPresenter select
]

{ #category : 'accessing' }
JadeiteServerFileSelectorPresenter >> selectedFileOrDirectory [

	^directoryContentsList selectedItem value first
]

{ #category : 'as yet unclassified' }
JadeiteServerFileSelectorPresenter >> selectedFilePath [
	^self pathText value , '/' , directoryContentsList selection key
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
	| directoryContents |
	directoryContents := fileService directoryContents.
	directoryContentsList list: directoryContents
]
