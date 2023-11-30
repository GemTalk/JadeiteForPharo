Class {
	#name : 'JadeiteValueHolder',
	#superclass : 'ValueHolder',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteValueHolder >> value [

	^self contents
]

{ #category : 'accessing' }
JadeiteValueHolder >> value: anObject [

	contents := anObject.
	self announcer announce: ValueChanged
]
