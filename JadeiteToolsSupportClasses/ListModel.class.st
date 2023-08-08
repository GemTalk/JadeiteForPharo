Class {
	#name : 'ListModel',
	#superclass : 'SpCollectionListModel',
	#category : 'JadeiteToolsSupportClasses'
}

{ #category : 'instance creation' }
ListModel class >> new [

	^self basicNew collection: OrderedCollection new
]

{ #category : 'instance creation' }
ListModel class >> withAll: aCollection [

	^self on: aCollection 
]

{ #category : 'adding' }
ListModel >> addAll: aCollection [

	self collection addAll: aCollection
]

{ #category : 'converting' }
ListModel >> asBag [ 
	
	^collection asBag 
]

{ #category : 'converting' }
ListModel >> asOrderedCollection [ 

	^collection
]

{ #category : 'converting' }
ListModel >> asSortedCollection [ 

	self beSorted
]

{ #category : 'converting' }
ListModel >> beSorted [

	self collection: self collection asSortedCollection 
]

{ #category : 'enumerating' }
ListModel >> detect: block ifNone: absentBlock [

	^collection detect: block ifNone: absentBlock 
]

{ #category : 'enumerating' }
ListModel >> do: aBlock [

	collection do: aBlock
]

{ #category : 'enumerating' }
ListModel >> includes: anObject [

	^collection includes: anObject
]

{ #category : 'testing' }
ListModel >> isEmpty [ 
	collection ifNil: [^true ].
	^collection isEmpty
]

{ #category : 'accessing' }
ListModel >> list: aCollection [

	collection := aCollection
]

{ #category : 'testing' }
ListModel >> notEmpty [

	^self isEmpty not
]

{ #category : 'removing' }
ListModel >> remove: anObject [

	self todo: 'where are these arrays coming from?'.
	(collection isKindOf: Array) ifTrue: [
		collection := collection asOrderedCollection ].
	collection remove: anObject.
	self announcer announce: (ValueChanged newValue: self)
]

{ #category : 'removing' }
ListModel >> remove: anObject ifAbsent: absentBlock [
	collection remove: anObject ifAbsent: absentBlock
]

{ #category : 'removing' }
ListModel >> removeAll: objects [
	self todo: 'where are these arrays coming from?'.
(	collection isKindOf: Array ) ifTrue:[collection := collection asOrderedCollection ].
	collection removeAll: objects
]

{ #category : 'removing' }
ListModel >> removeWithoutNotification: removal ifAbsent: absentBlock view: theView [

	self todo:
		'brought over form Dolphin. Get rid of view after making work?'.
	collection remove: removal.
	self refreshList
]

{ #category : 'dolphin' }
ListModel >> searchPolicy: aSearchPolicy [

	self todo:'used by dolphin - is there a pharo equivalent?'
]

{ #category : 'enumerating' }
ListModel >> select: aBlock [

	^collection select: aBlock
]

{ #category : 'accessing' }
ListModel >> sortingBlock: aBlock [
	sorting := aBlock.
	self refreshList
]

{ #category : 'enumerating' }
ListModel >> union: aCollection [

	^collection union: aCollection
]
