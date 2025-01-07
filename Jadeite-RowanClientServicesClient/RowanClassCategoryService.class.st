"
Not a true service yet
"
Class {
	#name : 'RowanClassCategoryService',
	#superclass : 'Object',
	#instVars : [
		'name',
		'substringIndex'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'comparison' }
RowanClassCategoryService >> = catService [

	(catService isKindOf: RowanClassCategoryService) ifFalse: [ ^ false ].
	^ self data = catService data and: [
		  self firstSubstringsToIndex = catService firstSubstringsToIndex
			  and: [ self substringIndex = catService substringIndex ] ]
]

{ #category : 'accessing' }
RowanClassCategoryService >> data [

	name = String new ifTrue: [ ^ self nilCategoryDisplayName ].
	name ifNil: [ ^ String new ].
	substringIndex ifNil: [ ^ name ].
	^ (name substrings: '-') at: substringIndex ifAbsent: [  ]
]

{ #category : 'displaying' }
RowanClassCategoryService >> displayString [

	^ self data
]

{ #category : 'accessing' }
RowanClassCategoryService >> firstSubstringsToIndex [

	self name = self nilCategoryDisplayName ifTrue: [ ^ String new ].
	substringIndex ifNil: [ ^ name ].
	^ ((name substrings: '-') first: substringIndex) fold: [ :a :b |
		  a , '-' , b ]
]

{ #category : 'testing' }
RowanClassCategoryService >> hasChildren [ 
	^name >= self data
]

{ #category : 'comparison' }
RowanClassCategoryService >> hash [
	"is this right?"
	^ (self data hash bitXor: self firstSubstringsToIndex hash)
		  bitXor: self substringIndex hash
]

{ #category : 'initialization' }
RowanClassCategoryService >> initializeSubstringIndex [
	"set the substring index based on the number of dashes in the name"

	substringIndex := (name substrings: '-') size - 1
]

{ #category : 'accessing' }
RowanClassCategoryService >> name [

	^ name
]

{ #category : 'accessing' }
RowanClassCategoryService >> name: aString [

	aString = String new
		ifTrue: [ name := self nilCategoryDisplayName ]
		ifFalse: [ name := aString ]
]

{ #category : 'constants' }
RowanClassCategoryService >> nilCategoryDisplayName [

	^ 'no class category'
]

{ #category : 'printing' }
RowanClassCategoryService >> printOn: aStream [

	super printOn: aStream.
	aStream
		space;
		nextPut: $(;
		nextPutAll: self data asString;
		nextPut: $)
]

{ #category : 'accessing' }
RowanClassCategoryService >> substringIndex [

	^ substringIndex
]

{ #category : 'accessing' }
RowanClassCategoryService >> substringIndex: anObject [

	substringIndex := anObject
]
