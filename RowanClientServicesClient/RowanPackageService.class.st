Class {
	#name : 'RowanPackageService',
	#superclass : 'RowanService',
	#instVars : [
		'projectDefinition',
		'packageName',
		'name',
		'isDirty',
		'classes',
		'defaultTemplate',
		'projectName',
		'testClasses',
		'hierarchyServices',
		'selectedClass',
		'dictionaryName'
	],
	#category : 'RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanPackageService class >> templateClassName [ 

	^#RowanPackageService
]

{ #category : 'comparing' }
RowanPackageService >> <= packageService [

	^ packageService isService and: [
		  packageService isPackageService and: [
			  name <= packageService name ] ]
]

{ #category : 'comparing' }
RowanPackageService >> = packageService [

	^ packageService isService and: [
		  packageService isPackageService and: [ name = packageService name ] ]
]

{ #category : 'private' }
RowanPackageService >> addHierarchyService: service to: treeModel withParent: parentService [
	treeModel getNodeFor: service ifAbsent: [treeModel add: service asChildOf: parentService].
	(hierarchyServices at: service ifAbsent: [^self]) do: 
			[:classService |
			self
				addHierarchyService: classService
				to: treeModel
				withParent: service]
]

{ #category : 'public' }
RowanPackageService >> basicPrepareForReplication [
	"don't iterate over sub colletions"
	classes := nil.
	testClasses := nil. 
	selectedClass := nil. 
]

{ #category : 'public' }
RowanPackageService >> classHierarchyUpdate: presenter browser: browser [
	browser isHierarchyTabSelected ifFalse: [^false].
	browser packageListPresenter selectionOrNil
		ifNil: [^self]
		ifNotNil: [:packageService | packageService name = name ifFalse: [^self]].
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices
]

{ #category : 'accessing' }
RowanPackageService >> classes [

	^classes
]

{ #category : 'accessing' }
RowanPackageService >> classes: anArray [
	classes := anArray
]

{ #category : 'public' }
RowanPackageService >> classesUpdate: presenter browser: browser [
	"If the selected packages have the same class defined and extended, show the defined class"

	| condensedList selections selectedPackageServices validatedList |
	classes ifNil: [ ^self ].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	(self doesUpdateApply: browser) ifFalse: [^self].
	self removeDeletedClassesIn: presenter browser: browser.
	condensedList := self condenseExtensions: presenter.
	validatedList := Dictionary new.
	condensedList keysAndValuesDo: 
			[:classService :dontcare |
			(browser isValidClassService: classService) ifTrue: [validatedList at: classService put: dontcare]].
	presenter selections isEmpty
		ifTrue: 
			[presenter
				list: (ListModel withAll: (validatedList keys asSet asSortedCollection: [:x :y | x name < y name]) )]
		ifFalse: 
			[self
				updateList: presenter
				whilePreservingSelections: validatedList
				browser: browser].
	"#selections is very expensive in Dolphin. Don't send it in a loop"
	selections := browser packageListPresenter selections.
	selectedPackageServices := browser isRowanProjectSelected ifTrue: [selections] ifFalse: [Array new].
	presenter list do: [:classService | classService selectedPackageServices: selectedPackageServices].
	self todo:[presenter view invalidate].
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]
]

{ #category : 'private' }
RowanPackageService >> condenseExtensions: presenter [
	| defined dictionary rejections |
	dictionary := Dictionary new.
	presenter list do:[:service | dictionary at: service put: nil]. 
	classes ifNil: [ ^self ].
	classes do: [ :service | dictionary at: service put: nil ].
	defined := dictionary keys select: [:svc | svc isDefined] thenCollect: [:svc | svc name].
	rejections := dictionary keys select: [:svc | svc isExtension and: [defined includes: svc name]].
	dictionary keysAndValuesRemove: [ :key :value |
			rejections includes: key ].
	rejections := dictionary keys select: [:svc | svc wasRenamed].
	dictionary keysAndValuesRemove: [ :key :value |
			rejections includes: key ].
	^dictionary
]

{ #category : 'accessing' }
RowanPackageService >> confirmClassRemoval: classService [
	^MessageBox confirm: 'Really delete class ' , classService name , '?'
]

{ #category : 'accessing' }
RowanPackageService >> defaultTemplate [
	^defaultTemplate
]

{ #category : 'accessing' }
RowanPackageService >> defaultTemplate: anObject [
	defaultTemplate := anObject
]

{ #category : 'accessing' }
RowanPackageService >> dictionaryName [
	^dictionaryName
]

{ #category : 'displaying' }
RowanPackageService >> displayName [
	"for logging. for now"

	^name
]

{ #category : 'displaying' }
RowanPackageService >> displayString [
	^self name
]

{ #category : 'displaying' }
RowanPackageService >> displayStringFor: displayThing [
	name ifNil: [^self].
	self isDirty == true
		ifTrue: 
			[displayThing font beBold.
			displayThing forecolor: Color black]
]

{ #category : 'private' }
RowanPackageService >> doesUpdateApply: browser [
	| selections |
	selections := browser packageListPresenter selections.
	^selections includes: self
]

{ #category : 'comparing' }
RowanPackageService >> hash [
	^self name hash
]

{ #category : 'public' }
RowanPackageService >> hierarchyServices: collection [

	hierarchyServices := collection
]

{ #category : 'accessing' }
RowanPackageService >> isDirty [
	^isDirty
]

{ #category : 'accessing' }
RowanPackageService >> isDirty: anObject [
	isDirty := anObject
]

{ #category : 'public' }
RowanPackageService >> isPackageService [

	^true
]

{ #category : 'printing' }
RowanPackageService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: name
]

{ #category : 'printing' }
RowanPackageService >> logSentOn: aStream [
	super logSentOn: aStream.
	aStream
		space;
		nextPutAll: name
]

{ #category : 'accessing' }
RowanPackageService >> name [
	^name
]

{ #category : 'accessing' }
RowanPackageService >> name: aString [
	name := aString asString
]

{ #category : 'public' }
RowanPackageService >> packageUpdate: presenter [
	| packageInList |
	packageInList := presenter list detect: [:packageService | packageService name = name] ifNone: [].
	packageInList ifNotNil: [:packageService | packageService isDirty: self isDirty].
	presenter view invalidate
]

{ #category : 'public' }
RowanPackageService >> prepareForReplication [
	super prepareForReplication.
	self basicPrepareForReplication
]

{ #category : 'accessing' }
RowanPackageService >> projectName [
	^projectName
]

{ #category : 'accessing' }
RowanPackageService >> projectName: anObject [
	projectName := anObject
]

{ #category : 'must not strip' }
RowanPackageService >> remoteServiceName [
	^'Rowan packageServiceClass'
]

{ #category : 'private' }
RowanPackageService >> removeDeletedClassesIn: presenter browser: browser [
	^super
		removeDeletedClassesIn: presenter
		browser: browser
		classes: classes
]

{ #category : 'public' }
RowanPackageService >> replicateFrom: newService [
	^(self isPackageService and: [newService isPackageService])
		ifTrue: [super replicateFrom: newService]
]

{ #category : 'Init / Release' }
RowanPackageService >> rowanPostUpdate [
	super rowanPostUpdate.
	classes ifNotNil: [classes do: [:service | service rowanPostUpdate]].
]

{ #category : 'public' }
RowanPackageService >> selectIn: presenter [
	| selection |
	presenter selectProjectNamed: projectName.
	selection := presenter packageListPresenter list
				detect: [:packageService | packageService name = self name].
	presenter packageListPresenter selectItem: selection
]

{ #category : 'accessing' }
RowanPackageService >> selectedClass [
	^selectedClass
]

{ #category : 'accessing' }
RowanPackageService >> selectedClass: anObject [
	selectedClass := anObject
]

{ #category : 'accessing' }
RowanPackageService >> sortAspect [

	^name
]

{ #category : 'public' }
RowanPackageService >> testClasses: presenter browser: browser [
	| additions |
	additions := OrderedCollection new.
	testClasses ifNil: [^self].
	testClasses do: 
			[:newClassService |
			| updatedClass |
			updatedClass := presenter model detect: [:classService | classService = newClassService]
						ifNone: 
							[additions add: newClassService.
							nil].
			updatedClass ifNotNil: [updatedClass replicateFrom: newClassService]].
	browser addUpdatedTestClasses: additions
]

{ #category : 'private' }
RowanPackageService >> updateList: presenter whilePreservingSelections: updates browser: browser [
	| replicate |
	presenter list do: 
			[:service |
			replicate := updates at: service ifAbsent: [].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	updates keysDo: 
			[:update |
			| existing |
			existing := presenter model detect: [:service | service name = update name] ifNone: [].
			existing ifNil: [update wasRenamed ifFalse: [presenter model add: update]]]
]
