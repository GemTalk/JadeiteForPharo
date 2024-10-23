Class {
	#name : 'RowanDictionaryService',
	#superclass : 'RowanService',
	#instVars : [
		'name',
		'classes',
		'hierarchyServices',
		'globals',
		'defaultTemplate',
		'testClasses'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'private' }
RowanDictionaryService class >> defaultIconName [
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Dictionary' extension: 'ico'.
]

{ #category : 'private' }
RowanDictionaryService class >> icon [
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon
]

{ #category : 'accessing' }
RowanDictionaryService class >> templateClassName [ 

	^#RowanDictionaryService
]

{ #category : 'comparing' }
RowanDictionaryService >> = dictionaryService [

	^ dictionaryService isService and: [
		  dictionaryService isDictionaryService
			  ifTrue: [ name = dictionaryService name ]
			  ifFalse: [ ^ false ] ]
]

{ #category : 'public' }
RowanDictionaryService >> basicPrepareForReplication [
	super basicPrepareForReplication.
	classes := nil. 
	hierarchyServices := nil.
]

{ #category : 'updates' }
RowanDictionaryService >> classHierarchyUpdate: presenter browser: browser [
	browser isHierarchyTabSelected ifFalse: [^false].
	browser dictionaryListPresenter selectionOrNil
		ifNil: [^self]
		ifNotNil: [:dictionaryService | dictionaryService name = name ifFalse: [^self]].
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices
]

{ #category : 'accessing' }
RowanDictionaryService >> classes [

	^classes
]

{ #category : 'accessing' }
RowanDictionaryService >> classes: anArray [
	classes := anArray
]

{ #category : 'updates' }
RowanDictionaryService >> classesUpdate: presenter browser: browser [

	| updatedClasses |
	presenter list isEmpty ifTrue: [
		self initializePresenterList: presenter ].
	(self doesUpdateApply: browser) ifFalse: [ ^ self ].
	classes ifNil: [ ^presenter list: ListModel new ].
	self removeDeletedClassesIn: presenter browser: browser.
	presenter selectionOrNil
		ifNil: [
			updatedClasses := classes asSet reject: [ :classService |
				                  classService wasRenamed ].
			updatedClasses addAll: presenter list.
			presenter list: (ListModel
					 withAll: (updatedClasses asSortedCollection: 
					  [ :x :y | x name < y name ])) ]
		ifNotNil: [
			self
				updateList: presenter
				whilePreservingSelections: classes
				browser: browser ].
	presenter list do: [ :classService |
		classService
			selectedPackageServices: browser packageListPresenter selections
			browser: browser ].
	presenter view invalidate.
	browser isClassSelected ifFalse: [ self emptyFilterListsIn: browser ]
]

{ #category : 'accessing' }
RowanDictionaryService >> confirmClassRemoval: classService [
	| messageStream |
	messageStream := WriteStream on: String new.
	messageStream
		nextPutAll: 'Really delete class ';
		nextPutAll: classService name;
		nextPut: $?.
	classService packageName = RowanService notRowanizedPackageName
		ifTrue: 
			[messageStream
				cr;
				nextPutAll: 'Note that removal of unpackaged classes will not be tracked by Rowan'].
	^MessageBox confirm: messageStream contents
]

{ #category : 'accessing' }
RowanDictionaryService >> defaultTemplate [
	^defaultTemplate
]

{ #category : 'accessing' }
RowanDictionaryService >> defaultTemplate: anObject [
	defaultTemplate := anObject
]

{ #category : 'displaying' }
RowanDictionaryService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'displaying' }
RowanDictionaryService >> displayString [
	^self name
]

{ #category : 'displaying' }
RowanDictionaryService >> displayStringFor: displayThing [
	displayThing forecolor: Color black
]

{ #category : 'private' }
RowanDictionaryService >> doesUpdateApply: browser [
	^browser isDictionaryTabSelected 
]

{ #category : 'accessing' }
RowanDictionaryService >> globals [
	^globals
]

{ #category : 'accessing' }
RowanDictionaryService >> globals: anObject [
	globals := anObject
]

{ #category : 'comparing' }
RowanDictionaryService >> hash [
	^self name hash
]

{ #category : 'public' }
RowanDictionaryService >> isDictionaryService [

	^true
]

{ #category : 'accessing' }
RowanDictionaryService >> name [
	^name
]

{ #category : 'accessing' }
RowanDictionaryService >> name: aString [
	name := aString asString
]

{ #category : 'public' }
RowanDictionaryService >> prepareForReplication [
	super prepareForReplication.
	classes := nil. 
	hierarchyServices := nil.
]

{ #category : 'private' }
RowanDictionaryService >> removeDeletedClassesIn: presenter browser: browser [
	^super
		removeDeletedClassesIn: presenter
		browser: browser
		classes: classes
]

{ #category : 'Init / Release' }
RowanDictionaryService >> rowanPostUpdate [
	super rowanPostUpdate.
	hierarchyServices
		ifNotNil: 
			[hierarchyServices keysAndValuesDo: 
					[:key :value |
					key isBehavior ifTrue: [key rowanPostUpdate].
					value do: [:service | service rowanPostUpdate]]].
	hierarchyServices := nil.
	classes ifNotNil: [classes do: [:service | service rowanPostUpdate]].
	classes := Array new
]

{ #category : 'public' }
RowanDictionaryService >> selectIn: presenter [

	| selection |
	presenter selectProjectNamed: self class notRowanizedPackageName.
	selection := presenter dictionaryPresenter list detect: [
		             :dictionaryService |
		             dictionaryService name = self name ].
	presenter dictionaryPresenter selectedItem = selection ifFalse: [
		presenter dictionaryPresenter selection: selection ]
]

{ #category : 'public' }
RowanDictionaryService >> selectPackageOrDictionaryService: service in: presenter [ 
	presenter  selectProjectNamed: service projectName. 
	presenter dictionaryPresenter selection: service

	
]

{ #category : 'accessing' }
RowanDictionaryService >> sortAspect [

	^name
]

{ #category : 'updates' }
RowanDictionaryService >> testClasses: presenter browser: browser [
	| additions sortedTests |
	additions := OrderedCollection new.
	testClasses ifNil: [^self].
	sortedTests := testClasses asSortedCollection: [ :x :y | x displayString <= y displayString ].
	presenter model list: sortedTests. 
	sortedTests do: 
			[:newClassService |
			| updatedClass |
			updatedClass := presenter model detect: [:classService | classService = newClassService]
						ifNone: 
							[additions add: newClassService.
							nil].
			updatedClass ifNotNil: [updatedClass replicateFrom: newClassService]].
	browser addUpdatedTestClasses: additions.
	presenter invalidate
]
