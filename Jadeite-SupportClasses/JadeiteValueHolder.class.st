Class {
	#name : 'JadeiteValueHolder',
	#superclass : 'ValueHolder',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'printing' }
JadeiteValueHolder >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $:;
		nextPutAll: contents printString
]

{ #category : 'accessing' }
JadeiteValueHolder >> value [

	^self contents
]

{ #category : 'accessing' }
JadeiteValueHolder >> value: anObject [

	contents := anObject.
	self announcer announce: ValueChanged
]
