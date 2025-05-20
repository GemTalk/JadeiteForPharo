Class {
	#name : 'JadeiteLoadProjectDialog',
	#superclass : 'JadeiteServerFileSelectorDialog',
	#instVars : [
		'projectHomePresenter',
		'customAttributesList',
		'componentList',
		'session',
		'attributes',
		'components',
		'resolveStrictCheckbox',
		'urlText',
		'lastSelectedTabName'
	],
	#classVars : [
		'PreviousFilePath',
		'PreviousProjectHomePath'
	],
	#category : 'Jadeite-FileDialog',
	#package : 'Jadeite-FileDialog'
}

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> instantiateDialogOn: aGciSession [
	| inst |
	inst := self create.
	inst session: aGciSession.
	inst setPresenterModels: aGciSession.
	inst showDirectoryContents.
	inst updateCaptionInSession: aGciSession.
	^inst
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> previousFilePath [

	^PreviousFilePath
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> previousFilePath: aString [

	PreviousFilePath := aString
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> previousProjectHomePath [

	^PreviousProjectHomePath
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> previousProjectHomePath: aString [

	PreviousProjectHomePath := aString
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> showNonModalOnSession: aGciSession [
	" for testing" 
	| inst  |
	inst := self instantiateDialogOn: aGciSession.
	^inst show.
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog class >> showOnSession: aGciSession [
	| inst answer |
	inst := self instantiateDialogOn: aGciSession.
	answer := inst showModal.
	^answer
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> answer [
	"Answer the model if the receiver was confirmed (with #apply, #ok) or nil otherwise"
	^self isConfirmed
		ifTrue: 
			[lastSelectedTabName = 'URL Container'
				ifTrue: [Array with: lastSelectedTabName with: urlText value]
				ifFalse: 
					[{lastSelectedTabName.
						fileSelectorPresenter pathText value.
						projectHomePresenter pathText value.
						components.
						attributes.
						resolveStrictCheckbox value}]]
		ifFalse: [nil]
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> apply [
	self flushChanges.
	confirmed := true
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> initialize [
	super initialize.
	self class previousFilePath
		ifNil: [self class previousFilePath: JadePresenter expandedRowanProjectsHome].
	self class previousProjectHomePath
		ifNil: [self class previousProjectHomePath: JadePresenter expandedRowanProjectsHome]
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> isAdvancedTabSelected [
	^self selectedTab = 'Advanced Container'
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> isProjectHomeTabSelected [
	^self selectedTab = 'Project Home Container'
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> isProjectSpecTabSelected [
	^self selectedTab = 'Project Spec Container'
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> isURLTabSelected [
	^self selectedTab = 'URL Container'
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> lastSelectedTabName [
	^lastSelectedTabName
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> lastSelectedTabName: anObject [
	lastSelectedTabName := anObject
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> load [
	| fileService |
	self isURLTabSelected ifTrue: [^self loadFromUrl].
	fileSelectorPresenter isFileSelected
		ifFalse: [^MessageBox notify: 'Project Spec file must be selected'].
	fileSelectorPresenter selectionMade.
	projectHomePresenter selectionMade.
	fileService := RowanFileServiceClient new
				path: projectHomePresenter pathText value;
				session: session.
	self class previousProjectHomePath: fileService directoryPath.
	fileService path: fileSelectorPresenter pathText value.
	self class previousFilePath: fileService directoryPath.
	self ok
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> loadFromUrl [
	lastSelectedTabName := self selectedTab.
	confirmed := true.
	self view close.
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> ok [
	| fileService |
	fileService := RowanFileServiceClient new
				path: projectHomePresenter pathText value;
				session: session.
	self class previousProjectHomePath: fileService directoryPath.
	fileService path: fileSelectorPresenter pathText value.
	self class previousFilePath: fileService directoryPath.
	components := componentList selections.
	attributes := customAttributesList selections.
	lastSelectedTabName := self selectedTab.
	^super ok
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> projectHomePresenter [
	^projectHomePresenter
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> resolveStrictCheckbox [
	"for testing"
	^resolveStrictCheckbox
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> select [
	self isProjectSpecTabSelected
		ifTrue: 
			[fileSelectorPresenter isDirectorySelected
				ifTrue: [^MessageBox notify: 'Project Spec must be a file']].
	self isProjectHomeTabSelected
		ifTrue: 
			[projectHomePresenter isDirectorySelected
				ifFalse: [^MessageBox notify: 'Project Home must be a directory']]
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> selectedTab [
	^(self view viewNamed: 'Tabs') currentCard name
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> session [
	^session
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> session: anObject [
	session := anObject
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> setPresenterModels: aGciSession [
	| projectSpecService projectHomeService |
	projectSpecService := RowanFileServiceClient new path: self class previousFilePath.
	projectSpecService session: aGciSession.
	fileSelectorPresenter model: projectSpecService asValue.
	projectHomeService := RowanFileServiceClient new path: self class previousProjectHomePath.
	projectHomeService session: aGciSession.
	projectHomePresenter model: projectHomeService asValue.
	fileSelectorPresenter pathText value: self class previousFilePath.
	projectHomePresenter pathText value: self class previousProjectHomePath
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> shellName [

	^'Jadeite Load Project Dialog'.
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> showDirectoryContents [
	fileSelectorPresenter showDirectoryContents.
	projectHomePresenter showDirectoryContents
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> updateProperties [

	| loadSpecService |
	fileSelectorPresenter directoryContentsList selectionOrNil ifNil: [
		^ self ].
	loadSpecService := RowanLoadSpecService new loadSpecPath:
		                   fileSelectorPresenter pathText value , '/'
		                   ,
		                   fileSelectorPresenter directoryContentsList
			                   selection key.
	[
	RowanServiceUpdater current
		updateService: loadSpecService
		session: session
		onCompletion: nil ]
		on: Error
		do: [ :ex |
			customAttributesList list: OrderedCollection new.
			componentList list: OrderedCollection new.
			^ self "not a valid load spec" ].
	customAttributesList list: loadSpecService conditionalAttributes.
	customAttributesList view selectAll.
	componentList list:
		loadSpecService componentNames asOrderedCollection.
	componentList view selectAll
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> urlText [
	^urlText
]

{ #category : 'as yet unclassified' }
JadeiteLoadProjectDialog >> urlText: anObject [
	urlText := anObject
]
