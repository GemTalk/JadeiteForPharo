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
	substringIndex ifNil: [ ^name ]. 
	^(name substrings: '-') at: substringIndex ifAbsent: [ ]
]

{ #category : 'displaying' }
RowanClassCategoryService >> displayString [

	^ self data
]

{ #category : 'accessing' }
RowanClassCategoryService >> firstSubstringsToIndex [ 
	substringIndex ifNil: [ ^name ]. 
	^((name substrings: '-') first: substringIndex) fold: [:a :b | a, '-', b]
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

{ #category : 'accessing' }
RowanClassCategoryService >> name: aString [ 

	name := aString 
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
