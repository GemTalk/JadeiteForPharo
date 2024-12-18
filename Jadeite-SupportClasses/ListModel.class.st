Class {
	#name : 'ListModel',
	#superclass : 'SpCollectionListModel',
	#traits : 'JadeiteUtilityTrait',
	#classTraits : 'JadeiteUtilityTrait classTrait',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
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

	aCollection ifNil: [ ^ self ].
	self collection addAll: aCollection
]

{ #category : 'converting' }
ListModel >> asBag [ 
	
	^collection asBag 
]

{ #category : 'converting' }
ListModel >> asOrderedCollection [ 

	^collection asOrderedCollection
]

{ #category : 'converting' }
ListModel >> asSortedCollection [ 

	^collection asSortedCollection
]

{ #category : 'accessing' }
ListModel >> at: anIndex [

	^collection at: anIndex ifAbsent: [ nil ]
]

{ #category : 'converting' }
ListModel >> beSorted [

	self collection: (self sortedProjectsFrom: collection)
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

	collection := aCollection asOrderedCollection
]

{ #category : 'testing' }
ListModel >> notEmpty [

	^self isEmpty not
]

{ #category : 'removing' }
ListModel >> refreshList [

	self sortingBlock ifNotNil: [ :aSortFunction |
		collection := (collection sorted: aSortFunction) asOrderedCollection ]
]

{ #category : 'enumerating' }
ListModel >> reject: aBlock [

	^collection reject: aBlock
]

{ #category : 'removing' }
ListModel >> remove: anObject [

	(collection isKindOf: Array) ifTrue: [
		Transcript
			cr;
			show: 'ListModel list is an Array again. :(';
			tab;
			print: collection;
			flush.
		collection := collection asOrderedCollection ]. "yuck - still can't find the source of these Arrays"
	collection remove: anObject.
	self announcer announce: (ValueChanged newValue: self)
]

{ #category : 'removing' }
ListModel >> remove: anObject ifAbsent: absentBlock [
	collection remove: anObject ifAbsent: absentBlock
]

{ #category : 'removing' }
ListModel >> removeAll [
	
	collection := OrderedCollection new. "Must not be an Array so can be collection can be added to"
	
	self refreshList.
	self announcer announce: (ValueChanged newValue: self)
		
]

{ #category : 'removing' }
ListModel >> removeAll: objects [

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
ListModel >> size [

	collection ifNil: [ ^ 0 ].
	^ super size
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
