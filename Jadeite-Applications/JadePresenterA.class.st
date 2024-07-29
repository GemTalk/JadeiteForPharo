Class {
	#name : 'JadePresenterA',
	#superclass : 'JadePresenter',
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'public' }
JadePresenterA class >> createIn: aCompositePresenter gciSession: aGciSession [
	"Answers an instance of the receiver created as a sub-presenter of aCompositePresenter
	and wired up to a view identified by the resource name aResourceNameString. The new
	presenter is to be connected to aModel. It is assumed that, at this stage, aCompositePresenter
	is already opened in a view. For this reason we must force an #onViewOpened message to
	the newly created presenter"

	| newOne |
	newOne := aCompositePresenter add: (self new gciSession: aGciSession; yourself).
	newOne createView: self defaultView.
	^newOne onViewOpened; yourself
	
]

{ #category : 'public' }
JadePresenterA class >> script [
"
	JadePresenter script.
"

	| myPackages myPresenters myShells dict stream buildHierarchy reportHierarchy |
	myPackages := PackageManager current packages select: [:each | each packagePathname beginsWith: 'sources\'].
	myPresenters := Presenter allSubclasses select: [:eachPresenter | myPackages anySatisfy: [:eachPackage | eachPackage includesClass: eachPresenter]].
	myShells := myPresenters select: [:each | each inheritsFrom: Shell].
	myPresenters := myPresenters copy reject: [:each | myShells includes: each].
	buildHierarchy := [:eachClass |
		| child parent |
		child := eachClass.
		[
			parent := child superclass.
			parent notNil.
		] whileTrue: [
			(dict at: parent ifAbsentPut: [Set new]) add: child.
			child := parent.
		].
	].
	reportHierarchy := [:class :indent :printBlock| 
		indent timesRepeat: [stream nextPut: $-].
		printBlock value: class.
		(dict at: class ifAbsent: [nil]) ifNotNil: [:aSet | 
			(aSet asSortedCollection: [:a :b | a name <= b name]) do: [:each | reportHierarchy value: each value: indent + 1 value: printBlock].
		].
	].
	dict := Dictionary new.
	myShells do: buildHierarchy.
	"dict := Dictionary new.
	myPresenters do: buildHierarchy."
	stream := WriteStream on: String new.
	reportHierarchy value: Object value: 0 value: [:aClass | 
		stream nextPutAll: aClass name.
		(myPackages anySatisfy: [:eachPackage | eachPackage includesClass: aClass]) ifTrue: [
			stream nextPutAll: ' ( '.
			aClass allReferences do: [:each | 
				((each isKindOf: CompiledMethod) and: [each isClassMethod]) ifTrue: [
					stream nextPutAll: each methodClass instanceClass name.
					stream space.
				].
			].
			stream nextPutAll: ')'.
		].
		stream cr.
	].
	^stream contents.

]

{ #category : 'label edit' }
JadePresenterA >> aboutToEditLabel: anObject accept: aValueHolder [
	"Is it okay to start editing a label?"

	aValueHolder value: (self canEditLabel: anObject).

]

{ #category : 'label edit' }
JadePresenterA >> canEditLabel: anObject [

	^true.

]

{ #category : 'drag & drop' }
JadePresenterA >> createDragDropSchematicWiringFor: aPresenter [

	aPresenter
		when: #dragOver: 	send: #onDragOver: 	to: self;
		when: #drop:				send: #onDragDrop:	to: self;
		when: #drag:				send: #onDrag:			to: self;
		when: #dragCut:		send: #onDragCut:	to: self;
		yourself.


]

{ #category : 'label edit' }
JadePresenterA >> createLabelEditSchematicWiringFor: aPresenter [

	aPresenter
		when: #labelOf:changedTo: 			send: #labelOf:changedTo:				to: self;
		when: #aboutToEditLabel:accept: 	send: #aboutToEditLabel:accept:	to: self;
		when: #labelOf:editedTo:accept: 	send: #labelOf:editedTo:accept:		to: self;
		yourself.

]

{ #category : 'drag & drop' }
JadePresenterA >> createSchematicWiring [

	super createSchematicWiring.
	self dragDropPresenters do: [:each | 
		self createDragDropSchematicWiringFor: each.
	].
	self labelEditPresenters do: [:each | 
		self createLabelEditSchematicWiringFor: each.
	].

]

{ #category : 'drag & drop' }
JadePresenterA >> dragDropPresenter [

	^self primaryPresenter.

]

{ #category : 'drag & drop' }
JadePresenterA >> dragDropPresenters [

	^Set with: self dragDropPresenter.

]

{ #category : 'drag & drop' }
JadePresenterA >> drop: sourceObject on: targetObject description: aString [

	MessageBox 
		warning: 'Sorry, drop ' , aString , ' ' , sourceObject printString , ' on ' , targetObject printString , ' in ' , self class name , ' not yet supported.'
		caption: 'Jade System Browser'.
	SessionManager current pause.

]

{ #category : 'drag & drop' }
JadePresenterA >> dropClass: anOopType on: aTarget [

	self
		drop: anOopType 
		on: aTarget 
		description: 'class'.

]

{ #category : 'drag & drop' }
JadePresenterA >> dropClassCategory: anOopType on: aTarget [

	self
		drop: anOopType 
		on: aTarget 
		description: 'class category'.

]

{ #category : 'drag & drop' }
JadePresenterA >> dropMethod: anOopType on: aTarget [

	self
		drop: anOopType 
		on: aTarget 
		description: 'method'.

]

{ #category : 'drag & drop' }
JadePresenterA >> dropMethodCategory: anOopType on: aTarget [

	self
		drop: anOopType 
		on: aTarget 
		description: 'method category'.

]

{ #category : 'drag & drop' }
JadePresenterA >> dropSymbolDictionary: anOopType on: aTarget [

	self
		drop: anOopType 
		on: aTarget 
		description: 'symbol dictionary'.

]

{ #category : 'label edit' }
JadePresenterA >> labelEditPresenter [

	^self primaryPresenter.

]

{ #category : 'label edit' }
JadePresenterA >> labelEditPresenters [

	^Set with: self labelEditPresenter.

]

{ #category : 'label edit' }
JadePresenterA >> labelOf: a changedTo: b [
	"Letting us know that the rename occurred"
]

{ #category : 'label edit' }
JadePresenterA >> labelOf: oldString editedTo: newString accept: aValueHolder [
	"Is it okay to do the rename?"

	MessageBox 
		warning: 'Sorry. Item rename not yet supported.' 
		caption: 'Jade System Browser'.
	aValueHolder value: false.
	SessionManager current pause.

]

{ #category : 'public' }
JadePresenterA >> model: anObject [
	anObject class == GciSession ifTrue: [self error: 'should call gciSession: method']. 
	super model: anObject.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDrag: anInternalDragDropSession [ 

	self subclassResponsibility.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragClassCategoriesOver: aSession [ 

	self
		onDragOver: aSession 
		operations: self supportedClassCategoryDropOperations.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragClassesOver: aSession [ 

	self
		onDragOver: aSession 
		operations: self supportedClassDropOperations.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragCut: aSession [ 

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragDrop: aSession [ 

	(aSession isFormatAvailable: #'method') 			ifTrue: [^self onDragDropMethods: aSession].
	(aSession isFormatAvailable: #'methodCategory') 	ifTrue: [^self onDragDropMethodCategories: aSession].
	(aSession isFormatAvailable: #'class') 			ifTrue: [^self onDragDropClasses: aSession].
	(aSession isFormatAvailable: #'classCategory')		ifTrue: [^self onDragDropClassCategories: aSession].
	(aSession isFormatAvailable: #'symbolDictionary')	ifTrue: [^self onDragDropSymbolDictionaries: aSession].
	MessageBox notify: 'Sorry, we are not yet able to drag/drop ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'public' }
JadePresenterA >> onDragDropClassCategories: aSession [ 

	aSession dragObjects do: [:each | 
		self
			dropClassCategory: (each format: #classCategory)
			on: aSession suggestedTarget.
	].

]

{ #category : 'public' }
JadePresenterA >> onDragDropClasses: aSession [ 

	aSession dragObjects do: [:each | 
		self
			dropClass: (each format: #class)
			on: aSession suggestedTarget.
	].

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragDropMethodCategories: aSession [

	aSession dragObjects do: [:each | 
		self
			dropMethodCategory: (each format: #methodCategory)
			on: aSession suggestedTarget.
	].

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragDropMethods: aSession [

	aSession dragObjects do: [:each | 
		self
			dropMethod: (each format: #method)
			on: aSession suggestedTarget.
	].

]

{ #category : 'public' }
JadePresenterA >> onDragDropSymbolDictionaries: aSession [ 

	aSession dragObjects do: [:each | 
		self
			dropSymbolDictionary: (each format: #symbolDictionary)
			on: aSession suggestedTarget.
	].

]

{ #category : 'public' }
JadePresenterA >> onDragDropSymbolLists: aSession [ 

	aSession dragObjects do: [:each | 
		self
			dropSymbolList: (each format: #symbolList)
			on: aSession suggestedTarget.
	].

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragMethodCategoriesOver: aSession [

	self
		onDragOver: aSession 
		operations: self supportedMethodCategoryDropOperations.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragMethodsOver: aSession [

	self
		onDragOver: aSession 
		operations: self supportedMethodDropOperations.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragOver: aSession [

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'method') 			ifTrue: [^self onDragMethodsOver: aSession].
	(aSession isFormatAvailable: #'methodCategory') 	ifTrue: [^self onDragMethodCategoriesOver: aSession].
	(aSession isFormatAvailable: #'class') 			ifTrue: [^self onDragClassesOver: aSession].
	(aSession isFormatAvailable: #'classCategory')		ifTrue: [^self onDragClassCategoriesOver: aSession].
	(aSession isFormatAvailable: #'symbolDictionary')	ifTrue: [^self onDragSymbolDictionariesOver: aSession].
	MessageBox notify: 'Sorry, we are not yet able to drag over ' , aSession printString , '!'.
	SessionManager current pause.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragOver: aSession operations: aList [

	aList isEmpty ifTrue: [^self].
	aSession
		supportedOperations: aList;
		operation: aList first;
		yourself.

]

{ #category : 'drag & drop' }
JadePresenterA >> onDragSymbolDictionariesOver: aSession [ 

	self
		onDragOver: aSession 
		operations: self supportedSymbolDictionaryDropOperations.

]

{ #category : 'drag & drop' }
JadePresenterA >> primaryPresenter [

	^nil.

]

{ #category : 'drag & drop' }
JadePresenterA >> supportedClassCategoryDropOperations [

	^#().

]

{ #category : 'drag & drop' }
JadePresenterA >> supportedClassDropOperations [

	^#().

]

{ #category : 'drag & drop' }
JadePresenterA >> supportedMethodCategoryDropOperations [

	^#().

]

{ #category : 'drag & drop' }
JadePresenterA >> supportedMethodDropOperations [

	^#().

]

{ #category : 'drag & drop' }
JadePresenterA >> supportedSymbolListDropOperations [

	^#().

]

{ #category : 'public' }
JadePresenterA >> userSelection [

	^nil.

]
